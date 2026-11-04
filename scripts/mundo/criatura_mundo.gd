extends CharacterBody2D
## Criatura no mapa. Selvagem: passeia perto de onde nasceu e, conforme o temperamento,
## foge (tímida), revida (neutra) ou ataca quem chega perto (agressiva).
## Companheira: segue o herói e luta contra o alvo que o jogo indicar.

const Desenho = preload("res://scripts/arte/desenho.gd")
const Dano = preload("res://scripts/regras/dano.gd")
const Efeito = preload("res://scripts/mundo/efeito.gd")

const RAIO_AGRESSIVA := 110.0
const DISTANCIA_PERDER := 280.0
const DISTANCIA_SEGUIR := 44.0
const RAIO_PASSEIO := 110.0

var jogo: Node = null
var dados = null          # Criatura (regras)
var selvagem := true
var origem := Vector2.ZERO
var estado := "passear"   # passear, parada, lutar, fugir, seguir, presa, desmaiada
var alvo: Node2D = null
var olhar := Vector2.RIGHT

var _info := {}
var _golpe := {}
var _recarga := 0.0
var _tempo := 0.0
var _rumo := Vector2.ZERO
var _piscar := 0.0
var _t := 0.0
var _rng := RandomNumberGenerator.new()


static func criar(jogo_: Node, dados_, selvagem_: bool, posicao: Vector2):
	var c = load("res://scripts/mundo/criatura_mundo.gd").new()
	c.jogo = jogo_
	c.dados = dados_
	c.selvagem = selvagem_
	c.position = posicao
	c.origem = posicao
	c.estado = "passear" if selvagem_ else "seguir"
	return c


func _ready() -> void:
	_rng.randomize()
	_t = _rng.randf() * 10.0
	collision_layer = 4
	collision_mask = 1
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	atualizar_especie()


## Chamado também depois de evoluir.
func atualizar_especie() -> void:
	_info = dados.especie().get("mundo", {})
	_golpe = _info.get("golpe", {"nome": "Investida", "elemento": "", "poder": 35, "alcance": 30, "recarga": 1.3})
	for filho in get_children():
		if filho is CollisionShape2D:
			filho.queue_free()
	var forma := CollisionShape2D.new()
	var circulo := CircleShape2D.new()
	circulo.radius = raio() * 0.7
	forma.shape = circulo
	forma.position = Vector2(0, -raio() * 0.5)
	add_child(forma)
	queue_redraw()


func raio() -> float:
	return float(_info.get("raio", 11))


func velocidade() -> float:
	return float(_info.get("velocidade", 80))


func temperamento() -> String:
	return _info.get("temperamento", "neutra")


func nome_golpe() -> String:
	return _golpe.get("nome", "")


# ---- interface de combate (igual à do herói) ----

func ativo() -> bool:
	return is_inside_tree() and estado != "desmaiada" and estado != "presa" and not dados.desmaiada()


func elemento() -> String:
	return dados.elemento()


func defesa_elemental() -> int:
	return dados.atributo("resistencia")


func defesa_fisica() -> int:
	return dados.atributo("defesa")


func receber_ataque(quantia: int, atacante: Node2D) -> void:
	if not ativo():
		return
	dados.receber_dano(quantia)
	_piscar = 0.12
	get_parent().add_child(Efeito.criar("numero", position + Vector2(0, -raio() * 2.4), Color("ffeb7a"), str(quantia)))
	if dados.desmaiada():
		estado = "desmaiada"
		_tempo = 0.8
		jogo.criatura_desmaiou(self, atacante)
		return
	if selvagem:
		alvo = atacante
		if temperamento() == "timida" and dados.proporcao_vida() > 0.3:
			estado = "fugir"
			_tempo = 2.0
		else:
			estado = "lutar"


func provocar(quem: Node2D) -> void:
	if selvagem and ativo() and estado != "lutar":
		alvo = quem
		estado = "lutar"


# ---- comportamento ----

func _physics_process(delta: float) -> void:
	_t += delta
	_piscar = maxf(_piscar - delta, 0.0)
	_recarga = maxf(_recarga - delta, 0.0)
	_tempo -= delta
	var mover := Vector2.ZERO

	match estado:
		"desmaiada":
			if _tempo <= 0.0 and selvagem:
				queue_free()
		"presa":
			pass
		"passear", "parada":
			mover = _passear()
			_procurar_briga()
		"fugir":
			if _valido(alvo):
				mover = (position - alvo.position).normalized() * velocidade() * 1.2
			if _tempo <= 0.0:
				estado = "lutar" if _valido(alvo) and position.distance_to(alvo.position) < 90 else "passear"
		"lutar":
			mover = _lutar()
		"seguir":
			mover = _seguir()

	velocity = mover
	if mover.length() > 1.0:
		olhar = mover.normalized()
	move_and_slide()
	queue_redraw()


