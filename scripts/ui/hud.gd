extends CanvasLayer
## Interface: vida e experiência do herói e da companheira, Núcleos, área do mapa,
## mensagens, painel da equipe (Tab) e controles de toque.

const Mapa = preload("res://scripts/mundo/mapa.gd")
const Experiencia = preload("res://scripts/regras/experiencia.gd")
const Desenho = preload("res://scripts/arte/desenho.gd")
const ControlesToque = preload("res://scripts/ui/controles_toque.gd")

const DURACAO_MENSAGEM := 5.0

var jogo: Node = null
var _tela: Control
var _painel: PanelContainer
var _lista: VBoxContainer
var _mensagens: Array = []  # [texto, tempo]
var _toque: Control


func _ready() -> void:
	layer = 10
	_tela = Control.new()
	_tela.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tela.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tela.draw.connect(_desenhar)
	add_child(_tela)

	var botao := Button.new()
	botao.text = "Equipe (Tab)"
	botao.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	botao.position = Vector2(-150, 70)
	botao.size = Vector2(130, 34)
	botao.focus_mode = Control.FOCUS_NONE
	botao.pressed.connect(alternar_painel)
	add_child(botao)

	_toque = ControlesToque.new()
	_toque.hud = self
	add_child(_toque)

	_montar_painel()
	jogo.mensagem_enviada.connect(func(t): _mensagens.append([t, DURACAO_MENSAGEM]))


func painel_aberto() -> bool:
	return _painel.visible


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("equipe"):
		alternar_painel()
	elif Input.is_action_just_pressed("menu") and _painel.visible:
		alternar_painel()
	for m in _mensagens:
		m[1] -= delta
	_mensagens = _mensagens.filter(func(m): return m[1] > 0.0)
	if _mensagens.size() > 4:
		_mensagens = _mensagens.slice(_mensagens.size() - 4)
	_tela.queue_redraw()


# ---- desenho do topo e das mensagens ----

func _barra(pos: Vector2, largura: float, prop: float, cor: Color, texto: String) -> void:
	_tela.draw_rect(Rect2(pos, Vector2(largura, 14)), Color(0, 0, 0, 0.55))
	_tela.draw_rect(Rect2(pos + Vector2(2, 2), Vector2((largura - 4) * clampf(prop, 0, 1), 10)), cor)
	_texto(pos + Vector2(6, 11), texto, 11, Color.WHITE)


func _texto(pos: Vector2, texto: String, tam: int, cor: Color) -> void:
	var f := ThemeDB.fallback_font
	_tela.draw_string_outline(f, pos, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, 4, Color(0, 0, 0, 0.75))
	_tela.draw_string(f, pos, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, cor)


