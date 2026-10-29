"""Genera la silueta provisoria del soldado (Spike 001) como hoja de frames PNG.

Cada frame es 32x48, mira a la derecha, con los pies en la fila 47 al centro (x=16).
Las poses se arman con ángulos de cada segmento (0 = hacia abajo, positivo = hacia
adelante) para poder retocarlas rápido.
"""
import json
import math
import sys
from PIL import Image, ImageDraw

W, H = 32, 48
FOOT_Y = 47
THIGH, SHIN, TORSO, UPPER_ARM, FOREARM, HEAD_R = 9, 9, 12, 7, 7, 4

BODY = (196, 206, 214, 255)
BACK = (120, 132, 146, 255)
VISOR = (90, 220, 230, 255)
PACK = (150, 160, 172, 255)


def seg(p, angle, length):
    a = math.radians(angle)
    return (p[0] + math.sin(a) * length, p[1] + math.cos(a) * length)


def leg_end(hip, thigh, shin):
    knee = seg(hip, thigh, THIGH)
    return knee, seg(knee, shin, SHIN)


def draw_pose(p):
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if p.get("front"):
        return draw_front(img, d, p)
    lean = p.get("lean", 0)
    # Altura de la cadera: la que deja el pie más bajo en el piso.
    _, f1 = leg_end((0, 0), p["tf"], p["sf"])
    _, f2 = leg_end((0, 0), p["tb"], p["sb"])
    hip = (16 + p.get("dx", 0), FOOT_Y - max(f1[1], f2[1]) - p.get("lift", 0))
    bob = p.get("bob", 0)
    a = math.radians(lean)
    neck = (hip[0] + math.sin(a) * TORSO, hip[1] - math.cos(a) * TORSO + bob)
    shoulder = (hip[0] + math.sin(a) * (TORSO - 2), hip[1] - math.cos(a) * (TORSO - 2) + bob)
    head = (neck[0] + math.sin(a) * (HEAD_R + 1), neck[1] - math.cos(a) * (HEAD_R + 1))

    def limb(start, a1, l1, a2, l2, color, w):
        mid = seg(start, a1, l1)
        end = seg(mid, a2, l2)
        d.line([start, mid, end], fill=color, width=w, joint="curve")

    # Atrás: pierna y brazo del lado lejano, más oscuros.
    limb(hip, p["tb"], THIGH, p["sb"], SHIN, BACK, 4)
    limb(shoulder, p["ab"], UPPER_ARM, p["ab"] + p.get("fb", 30), FOREARM, BACK, 3)
    # Mochila del traje.
    back_dir = (-math.cos(a), -math.sin(a))
    pack_c = ((hip[0] + neck[0]) / 2 + back_dir[0] * 4, (hip[1] + neck[1]) / 2 + back_dir[1] * 4 + 1)
    d.rectangle([pack_c[0] - 2, pack_c[1] - 4, pack_c[0] + 2, pack_c[1] + 3], fill=PACK)
    # Torso y casco.
    d.line([hip, neck], fill=BODY, width=7)
    d.ellipse([head[0] - HEAD_R, head[1] - HEAD_R, head[0] + HEAD_R, head[1] + HEAD_R], fill=BODY)
    d.rectangle([head[0] + 1, head[1] - 1, head[0] + HEAD_R, head[1] + 1], fill=VISOR)
    # Adelante: pierna y brazo del lado cercano.
    limb(hip, p["tf"], THIGH, p["sf"], SHIN, BODY, 4)
    limb(shoulder, p["af"], UPPER_ARM, p["af"] + p.get("ff", 30), FOREARM, BODY, 3)
    return img


def draw_front(img, d, p):
    # De frente (mitad del giro): simétrico, piernas abiertas, visor al centro.
    hip_y = FOOT_Y - THIGH - SHIN
    for sx in (-3, 3):
        d.line([(16 + sx, hip_y), (16 + sx * 1.3, FOOT_Y)], fill=BODY, width=4)
    neck_y = hip_y - TORSO
    d.line([(16, hip_y), (16, neck_y)], fill=BODY, width=9)
    for sx in (-6, 6):
        d.line([(16 + sx, neck_y + 2), (16 + sx * 1.1, neck_y + 14)], fill=BACK, width=3)
    hy = neck_y - HEAD_R - 1
    d.ellipse([16 - HEAD_R, hy - HEAD_R, 16 + HEAD_R, hy + HEAD_R], fill=BODY)
    d.rectangle([16 - 3, hy - 1, 16 + 3, hy + 1], fill=VISOR)
    return img


def pose(tf, sf, tb, sb, af, ab, lean=0, **kw):
    return dict(tf=tf, sf=sf, tb=tb, sb=sb, af=af, ab=ab, lean=lean, **kw)


RUN = [
    pose(40, 10, -30, -70, -35, 40, 12),
    pose(25, 0, -15, -60, -20, 25, 12, bob=1),
    pose(5, -15, 5, -50, 0, 0, 12),
    pose(-30, -70, 40, 10, 40, -35, 12),
    pose(-15, -60, 25, 0, 25, -20, 12, bob=1),
    pose(5, -50, 5, -15, 0, 0, 12),
]

ANIMS = {
    # nombre: (fps, loop, frames)
    "quieto": (3, True, [pose(4, 4, -4, -4, 6, -4, 0, ff=20, fb=20), pose(4, 4, -4, -4, 6, -4, 0, ff=20, fb=20, bob=1)]),
    "arrancar": (10, False, [pose(20, -5, -15, -40, -20, 30, 20), pose(35, 5, -25, -60, -30, 40, 18)]),
    "correr": (12, True, RUN),
    "frenar": (8, True, [pose(35, 40, -10, -40, 35, -15, -15), pose(30, 38, -12, -42, 40, -10, -17)]),
    "girar": (8, False, [pose(5, 5, -5, -5, 10, -5, -5), dict(front=True)]),
    "preparar": (10, False, [pose(25, -10, 15, -25, -20, -30, 10), pose(45, -25, 30, -40, -40, -50, 20), pose(60, -35, 45, -50, -55, -65, 28)]),
    "subir": (8, True, [pose(65, 5, 15, -40, 150, 120, 10, ff=10, fb=10)]),
    "caer": (8, True, [pose(25, 15, -10, -25, 110, -100, 5, ff=20, fb=-20)]),
    "aterrizar": (10, False, [pose(60, -35, 45, -50, 40, 20, 25), pose(30, -10, 20, -25, 20, 0, 10)]),
}


def main(out_png, out_json):
    frames, meta, i = [], {}, 0
    for name, (fps, loop, poses) in ANIMS.items():
        meta[name] = {"start": i, "count": len(poses), "fps": fps, "loop": loop}
        for p in poses:
            frames.append(draw_pose(p))
            i += 1
    sheet = Image.new("RGBA", (W * len(frames), H), (0, 0, 0, 0))
    for n, f in enumerate(frames):
        sheet.paste(f, (n * W, 0))
    sheet.save(out_png)
    with open(out_json, "w") as fh:
        json.dump({"frame_size": [W, H], "animations": meta}, fh, indent=1)
    # Vista previa ampliada para revisar.
    sheet.resize((sheet.width * 6, sheet.height * 6), Image.NEAREST).save(out_png.replace(".png", "_x6_preview.png"))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
