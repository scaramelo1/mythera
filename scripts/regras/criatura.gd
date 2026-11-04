extends RefCounted
## Uma criatura individual (GDD, seção 11: "espécie" é fixa, "indivíduo" é cada uma).
## Guarda ID único, espécie atual, nível, experiência, vínculo e bônus próprios.

const Especies = preload("res://scripts/regras/especies.gd")
const Experiencia = preload("res://scripts/regras/experiencia.gd")

const ATRIBUTOS := ["vida", "ataque", "defesa", "poder", "resistencia", "velocidade"]
const BONUS_MAXIMO := 0.10  # cada criatura nasce com até +10% em cada atributo
const VINCULO_MAXIMO := 100

var id := ""
var especie_id := ""
var nivel := 1
var xp := 0
var vinculo := 0
var bonus := {}
var vida_atual := 0
var apelido := ""


static func nova(especie: String, nivel_inicial: int, rng: RandomNumberGenerator):
	var c = load("res://scripts/regras/criatura.gd").new()
	c.id = "%x-%08x" % [int(Time.get_unix_time_from_system()), rng.randi()]
	c.especie_id = especie
	c.nivel = clampi(nivel_inicial, 1, Experiencia.NIVEL_MAXIMO)
	for a in ATRIBUTOS:
		c.bonus[a] = snappedf(rng.randf_range(0.0, BONUS_MAXIMO), 0.001)
	c.vida_atual = c.atributo("vida")
	return c


func especie() -> Dictionary:
	return Especies.obter(especie_id)


func nome() -> String:
	return apelido if apelido != "" else especie().get("nome", especie_id)


func elemento() -> String:
	return especie().get("elemento", "")


## A(L) = piso((A0 + G × (L − 1)) × (1 + bônus))
func atributo(nome_atributo: String) -> int:
	var par: Array = especie().get("atributos", {}).get(nome_atributo, [0, 0])
	var base := float(par[0]) + float(par[1]) * (nivel - 1)
	return int(floor(base * (1.0 + bonus.get(nome_atributo, 0.0))))


func vida_maxima() -> int:
	return atributo("vida")


func proporcao_vida() -> float:
	var m := vida_maxima()
	return float(vida_atual) / m if m > 0 else 0.0


func receber_dano(quantia: int) -> void:
	vida_atual = maxi(vida_atual - quantia, 0)


func desmaiada() -> bool:
	return vida_atual <= 0


func curar_tudo() -> void:
	vida_atual = vida_maxima()


func ganhar_vinculo(quantia: int) -> void:
	vinculo = clampi(vinculo + quantia, 0, VINCULO_MAXIMO)


## Soma experiência; a vida máxima nova entra na vida atual. Devolve quantos níveis subiu.
func ganhar_xp(quantia: int) -> int:
	var vida_antes := vida_maxima()
	var r := Experiencia.ganhar(nivel, xp, quantia)
	nivel = r.nivel
	xp = r.xp
	vida_atual += vida_maxima() - vida_antes
	return r.niveis_ganhos


func pode_evoluir() -> bool:
	var e := especie()
	var proxima: String = e.get("evolui_para", "")
	var minimo: int = e.get("nivel_evolucao", 0)
	return proxima != "" and Especies.existe(proxima) and minimo > 0 and nivel >= minimo


## Troca a espécie e mantém ID, nível, experiência, vínculo e bônus (GDD, seção 5).
func evoluir() -> bool:
	if not pode_evoluir():
		return false
	var proporcao := proporcao_vida()
	especie_id = especie().evolui_para
	vida_atual = int(ceil(vida_maxima() * proporcao))
	return true


func para_dicionario() -> Dictionary:
	return {
		"id": id, "especie": especie_id, "nivel": nivel, "xp": xp, "vinculo": vinculo,
		"bonus": bonus.duplicate(), "vida": vida_atual, "apelido": apelido,
	}


static func de_dicionario(d: Dictionary):
	var c = load("res://scripts/regras/criatura.gd").new()
	c.id = d.get("id", "")
	c.especie_id = d.get("especie", "")
	c.nivel = int(d.get("nivel", 1))
	c.xp = int(d.get("xp", 0))
	c.vinculo = int(d.get("vinculo", 0))
	c.bonus = d.get("bonus", {}).duplicate()
	c.vida_atual = int(d.get("vida", c.vida_maxima()))
	c.apelido = d.get("apelido", "")
	return c
