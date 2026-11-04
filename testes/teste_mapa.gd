extends "res://testes/base.gd"

const Mapa = preload("res://scripts/mundo/mapa.gd")
const Tiles = preload("res://scripts/arte/tiles.gd")


func teste_inicio_e_fogueira() -> void:
	var m = Mapa.new()
	verdade(m.andavel(Mapa.INICIO), "o herói começa num lugar andável")
	igual(m.objetos[Mapa.CENTRO.y][Mapa.CENTRO.x], Tiles.FOGUEIRA, "fogueira no centro")


func teste_todas_as_zonas_tem_capim_alcancavel() -> void:
	var m = Mapa.new()
	for nome in Mapa.ZONAS:
		verdade(m.zonas[nome].size() >= 20, "zona %s com pouco capim alcançável: %d" % [nome, m.zonas[nome].size()])


func teste_mapa_sempre_igual() -> void:
	var a = Mapa.new()
	var b = Mapa.new()
	igual(a.chao, b.chao, "chão")
	igual(a.objetos, b.objetos, "objetos")


func teste_borda_fechada() -> void:
	var m = Mapa.new()
	for x in Mapa.LARGURA:
		verdade(not m.andavel(Vector2i(x, 0)) and not m.andavel(Vector2i(x, Mapa.ALTURA - 1)), "borda aberta em x=%d" % x)


func teste_cristais_alcancaveis() -> void:
	var m = Mapa.new()
	var alc := {}
	for p in m.alcancaveis():
		alc[p] = true
	igual(m.cristais.size(), 14, "quantidade de cristais")
	for c in m.cristais:
		verdade(alc.has(c), "cristal fora do alcance em %s" % str(c))


func teste_imagem_dos_tiles() -> void:
	var img := Tiles.criar_imagem()
	igual(img.get_width(), Tiles.T * Tiles.QUANTIDADE, "largura do atlas")
	var ts := Tiles.criar_tileset()
	igual(ts.get_physics_layers_count(), 1, "camada de colisão")
