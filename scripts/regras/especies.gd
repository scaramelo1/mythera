extends RefCounted
## Lê as espécies de dados/especies.json (dados fixos de cada espécie).

const CAMINHO := "res://dados/especies.json"

static var _cache: Dictionary = {}


static func todas() -> Dictionary:
	if _cache.is_empty():
		var texto := FileAccess.get_file_as_string(CAMINHO)
		var dados = JSON.parse_string(texto)
		if typeof(dados) != TYPE_DICTIONARY:
			push_error("Não consegui ler %s" % CAMINHO)
			return {}
		dados.erase("_sobre")
		_cache = dados
	return _cache


static func obter(id: String) -> Dictionary:
	return todas().get(id, {})


static func existe(id: String) -> bool:
	return todas().has(id)
