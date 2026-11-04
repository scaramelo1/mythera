extends SceneTree
## Lê o glTF do herói direto (sem importar) e mostra esqueleto, altura e direção do rosto:
##   godot --headless --path . -s testes/conferir_modelo.gd

func _init() -> void:
	for caminho in ["res://assets/modelos/heroi/heroi_masculino.gltf", "res://assets/modelos/heroi/heroi_feminino.gltf"]:
		var doc := GLTFDocument.new()
		var estado := GLTFState.new()
		var erro := doc.append_from_file(caminho, estado)
		if erro != OK:
			print("ERRO ao ler ", caminho, ": ", erro)
			continue
		var cena := doc.generate_scene(estado)
		var sk: Skeleton3D = null
		var malhas := 0
		var caixa := AABB()
		for n in cena.find_children("*", "", true, false):
			if n is Skeleton3D:
				sk = n
			if n is MeshInstance3D:
				malhas += 1
				var a: AABB = n.get_aabb()
				caixa = a if caixa.size == Vector3.ZERO else caixa.merge(a)
		print(caminho.get_file(), ": malhas=", malhas, " ossos=", sk.get_bone_count() if sk else 0,
			" altura=%.2f m" % caixa.size.y, " materiais com textura=", estado.get_textures().size())
		cena.free()
	quit()
