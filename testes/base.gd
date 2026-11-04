extends RefCounted
## Funções de conferência usadas pelos testes.

var erros: Array[String] = []


func igual(obtido, esperado, msg: String = "") -> void:
	if obtido != esperado:
		erros.append("%s: esperado %s, veio %s" % [msg, str(esperado), str(obtido)])


func perto(obtido: float, esperado: float, msg: String = "", margem: float = 0.0001) -> void:
	if absf(obtido - esperado) > margem:
		erros.append("%s: esperado %s, veio %s" % [msg, str(esperado), str(obtido)])


func verdade(cond: bool, msg: String) -> void:
	if not cond:
		erros.append(msg)


func rng(semente: int = 42) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = semente
	return r
