extends Control
## Controles na tela para celular e tablet (navegador, Android e iPhone):
## analógico à esquerda, arrasto à direita para girar a câmera e botões de ação.
## Aceita vários dedos ao mesmo tempo. Aparece sozinho quando a tela é tocada.

const RAIO_ANALOGICO := 90.0
const RAIO_BOTAO := 46.0

const BOTOES := [
	{"acao": "pular", "texto": "Pular", "pos": Vector2(-90, -110)},
	{"acao": "esquivar", "texto": "Esquiva", "pos": Vector2(-200, -70)},
	{"acao": "ataque", "texto": "Atacar", "pos": Vector2(-120, -230)},
	{"acao": "capturar", "texto": "Capturar", "pos": Vector2(-240, -190)},
	{"acao": "interagir", "texto": "Usar", "pos": Vector2(-330, -80)},
]

var dedo_analogico := -1
var centro_analogico := Vector2.ZERO
var ponta_analogico := Vector2.ZERO
var dedo_camera := -1
var dedos_botoes := {}  # índice do dedo -> ação


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = DisplayServer.is_touchscreen_available()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if not visible:
			visible = true
		if event.pressed:
			_tocou(event.index, event.position)
		else:
			_soltou(event.index)
		queue_redraw()
	elif event is InputEventScreenDrag:
		if event.index == dedo_analogico:
			ponta_analogico = event.position
			_aplicar_analogico()
			queue_redraw()
		elif event.index == dedo_camera:
			get_tree().call_group("camera_toque", "girar_camera_toque", event.relative)


func _tocou(dedo: int, pos: Vector2) -> void:
	for botao in BOTOES:
		if pos.distance_to(_posicao_botao(botao)) <= RAIO_BOTAO * 1.15:
			dedos_botoes[dedo] = botao.acao
			Input.action_press(botao.acao)
			return
	if pos.x < size.x * 0.45 and dedo_analogico == -1:
		dedo_analogico = dedo
		centro_analogico = pos
		ponta_analogico = pos
	elif dedo_camera == -1:
		dedo_camera = dedo


func _soltou(dedo: int) -> void:
	if dedos_botoes.has(dedo):
		Input.action_release(dedos_botoes[dedo])
		dedos_botoes.erase(dedo)
	elif dedo == dedo_analogico:
		dedo_analogico = -1
		for acao in ["frente", "tras", "esquerda", "direita"]:
			Input.action_release(acao)
	elif dedo == dedo_camera:
		dedo_camera = -1


func _aplicar_analogico() -> void:
	var v := (ponta_analogico - centro_analogico).limit_length(RAIO_ANALOGICO) / RAIO_ANALOGICO
	_forca("direita", v.x)
	_forca("esquerda", -v.x)
	_forca("tras", v.y)
	_forca("frente", -v.y)


func _forca(acao: String, valor: float) -> void:
	if valor > 0.05:
		Input.action_press(acao, valor)
	else:
		Input.action_release(acao)


func _posicao_botao(botao: Dictionary) -> Vector2:
	return size + botao.pos


func _draw() -> void:
	var fonte := get_theme_default_font()
	if dedo_analogico != -1:
		draw_circle(centro_analogico, RAIO_ANALOGICO, Color(1, 1, 1, 0.12))
		draw_arc(centro_analogico, RAIO_ANALOGICO, 0, TAU, 48, Color(1, 1, 1, 0.4), 3.0)
		var ponta := centro_analogico + (ponta_analogico - centro_analogico).limit_length(RAIO_ANALOGICO)
		draw_circle(ponta, 36.0, Color(1, 1, 1, 0.45))
	else:
		var canto := Vector2(150, size.y - 150)
		draw_arc(canto, RAIO_ANALOGICO, 0, TAU, 48, Color(1, 1, 1, 0.25), 3.0)
	for botao in BOTOES:
		var c := _posicao_botao(botao)
		var apertado: bool = botao.acao in dedos_botoes.values()
		draw_circle(c, RAIO_BOTAO, Color(1, 1, 1, 0.35 if apertado else 0.18))
		draw_arc(c, RAIO_BOTAO, 0, TAU, 40, Color(1, 1, 1, 0.5), 2.0)
		var largura := fonte.get_string_size(botao.texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
		draw_string(fonte, c + Vector2(-largura / 2.0, 6), botao.texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1, 1, 1, 0.9))


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
