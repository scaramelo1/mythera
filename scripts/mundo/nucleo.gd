extends Node2D
## Núcleo de Vínculo lançado. Vai até a criatura, prende e balança; o jogo decide se captura.

const Desenho = preload("res://scripts/arte/desenho.gd")
const Efeito = preload("res://scripts/mundo/efeito.gd")

const VELOCIDADE := 360.0
const ALCANCE_SEM_ALVO := 140.0
const TEMPO_PRESA := 0.9

var jogo: Node = null
var alvo = null
var direcao := Vector2.RIGHT
var _percorrido := 0.0
var _prendendo := false
var _tempo := 0.0
var _t := 0.0


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()
	if _prendendo:
		_tempo -= delta
		if _tempo <= 0.0:
			jogo.resolver_captura(self, alvo)
			queue_free()
		return
	if alvo != null and is_instance_valid(alvo) and alvo.ativo():
		var destino: Vector2 = alvo.position + Vector2(0, -alvo.raio() * 0.7)
		var passo := VELOCIDADE * delta
		if position.distance_to(destino) <= passo + 2.0:
			position = destino
			_prendendo = true
			_tempo = TEMPO_PRESA
			alvo.estado = "presa"
			return
		position += (destino - position).normalized() * passo
	else:
		position += direcao * VELOCIDADE * delta
		_percorrido += VELOCIDADE * delta
		if _percorrido >= ALCANCE_SEM_ALVO:
			get_parent().add_child(Efeito.criar("estilhaco", position, Color.WHITE, "", 12.0))
			queue_free()


func _draw() -> void:
	var balanco := sin(_t * 25.0) * 0.4 if _prendendo else 0.0
	draw_set_transform(Vector2.ZERO, balanco, Vector2.ONE)
	Desenho.nucleo(self, _t, 6.0 if _prendendo else 5.0)