func _desenhar() -> void:
	var h = jogo.heroi_dados
	var x := 16.0
	var y := 14.0
	_texto(Vector2(x, y + 14), "Vinculador · Nv %d" % h.nivel, 16, Color.WHITE)
	_barra(Vector2(x, y + 22), 220, float(h.vida) / h.vida_maxima(), Color("e5483b"), "Vida %d/%d" % [h.vida, h.vida_maxima()])
	var prox := Experiencia.para_proximo(h.nivel)
	_barra(Vector2(x, y + 40), 220, float(h.xp) / prox if prox > 0 else 1.0, Color("4aa8ff"), "XP %d/%d" % [h.xp, prox])

	y += 66
	var c = jogo.companheira
	if c != null and is_instance_valid(c):
		var d = c.dados
		_tela.draw_circle(Vector2(x + 6, y + 9), 6, Desenho.cor_elemento(d.elemento()))
		_texto(Vector2(x + 18, y + 14), "%s · Nv %d" % [d.nome(), d.nivel], 14, Color("ffe08a"))
		_barra(Vector2(x, y + 20), 180, d.proporcao_vida(), Color("5bd65b"), "Vida %d/%d" % [d.vida_atual, d.vida_maxima()])
		var px := Experiencia.para_proximo(d.nivel)
		_barra(Vector2(x, y + 38), 180, float(d.xp) / px if px > 0 else 1.0, Color("4aa8ff"), "XP %d/%d" % [d.xp, px])
	else:
		_texto(Vector2(x, y + 14), "Sem criatura: capture uma com o Núcleo (G)", 13, Color("ffe08a"))

	# canto direito: núcleos, coleção e área
	var largura := _tela.size.x
	var col = jogo.colecao
	var linhas := [
		"Núcleos de Vínculo: %d" % jogo.nucleos,
		"Capturadas: %d · Espécies vistas: %d" % [col.total(), col.vistas.size()],
		Mapa.ZONAS[jogo.mapa.zona_de(Mapa.em_tile(jogo.heroi.position))].nome,
	]
	for i in linhas.size():
		var f := ThemeDB.fallback_font
		var w := f.get_string_size(linhas[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
		_texto(Vector2(largura - w - 16, 28 + i * 18), linhas[i], 14, Color("8fe3ff") if i == 0 else Color.WHITE)

	# mensagens embaixo, no meio
	var base := _tela.size.y - 40.0
	for i in _mensagens.size():
		var m = _mensagens[_mensagens.size() - 1 - i]
		var f := ThemeDB.fallback_font
		var w := f.get_string_size(m[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
		var alfa := clampf(m[1], 0.0, 1.0)
		_texto(Vector2((largura - w) / 2.0, base - i * 22), m[0], 15, Color(1, 1, 1, alfa))

	if not _toque.visible:
		_texto(Vector2(16, _tela.size.y - 14),
			"WASD andar · Espaço atacar · Shift esquivar · G Núcleo · F comandar · Tab equipe · fogueira cura e salva", 12, Color(1, 1, 1, 0.8))


# ---- painel da equipe ----

func _montar_painel() -> void:
	_painel = PanelContainer.new()
	_painel.visible = false
	_painel.set_anchors_preset(Control.PRESET_CENTER)
	_painel.custom_minimum_size = Vector2(560, 360)
	_painel.position = Vector2(-280, -180)
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.08, 0.1, 0.14, 0.94)
	estilo.set_corner_radius_all(10)
	estilo.set_content_margin_all(16)
	_painel.add_theme_stylebox_override("panel", estilo)
	var rolagem := ScrollContainer.new()
	rolagem.custom_minimum_size = Vector2(528, 328)
	_lista = VBoxContainer.new()
	_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rolagem.add_child(_lista)
	_painel.add_child(rolagem)
	add_child(_painel)


func alternar_painel() -> void:
	_painel.visible = not _painel.visible
	if _painel.visible:
		_preencher_painel()


func _preencher_painel() -> void:
	for filho in _lista.get_children():
		filho.queue_free()
	var col = jogo.colecao
	_rotulo("Equipe (%d/6)" % col.equipe.size(), 20, Color.WHITE)
	if col.equipe.is_empty():
		_rotulo("Nenhuma criatura ainda. Enfraqueça uma criatura selvagem e lance o Núcleo (G).", 14, Color("cccccc"))
	for i in col.equipe.size():
		var c = col.equipe[i]
		var linha := HBoxContainer.new()
		var r := Label.new()
		r.text = "%s%s · Nv %d · %s · Vida %d/%d · %s" % ["★ " if i == 0 else "", c.nome(), c.nivel,
			c.elemento(), c.vida_atual, c.vida_maxima(), c.especie().get("mundo", {}).get("golpe", {}).get("nome", "")]
		r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r.add_theme_color_override("font_color", Desenho.cor_elemento(c.elemento()).lightened(0.3))
		linha.add_child(r)
		if i > 0 and not c.desmaiada():
			var b := Button.new()
			b.text = "Ativar"
			b.focus_mode = Control.FOCUS_NONE
			b.pressed.connect(func():
				jogo.ativar(c)
				_preencher_painel())
			linha.add_child(b)
		elif c.desmaiada():
			var d := Label.new()
			d.text = "desmaiada"
			linha.add_child(d)
		_lista.add_child(linha)
	if not col.reserva.is_empty():
		_rotulo("Reserva: %d criaturas" % col.reserva.size(), 16, Color("cccccc"))
	var fechar := Button.new()
	fechar.text = "Fechar"
	fechar.focus_mode = Control.FOCUS_NONE
	fechar.pressed.connect(alternar_painel)
	_lista.add_child(fechar)


func _rotulo(texto: String, tam: int, cor: Color) -> void:
	var l := Label.new()
	l.text = texto
	l.autowrap_mode = TextServer.AUTOWRAP_WORD
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", cor)
	_lista.add_child(l)
