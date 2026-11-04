extends "res://testes/base.gd"
## Os testes obrigatórios da seção 13 do GDD.

const Captura = preload("res://scripts/regras/captura.gd")


func teste_exemplo_do_gdd() -> void:
	# taxa 20%, vida 25%, núcleo +10%, condição +10% → 70%
	perto(Captura.chance(0.20, 0.25, 0.10, 0.10), 0.70, "exemplo do GDD")


func teste_limites() -> void:
	perto(Captura.chance(0.0, 1.0), 0.05, "mínimo de 5%")
	perto(Captura.chance(0.9, 0.0, 0.2, 0.1, 0.1), 0.95, "máximo de 95%")


func teste_condicoes_nao_se_somam() -> void:
	perto(Captura.bonus_condicao(["dormindo", "paralisada"]), 0.10, "duas condições")
	perto(Captura.bonus_condicao([]), 0.0, "sem condição")


func teste_sucesso_e_falha() -> void:
	var r := rng(7)
	var sucessos := 0
	for i in 10000:
		if Captura.sorteio(0.70, r):
			sucessos += 1
	verdade(sucessos > 6800 and sucessos < 7200, "70%% deu %d em 10000" % sucessos)
	verdade(not Captura.sorteio(0.0, rng(1)), "chance zero nunca captura")


func teste_sem_nucleo() -> void:
	igual(Captura.verificar(0, true, true, 1.0), Captura.SEM_NUCLEO, "sem núcleo")


func teste_fora_do_alcance() -> void:
	igual(Captura.verificar(3, true, true, Captura.ALCANCE + 0.1), Captura.LONGE, "longe")
	igual(Captura.verificar(3, true, true, Captura.ALCANCE), Captura.OK, "no limite pode")


func teste_alvo_invalido() -> void:
	igual(Captura.verificar(3, false, true, 1.0), Captura.SEM_ALVO, "sem alvo")
	igual(Captura.verificar(3, true, false, 1.0), Captura.NAO_SELVAGEM, "criatura que já tem dono")
