extends RefCounted
## Salva e carrega o jogo em JSON (GDD, seção 11: SG_MytheraSave).
## Grava num arquivo temporário e depois troca, para não corromper se o jogo fechar no meio.

const VERSAO := 1
const CAMINHO_PADRAO := "user://mythera.save"


static func salvar(dados: Dictionary, caminho: String = CAMINHO_PADRAO) -> bool:
	var completo := dados.duplicate(true)
	completo["versao"] = VERSAO
	var temporario := caminho + ".tmp"
	var arquivo := FileAccess.open(temporario, FileAccess.WRITE)
	if arquivo == null:
		return false
	arquivo.store_string(JSON.stringify(completo))
	arquivo.close()
	if FileAccess.file_exists(caminho):
		DirAccess.remove_absolute(caminho)
	return DirAccess.rename_absolute(temporario, caminho) == OK


## Devolve {} se não houver jogo salvo ou se o arquivo estiver estragado.
static func carregar(caminho: String = CAMINHO_PADRAO) -> Dictionary:
	if not FileAccess.file_exists(caminho):
		return {}
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(caminho)) != OK:
		return {}
	if typeof(json.data) != TYPE_DICTIONARY:
		return {}
	return json.data


static func apagar(caminho: String = CAMINHO_PADRAO) -> void:
	if FileAccess.file_exists(caminho):
		DirAccess.remove_absolute(caminho)
