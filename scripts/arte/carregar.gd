extends RefCounted
## Carrega imagens do jogo. No PC (editor) usa a textura importada; no navegador
## (pacote montado sem o editor) e nos testes lê o arquivo direto.


static func textura(caminho: String) -> Texture2D:
	if ResourceLoader.exists(caminho):
		var t = load(caminho)
		if t is Texture2D:
			return t
	if not FileAccess.file_exists(caminho):
		return null
	var bytes := FileAccess.get_file_as_bytes(caminho)
	var img := Image.new()
	var erro := OK
	match caminho.get_extension().to_lower():
		"png":
			erro = img.load_png_from_buffer(bytes)
		"webp":
			erro = img.load_webp_from_buffer(bytes)
		"jpg", "jpeg":
			erro = img.load_jpg_from_buffer(bytes)
	if erro != OK or img.is_empty():
		return null
	return ImageTexture.create_from_image(img)
