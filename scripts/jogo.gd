extends Node2D
## Primeiro modo de jogo: explorar o Vale Esmeralda, lutar, capturar e treinar criaturas.
## Liga o mapa, o herói, a companheira, as criaturas selvagens, a interface e o salvamento.

const Teclado = preload("res://scripts/entradas.gd")
const Tiles = preload("res://scripts/arte/tiles.gd")
const Mapa = preload("res://scripts/mundo/mapa.gd")
const Criatura = preload("res://scripts/regras/criatura.gd")
const Colecao = preload("res://scripts/regras/colecao.gd")
const HeroiDados = preload("res://scripts/regras/heroi_dados.gd")
const Experiencia = preload("res://scripts/regras/experiencia.gd")
const Captura = preload("res://scripts/regras/captura.gd")
const Salvamento = preload("res://scripts/regras/salvamento.gd")
const CriaturaMundo = preload("res://scripts/mundo/criatura_mundo.gd")
const Heroi = preload("res://scripts/mundo/heroi.gd")
const Nucleo = preload("res://scripts/mundo/nucleo.gd")
const Cristal = preload("res://scripts/mundo/cristal.gd")
const Efeito = preload("res://scripts/mundo/efeito.gd")
const Hud = preload("res://scripts/ui/hud.gd")

const NUCLEOS_INICIAIS := 10
const DISTANCIA_MIRA := 170.0
const DISTANCIA_ALVO := 260.0
const DISTANCIA_NASCER := 300.0
const INTERVALO_NASCER := 2.5
const SALVAR_A_CADA := 30.0
const RAIO_FOGUEIRA := 56.0

signal mensagem_enviada(texto: String)

var mapa = null
var colecao = null
var heroi_dados = null
var nucleos := NUCLEOS_INICIAIS
var rng := RandomNumberGenerator.new()
var heroi: CharacterBody2D = null
var companheira = null
var alvo_captura = null
var selvagens: Array = []
var mensagens: Array[String] = []

## Para os testes
var caminho_save := Salvamento.CAMINHO_PADRAO
var usar_save := true
var com_interface := true
var forcar_captura := 0  # 1 sempre captura, -1 sempre falha, 0 sorteia
var nascer_automatico := true

var _mundo: Node2D = null
var _alvo_marcado = null
var _tempo_nascer := 0.0
var _tempo_salvar := 0.0
var _hud = null


func _ready() -> void:
	Teclado.registrar()
	rng.randomize()
	mapa = Mapa.new()
	_montar_mapa()
	_mundo = Node2D.new()
	_mundo.name = "Mundo"
	_mundo.y_sort_enabled = true
	add_child(_mundo)

	heroi = Heroi.new()
	heroi.name = "Heroi"
	heroi.jogo = self
	_carregar()
	heroi.dados = heroi_dados
	heroi.escala = 0.75  # tiles de 32 px no Vale
	_mundo.add_child(heroi)
	_montar_camera()

	for p in mapa.cristais:
		var c = Cristal.new()
		c.jogo = self
		c.position = Mapa.em_pixels(p) + Vector2(0, 8)
		_mundo.add_child(c)

	if com_interface:
		_hud = Hud.new()
		_hud.jogo = self
		add_child(_hud)

	invocar_companheira(false)
	if nascer_automatico:
		_povoar(true)
	if colecao.total() == 0:
		mensagem("Bem-vindo ao Vale Esmeralda! Enfraqueça uma criatura e lance o Núcleo de Vínculo (G).")
	else:
		mensagem("Bem-vindo de volta, Vinculador!")


func _montar_mapa() -> void:
	var ts := Tiles.criar_tileset()
	var chao := TileMapLayer.new()
	chao.name = "Chao"
	chao.tile_set = ts
	var objetos := TileMapLayer.new()
	objetos.name = "Objetos"
	objetos.tile_set = ts
	for y in Mapa.ALTURA:
		for x in Mapa.LARGURA:
			chao.set_cell(Vector2i(x, y), 0, Vector2i(mapa.chao[y][x], 0))
			if mapa.objetos[y][x] != -1:
				objetos.set_cell(Vector2i(x, y), 0, Vector2i(mapa.objetos[y][x], 0))
	add_child(chao)
	add_child(objetos)


