extends SceneTree
## Joga sozinho o primeiro modo, sem janela:
##   godot --headless --path . -s testes/teste_jogo.gd

const Jogo = preload("res://scripts/jogo.gd")
const Criatura = preload("res://scripts/regras/criatura.gd")
const Mapa = preload("res://scripts/mundo/mapa.gd")

const SAVE := "user://teste_jogo.save"

var erros: Array[String] = []
var jogo = null


func _init() -> void:
	_rodar.call_deferred()


func _novo_jogo(usar_save: bool, nascer: bool):
	var j = Jogo.new()
	j.caminho_save = SAVE
	j.usar_save = usar_save
	j.nascer_automatico = nascer
	root.add_child(j)
	await _quadros(5)
	return j


func _rodar() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))

	# 1. o mundo nasce povoado
	jogo = await _novo_jogo(false, true)
	await _quadros(10)
	_conferir(jogo.selvagens.size() >= 18, "o mapa devia ter criaturas (tem %d)" % jogo.selvagens.size())
	jogo.queue_free()
	await _quadros(2)

	# daqui para frente, sem criaturas nascendo sozinhas (teste controlado)
	jogo = await _novo_jogo(true, false)
	var heroi = jogo.heroi
	_conferir(jogo.companheira == null, "começa sem criatura")
	_conferir(jogo.nucleos == 10, "começa com 10 núcleos")

	# 2. andar
	var x0: float = heroi.position.x
	Input.action_press("direita")
	await _quadros(30)
	Input.action_release("direita")
	_conferir(heroi.position.x > x0 + 40.0, "herói devia andar para a direita (%.0f → %.0f)" % [x0, heroi.position.x])
	heroi.position = Mapa.em_pixels(Vector2i(46, 36))
	await _quadros(2)

	# 3. bater até desmaiar dá experiência
	var alvo = jogo.nascer("pradaria", heroi.position + Vector2(24, 0), "mosshell", 1)
	await _quadros(2)
	heroi.olhar = Vector2.RIGHT
	for i in 40:
		if not is_instance_valid(alvo) or alvo.dados.desmaiada():
			break
		heroi.atacar()
		await _quadros(30)
	_conferir(not is_instance_valid(alvo) or alvo.dados.desmaiada(), "a criatura devia desmaiar com os golpes")
	_conferir(jogo.heroi_dados.xp > 0 or jogo.heroi_dados.nivel > 1, "herói devia ganhar experiência")
	_conferir(jogo.colecao.vistas.has("mosshell"), "Mosshell devia entrar nas vistas")
	await _quadros(60)

	# 4. captura que dá certo vira companheira
	var aquori = jogo.nascer("pradaria", heroi.position + Vector2(60, 0), "aquori", 2)
	await _quadros(2)
	jogo.forcar_captura = 1
	jogo.lancar_nucleo()
	_conferir(jogo.nucleos == 9, "lançar gasta 1 núcleo")
	await _quadros(120)
	_conferir(jogo.colecao.total() == 1, "devia ter capturado o Aquori")
	_conferir(not is_instance_valid(aquori), "o Aquori selvagem devia sumir do mapa")
	_conferir(jogo.companheira != null and jogo.companheira.dados.especie_id == "aquori", "Aquori devia virar companheira")

	# 5. captura que falha
	var flarin = jogo.nascer("pradaria", heroi.position + Vector2(-60, 0), "flarin", 1)
	await _quadros(2)
	jogo.forcar_captura = -1
	jogo.lancar_nucleo()
	await _quadros(120)
	_conferir(jogo.colecao.total() == 1, "a captura falha não devia adicionar")
	_conferir(_tem_mensagem("escapou"), "devia avisar que escapou")

	# 6. a companheira luta (comandar)
	if is_instance_valid(flarin):
		flarin.queue_free()
	await _quadros(2)
	var mosshell = jogo.nascer("pradaria", heroi.position + Vector2(0, 50), "mosshell", 1)
	await _quadros(2)
	jogo.comandar()
	var vida_antes: int = mosshell.dados.vida_atual
	for i in 600:
		await physics_frame
		if not is_instance_valid(mosshell) or mosshell.dados.vida_atual < vida_antes:
			break
	_conferir(not is_instance_valid(mosshell) or mosshell.dados.vida_atual < vida_antes, "a companheira devia atacar o alvo")

	# 7. evolução: Flarin nível 17 ativo, ganha experiência e vira Flarvex
	var f = Criatura.nova("flarin", 17, jogo.rng)
	jogo.colecao.adicionar(f)
	jogo.ativar(f)
	await _quadros(2)
	_conferir(jogo.companheira.dados == f, "Flarin devia estar ativo")
	jogo.dar_experiencia(5000, heroi.position)
	_conferir(f.especie_id == "flarvex", "Flarin devia evoluir no 18 (está %s nível %d)" % [f.especie_id, f.nivel])
	_conferir(_tem_mensagem("evoluiu"), "devia avisar a evolução")

	# 8. fogueira cura
	jogo.heroi_dados.receber_dano(20)
	heroi.position = Mapa.em_pixels(Mapa.CENTRO) + Vector2(0, 40)
	await _quadros(5)
	_conferir(jogo.heroi_dados.vida == jogo.heroi_dados.vida_maxima(), "fogueira devia curar o herói")

	# 9. sem núcleos
	jogo.nucleos = 0
	jogo.lancar_nucleo()
	_conferir(_tem_mensagem("Sem Núcleos"), "devia avisar que acabaram os núcleos")
	jogo.nucleos = 4

	# 10. salvar e carregar
	jogo.salvar()
	var total: int = jogo.colecao.total()
	var nivel: int = jogo.heroi_dados.nivel
	jogo.queue_free()
	await _quadros(2)
	jogo = await _novo_jogo(true, false)
	_conferir(jogo.colecao.total() == total, "coleção devia voltar igual (%d)" % jogo.colecao.total())
	_conferir(jogo.heroi_dados.nivel == nivel, "nível do herói devia voltar")
	_conferir(jogo.nucleos == 4, "núcleos deviam voltar")
	_conferir(jogo.companheira != null, "companheira devia voltar ao carregar")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))
	for e in erros:
		print("  FALHOU ", e)
	print("teste do jogo: %s" % ("ok" if erros.is_empty() else "%d falhas" % erros.size()))
	quit(1 if erros.size() > 0 else 0)


func _tem_mensagem(trecho: String) -> bool:
	for m in jogo.mensagens:
		if trecho.to_lower() in m.to_lower():
			return true
	return false


func _quadros(n: int) -> void:
	for i in n:
		await physics_frame


func _conferir(cond: bool, msg: String) -> void:
	if not cond:
		erros.append(msg)
