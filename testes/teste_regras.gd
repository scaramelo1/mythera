extends "res://testes/base.gd"

const Elementos = preload("res://scripts/regras/elementos.gd")
const Dano = preload("res://scripts/regras/dano.gd")
const Experiencia = preload("res://scripts/regras/experiencia.gd")
const Criatura = preload("res://scripts/regras/criatura.gd")
const Especies = preload("res://scripts/regras/especies.gd")
const Colecao = preload("res://scripts/regras/colecao.gd")
const Salvamento = preload("res://scripts/regras/salvamento.gd")


func teste_especies_carregam() -> void:
	for id in ["flarin", "flarvex", "aquori", "mosshell"]:
		verdade(Especies.existe(id), "falta a espécie " + id)
	igual(Especies.obter("flarin").elemento, "fogo", "elemento do Flarin")


func teste_vantagem_dos_elementos() -> void:
	perto(Elementos.multiplicador("fogo", "natureza"), 1.5, "fogo x natureza")
	perto(Elementos.multiplicador("natureza", "agua"), 1.5, "natureza x água")
	perto(Elementos.multiplicador("agua", "fogo"), 1.5, "água x fogo")
	perto(Elementos.multiplicador("natureza", "fogo"), 0.67, "natureza x fogo")
	perto(Elementos.multiplicador("fogo", "fogo"), 1.0, "fogo x fogo")
	perto(Elementos.multiplicador("", "agua"), 1.0, "golpe sem elemento")
	perto(Elementos.multiplicador("", ""), 1.0, "nenhum dos dois com elemento")


func teste_dano() -> void:
	# 20 × 40 ÷ (15 + 50) = 12,3 → 12
	igual(Dano.calcular(20, 40, 15), 12, "dano neutro")
	# com vantagem: 12,3 × 1,5 = 18,46 → 18
	igual(Dano.calcular(20, 40, 15, "fogo", "natureza"), 18, "dano com vantagem")
	igual(Dano.calcular(1, 1, 999), 1, "dano mínimo é 1")


func teste_experiencia_do_gdd() -> void:
	igual(Experiencia.para_proximo(1), 50, "nível 1")
	igual(Experiencia.para_proximo(10), 1581, "nível 10")
	igual(Experiencia.para_proximo(59), 22659, "nível 59")
	igual(Experiencia.para_proximo(60), 0, "nível máximo")


func teste_subir_varios_niveis() -> void:
	# 50 (1→2) + 141 (2→3) = 191; sobram 9
	var r := Experiencia.ganhar(1, 0, 200)
	igual(r.nivel, 3, "nível")
	igual(r.xp, 9, "sobra")
	igual(r.niveis_ganhos, 2, "níveis ganhos")


func teste_nao_passa_do_60() -> void:
	var r := Experiencia.ganhar(59, 0, 10_000_000)
	igual(r.nivel, 60, "trava no 60")
	igual(r.xp, 0, "xp zera no máximo")


func teste_atributos_e_bonus_individual() -> void:
	var a = Criatura.nova("flarin", 10, rng(1))
	var b = Criatura.nova("flarin", 10, rng(2))
	# ataque do Flarin no nível 10 sem bônus: 14 + 2,2 × 9 = 33,8
	verdade(a.atributo("ataque") >= 33 and a.atributo("ataque") <= 37, "ataque fora da faixa: %d" % a.atributo("ataque"))
	verdade(a.bonus != b.bonus, "duas criaturas da mesma espécie deviam ser diferentes")
	verdade(a.id != b.id, "IDs repetidos")
	igual(a.vida_atual, a.vida_maxima(), "nasce com vida cheia")


func teste_subir_nivel_aumenta_vida() -> void:
	var c = Criatura.nova("aquori", 1, rng())
	c.receber_dano(10)
	var faltando: int = c.vida_maxima() - c.vida_atual
	c.ganhar_xp(50)
	igual(c.nivel, 2, "subiu para o 2")
	igual(c.vida_maxima() - c.vida_atual, faltando, "o dano continua, a vida nova entra")


func teste_evolucao_mantem_identidade() -> void:
	var c = Criatura.nova("flarin", 17, rng())
	c.vinculo = 40
	verdade(not c.pode_evoluir(), "não evolui antes do 18")
	c.nivel = 18
	var id_antes: String = c.id
	var ataque_antes: int = c.atributo("ataque")
	verdade(c.evoluir(), "devia evoluir no 18")
	igual(c.especie_id, "flarvex", "nova espécie")
	igual(c.id, id_antes, "mesmo ID")
	igual(c.nivel, 18, "mesmo nível")
	igual(c.vinculo, 40, "mesmo vínculo")
	verdade(c.atributo("ataque") > ataque_antes, "evolução deve deixar mais forte")
	verdade(not c.evoluir(), "Flarvex não evolui de novo")


func teste_especie_sem_evolucao() -> void:
	var c = Criatura.nova("mosshell", 60, rng())
	verdade(not c.pode_evoluir(), "Mosshell ainda não tem evolução")


func teste_equipe_cheia_vai_para_reserva() -> void:
	var col = Colecao.new()
	var r := rng()
	for i in 6:
		igual(col.adicionar(Criatura.nova("aquori", 1, r)), "equipe", "criatura %d" % i)
	igual(col.adicionar(Criatura.nova("flarin", 1, r)), "reserva", "a 7.ª vai para a reserva")
	igual(col.total(), 7, "total")
	verdade(col.capturadas.has("flarin"), "registro marca o Flarin")


func teste_salvar_e_carregar() -> void:
	var col = Colecao.new()
	var c = Criatura.nova("mosshell", 5, rng())
	c.apelido = "Casco"
	c.receber_dano(7)
	col.adicionar(c)
	var caminho := "user://teste_mythera.save"
	verdade(Salvamento.salvar({"colecao": col.para_dicionario()}, caminho), "não salvou")
	var dados := Salvamento.carregar(caminho)
	Salvamento.apagar(caminho)
	igual(int(dados.get("versao", 0)), Salvamento.VERSAO, "versão do arquivo")
	var col2 = Colecao.de_dicionario(dados.colecao)
	var c2 = col2.buscar(c.id)
	verdade(c2 != null, "criatura sumiu ao carregar")
	if c2:
		igual(JSON.stringify(c2.para_dicionario()), JSON.stringify(c.para_dicionario()), "criatura igual depois de carregar")


func teste_arquivo_estragado() -> void:
	var caminho := "user://teste_estragado.save"
	var f := FileAccess.open(caminho, FileAccess.WRITE)
	f.store_string("{isso não é json")
	f.close()
	igual(Salvamento.carregar(caminho), {}, "arquivo estragado vira vazio")
	Salvamento.apagar(caminho)
	igual(Salvamento.carregar(caminho), {}, "sem arquivo vira vazio")


func teste_heroi_sobe_de_nivel() -> void:
	var HeroiDados = load("res://scripts/regras/heroi_dados.gd")
	var h = HeroiDados.new()
	igual(h.vida, 60, "vida inicial")
	h.receber_dano(20)
	igual(h.ganhar_xp(50), 1, "sobe 1 nível com 50 de experiência")
	igual(h.vida_maxima(), 68, "vida máxima no nível 2")
	igual(h.vida, 48, "dano continua, vida nova entra")
	var copia = HeroiDados.de_dicionario(h.para_dicionario())
	igual(copia.para_dicionario(), h.para_dicionario(), "salvar e carregar")