func _montar_camera() -> void:
	var cam := Camera2D.new()
	cam.name = "Camera"
	cam.zoom = Vector2(2, 2)
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = Mapa.LARGURA * Tiles.T
	cam.limit_bottom = Mapa.ALTURA * Tiles.T
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 8.0
	heroi.add_child(cam)


# ---- salvar e carregar ----

func _carregar() -> void:
	var d := Salvamento.carregar(caminho_save) if usar_save else {}
	if d.is_empty():
		heroi_dados = HeroiDados.new()
		colecao = Colecao.new()
		nucleos = NUCLEOS_INICIAIS
		heroi.position = Mapa.em_pixels(Mapa.INICIO)
		return
	heroi_dados = HeroiDados.de_dicionario(d.get("heroi", {}))
	colecao = Colecao.de_dicionario(d.get("colecao", {}))
	nucleos = int(d.get("nucleos", NUCLEOS_INICIAIS))
	var pos: Array = d.get("posicao", [])
	var p := Vector2(pos[0], pos[1]) if pos.size() == 2 else Mapa.em_pixels(Mapa.INICIO)
	if not mapa.andavel(Mapa.em_tile(p)) or heroi_dados.desmaiado():
		p = Mapa.em_pixels(Mapa.INICIO)
		heroi_dados.curar_tudo()
	heroi.position = p


func salvar() -> void:
	if not usar_save:
		return
	Salvamento.salvar({
		"heroi": heroi_dados.para_dicionario(),
		"posicao": [heroi.position.x, heroi.position.y],
		"nucleos": nucleos,
		"colecao": colecao.para_dicionario(),
	}, caminho_save)


# ---- laço ----

func _process(delta: float) -> void:
	if heroi == null:
		return
	selvagens = selvagens.filter(func(c): return is_instance_valid(c))
	alvo_captura = _mais_proximo(selvagens_perto(heroi.position, DISTANCIA_MIRA), heroi.position)

	_tempo_nascer += delta
	if nascer_automatico and _tempo_nascer >= INTERVALO_NASCER:
		_tempo_nascer = 0.0
		_povoar(false)

	_tempo_salvar += delta
	if _tempo_salvar >= SALVAR_A_CADA:
		_tempo_salvar = 0.0
		salvar()

	if heroi.position.distance_to(Mapa.em_pixels(Mapa.CENTRO)) <= RAIO_FOGUEIRA and _precisa_descansar():
		descansar()


func pausado() -> bool:
	return _hud != null and _hud.painel_aberto()


func mensagem(texto: String) -> void:
	mensagens.append(texto)
	if mensagens.size() > 50:
		mensagens.pop_front()
	mensagem_enviada.emit(texto)


# ---- consultas usadas pelas criaturas e pelo herói ----

func selvagens_perto(pos: Vector2, raio: float) -> Array:
	return selvagens.filter(func(c): return is_instance_valid(c) and c.ativo() and c.position.distance_to(pos) <= raio)


func _mais_proximo(lista: Array, pos: Vector2):
	var melhor = null
	var menor := INF
	for c in lista:
		var d: float = c.position.distance_to(pos)
		if d < menor:
			menor = d
			melhor = c
	return melhor


## Herói ou companheira mais perto (para as selvagens agressivas).
func lutador_mais_proximo(pos: Vector2, raio: float, _amigos := true):
	var lista := []
	if heroi.ativo():
		lista.append(heroi)
	if companheira != null and is_instance_valid(companheira) and companheira.ativo():
		lista.append(companheira)
	var perto = _mais_proximo(lista, pos)
	if perto != null and perto.position.distance_to(pos) <= raio:
		return perto
	return null


func alvo_para_companheira():
	if _valido(_alvo_marcado) and _alvo_marcado.position.distance_to(heroi.position) <= DISTANCIA_ALVO:
		return _alvo_marcado
	for c in selvagens:
		if _valido(c) and c.estado == "lutar" and c.position.distance_to(heroi.position) <= DISTANCIA_ALVO:
			return c
	return null


