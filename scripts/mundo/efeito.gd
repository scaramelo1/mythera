extends Node2D
## Efeitos curtos: anel do golpe, número de dano, brilho da captura, estilhaço do núcleo e golpe do herói.

const Desenho = preload("res://scripts/arte/desenho.gd")

var tipo := "anel"
var cor := Color.WHITE
var texto := ""
var duracao := 0.5
var raio := 16.0
var direcao := Vector2.RIGHT
var _t := 0.0


static func criar(tipo_: String, posicao: Vector2, cor_ := Color.WHITE, texto_ := "", raio_ := 16.0):
	var e = load("res://scripts/mundo/efeito.gd").new()
	e.tipo = tipo_
	e.position = posicao
	e.cor = cor_
	e.texto = texto_
	e.raio = raio_
	e.z_index = 10
	e.duracao = {"numero": 0.8, "brilho": 0.9, "texto": 1.6}.get(tipo_, 0.35)
	return e


func _process(delta: float) -> void:
	_t += delta
	if _t >= duracao:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var k := _t / duracao
	var alfa := 1.0 - k
	match tipo:
		"anel":
			draw_arc(Vector2.ZERO, raio * (0.4 + k), 0, TAU, 24, Color(cor, alfa), 3.0)
		"corte":
			var a := direcao.angle()
			draw_arc(Vector2.ZERO, raio, a - 1.0, a + 1.0, 12, Color(1, 1, 1, alfa), 4.0)
		"numero", "texto":
			var fonte := ThemeDB.fallback_font
			var tam := 12 if tipo == "numero" else 11
			var largura := fonte.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
			var p := Vector2(-largura / 2.0, -k * 18.0)
			draw_string_outline(fonte, p, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, 3, Color(0, 0, 0, alfa))
			draw_string(fonte, p, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, Color(cor, alfa))
		"brilho":
			for i in 8:
				var ang := TAU * i / 8.0 + k
				draw_line(Vector2.from_angle(ang) * raio * k, Vector2.from_angle(ang) * raio * (k + 0.4),
					Color(1, 0.85, 0.25, alfa), 2.0)
			draw_circle(Vector2.ZERO, raio * 0.5 * alfa, Color(1, 1, 0.8, alfa))
		"estilhaco":
			for i in 6:
				var ang := TAU * i / 6.0
				draw_circle(Vector2.from_angle(ang) * raio * k, 2.0, Color("b8ecff", alfa))
