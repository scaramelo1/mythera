extends RefCounted
## Equipe (até 6) e reserva das criaturas capturadas.

const Criatura = preload("res://scripts/regras/criatura.gd")

const TAMANHO_EQUIPE := 6
const EQUIPE := "equipe"
const RESERVA := "reserva"

var equipe: Array = []
var reserva: Array = []
## Espécies já vistas e capturadas (registro de criaturas)
var vistas := {}
var capturadas := {}


## Coloca na equipe; se estiver cheia, vai para a reserva. Devolve para onde foi.
func adicionar(c) -> String:
	capturadas[c.especie_id] = true
	vistas[c.especie_id] = true
	if equipe.size() < TAMANHO_EQUIPE:
		equipe.append(c)
		return EQUIPE
	reserva.append(c)
	return RESERVA


func ver(especie_id: String) -> void:
	vistas[especie_id] = true


func total() -> int:
	return equipe.size() + reserva.size()


func buscar(id: String):
	for c in equipe + reserva:
		if c.id == id:
			return c
	return null


func para_dicionario() -> Dictionary:
	return {
		"equipe": equipe.map(func(c): return c.para_dicionario()),
		"reserva": reserva.map(func(c): return c.para_dicionario()),
		"vistas": vistas.keys(),
		"capturadas": capturadas.keys(),
	}


static func de_dicionario(d: Dictionary):
	var col = load("res://scripts/regras/colecao.gd").new()
	for x in d.get("equipe", []):
		col.equipe.append(Criatura.de_dicionario(x))
	for x in d.get("reserva", []):
		col.reserva.append(Criatura.de_dicionario(x))
	for e in d.get("vistas", []):
		col.vistas[e] = true
	for e in d.get("capturadas", []):
		col.capturadas[e] = true
	return col
