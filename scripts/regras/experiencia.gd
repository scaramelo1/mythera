extends RefCounted
## Experiência e níveis (GDD, seção 5). Vale para o herói e para as criaturas.
## Experiência para passar do nível L para L + 1: 50 × L^1,5.

const NIVEL_MAXIMO := 60


static func para_proximo(nivel: int) -> int:
	if nivel >= NIVEL_MAXIMO:
		return 0
	return int(round(50.0 * pow(float(nivel), 1.5)))


## Experiência ao vencer uma criatura (proposta, para balancear).
static func por_vitoria(nivel_inimigo: int) -> int:
	return 10 + 6 * nivel_inimigo


## Soma experiência. Devolve {nivel, xp, niveis_ganhos}.
static func ganhar(nivel: int, xp: int, quantia: int) -> Dictionary:
	var ganhos := 0
	xp += maxi(quantia, 0)
	while nivel < NIVEL_MAXIMO and xp >= para_proximo(nivel):
		xp -= para_proximo(nivel)
		nivel += 1
		ganhos += 1
	if nivel >= NIVEL_MAXIMO:
		xp = 0
	return {"nivel": nivel, "xp": xp, "niveis_ganhos": ganhos}