func marcar_alvo(c) -> void:
	_alvo_marcado = c


func heroi_atacado(atacante) -> void:
	if atacante != null and is_instance_valid(atacante) and atacante.get("selvagem") == true and not _valido(_alvo_marcado):
		_alvo_marcado = atacante


func comandar() -> void:
	if companheira == null:
		mensagem("Você ainda não tem criatura. Capture uma com o Núcleo (G).")
		return
	var c = _mais_proximo(selvagens_perto(heroi.position, DISTANCIA_ALVO), heroi.position)
	if c == null:
		mensagem("Nenhuma criatura selvagem por perto.")
		return
	marcar_alvo(c)
	c.provocar(companheira)
	mensagem("%s, %s!" % [companheira.dados.nome(), companheira.nome_golpe()])


func _valido(c) -> bool:
	return c != null and is_instance_valid(c) and c.ativo()


# ---- captura ----

func chance_de(c) -> float:
	return Captura.chance(float(c.dados.especie().get("taxa_captura", 0.2)), c.dados.proporcao_vida(),
		Captura.bonus_nucleo("nucleo_simples"), 0.0, 0.0)


func lancar_nucleo() -> void:
	if nucleos <= 0:
		mensagem("Sem Núcleos de Vínculo! Pegue os cristais azuis pelo mapa.")
		return
	var alvo = alvo_captura if _valido(alvo_captura) else null
	nucleos -= 1
	var n = Nucleo.new()
	n.jogo = self
	n.alvo = alvo
	n.direcao = heroi.olhar
	n.position = heroi.position + Vector2(0, -14)
	n.z_index = 5
	_mundo.add_child(n)
	if alvo == null:
		mensagem("O Núcleo não achou nenhuma criatura perto. Chegue mais perto.")


func resolver_captura(_nucleo, c) -> void:
	if c == null or not is_instance_valid(c) or c.dados.desmaiada():
		return
	var chance := chance_de(c)
	var sucesso := rng.randf() <= chance
	if forcar_captura != 0:
		sucesso = forcar_captura > 0
	if sucesso:
		var destino: String = colecao.adicionar(c.dados)
		_mundo.add_child(Efeito.criar("brilho", c.position + Vector2(0, -10), Color.WHITE, "", 24.0))
		selvagens.erase(c)
		if _alvo_marcado == c:
			_alvo_marcado = null
		c.queue_free()
		var onde := "sua equipe" if destino == Colecao.EQUIPE else "a reserva (equipe cheia)"
		mensagem("%s Nv %d capturado! Foi para %s." % [c.dados.nome(), c.dados.nivel, onde])
		invocar_companheira()
		salvar()
	else:
		c.estado = "lutar" if c.temperamento() != "timida" else "fugir"
		c.alvo = heroi
		c.set("_tempo", 2.0)
		_mundo.add_child(Efeito.criar("estilhaco", c.position + Vector2(0, -10), Color.WHITE, "", 14.0))
		mensagem("%s escapou! A chance era %d%%. Enfraqueça mais." % [c.dados.nome(), roundi(chance * 100.0)])


func coletar_cristal(_cristal) -> void:
	nucleos += 1
	mensagem("Cristal de Essência: +1 Núcleo de Vínculo (%d)." % nucleos)


# ---- vitória, derrota e descanso ----

func criatura_desmaiou(c, _atacante) -> void:
	if c.selvagem:
		selvagens.erase(c)
		if _alvo_marcado == c:
			_alvo_marcado = null
		colecao.ver(c.dados.especie_id)
		dar_experiencia(Experiencia.por_vitoria(c.dados.nivel), c.position)
	else:
		mensagem("%s desmaiou! Descanse na fogueira para curar." % c.dados.nome())
		if companheira == c:
			companheira = null
		get_tree().create_timer(0.8).timeout.connect(c.queue_free)
		get_tree().create_timer(1.0).timeout.connect(invocar_companheira)


