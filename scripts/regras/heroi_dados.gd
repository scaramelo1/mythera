extends RefCounted
## Herói (Vinculador): nível, experiência, vida e atributos (proposta, para balancear).
## Os atributos do GDD (vigor, força, essência, agilidade) e os talentos entram depois.

const Experiencia = preload("res://scripts/regras/experiencia.gd")

var nivel := 1
var xp := 0
var vida := 0


func _init() -> void:
	vida = vida_maxima()


func vida_maxima() -> int:
	return 60 + 8 * (nivel - 1)


func ataque() -> int:
	return 10 + 2 * (nivel - 1)


func defesa() -> int:
	return int(8 + 1.5 * (nivel - 1))


func receber_dano(quantia: int) -> void:
	vida = maxi(vida - quantia, 0)


func desmaiado() -> bool:
	return vida <= 0


func curar_tudo() -> void:
	vida = vida_maxima()


## Devolve quantos níveis subiu. A vida ganha no nível entra na vida atual.
func ganhar_xp(quantia: int) -> int:
	var antes := vida_maxima()
	var r := Experiencia.ganhar(nivel, xp, quantia)
	nivel = r.nivel
	xp = r.xp
	vida += vida_maxima() - antes
	return r.niveis_ganhos


func para_dicionario() -> Dictionary:
	return {"nivel": nivel, "xp": xp, "vida": vida}


static func de_dicionario(d: Dictionary):
	var h = load("res://scripts/regras/heroi_dados.gd").new()
	h.nivel = int(d.get("nivel", 1))
	h.xp = int(d.get("xp", 0))
	h.vida = clampi(int(d.get("vida", h.vida_maxima())), 0, h.vida_maxima())
	return h
