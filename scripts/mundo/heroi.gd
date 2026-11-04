extends CharacterBody2D
## Herói (Vinculador) visto de cima: anda em 8 direções, ataca de perto, esquiva e lança o Núcleo de Vínculo.

const Desenho = preload("res://scripts/arte/desenho.gd")
const Dano = preload("res://scripts/regras/dano.gd")
const Efeito = preload("res://scripts/mundo/efeito.gd")

const VELOCIDADE := 130.0
const ESQUIVA_VELOCIDADE := 330.0
const ESQUIVA_DURACAO := 0.18
const ESQUIVA_ESPERA := 0.6
const ATAQUE_ALCANCE := 34.0
const ATAQUE_RECARGA := 0.45
const ATAQUE_PODER := 45.0
const INVULNERAVEL_APOS_DANO := 0.6

var jogo: Node = null
var dados = null  # HeroiDados
var olhar := Vector2.DOWN
var esquivando := false

var _tempo_esquiva := 0.0
var _espera_esquiva := 0.0
var _recarga_ataque := 0.0
var _invulneravel := 0.0
var _passo := 0.0
var _piscar := 0.0


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var forma := CollisionShape2D.new()
	var circulo := CircleShape2D.new()
	circulo.radius = 6.0
	forma.shape = circulo
	forma.position = Vector2(0, -4)
	add_child(forma)


# ---- interface de combate ----

func ativo() -> bool:
	return not dados.desmaiado()


func elemento() -> String:
	return ""


func defesa_elemental() -> int:
	return dados.defesa()


func defesa_fisica() -> int:
	return dados.defesa()


func receber_ataque(quantia: int, atacante: Node2D) -> void:
	if esquivando or _invulneravel > 0.0 or not ativo():
		return
	dados.receber_dano(quantia)
	_invulneravel = INVULNERAVEL_APOS_DANO
	_piscar = 0.15
	get_parent().add_child(Efeito.criar("numero", position + Vector2(0, -34), Color("ff8a7a"), str(quantia)))
	jogo.heroi_atacado(atacante)
	if dados.desmaiado():
		jogo.heroi_desmaiou()


# ---- controles ----

func _physics_process(delta: float) -> void:
	_espera_esquiva = maxf(_espera_esquiva - delta, 0.0)
	_recarga_ataque = maxf(_recarga_ataque - delta, 0.0)
	_invulneravel = maxf(_invulneravel - delta, 0.0)
	_piscar = maxf(_piscar - delta, 0.0)

	if jogo.pausado():
		velocity = Vector2.ZERO
		queue_redraw()
		return

	var entrada := Input.get_vector("esquerda", "direita", "cima", "baixo")
	if entrada.length() > 0.1:
		olhar = entrada.normalized()

	if esquivando:
		_tempo_esquiva -= delta
		velocity = olhar * ESQUIVA_VELOCIDADE
		if _tempo_esquiva <= 0.0:
			esquivando = false
	else:
		velocity = entrada * VELOCIDADE
		if Input.is_action_just_pressed("esquivar") and _espera_esquiva <= 0.0:
			esquivando = true
			_tempo_esquiva = ESQUIVA_DURACAO
			_espera_esquiva = ESQUIVA_ESPERA
		if Input.is_action_just_pressed("atacar"):
			atacar()
		if Input.is_action_just_pressed("capturar"):
			jogo.lancar_nucleo()
		if Input.is_action_just_pressed("comandar"):
			jogo.comandar()

	move_and_slide()
	if velocity.length() > 1.0:
		_passo += delta * 14.0
	queue_redraw()


func atacar() -> void:
	if _recarga_ataque > 0.0:
		return
	_recarga_ataque = ATAQUE_RECARGA
	var centro := position + olhar * 14.0 + Vector2(0, -8)
	var corte = Efeito.criar("corte", centro, Color.WHITE, "", 16.0)
	corte.direcao = olhar
	get_parent().add_child(corte)
	for c in jogo.selvagens_perto(position, ATAQUE_ALCANCE + 14.0):
		var para: Vector2 = (c.position - position).normalized()
		if para.dot(olhar) < 0.2 and c.position.distance_to(position) > 14.0:
			continue
		var quantia := Dano.calcular(dados.ataque(), ATAQUE_PODER, c.defesa_fisica(), "", c.elemento(),
			Dano.variacao_aleatoria(jogo.rng))
		c.receber_ataque(quantia, self)
		jogo.marcar_alvo(c)


func _draw() -> void:
	if _invulneravel > 0.0 and int(_invulneravel * 20.0) % 2 == 0:
		modulate = Color(1, 1, 1, 0.5)
	else:
		modulate = Color.WHITE
	Desenho.heroi(self, olhar, _passo, _piscar > 0.0)
