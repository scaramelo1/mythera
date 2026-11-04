extends RefCounted
## Desenhos provisórios feitos no código (herói e criaturas), até chegar a arte de verdade.
## Tudo é desenhado em volta do ponto (0, 0), que fica nos pés.

const SOMBRA := Color(0, 0, 0, 0.28)
const OLHO := Color("1d1d26")


static func elipse(ci: CanvasItem, c: Vector2, raio: Vector2, cor: Color, lados := 20) -> void:
	var pts := PackedVector2Array()
	for i in lados:
		var a := TAU * i / lados
		pts.append(c + Vector2(cos(a) * raio.x, sin(a) * raio.y))
	ci.draw_colored_polygon(pts, cor)


static func olhos(ci: CanvasItem, c: Vector2, distancia: float, r: float) -> void:
	for lado in [-1, 1]:
		var p: Vector2 = c + Vector2(lado * distancia, 0)
		ci.draw_circle(p, r, OLHO)
		ci.draw_circle(p + Vector2(-r * 0.35, -r * 0.35), r * 0.4, Color.WHITE)


## Herói visto de cima, de lado (vira para a esquerda ou direita) e de costas quando anda para cima.
static func heroi(ci: CanvasItem, olhar: Vector2, passo: float, piscando: bool) -> void:
	elipse(ci, Vector2(0, 0), Vector2(9, 4), SOMBRA)
	var lado := -1.0 if olhar.x < -0.1 else 1.0
	var costas := olhar.y < -0.5
	var balanco := sin(passo) * 2.0
	var pele := Color("f2c9a0")
	var roupa := Color("2f6fb0") if not piscando else Color.WHITE
	# pernas
	ci.draw_rect(Rect2(-5, -6 + balanco * 0.5, 4, 6), Color("3b2f2a"))
	ci.draw_rect(Rect2(1, -6 - balanco * 0.5, 4, 6), Color("3b2f2a"))
	# mochila (aparece de costas e de lado)
	if costas:
		ci.draw_rect(Rect2(-6, -17, 12, 9), Color("7a5232"))
	else:
		ci.draw_rect(Rect2(-lado * 9 - 2, -16, 4, 8), Color("7a5232"))
	# corpo e lenço
	elipse(ci, Vector2(0, -12), Vector2(7, 7), roupa)
	ci.draw_rect(Rect2(-6, -17, 12, 3), Color("d9482b"))
	# cabeça
	ci.draw_circle(Vector2(0, -24), 7.5, pele)
	elipse(ci, Vector2(0, -28), Vector2(8, 5), Color("5a3a22"))
	if costas:
		ci.draw_circle(Vector2(0, -24), 7, Color("5a3a22"))
	else:
		olhos(ci, Vector2(lado * 2.0, -23), 2.8, 1.3)


static func criatura(ci: CanvasItem, forma: String, r: float, cor: Color, cor2: Color,
		olhar: Vector2, t: float, piscando: bool) -> void:
	var lado := -1.0 if olhar.x < -0.1 else 1.0
	if piscando:
		cor = Color.WHITE
		cor2 = Color.WHITE
	elipse(ci, Vector2(0, 0), Vector2(r * 1.1, r * 0.45), SOMBRA)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2(lado, 1))
	match forma:
		"raposa":
			_raposa(ci, r, cor, cor2, t)
		"lontra":
			_lontra(ci, r, cor, cor2, t)
		"tartaruga":
			_tartaruga(ci, r, cor, cor2, t)
		_:
			ci.draw_circle(Vector2(0, -r), r, cor)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _raposa(ci: CanvasItem, r: float, cor: Color, cor2: Color, t: float) -> void:
	# cauda em chama, atrás
	var f := sin(t * 10.0) * r * 0.12
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(-r * 0.6, -r * 0.8), Vector2(-r * 1.9, -r * 1.7 + f), Vector2(-r * 1.2, -r * 0.4)]), cor2)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(-r * 0.6, -r * 0.7), Vector2(-r * 1.5, -r * 1.3 - f), Vector2(-r * 1.0, -r * 0.45)]), cor)
	# corpo, peito e patas
	elipse(ci, Vector2(0, -r * 0.75), Vector2(r * 0.95, r * 0.65), cor)
	elipse(ci, Vector2(r * 0.35, -r * 0.6), Vector2(r * 0.4, r * 0.4), Color(1, 0.95, 0.85))
	for x in [-0.5, 0.5]:
		ci.draw_circle(Vector2(r * x, -r * 0.15), r * 0.2, cor.darkened(0.25))
	# cabeça e orelhas
	var cab := Vector2(r * 0.7, -r * 1.55)
	ci.draw_colored_polygon(PackedVector2Array([cab + Vector2(-r * 0.55, -r * 0.2), cab + Vector2(-r * 0.4, -r * 1.05), cab + Vector2(0, -r * 0.4)]), cor)
	ci.draw_colored_polygon(PackedVector2Array([cab + Vector2(0.1 * r, -r * 0.4), cab + Vector2(r * 0.45, -r * 1.05), cab + Vector2(r * 0.6, -r * 0.2)]), cor)
	ci.draw_circle(cab, r * 0.62, cor)
	elipse(ci, cab + Vector2(r * 0.35, r * 0.2), Vector2(r * 0.35, r * 0.25), Color(1, 0.95, 0.85))
	ci.draw_circle(cab + Vector2(r * 0.68, r * 0.15), r * 0.1, OLHO)
	olhos(ci, cab + Vector2(r * 0.1, -r * 0.1), r * 0.25, r * 0.13)


