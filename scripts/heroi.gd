extends CharacterBody3D
## Herói em terceira pessoa: andar, pular, esquivar e girar a câmera.
## Mouse no PC, controle (analógico direito) e arrasto na tela do celular.

const VELOCIDADE := 6.0
const ACELERACAO := 40.0
const PULO := 5.5
const ESQUIVA_VELOCIDADE := 15.0
const ESQUIVA_DURACAO := 0.22
const ESQUIVA_ESPERA := 0.7
const SENSIBILIDADE_MOUSE := 0.003
const SENSIBILIDADE_TOQUE := 0.006
const SENSIBILIDADE_CONTROLE := 2.5
const CAMERA_MIN := deg_to_rad(-65.0)
const CAMERA_MAX := deg_to_rad(25.0)

## Modelos 3D do herói (Quaternius, CC0). Sem o modelo importado (ex.: testes na VPS), fica o boneco simples.
const MODELOS := {
	"masculino": "res://assets/modelos/heroi/heroi_masculino.gltf",
	"feminino": "res://assets/modelos/heroi/heroi_feminino.gltf",
}
## Nomes das animações que o herói procura no modelo (entram quando chegar o pacote de animações).
const ANIMACOES := {
	"parado": ["parado", "Idle", "Idle_Loop"],
	"andar": ["andar", "Walk", "Walk_Loop", "Jog_Fwd_Loop"],
	"pular": ["pular", "Jump", "Jump_Loop"],
	"esquivar": ["esquivar", "Roll", "Dodge"],
}

@export_enum("masculino", "feminino") var aparencia := "masculino"

@onready var pivo: Node3D = $Pivo
@onready var braco: SpringArm3D = $Pivo/Braco
@onready var corpo: Node3D = $Corpo

var gravidade: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var tempo_esquiva := 0.0
var espera_esquiva := 0.0
var direcao_esquiva := Vector3.ZERO
var esquivando := false
var animacao: AnimationPlayer = null


func _ready() -> void:
	add_to_group("camera_toque")
	braco.add_excluded_object(get_rid())
	braco.rotation.x = deg_to_rad(-15.0)
	_carregar_modelo()


func _carregar_modelo() -> void:
	var caminho: String = MODELOS.get(aparencia, "")
	if caminho == "" or not ResourceLoader.exists(caminho):
		return
	var cena := load(caminho) as PackedScene
	if cena == null:
		return
	var modelo := cena.instantiate()
	modelo.name = "Modelo"
	modelo.rotation.y = PI  # o modelo olha para +Z; o herói olha para -Z
	corpo.add_child(modelo)
	for parte in ["Tronco", "Cabeca", "Mochila"]:
		corpo.get_node(parte).visible = false
	animacao = modelo.find_child("AnimationPlayer", true, false) as AnimationPlayer


func _tocar(estado: String) -> void:
	if animacao == null:
		return
	for nome in ANIMACOES.get(estado, []):
		if animacao.has_animation(nome):
			if animacao.current_animation != nome:
				animacao.play(nome, 0.15)
			return


func _unhandled_input(event: InputEvent) -> void:
	# Toques viram cliques "emulados"; esses são tratados pelos controles de toque.
	if event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		girar_camera(event.relative * SENSIBILIDADE_MOUSE)
	elif event is InputEventMouseButton and event.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("menu"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


## Chamado pelo mouse, pelo controle e pelo arrasto na tela (grupo "camera_toque").
func girar_camera(delta_tela: Vector2) -> void:
	pivo.rotate_y(-delta_tela.x)
	braco.rotation.x = clampf(braco.rotation.x - delta_tela.y, CAMERA_MIN, CAMERA_MAX)


func girar_camera_toque(relativo: Vector2) -> void:
	girar_camera(relativo * SENSIBILIDADE_TOQUE)


func _physics_process(delta: float) -> void:
	var analogico_direito := Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
	if analogico_direito.length() > 0.2:
		girar_camera(analogico_direito * SENSIBILIDADE_CONTROLE * delta)

	if not is_on_floor():
		velocity.y -= gravidade * delta
	espera_esquiva = maxf(espera_esquiva - delta, 0.0)

	var entrada := Input.get_vector("esquerda", "direita", "frente", "tras")
	var direcao := pivo.global_basis * Vector3(entrada.x, 0.0, entrada.y)
	direcao.y = 0.0
	direcao = direcao.normalized() * minf(entrada.length(), 1.0)

	if esquivando:
		tempo_esquiva -= delta
		velocity.x = direcao_esquiva.x * ESQUIVA_VELOCIDADE
		velocity.z = direcao_esquiva.z * ESQUIVA_VELOCIDADE
		if tempo_esquiva <= 0.0:
			esquivando = false
	else:
		if Input.is_action_just_pressed("esquivar") and espera_esquiva <= 0.0:
			_comecar_esquiva(direcao)
		var alvo := direcao * VELOCIDADE
		velocity.x = move_toward(velocity.x, alvo.x, ACELERACAO * delta)
		velocity.z = move_toward(velocity.z, alvo.z, ACELERACAO * delta)
		if Input.is_action_just_pressed("pular") and is_on_floor():
			velocity.y = PULO

	var plano := Vector3(velocity.x, 0.0, velocity.z)
	if plano.length() > 0.3:
		corpo.rotation.y = lerp_angle(corpo.rotation.y, atan2(-plano.x, -plano.z), 12.0 * delta)

	move_and_slide()

	if esquivando:
		_tocar("esquivar")
	elif not is_on_floor():
		_tocar("pular")
	elif plano.length() > 0.5:
		_tocar("andar")
	else:
		_tocar("parado")

	if global_position.y < -30.0:
		_voltar_ao_inicio()


func _comecar_esquiva(direcao: Vector3) -> void:
	if direcao.length() < 0.1:
		direcao = -corpo.global_basis.z
	direcao_esquiva = Vector3(direcao.x, 0.0, direcao.z).normalized()
	esquivando = true
	tempo_esquiva = ESQUIVA_DURACAO
	espera_esquiva = ESQUIVA_ESPERA


func _voltar_ao_inicio() -> void:
	global_position = Vector3(0.0, 2.0, 0.0)
	velocity = Vector3.ZERO
