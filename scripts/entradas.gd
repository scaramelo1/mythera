extends Node
## Registra os controles do jogo (teclado, mouse e controle).
## Os comandos seguem a seção 6 do GDD. O toque na tela fica em scripts/ui/controles_toque.gd.

const TECLAS := {
	"frente": [KEY_W, KEY_UP],
	"tras": [KEY_S, KEY_DOWN],
	"esquerda": [KEY_A, KEY_LEFT],
	"direita": [KEY_D, KEY_RIGHT],
	"pular": [KEY_SPACE],
	"esquivar": [KEY_SHIFT],
	"ataque_especial": [KEY_Q],
	"interagir": [KEY_E],
	"invocar": [KEY_R],
	"comandar": [KEY_F],
	"capturar": [KEY_G],
	"inventario": [KEY_TAB],
	"menu": [KEY_ESCAPE],
}

const BOTOES_CONTROLE := {
	"pular": JOY_BUTTON_A,
	"esquivar": JOY_BUTTON_B,
	"interagir": JOY_BUTTON_X,
	"capturar": JOY_BUTTON_Y,
	"invocar": JOY_BUTTON_LEFT_SHOULDER,
	"comandar": JOY_BUTTON_RIGHT_SHOULDER,
	"inventario": JOY_BUTTON_BACK,
	"menu": JOY_BUTTON_START,
}

const EIXOS_CONTROLE := {
	"frente": [JOY_AXIS_LEFT_Y, -1.0],
	"tras": [JOY_AXIS_LEFT_Y, 1.0],
	"esquerda": [JOY_AXIS_LEFT_X, -1.0],
	"direita": [JOY_AXIS_LEFT_X, 1.0],
}


func _ready() -> void:
	for acao in TECLAS:
		_garantir(acao)
		for tecla in TECLAS[acao]:
			var ev := InputEventKey.new()
			ev.physical_keycode = tecla
			InputMap.action_add_event(acao, ev)
	for acao in BOTOES_CONTROLE:
		var ev := InputEventJoypadButton.new()
		ev.button_index = BOTOES_CONTROLE[acao]
		InputMap.action_add_event(acao, ev)
	for acao in EIXOS_CONTROLE:
		var ev := InputEventJoypadMotion.new()
		ev.axis = EIXOS_CONTROLE[acao][0]
		ev.axis_value = EIXOS_CONTROLE[acao][1]
		InputMap.action_add_event(acao, ev)
	_garantir("ataque")
	var clique := InputEventMouseButton.new()
	clique.button_index = MOUSE_BUTTON_LEFT
	InputMap.action_add_event("ataque", clique)
	var gatilho := InputEventJoypadMotion.new()
	gatilho.axis = JOY_AXIS_TRIGGER_RIGHT
	gatilho.axis_value = 1.0
	InputMap.action_add_event("ataque", gatilho)


func _garantir(acao: String) -> void:
	if not InputMap.has_action(acao):
		InputMap.add_action(acao, 0.2)
