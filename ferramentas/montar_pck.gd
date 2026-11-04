extends SceneTree
## Junta o jogo num arquivo .pck sem abrir o editor (a VPS não tem memória para o editor).
##   godot --headless --path . -s ferramentas/montar_pck.gd -- exportar/web/index.pck

const PASTAS_FORA := ["testes", "docs", "publicar", "ferramentas", "exportar", "arte-original", ".git", ".godot"]
const EXTENSOES := ["gd", "tscn", "tres", "json", "godot", "png", "webp", "ogg", "wav"]


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var destino: String = args[0] if args.size() > 0 else "exportar/web/index.pck"
	var pacote := PCKPacker.new()
	if pacote.pck_start(destino) != OK:
		push_error("Não consegui criar " + destino)
		quit(1)
		return
	var arquivos := _listar("res://")
	for caminho in arquivos:
		pacote.add_file(caminho, ProjectSettings.globalize_path(caminho))
	pacote.flush()
	print("%d arquivos em %s" % [arquivos.size(), destino])
	quit(0)


func _listar(pasta: String) -> Array[String]:
	var lista: Array[String] = []
	var d := DirAccess.open(pasta)
	if d == null:
		return lista
	for nome in d.get_directories():
		if nome in PASTAS_FORA or FileAccess.file_exists(pasta.path_join(nome).path_join(".gdignore")):
			continue
		lista.append_array(_listar(pasta.path_join(nome)))
	for nome in d.get_files():
		if nome.get_extension() in EXTENSOES:
			lista.append(pasta.path_join(nome))
	return lista
