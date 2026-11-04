extends RefCounted
## Gera o Vale Esmeralda de testes (sempre igual, pela semente) e guarda o que cada tile é.
## Áreas: clareira com fogueira no centro, floresta (Mosshell), campo de pedras (Flarin),
## lago (Aquori) e pradaria perto do início (criaturas de nível baixo).

const Tiles = preload("res://scripts/arte/tiles.gd")

const LARGURA := 80
const ALTURA := 60
const SEMENTE := 7
const CENTRO := Vector2i(40, 30)
const INICIO := Vector2i(40, 33)

## zona -> espécies que aparecem: [id, nível mínimo, nível máximo, peso]
const ZONAS := {
	"pradaria": {"nome": "Pradaria", "maximo": 6, "especies": [["flarin", 1, 3, 2], ["mosshell", 2, 3, 1], ["aquori", 1, 3, 1]]},
	"campo": {"nome": "Campo de Pedras", "maximo": 6, "especies": [["flarin", 3, 6, 1]]},
	"floresta": {"nome": "Floresta Antiga", "maximo": 6, "especies": [["mosshell", 3, 6, 3], ["flarin", 4, 6, 1]]},
	"lago": {"nome": "Lago Espelhado", "maximo": 5, "especies": [["aquori", 3, 6, 1]]},
}

var chao: Array = []      # [y][x] -> tile do chão
var objetos: Array = []   # [y][x] -> tile de objeto ou -1
var zonas := {}           # nome -> Array[Vector2i] de capim alcançável
var cristais: Array[Vector2i] = []

var _ruido := FastNoiseLite.new()
var _ruido2 := FastNoiseLite.new()
var _rng := RandomNumberGenerator.new()


func _init() -> void:
	_rng.seed = SEMENTE
	_ruido.seed = SEMENTE
	_ruido.frequency = 0.08
	_ruido2.seed = SEMENTE + 1
	_ruido2.frequency = 0.15
	_gerar()


func dentro(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < LARGURA and p.y < ALTURA


func andavel(p: Vector2i) -> bool:
	if not dentro(p):
		return false
	return chao[p.y][p.x] != Tiles.AGUA and objetos[p.y][p.x] == -1


func zona_de(p: Vector2i) -> String:
	if _distancia_lago(p) < 1.75:
		return "lago"
	if p.x < 34 and p.y < 30:
		return "floresta"
	if p.x > 46 and p.y < 26:
		return "campo"
	return "pradaria"


func _distancia_lago(p: Vector2i) -> float:
	var c := Vector2(62, 43)
	var d := (Vector2(p) - c) / Vector2(11, 7)
	return d.length() + _ruido.get_noise_2d(p.x, p.y) * 0.25


func _gerar() -> void:
	for y in ALTURA:
		chao.append([])
		objetos.append([])
		for x in LARGURA:
			chao[y].append(Tiles.GRAMA if _ruido2.get_noise_2d(x, y) < 0.25 else Tiles.GRAMA2)
			objetos[y].append(-1)

	for y in ALTURA:
		for x in LARGURA:
			var p := Vector2i(x, y)
			var dl := _distancia_lago(p)
			var n := _ruido.get_noise_2d(x * 1.7, y * 1.7)
			var n2 := _ruido2.get_noise_2d(x, y)
			if dl < 1.0:
				chao[y][x] = Tiles.AGUA
			elif dl < 1.25:
				chao[y][x] = Tiles.AREIA
			elif dl < 1.75:
				if n2 > -0.15:
					chao[y][x] = Tiles.CAPIM
			else:
				match zona_de(p):
					"floresta":
						if n > 0.05:
							objetos[y][x] = Tiles.ARVORE
						elif n2 > 0.1:
							chao[y][x] = Tiles.CAPIM
					"campo":
						if _rng.randf() < 0.05:
							objetos[y][x] = Tiles.PEDRA
						elif n2 > 0.05:
							chao[y][x] = Tiles.CAPIM
					_:
						if _rng.randf() < 0.02:
							objetos[y][x] = Tiles.ARVORE
						elif n2 > 0.3:
							chao[y][x] = Tiles.CAPIM
						elif n2 < -0.45:
							chao[y][x] = Tiles.FLORES

	# borda de árvores
	for y in ALTURA:
		for x in LARGURA:
			if x < 2 or y < 2 or x >= LARGURA - 2 or y >= ALTURA - 2:
				objetos[y][x] = Tiles.ARVORE
				if chao[y][x] == Tiles.AGUA:
					chao[y][x] = Tiles.GRAMA

	# clareira do início, com a fogueira no meio
	for y in range(CENTRO.y - 5, CENTRO.y + 6):
		for x in range(CENTRO.x - 6, CENTRO.x + 7):
			if Vector2(x, y).distance_to(Vector2(CENTRO)) <= 5.5:
				objetos[y][x] = -1
				chao[y][x] = Tiles.GRAMA
	objetos[CENTRO.y][CENTRO.x] = Tiles.FOGUEIRA

	# caminhos de terra da clareira até cada área
	_caminho(CENTRO, Vector2i(16, 13))
	_caminho(CENTRO, Vector2i(64, 12))
	_caminho(CENTRO, Vector2i(50, 41))
	_caminho(CENTRO, Vector2i(22, 48))

	_marcar_zonas()
	_espalhar_cristais()


func _caminho(de: Vector2i, ate: Vector2i) -> void:
	var p := de
	while p != ate:
		if p.x != ate.x and (p.y == ate.y or _rng.randf() < 0.5):
			p.x += signi(ate.x - p.x)
		else:
			p.y += signi(ate.y - p.y)
		for d in [Vector2i.ZERO, Vector2i(1, 0), Vector2i(0, 1)]:
			var q: Vector2i = p + d
			if dentro(q) and q.x >= 2 and q.y >= 2 and q.x < LARGURA - 2 and q.y < ALTURA - 2:
				if chao[q.y][q.x] == Tiles.AGUA:
					continue
				objetos[q.y][q.x] = -1
				if q != CENTRO:
					chao[q.y][q.x] = Tiles.TERRA
	objetos[CENTRO.y][CENTRO.x] = Tiles.FOGUEIRA


## Só entram nas zonas os tiles de capim que dá para alcançar a pé a partir do início.
func _marcar_zonas() -> void:
	var alcancavel := alcancaveis()
	for nome in ZONAS:
		zonas[nome] = [] as Array[Vector2i]
	for p in alcancavel:
		if chao[p.y][p.x] == Tiles.CAPIM:
			zonas[zona_de(p)].append(p)


func alcancaveis() -> Array[Vector2i]:
	var vistos := {INICIO: true}
	var fila: Array[Vector2i] = [INICIO]
	var i := 0
	while i < fila.size():
		var p := fila[i]
		i += 1
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q: Vector2i = p + d
			if not vistos.has(q) and andavel(q):
				vistos[q] = true
				fila.append(q)
	return fila


func _espalhar_cristais() -> void:
	var lugares := alcancaveis().filter(func(p): return chao[p.y][p.x] in [Tiles.GRAMA, Tiles.GRAMA2, Tiles.FLORES] \
		and Vector2(p).distance_to(Vector2(CENTRO)) > 8)
	for i in 14:
		cristais.append(lugares[_rng.randi_range(0, lugares.size() - 1)])


## Centro do tile em pixels.
static func em_pixels(p: Vector2i) -> Vector2:
	return Vector2(p) * Tiles.T + Vector2.ONE * Tiles.T / 2.0


static func em_tile(pos: Vector2) -> Vector2i:
	return Vector2i(floori(pos.x / Tiles.T), floori(pos.y / Tiles.T))
