extends RefCounted
## Elementos e vantagens. O protótipo usa só fogo, água e natureza (GDD, seção 3).
## Fogo vence natureza, natureza vence água, água vence fogo.

const FOGO := "fogo"
const AGUA := "agua"
const NATUREZA := "natureza"

const VANTAGEM := 1.5
const DESVANTAGEM := 0.67

## elemento -> elemento que ele vence
const VENCE := {
	FOGO: NATUREZA,
	NATUREZA: AGUA,
	AGUA: FOGO,
}


static func multiplicador(elemento_golpe: String, elemento_alvo: String) -> float:
	if elemento_golpe == "" or elemento_alvo == "":
		return 1.0
	if VENCE.get(elemento_golpe, "") == elemento_alvo:
		return VANTAGEM
	if VENCE.get(elemento_alvo, "") == elemento_golpe:
		return DESVANTAGEM
	return 1.0