func dar_experiencia(xp: int, onde: Vector2) -> void:
	_mundo.add_child(Efeito.criar("texto", onde + Vector2(0, -30), Color("8fe3ff"), "+%d XP" % xp))
	if heroi_dados.ganhar_xp(xp) > 0:
		mensagem("Você subiu para o nível %d!" % heroi_dados.nivel)
	if companheira != null and is_instance_valid(companheira) and companheira.ativo():
		var cd = companheira.dados
		if cd.ganhar_xp(xp) > 0:
			mensagem("%s subiu para o nível %d!" % [cd.nome(), cd.nivel])
			if cd.pode_evoluir():
				var antes: String = cd.nome()
				cd.evoluir()
				companheira.atualizar_especie()
				_mundo.add_child(Efeito.criar("brilho", companheira.position + Vector2(0, -10), Color.WHITE, "", 32.0))
				mensagem("%s evoluiu para %s!" % [antes, cd.nome()])
	salvar()


func heroi_desmaiou() -> void:
	mensagem("Você desmaiou e acordou na fogueira.")
	heroi.position = Mapa.em_pixels(Mapa.INICIO)
	_alvo_marcado = null
	for c in selvagens:
		if is_instance_valid(c) and c.alvo == heroi:
			c.alvo = null
			c.estado = "passear"
	if companheira != null and is_instance_valid(companheira):
		companheira.position = heroi.position + Vector2(-24, 8)
	descansar(false)


func _precisa_descansar() -> bool:
	if heroi_dados.vida < heroi_dados.vida_maxima():
		return true
	for c in colecao.equipe + colecao.reserva:
		if c.vida_atual < c.vida_maxima():
			return true
	return false


func descansar(avisar := true) -> void:
	heroi_dados.curar_tudo()
	for c in colecao.equipe + colecao.reserva:
		c.curar_tudo()
	invocar_companheira()
	salvar()
	if avisar:
		mensagem("Você descansou na fogueira. Todos estão curados e o jogo foi salvo.")


# ---- companheira ----

func invocar_companheira(avisar := true) -> void:
	if companheira != null and is_instance_valid(companheira) and companheira.ativo():
		return
	for c in colecao.equipe:
		if not c.desmaiada():
			companheira = CriaturaMundo.criar(self, c, false, heroi.position + Vector2(-24, 10))
			_mundo.add_child(companheira)
			if avisar:
				mensagem("Vai, %s!" % c.nome())
			return
	companheira = null


## Troca a criatura ativa (painel da equipe).
func ativar(c) -> void:
	if not colecao.equipe.has(c) or c.desmaiada():
		return
	colecao.equipe.erase(c)
	colecao.equipe.push_front(c)
	if companheira != null and is_instance_valid(companheira):
		companheira.queue_free()
	companheira = null
	invocar_companheira()
	salvar()


# ---- criaturas selvagens ----

func _povoar(inicial: bool) -> void:
	for zona in Mapa.ZONAS:
		var info: Dictionary = Mapa.ZONAS[zona]
		var lugares: Array = mapa.zonas[zona]
		var vivas := selvagens.filter(func(c): return is_instance_valid(c) and c.get_meta("zona", "") == zona).size()
		var faltam: int = info.maximo - vivas
		if not inicial:
			faltam = mini(faltam, 1)
		for i in faltam:
			for tentativa in 12:
				var p := Mapa.em_pixels(lugares[rng.randi_range(0, lugares.size() - 1)])
				if p.distance_to(heroi.position) >= DISTANCIA_NASCER:
					nascer(zona, p)
					break


func nascer(zona: String, pos: Vector2, especie := "", nivel := 0):
	if especie == "":
		var sorteio := _sortear_especie(Mapa.ZONAS[zona].especies)
		especie = sorteio[0]
		nivel = rng.randi_range(sorteio[1], sorteio[2])
	var dados = Criatura.nova(especie, maxi(nivel, 1), rng)
	var c = CriaturaMundo.criar(self, dados, true, pos)
	c.set_meta("zona", zona)
	selvagens.append(c)
	_mundo.add_child(c)
	return c


func _sortear_especie(lista: Array) -> Array:
	var total := 0
	for e in lista:
		total += int(e[3])
	var r := rng.randi_range(1, total)
	for e in lista:
		r -= int(e[3])
		if r <= 0:
			return e
	return lista[0]
