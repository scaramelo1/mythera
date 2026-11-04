extends RefCounted
## Gera no código as texturas do mapa (provisórias, até chegar a arte de verdade).
## Não precisa de arquivo de imagem nem de importação: funciona igual no PC, no navegador e nos testes.

const T := 32  # tamanho do tile em pixels

enum { GRAMA, GRAMA2, CAPIM, TERRA, AREIA, AGUA, FLORES, ARVORE, PEDRA, FOGUEIRA }
const QUANTIDADE := 10
## Tiles que bloqueiam a passagem.
const BLOQUEIAM := [AGUA, ARVORE, PEDRA, FOGUEIRA]

static var _rng := RandomNumberGenerator.new()


static func criar_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(T, T)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 0)
	var fonte := TileSetAtlasSource.new()
	fonte.texture = ImageTexture.create_from_image(criar_imagem())
	fonte.texture_region_size = Vector2i(T, T)
	for i in QUANTIDADE:
		fonte.create_tile(Vector2i(i, 0))
	ts.add_source(fonte, 0)
	for i in BLOQUEIAM:
		var dados := fonte.get_tile_data(Vector2i(i, 0), 0)
		var m := 2.0 if i == AGUA else 6.0  # árvores e pedras um pouco menores que o tile
		var h := T / 2.0
		dados.add_collision_polygon(0)
		dados.set_collision_polygon_points(0, 0, PackedVector2Array([
			Vector2(-h + m, -h + m), Vector2(h - m, -h + m), Vector2(h - m, h - m), Vector2(-h + m, h - m)]))
	return ts


static func criar_imagem() -> Image:
	_rng.seed = 2026
	var img := Image.create(T * QUANTIDADE, T, false, Image.FORMAT_RGBA8)
	_grama(img, GRAMA, Color("5fa148"), 0.05)
	_grama(img, GRAMA2, Color("58994a"), 0.06)
	_grama(img, CAPIM, Color("4c8f3d"), 0.05)
	_capim(img, CAPIM)
	_ruido(img, TERRA, Color("b58b57"), 0.06)
	_ruido(img, AREIA, Color("e3cf8f"), 0.04)
	_agua(img, AGUA)
	_grama(img, FLORES, Color("5fa148"), 0.05)
	_flores(img, FLORES)
	_grama(img, ARVORE, Color("5fa148"), 0.05)
	_arvore(img, ARVORE)
	_grama(img, PEDRA, Color("5fa148"), 0.05)
	_pedra(img, PEDRA)
	_ruido(img, FOGUEIRA, Color("b58b57"), 0.06)
	_fogueira(img, FOGUEIRA)
	return img


static func _px(img: Image, tile: int, x: int, y: int, cor: Color) -> void:
	if x >= 0 and x < T and y >= 0 and y < T:
		img.set_pixel(tile * T + x, y, cor)


static func _circulo(img: Image, tile: int, c: Vector2, r: float, cor: Color) -> void:
	for y in T:
		for x in T:
			if Vector2(x + 0.5, y + 0.5).distance_to(c) <= r:
				_px(img, tile, x, y, cor)


static func _ruido(img: Image, tile: int, base: Color, forca: float) -> void:
	for y in T:
		for x in T:
			var v := _rng.randf_range(-forca, forca)
			_px(img, tile, x, y, Color(base.r + v, base.g + v, base.b + v))


static func _grama(img: Image, tile: int, base: Color, forca: float) -> void:
	_ruido(img, tile, base, forca)
	for i in 10:
		var x := _rng.randi_range(1, T - 2)
		var y := _rng.randi_range(2, T - 1)
		_px(img, tile, x, y, base.darkened(0.18))
		_px(img, tile, x, y - 1, base.lightened(0.12))


static func _capim(img: Image, tile: int) -> void:
	for i in 26:
		var x := _rng.randi_range(0, T - 1)
		var y := _rng.randi_range(5, T - 1)
		var altura := _rng.randi_range(4, 8)
		for k in altura:
			_px(img, tile, x + (1 if k > altura - 2 and i % 2 == 0 else 0), y - k,
				Color("3d7a2f").lightened(0.04 * k))


static func _agua(img: Image, tile: int) -> void:
	_ruido(img, tile, Color("3f7fd0"), 0.025)
	for i in 5:
		var x := _rng.randi_range(2, T - 8)
		var y := _rng.randi_range(2, T - 2)
		for k in 5:
			_px(img, tile, x + k, y, Color("8cc3f2"))


static func _flores(img: Image, tile: int) -> void:
	var cores := [Color("f2e14b"), Color("f07aa8"), Color("ffffff"), Color("b37af0")]
	for i in 7:
		var c := Vector2(_rng.randi_range(3, T - 4), _rng.randi_range(3, T - 4))
		var cor: Color = cores[i % cores.size()]
		for d in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
			_px(img, tile, int(c.x + d.x), int(c.y + d.y), cor)
		_px(img, tile, int(c.x), int(c.y), Color("f2a33a"))


static func _arvore(img: Image, tile: int) -> void:
	_circulo(img, tile, Vector2(17, 19), 13, Color(0, 0, 0, 0.25))  # sombra
	_circulo(img, tile, Vector2(16, 15), 13, Color("2f6b2a"))
	_circulo(img, tile, Vector2(14, 13), 10, Color("3c8534"))
	_circulo(img, tile, Vector2(12, 10), 5, Color("5aa84a"))


static func _pedra(img: Image, tile: int) -> void:
	_circulo(img, tile, Vector2(17, 19), 11, Color(0, 0, 0, 0.25))
	_circulo(img, tile, Vector2(16, 16), 11, Color("8a8a86"))
	_circulo(img, tile, Vector2(14, 14), 8, Color("a3a39e"))
	_circulo(img, tile, Vector2(12, 11), 3, Color("c4c4bf"))


static func _fogueira(img: Image, tile: int) -> void:
	_circulo(img, tile, Vector2(16, 17), 11, Color("6b6b66"))
	_circulo(img, tile, Vector2(16, 17), 8, Color("4a3424"))
	_circulo(img, tile, Vector2(16, 16), 6, Color("f07a2a"))
	_circulo(img, tile, Vector2(16, 15), 3.5, Color("ffd23f"))
