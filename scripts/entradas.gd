extends Node
## Controles do jogo 2D: teclado, controle e (em scripts/ui/controles_toque.gd) toque na tela.

const TECLAS := {
	"cima": [KEY_W, KEY_UP],
	"baixo": [KEY_S, KEY_DOWN],
	"esquerda": [KEY_A, KEY_LEFT],
	"direita": [KEY_D, KEY_RIGHT],
	"atacar": [KEY_SPACE, KEY_J],
	"esquivar": [KEY_SHIFT, KEY_K],
	"capturar": [KEY_G, KEY_L],
	"comandar": [KEY_F],
	"interagir": [KEY_E],
	"equipe": [KEY_TAB, KEY_I],
	"menu": [KEY_ESCAPE],
}

const BOTOES_CONTROLE := {
	"atacar": JOY_BUTTON_A,
	"esquivar": JOY_BUTTON_B,
	"capturar": JOY_BUTTON_Y,
	"interagir": JOY_BUTTON_X,
	"comandar": JOY_BUTTON_RIGHT_SHOULDER,
	"equipe": JOY_BUTTON_BACK,
	"menu": JOY_BUTTON_START,
}

const EIXOS_CONTROLE := {
	"cima": [JOY_AXIS_LEFT_Y, -1.0],
	"baixo": [JOY_AXIS_LEFT_Y, 1.0],
	"esquerda": [JOY_AXIS_LEFT_X, -1.0],
	"direita": [JOY_AXIS_LEFT_X, 1.0],
}


func _ready() -> void:
	registrar()


## Pode ser chamado mais de uma vez (os testes chamam direto).
static func registrar() -> void:
	for acao in TECLAS:
		if InputMap.has_action(acao):
			continue
		InputMap.add_action(acao, 0.2)
		for tecla in TECLAS[acao]:
			var ev := InputEventKey.new()
			ev.physical_keycode = tecla
			InputMap.action_add_event(acao, ev)
		if BOTOES_CONTROLE.has(acao):
			var b := InputEventJoypadButton.new()
			b.button_index = BOTOES_CONTROLE[acao]
			InputMap.action_add_event(acao, b)
		if EIXOS_CONTROLE.has(acao):
			var m := InputEventJoypadMotion.new()
			m.axis = EIXOS_CONTROLE[acao][0]
			m.axis_value = EIXOS_CONTROLE[acao][1]
			InputMap.action_add_event(acao, m)
