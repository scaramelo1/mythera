extends SceneTree
## Abre o mapa de testes sem janela e simula os comandos do herói:
##   godot --headless --path . -s testes/teste_cena.gd

var erros: Array[String] = []


func _init() -> void:
	_rodar.call_deferred()


func _rodar() -> void:
	if not InputMap.has_action("frente"):
		root.add_child(load("res://scripts/entradas.gd").new())
		await process_frame
	var mapa: Node = load("res://cenas/mapa_testes.tscn").instantiate()
	root.add_child(mapa)
	var heroi: CharacterBody3D = mapa.get_node("Heroi")
	await _quadros(30)
	_conferir(heroi.is_on_floor(), "herói devia estar no chão")
	var inicio := heroi.global_position

	# câmera virada para o outro lado: "frente" deve seguir a câmera
	heroi.girar_camera(Vector2(PI, 0))
	Input.action_press("frente")
	await _quadros(60)
	Input.action_release("frente")
	var andou := heroi.global_position - inicio
	_conferir(andou.z > 4.0, "com a câmera virada, frente devia ir para +Z (andou %s)" % str(andou))
	_conferir(absf(heroi.global_position.y) < 0.2, "devia continuar no chão")

	# pulo
	await _quadros(20)
	Input.action_press("pular")
	await physics_frame
	Input.action_release("pular")
	var altura := 0.0
	for i in 40:
		await physics_frame
		altura = maxf(altura, heroi.global_position.y)
	_conferir(altura > 1.0, "pulo devia passar de 1 m (foi %.2f)" % altura)
	await _quadros(60)
	_conferir(heroi.is_on_floor(), "devia voltar ao chão")

	# esquiva parada: anda para onde o corpo olha
	var antes := heroi.global_position
	Input.action_press("esquivar")
	await physics_frame
	Input.action_release("esquivar")
	await _quadros(20)
	var esquiva := (heroi.global_position - antes).length()
	_conferir(esquiva > 2.0, "esquiva devia avançar mais de 2 m (foi %.2f)" % esquiva)

	# câmera não passa dos limites
	heroi.girar_camera(Vector2(0, 10))
	_conferir(heroi.braco.rotation.x >= heroi.CAMERA_MIN - 0.001, "câmera passou do limite de cima")

	for e in erros:
		print("  FALHOU ", e)
	print("teste da cena: %s" % ("ok" if erros.is_empty() else "%d falhas" % erros.size()))
	quit(1 if erros.size() > 0 else 0)


func _quadros(n: int) -> void:
	for i in n:
		await physics_frame


func _conferir(cond: bool, msg: String) -> void:
	if not cond:
		erros.append(msg)
