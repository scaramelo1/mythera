extends SceneTree
## Herói andando no mapa da vila, sem janela:
##   godot --headless --path . -s testes/teste_vila.gd
## Anda em direções sorteadas por 20 s e confere que nunca entra em lugar bloqueado.

var erros: Array[String] = []


func _init() -> void:
	_rodar.call_deferred()


func _rodar() -> void:
	var vila = load("res://scripts/vila.gd").new()
	root.add_child(vila)
	await _quadros(5)
	var heroi = vila.heroi
	_conferir(vila.tamanho == Vector2i(1536, 1024), "tamanho do mapa: %s" % str(vila.tamanho))
	_conferir(vila.andavel(heroi.position), "o herói começa num lugar andável")
	_conferir(vila.formas_de_colisao > 50, "paredes invisíveis montadas (%d)" % vila.formas_de_colisao)

	# para cima a partir do início: a fonte bloqueia
	Input.action_press("cima")
	await _quadros(120)
	Input.action_release("cima")
	_conferir(heroi.position.y < vila.inicio.y - 30.0, "devia subir pela praça")
	_conferir(heroi.position.y > 486.0, "a fonte devia bloquear (y = %.0f)" % heroi.position.y)

	# passeio sorteado
	var r := RandomNumberGenerator.new()
	r.seed = 3
	var direcoes := ["cima", "baixo", "esquerda", "direita"]
	var fora := 0
	var percorrido := 0.0
	var antes: Vector2 = heroi.position
	for passo in 40:
		var a: String = direcoes[r.randi_range(0, 3)]
		var b: String = direcoes[r.randi_range(0, 3)]
		Input.action_press(a)
		Input.action_press(b)
		for q in 30:
			await physics_frame
			if not vila.andavel(heroi.position + Vector2(0, -4)):
				fora += 1
			percorrido += heroi.position.distance_to(antes)
			antes = heroi.position
		Input.action_release(a)
		Input.action_release(b)
	_conferir(fora == 0, "o herói entrou em lugar bloqueado %d vezes" % fora)
	_conferir(percorrido > 300.0, "o herói devia andar bastante (%.0f px)" % percorrido)

	for e in erros:
		print("  FALHOU ", e)
	print("teste da vila: %s" % ("ok" if erros.is_empty() else "%d falhas" % erros.size()))
	quit(1 if erros.size() > 0 else 0)


func _quadros(n: int) -> void:
	for i in n:
		await physics_frame


func _conferir(cond: bool, msg: String) -> void:
	if not cond:
		erros.append(msg)
