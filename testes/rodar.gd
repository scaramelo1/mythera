extends SceneTree
## Roda os testes das regras sem abrir o jogo:
##   godot --headless --path . -s testes/rodar.gd
## Cada função que começa com "teste_" nos arquivos abaixo é um teste.

const ARQUIVOS := [
	"res://testes/teste_regras.gd",
	"res://testes/teste_captura.gd",
]


func _init() -> void:
	var total := 0
	var falhas := 0
	for caminho in ARQUIVOS:
		var script: Script = load(caminho)
		for metodo in script.get_script_method_list():
			var nome: String = metodo.name
			if not nome.begins_with("teste_"):
				continue
			var t = script.new()
			total += 1
			t.call(nome)
			if t.erros.is_empty():
				print("  ok   ", nome)
			else:
				falhas += 1
				print("  FALHOU ", nome)
				for e in t.erros:
					print("         ", e)
	print("\n%d testes, %d falharam" % [total, falhas])
	quit(1 if falhas > 0 else 0)
