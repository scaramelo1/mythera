extends RefCounted
## Captura com o Núcleo de Vínculo (GDD, seção 4):
## P = limite(B + 0,40 × (1 − H) + N + S + V, entre 0,05 e 0,95)

const MINIMO := 0.05
const MAXIMO := 0.95
const PESO_VIDA := 0.40
const ALCANCE := 4.0  # metros; no começo a captura é de perto (GDD, seção 13)

## Bônus de cada núcleo (N).
const NUCLEOS := {
	"nucleo_simples": 0.0,
	"nucleo_bom": 0.10,
	"nucleo_otimo": 0.20,
}

## Bônus de condição (S).
const CONDICOES := {
	"dormindo": 0.10,
	"paralisada": 0.10,
	"congelada": 0.10,
}

## Motivos para não poder tentar.
const OK := ""
const SEM_NUCLEO := "sem_nucleo"
const LONGE := "longe"
const SEM_ALVO := "sem_alvo"
const NAO_SELVAGEM := "nao_selvagem"


static func chance(taxa_base: float, vida_restante: float, bonus_nucleo: float = 0.0,
		bonus_condicao: float = 0.0, bonus_vinculo: float = 0.0) -> float:
	var h := clampf(vida_restante, 0.0, 1.0)
	return clampf(taxa_base + PESO_VIDA * (1.0 - h) + bonus_nucleo + bonus_condicao + bonus_vinculo,
		MINIMO, MAXIMO)


static func bonus_nucleo(tipo: String) -> float:
	return NUCLEOS.get(tipo, 0.0)


static func bonus_condicao(condicoes: Array) -> float:
	var total := 0.0
	for c in condicoes:
		total = maxf(total, CONDICOES.get(c, 0.0))  # condições não se somam
	return total


## Confere se dá para tentar. Equipe cheia não impede: a criatura vai para a reserva.
static func verificar(quantidade_nucleos: int, tem_alvo: bool, selvagem: bool, distancia: float) -> String:
	if quantidade_nucleos <= 0:
		return SEM_NUCLEO
	if not tem_alvo:
		return SEM_ALVO
	if not selvagem:
		return NAO_SELVAGEM
	if distancia > ALCANCE:
		return LONGE
	return OK


static func sorteio(p: float, rng: RandomNumberGenerator) -> bool:
	return rng.randf() <= p