func _passear() -> Vector2:
	if _tempo <= 0.0:
		if estado == "passear":
			estado = "parada"
			_tempo = _rng.randf_range(0.8, 2.5)
		else:
			estado = "passear"
			_tempo = _rng.randf_range(0.8, 2.0)
			var para_casa := (origem - position)
			_rumo = Vector2.from_angle(_rng.randf() * TAU)
			if para_casa.length() > RAIO_PASSEIO:
				_rumo = para_casa.normalized()
	return _rumo * velocidade() * 0.4 if estado == "passear" else Vector2.ZERO


func _procurar_briga() -> void:
	if temperamento() != "agressiva":
		return
	var perto = jogo.lutador_mais_proximo(position, RAIO_AGRESSIVA, true)
	if perto != null:
		provocar(perto)


func _lutar() -> Vector2:
	if not selvagem and not _valido(alvo):
		alvo = jogo.alvo_para_companheira()
	if not _valido(alvo) or position.distance_to(alvo.position) > DISTANCIA_PERDER:
		alvo = null
		estado = "passear" if selvagem else "seguir"
		return Vector2.ZERO
	var distancia := position.distance_to(alvo.position)
	var alcance := float(_golpe.get("alcance", 30))
	olhar = (alvo.position - position).normalized()
	if distancia > alcance * 0.9:
		return olhar * velocidade()
	if _recarga <= 0.0:
		_atacar(alvo)
	return Vector2.ZERO


func _seguir() -> Vector2:
	var alvo_novo = jogo.alvo_para_companheira()
	if alvo_novo != null:
		alvo = alvo_novo
		estado = "lutar"
		return Vector2.ZERO
	var heroi: Node2D = jogo.heroi
	var distancia := position.distance_to(heroi.position)
	if distancia > 420.0:
		position = heroi.position + Vector2(-24, 8)
		return Vector2.ZERO
	if distancia > DISTANCIA_SEGUIR:
		var rapidez := velocidade() * (1.6 if distancia > 120.0 else 1.1)
		return (heroi.position - position).normalized() * rapidez
	return Vector2.ZERO


func _atacar(quem: Node2D) -> void:
	_recarga = float(_golpe.get("recarga", 1.3))
	var poder := float(_golpe.get("poder", 35))
	var el: String = _golpe.get("elemento", "")
	var variacao: float = Dano.variacao_aleatoria(jogo.rng)
	var quantia := Dano.calcular(dados.atributo("poder"), poder, quem.defesa_elemental(), el, quem.elemento(), variacao)
	get_parent().add_child(Efeito.criar("anel", quem.position + Vector2(0, -8), Desenho.cor_elemento(el), "", 14.0))
	quem.receber_ataque(quantia, self)


func _valido(n) -> bool:
	return n != null and is_instance_valid(n) and n.ativo()


# ---- desenho ----

func _draw() -> void:
	var cor := Color(_info.get("cor", "#cccccc"))
	var cor2 := Color(_info.get("cor2", "#ffffff"))
	var alfa := 1.0
	if estado == "desmaiada":
		alfa = clampf(_tempo / 0.8, 0.0, 1.0)
		modulate = Color(1, 1, 1, alfa)
	if estado == "presa":
		draw_set_transform(Vector2(sin(_t * 30.0) * 1.5, 0), 0.0, Vector2.ONE * 0.85)
	Desenho.criatura(self, _info.get("forma", ""), raio(), cor, cor2, olhar, _t, _piscar > 0.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if estado == "desmaiada":
		return
	# barra de vida e nível
	var largura := 26.0
	var topo := -raio() * 2.6 - 6.0
	draw_rect(Rect2(-largura / 2, topo, largura, 4), Color(0, 0, 0, 0.6))
	var prop: float = dados.proporcao_vida()
	var cor_vida := Color("5bd65b") if prop > 0.5 else (Color("f2c53d") if prop > 0.25 else Color("e5483b"))
	draw_rect(Rect2(-largura / 2 + 1, topo + 1, (largura - 2) * prop, 2), cor_vida)
	var fonte := ThemeDB.fallback_font
	var rotulo := "Nv %d" % dados.nivel
	if not selvagem:
		rotulo = "★ " + rotulo
	draw_string_outline(fonte, Vector2(-largura / 2, topo - 2), rotulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, 3, Color(0, 0, 0, 0.8))
	draw_string(fonte, Vector2(-largura / 2, topo - 2), rotulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 9,
		Color("ffe08a") if not selvagem else Color.WHITE)
	# chance de captura quando é o alvo do núcleo
	if selvagem and jogo.alvo_captura == self:
		var chance := "Núcleo %d%%" % roundi(jogo.chance_de(self) * 100.0)
		var p := Vector2(-fonte.get_string_size(chance, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x / 2, topo - 13)
		draw_string_outline(fonte, p, chance, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, 3, Color(0, 0, 0, 0.8))
		draw_string(fonte, p, chance, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("8fe3ff"))
		draw_arc(Vector2(0, -raio() * 0.6), raio() * 1.4, 0, TAU, 24, Color("8fe3ff", 0.7), 1.5)
