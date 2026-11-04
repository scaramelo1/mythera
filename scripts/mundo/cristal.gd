extends Node2D
## Cristal de Essência: o herói pega ao passar por cima e ganha 1 Núcleo de Vínculo. Volta depois de um tempo.

const Desenho = preload("res://scripts/arte/desenho.gd")
const TEMPO_VOLTA := 90.0
const RAIO_PEGAR := 16.0

var jogo: Node = null
var disponivel := true
var _espera := 0.0
var _t := 0.0


func _process(delta: float) -> void:
	_t += delta
	if not disponivel:
		_espera -= delta
		if _espera <= 0.0:
			disponivel = true
			visible = true
		return
	if jogo.heroi != null and jogo.heroi.position.distance_to(position) <= RAIO_PEGAR:
		disponivel = false
		visible = false
		_espera = TEMPO_VOLTA
		jogo.coletar_cristal(self)
	queue_redraw()


func _draw() -> void:
	Desenho.cristal(self, _t)
