extends RefCounted
## Fórmula de dano (proposta, para aprovar e balancear):
## dano = piso(ataque × poder do golpe ÷ (defesa + 50) × vantagem do elemento × variação), mínimo 1.
## Golpe físico usa ataque contra defesa; golpe elemental usa poder contra resistência.

const Elementos = preload("res://scripts/regras/elementos.gd")

const VARIACAO_MIN := 0.9
const VARIACAO_MAX := 1.0


static func calcular(ataque: float, poder_golpe: float, defesa: float,
		elemento_golpe: String = "", elemento_alvo: String = "", variacao: float = 1.0) -> int:
	var base := ataque * poder_golpe / (defesa + 50.0)
	var mult := Elementos.multiplicador(elemento_golpe, elemento_alvo)
	return maxi(1, int(floor(base * mult * variacao)))


static func variacao_aleatoria(rng: RandomNumberGenerator) -> float:
	return rng.randf_range(VARIACAO_MIN, VARIACAO_MAX)
