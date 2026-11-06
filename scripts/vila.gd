extends Node2D
## Vila (mapa desenhado pelo dono, assets/mapas/vila.webp). Por enquanto só o herói andando.
## Onde dá para andar vem de dados/vila_mascara.json (gerado por ferramentas/gerar_mascara_vila.py).

const Teclado = preload("res://scripts/entradas.gd")
const Heroi = preload("res://scripts/mundo/heroi.gd")
const HeroiDados = preload("res://scripts/regras/heroi_dados.gd")
const ControlesToque = preload("res://scripts/ui/controles_toque.gd")
const Carregar = preload("res://scripts/arte/carregar.gd")

const MAPA := "res://assets/mapas/vila.webp"
const MASCARA := "res://dados/vila_mascara.json"

var heroi: CharacterBody2D = null
var rng := RandomNumberGenerator.new()
var celula := 8
var linhas: PackedStringArray = []
var tamanho := Vector2i.ZERO
var inicio := Vector2.ZERO
var formas_de_colisao := 0


func _ready() -> void:
	Teclado.registrar()
	rng.randomize()
	var fundo := Sprite2D.new()
	fundo.name = "Fundo"
	fundo.centered = false
	fundo.texture = _carregar_mapa()
	add_child(fundo)
	tamanho = Vector2i(fundo.texture.get_size())
	_carregar_mascara()
	_montar_colisao()

	heroi = Heroi.new()
	heroi.name = "Heroi"
	heroi.jogo = self
	heroi.dados = HeroiDados.new()
	heroi.position = inicio
	add_child(heroi)

	var cam := Camera2D.new()
	cam.zoom = Vector2(2, 2)
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = tamanho.x
	cam.limit_bottom = tamanho.y
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 8.0
	heroi.add_child(cam)

	var tela := CanvasLayer.new()
	add_child(tela)
	var toque = ControlesToque.new()
	toque.botoes = ControlesToque.BOTOES.filter(func(b): return b.acao in ["atacar", "esquivar"])
	tela.add_child(toque)
	var ajuda := Label.new()
	ajuda.text = "WASD ou setas: andar · Espaço: atacar · Shift: esquivar"
	ajuda.position = Vector2(16, 12)
	ajuda.add_theme_color_override("font_outline_color", Color.BLACK)
	ajuda.add_theme_constant_override("outline_size", 4)
	tela.add_child(ajuda)


func _carregar_mapa() -> Texture2D:
	return Carregar.textura(MAPA)


func _carregar_mascara() -> void:
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(MASCARA))
	celula = int(d.celula)
	linhas = PackedStringArray(d.linhas)
	inicio = Vector2(d.inicio[0], d.inicio[1])


func andavel(pos: Vector2) -> bool:
	var x := floori(pos.x / celula)
	var y := floori(pos.y / celula)
	if y < 0 or y >= linhas.size() or x < 0 or x >= linhas[y].length():
		return false
	return linhas[y][x] == "1"


## Paredes invisíveis só nas células bloqueadas que encostam numa livre,
## juntadas em retângulos (bem menos formas para a física).
func _montar_colisao() -> void:
	var altura := linhas.size()
	var largura := linhas[0].length()
	var borda := {}
	for y in altura:
		for x in largura:
			if linhas[y][x] != "0":
				continue
			for dy in [-1, 0, 1]:
				for dx in [-1, 0, 1]:
					var nx: int = x + dx
					var ny: int = y + dy
					if ny >= 0 and ny < altura and nx >= 0 and nx < largura and linhas[ny][nx] == "1":
						borda[Vector2i(x, y)] = true
	# faixas horizontais por linha, depois junta faixas iguais de linhas seguidas
	var abertas := {}  # Vector2i(x0, x1) -> Rect2i
	var prontos: Array[Rect2i] = []
	for y in altura + 1:
		var faixas := {}
		if y < altura:
			var x := 0
			while x < largura:
				if borda.has(Vector2i(x, y)):
					var x0 := x
					while x < largura and borda.has(Vector2i(x, y)):
						x += 1
					faixas[Vector2i(x0, x)] = true
				else:
					x += 1
		var novas := {}
		for f in faixas:
			if abertas.has(f):
				var r: Rect2i = abertas[f]
				r.size.y += 1
				novas[f] = r
			else:
				novas[f] = Rect2i(f.x, y, f.y - f.x, 1)
		for f in abertas:
			if not novas.has(f):
				prontos.append(abertas[f])
		abertas = novas
	var corpo := StaticBody2D.new()
	corpo.name = "Paredes"
	corpo.collision_layer = 1
	corpo.collision_mask = 0
	for r in prontos:
		var forma := CollisionShape2D.new()
		var ret := RectangleShape2D.new()
		ret.size = Vector2(r.size) * celula
		forma.shape = ret
		forma.position = Vector2(r.position) * celula + ret.size / 2.0
		corpo.add_child(forma)
	add_child(corpo)
	formas_de_colisao = prontos.size()


# ---- o que o herói pergunta ao jogo (nada a fazer na vila, por enquanto) ----

func pausado() -> bool:
	return false


func lancar_nucleo() -> void:
	pass


func comandar() -> void:
	pass


func selvagens_perto(_pos: Vector2, _raio: float) -> Array:
	return []


func marcar_alvo(_c) -> void:
	pass


func heroi_atacado(_atacante) -> void:
	pass


func heroi_desmaiou() -> void:
	pass
