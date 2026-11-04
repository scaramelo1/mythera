"""Gera dados/vila_mascara.json: onde o herói pode andar no mapa da vila (assets/mapas/vila.webp).

Grade de 8 x 8 px. Liberado = caminhos e praça (detectados pela cor) + áreas marcadas à mão.
Bloqueado à mão: fonte, estátuas, mural e barracas. Só fica liberado o que dá para alcançar do início.
Uso: python3 ferramentas/gerar_mascara_vila.py [pasta_para_previa]
"""
import json, sys
from PIL import Image, ImageDraw

MAPA = "assets/mapas/vila.webp"
SAIDA = "dados/vila_mascara.json"
C = 8
INICIO = (812, 560)  # em pixels: praça, ao sul da fonte

# retângulos (x0, y0, x1, y1) em pixels da imagem
LIBERAR = [
    (748, 205, 812, 400),   # subida da praça até a porta do salão
    (700, 368, 932, 560),   # praça em volta da fonte
    (1160, 440, 1232, 560), # da praça até o caminho da ponte
    (775, 560, 842, 662),   # escada ao sul da praça
    (415, 652, 850, 706),   # caminho de baixo
    (395, 596, 440, 706),   # curva do caminho da esquerda
    (690, 700, 770, 760),   # descida até o píer
    (930, 540, 1240, 580),  # caminho ao sul do mercado até a ponte
    (360, 640, 430, 700),   # ligação até a passagem do acampamento
    (150, 745, 360, 905),   # acampamento
    (320, 650, 372, 760),   # passagem até o acampamento
    (540, 755, 770, 792),   # píer
    (705, 712, 770, 832),   # píer que desce
    (1222, 516, 1350, 560), # ponte de pedra
    (1340, 500, 1420, 560), # depois da ponte
    (1330, 556, 1372, 724), # trilha até as ruínas
    (1200, 724, 1440, 912), # ruínas
    (1262, 196, 1336, 262), # entrada da caverna
]
BLOQUEAR = [
    # construções
    (195, 75, 305, 228),    # moinho
    (298, 150, 402, 268),   # celeiro
    (115, 222, 292, 362),   # plantação de trigo
    (398, 282, 518, 386),   # casa ao lado do celeiro
    (543, 258, 688, 386),   # loja azul
    (660, 30, 890, 205),    # salão principal
    (558, 158, 745, 252),   # jardim murado à esquerda do salão
    (812, 158, 978, 252),   # jardim murado à direita do salão
    (945, 236, 1108, 388),  # prédio vermelho
    (232, 382, 364, 508),   # casa da esquerda
    (460, 412, 592, 548),   # casa do meio
    (145, 496, 388, 648),   # cercado dos animais
    (428, 552, 578, 668),   # horta
    (575, 552, 722, 692),   # casa do sul
    (898, 562, 1018, 692),  # casa do sudeste
    (1112, 552, 1252, 722), # casa da roda-d'água
    (1212, 105, 1392, 196), # rochas da caverna
    (1212, 196, 1270, 245), (1342, 196, 1392, 245),
    # postes e estandartes
    (518, 308, 546, 388), (852, 308, 878, 392), (1106, 308, 1134, 388),
    (682, 436, 712, 562), (900, 436, 932, 562), (668, 700, 692, 752),
    (636, 128, 668, 222), (886, 120, 918, 222),
    (752, 396, 872, 486),   # fonte
    (688, 222, 742, 302),   # estátua esquerda
    (814, 222, 870, 302),   # estátua direita
    (694, 318, 745, 388),   # mural de avisos
    (1014, 410, 1112, 470), # barraca listrada
    (972, 486, 1052, 545),  # barraca azul
    (1082, 452, 1182, 535), # tenda roxa
    (190, 760, 285, 825),   # barraca do acampamento
    (158, 818, 202, 862),   # caixotes
    (205, 850, 258, 892),   # tronco
    (272, 828, 328, 882),   # fogueira
    (1188, 760, 1218, 830), (1256, 740, 1290, 812), (1318, 720, 1350, 780),  # colunas
    (1398, 760, 1432, 830), (1200, 840, 1236, 900), (1350, 840, 1386, 900),
    (1286, 700, 1360, 760), # arco
]


def dentro(x, y, rets):
    return any(x0 <= x < x1 and y0 <= y < y1 for x0, y0, x1, y1 in rets)


def main():
    img = Image.open(MAPA).convert("RGB")
    W, H = img.size
    px = img.load()
    gx, gy = W // C, H // C
    grade = [[0] * gx for _ in range(gy)]
    for y in range(gy):
        for x in range(gx):
            n = t = 0
            for yy in range(y * C, y * C + C):
                for xx in range(x * C, x * C + C):
                    r, g, b = px[xx, yy]
                    n += 1
                    # terra clara ou pedra/calçamento
                    if (r > 170 and g > 130 and b < 180 and r - b > 35 and r - g < 75) or \
                       (abs(r - g) < 25 and abs(g - b) < 35 and 130 < r < 240):
                        t += 1
            cx, cy = x * C + C // 2, y * C + C // 2
            livre = t / n > 0.35 or dentro(cx, cy, LIBERAR)
            if dentro(cx, cy, BLOQUEAR):
                livre = False
            grade[y][x] = 1 if livre else 0
    # tapa buracos de uma célula no meio do caminho (sombras e detalhes do desenho)
    for _ in range(2):
        nova = [linha[:] for linha in grade]
        for y in range(1, gy - 1):
            for x in range(1, gx - 1):
                viz = grade[y - 1][x] + grade[y + 1][x] + grade[y][x - 1] + grade[y][x + 1]
                cx, cy = x * C + C // 2, y * C + C // 2
                if grade[y][x] == 0 and viz >= 3 and not dentro(cx, cy, BLOQUEAR):
                    nova[y][x] = 1
        grade = nova
    # só o que se alcança a partir do início
    ini = (INICIO[0] // C, INICIO[1] // C)
    assert grade[ini[1]][ini[0]] == 1, "início bloqueado"
    vistos = {ini}
    fila = [ini]
    while fila:
        x, y = fila.pop()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            q = (x + dx, y + dy)
            if 0 <= q[0] < gx and 0 <= q[1] < gy and q not in vistos and grade[q[1]][q[0]] == 1:
                vistos.add(q)
                fila.append(q)
    final = ["".join("1" if (x, y) in vistos else "0" for x in range(gx)) for y in range(gy)]
    json.dump({"celula": C, "largura": gx, "altura": gy, "inicio": list(INICIO), "linhas": final},
              open(SAIDA, "w"), indent=0)
    print("células livres:", len(vistos), "de", gx * gy)
    if len(sys.argv) > 1:
        ov = Image.open(MAPA).convert("RGBA")
        lay = Image.new("RGBA", ov.size, (0, 0, 0, 0))
        d = ImageDraw.Draw(lay)
        for y in range(gy):
            for x in range(gx):
                if final[y][x] == "1":
                    d.rectangle([x * C, y * C, x * C + C - 1, y * C + C - 1], fill=(0, 255, 255, 140))
                elif grade[y][x] == 1:
                    d.rectangle([x * C, y * C, x * C + C - 1, y * C + C - 1], fill=(255, 255, 0, 170))
        d.ellipse([INICIO[0] - 8, INICIO[1] - 8, INICIO[0] + 8, INICIO[1] + 8], fill=(255, 0, 255, 255))
        Image.alpha_composite(ov, lay).convert("RGB").save(sys.argv[1] + "/vila_mascara.png")


if __name__ == "__main__":
    main()
