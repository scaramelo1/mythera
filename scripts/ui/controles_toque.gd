extends Control
## Controles na tela para celular e tablet (navegador, Android e iPhone):
## analógico à esquerda e botões de ação à direita. Vários dedos ao mesmo tempo.
## Aparece sozinho quando a tela é tocada.

const RAIO_ANALOGICO := 80.0
const RAIO_BOTAO := 44.0

const BOTOES := [
	{"acao": "atacar", "texto": "Atacar", "pos": Vector2(-90, -100), "raio": 54.0},
	{"acao": "capturar", "texto": "Núcleo", "pos": Vector2(-220, -80)},
	{"acao": "esquivar", "texto": "Esquiva", "pos": Vector2(-110, -230)},
	{"acao": "comandar", "texto": "Comandar", "pos": Vector2(-235, -200)},
]

var hud = null
var dedo_analogico := -1
var centro_analogico := Vector2.ZERO
var ponta_analogico := Vector2.ZERO
var dedos_botoes := {}


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = DisplayServer.is_touchscreen_available()


func _input(event: InputEvent) -> void:
	if hud != null and hud.painel_aberto():
		return
	if event is InputEventScreenTouch:
		visible = true
		if event.pressed:
			_tocou(event.index, event.position)
		else:
			_soltou(event.index)
		queue_redraw()
	elif event is InputEventScreenDrag and event.index == dedo_analogico:
		ponta_analogico = event.position
		var v := (ponta_analogico - centro_analogico).limit_length(RAIO_ANALOGICO) / RAIO_ANALOGICO
		_forca("direita", v.x)
		_forca("esquerda", -v.x)
		_forca("baixo", v.y)
		_forca("cima", -v.y)
		queue_redraw()


func _tocou(dedo: int, pos: Vector2) -> void:
	for b in BOTOES:
		if pos.distance_to(size + b.pos) <= b.get("raio", RAIO_BOTAO) * 1.15:
			dedos_botoes[dedo] = b.acao
			Input.action_press(b.acao)
			return
	if pos.x < size.x * 0.5 and pos.y > 140 and dedo_analogico == -1:
		dedo_analogico = dedo
		centro_analogico = pos
		ponta_analogico = pos


func _soltou(dedo: int) -> void:
	if dedos_botoes.has(dedo):
		Input.action_release(dedos_botoes[dedo])
		dedos_botoes.erase(dedo)
	elif dedo == dedo_analogico:
		dedo_analogico = -1
		for acao in ["cima", "baixo", "esquerda", "direita"]:
			Input.action_release(acao)


func _forca(acao: String, valor: float) -> void:
	if valor > 0.08:
		Input.action_press(acao, valor)
	else:
		Input.action_release(acao)


func _draw() -> void:
	var fonte := ThemeDB.fallback_font
	if dedo_analogico != -1:
		draw_circle(centro_analogico, RAIO_ANALOGICO, Color(1, 1, 1, 0.12))
		draw_arc(centro_analogico, RAIO_ANALOGICO, 0, TAU, 48, Color(1, 1, 1, 0.4), 3.0)
		draw_circle(centro_analogico + (ponta_analogico - centro_analogico).limit_length(RAIO_ANALOGICO), 32.0, Color(1, 1, 1, 0.45))
	else:
		draw_arc(Vector2(140, size.y - 140), RAIO_ANALOGICO, 0, TAU, 48, Color(1, 1, 1, 0.25), 3.0)
	for b in BOTOES:
		var c: Vector2 = size + b.pos
		var r: float = b.get("raio", RAIO_BOTAO)
		var apertado: bool = b.acao in dedos_botoes.values()
		draw_circle(c, r, Color(1, 1, 1, 0.35 if apertado else 0.16))
		draw_arc(c, r, 0, TAU, 40, Color(1, 1, 1, 0.5), 2.0)
		var w := fonte.get_string_size(b.texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
		draw_string(fonte, c + Vector2(-w / 2.0, 5), b.texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1, 1, 1, 0.9))


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