static func _lontra(ci: CanvasItem, r: float, cor: Color, cor2: Color, t: float) -> void:
	var balanco := sin(t * 4.0) * r * 0.08
	# cauda achatada
	elipse(ci, Vector2(-r * 1.1, -r * 0.35 + balanco), Vector2(r * 0.7, r * 0.25), cor.darkened(0.15))
	# corpo
	elipse(ci, Vector2(0, -r * 0.9), Vector2(r * 0.85, r * 0.9), cor)
	elipse(ci, Vector2(r * 0.2, -r * 0.8), Vector2(r * 0.5, r * 0.6), cor2)
	# cabeça
	var cab := Vector2(r * 0.35, -r * 1.85)
	ci.draw_circle(cab + Vector2(-r * 0.45, -r * 0.45), r * 0.22, cor)
	ci.draw_circle(cab + Vector2(r * 0.45, -r * 0.45), r * 0.22, cor)
	ci.draw_circle(cab, r * 0.62, cor)
	elipse(ci, cab + Vector2(r * 0.15, r * 0.22), Vector2(r * 0.42, r * 0.28), cor2)
	ci.draw_circle(cab + Vector2(r * 0.18, r * 0.1), r * 0.1, OLHO)
	olhos(ci, cab + Vector2(r * 0.12, -r * 0.15), r * 0.27, r * 0.14)
	# bolhas
	ci.draw_arc(Vector2(r * 1.1, -r * 2.4 - fmod(t * 8.0, r)), r * 0.15, 0, TAU, 10, Color(0.75, 0.9, 1, 0.8), 1.0)


static func _tartaruga(ci: CanvasItem, r: float, cor: Color, cor2: Color, t: float) -> void:
	# patas e cabeça
	for p in [Vector2(-0.7, -0.15), Vector2(0.6, -0.15)]:
		ci.draw_circle(Vector2(r * p.x, r * p.y), r * 0.25, cor.lightened(0.2))
	var cab := Vector2(r * 1.05, -r * 0.75 + sin(t * 3.0) * r * 0.05)
	ci.draw_circle(cab, r * 0.42, cor.lightened(0.25))
	olhos(ci, cab + Vector2(r * 0.08, -r * 0.05), r * 0.17, r * 0.1)
	# casco com musgo
	elipse(ci, Vector2(0, -r * 0.7), Vector2(r * 1.0, r * 0.75), cor2)
	elipse(ci, Vector2(0, -r * 0.8), Vector2(r * 0.85, r * 0.62), cor)
	for p in [Vector2(-0.35, -0.95), Vector2(0.3, -0.9), Vector2(0, -0.55)]:
		ci.draw_circle(Vector2(r * p.x, r * p.y), r * 0.2, cor.darkened(0.2))
	ci.draw_circle(Vector2(-r * 0.2, -r * 1.25), r * 0.18, Color("7cc95a"))
	ci.draw_line(Vector2(-r * 0.1, -r * 1.3), Vector2(r * 0.15, -r * 1.65), Color("7cc95a"), 2.0)


static func cristal(ci: CanvasItem, t: float) -> void:
	elipse(ci, Vector2(0, 0), Vector2(6, 2.5), SOMBRA)
	var y := sin(t * 3.0) * 1.5
	var pts := PackedVector2Array([Vector2(0, -16 + y), Vector2(5, -8 + y), Vector2(0, -2 + y), Vector2(-5, -8 + y)])
	ci.draw_colored_polygon(pts, Color("5ec8f2"))
	ci.draw_colored_polygon(PackedVector2Array([Vector2(0, -16 + y), Vector2(5, -8 + y), Vector2(0, -8 + y)]), Color("b8ecff"))


static func nucleo(ci: CanvasItem, t: float, r := 5.0) -> void:
	ci.draw_circle(Vector2.ZERO, r, Color("e8f6ff"))
	ci.draw_circle(Vector2.ZERO, r * 0.55, Color("5ec8f2"))
	ci.draw_arc(Vector2.ZERO, r + 2.0, t * 6.0, t * 6.0 + PI, 12, Color("ffd23f"), 1.5)


const CORES_ELEMENTO := {
	"fogo": Color("ff7a2a"),
	"agua": Color("4aa8ff"),
	"natureza": Color("6fd24a"),
	"": Color("ffffff"),
}


static func cor_elemento(elemento: String) -> Color:
	return CORES_ELEMENTO.get(elemento, Color.WHITE)
