"""Dibuja los esqueletos OpenPose de los 21 cuadros a partir de las poses de la silueta.

OpenPose es un formato estándar de esqueleto: 18 puntos (nariz, cuello, hombros, codos,
manos, caderas, rodillas, tobillos, ojos, orejas) unidos por palos de colores fijos. El
ControlNet de OpenPose lee esos colores para saber qué parte es cuál y de qué lado.

Uso:
    python3 make_poses.py <carpeta_salida>
Genera pose_<animacion>_<n>.png (832x1216, fondo negro) y poses_sheet.png para revisar.
"""

import math
import pathlib
import sys

from PIL import Image, ImageDraw

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
import make_silhouette as sil  # noqa: E402

W, H = 832, 1216
# 1 píxel de la silueta = 18 px del esqueleto (40 px de alto ≈ 720 px, 60 % del alto).
# Con más (24) SDXL dibujaba al personaje más grande que el esqueleto y cortaba los pies.
SCALE = 18
FOOT_Y = 1080

# Pares de puntos (índices COCO de OpenPose) y sus colores estándar.
LIMBS = [(1, 2), (1, 5), (2, 3), (3, 4), (5, 6), (6, 7), (1, 8), (8, 9), (9, 10), (1, 11),
         (11, 12), (12, 13), (1, 0), (0, 14), (14, 16), (0, 15), (15, 17)]
COLORS = [(255, 0, 0), (255, 85, 0), (255, 170, 0), (255, 255, 0), (170, 255, 0), (85, 255, 0),
          (0, 255, 0), (0, 255, 85), (0, 255, 170), (0, 255, 255), (0, 170, 255), (0, 85, 255),
          (0, 0, 255), (85, 0, 255), (170, 0, 255), (255, 0, 255), (255, 0, 170), (255, 0, 85)]


def side_keypoints(p: dict) -> dict:
    """Puntos de una pose de perfil mirando a la derecha.

    Mirando a la derecha se ve el lado izquierdo del cuerpo: los miembros "de adelante"
    (f) de la silueta son los izquierdos y los "de atrás" (b), los derechos.
    """
    seg, leg = sil.seg, sil.leg_end
    _, f1 = leg((0, 0), p["tf"], p["sf"])
    _, f2 = leg((0, 0), p["tb"], p["sb"])
    hip = (16 + p.get("dx", 0), sil.FOOT_Y - max(f1[1], f2[1]) - p.get("lift", 0))
    a = math.radians(p.get("lean", 0))
    bob = p.get("bob", 0)
    up = (math.sin(a), -math.cos(a))
    neck = (hip[0] + up[0] * sil.TORSO, hip[1] + up[1] * sil.TORSO + bob)
    shoulder = (hip[0] + up[0] * (sil.TORSO - 2), hip[1] + up[1] * (sil.TORSO - 2) + bob)
    head = (neck[0] + up[0] * (sil.HEAD_R + 1), neck[1] + up[1] * (sil.HEAD_R + 1))
    fwd = (math.cos(a), math.sin(a))  # hacia donde mira, perpendicular al torso
    k = {}
    k[1] = neck
    k[0] = (head[0] + fwd[0] * 3.5, head[1] + fwd[1] * 3.5)  # nariz
    k[15] = (head[0] + fwd[0] * 2, head[1] - 1)  # ojo izquierdo (el visible)
    k[17] = (head[0] - fwd[0] * 1, head[1])  # oreja izquierda
    for side, (ta, sa, aa, fa) in {"L": ("tf", "sf", "af", "ff"), "R": ("tb", "sb", "ab", "fb")}.items():
        knee, ankle = leg(hip, p[ta], p[sa])
        elbow = seg(shoulder, p[aa], sil.UPPER_ARM)
        wrist = seg(elbow, p[aa] + p.get(fa, 30), sil.FOREARM)
        idx = (11, 12, 13, 5, 6, 7) if side == "L" else (8, 9, 10, 2, 3, 4)
        for i, pt in zip(idx, (hip, knee, ankle, shoulder, elbow, wrist)):
            k[i] = pt
    return k


def front_keypoints() -> dict:
    """Pose de frente (mitad del giro). El lado derecho del personaje queda a la izquierda."""
    hip_y = sil.FOOT_Y - sil.THIGH - sil.SHIN
    neck_y = hip_y - sil.TORSO
    head_y = neck_y - sil.HEAD_R - 1
    k = {1: (16, neck_y), 0: (16, head_y + 1), 14: (14.5, head_y), 15: (17.5, head_y),
         16: (12.5, head_y), 17: (19.5, head_y)}
    for sx, (h, kn, an, s, e, w) in ((-1, (8, 9, 10, 2, 3, 4)), (1, (11, 12, 13, 5, 6, 7))):
        k[h] = (16 + sx * 3, hip_y)
        k[kn] = (16 + sx * 3.5, hip_y + sil.THIGH)
        k[an] = (16 + sx * 4, sil.FOOT_Y)
        k[s] = (16 + sx * 5, neck_y + 1)
        k[e] = (16 + sx * 6, neck_y + 8)
        k[w] = (16 + sx * 6.5, neck_y + 14)
    return k


def draw(k: dict) -> Image.Image:
    img = Image.new("RGB", (W, H), "black")
    d = ImageDraw.Draw(img)

    def px(pt):
        return (W / 2 + (pt[0] - 16) * SCALE, FOOT_Y + (pt[1] - sil.FOOT_Y) * SCALE)

    for (a, b), color in zip(LIMBS, COLORS):
        if a in k and b in k:
            d.line([px(k[a]), px(k[b])], fill=tuple(int(c * 0.6) for c in color), width=14)
    for i, color in enumerate(COLORS):
        if i in k:
            x, y = px(k[i])
            d.ellipse([x - 9, y - 9, x + 9, y + 9], fill=color)
    return img


def main(out_dir: str) -> None:
    out = pathlib.Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    thumbs = []
    for name, (_, _, poses) in sil.ANIMS.items():
        for n, p in enumerate(poses):
            img = draw(front_keypoints() if p.get("front") else side_keypoints(p))
            img.save(out / f"pose_{name}_{n}.png")
            thumbs.append((f"{name} {n}", img.resize((W // 6, H // 6))))
    cols = 7
    tw, th = W // 6, H // 6
    sheet = Image.new("RGB", (cols * tw, -(-len(thumbs) // cols) * (th + 14)), (30, 30, 30))
    d = ImageDraw.Draw(sheet)
    for i, (label, t) in enumerate(thumbs):
        x, y = (i % cols) * tw, (i // cols) * (th + 14)
        sheet.paste(t, (x, y + 14))
        d.text((x + 4, y + 1), label, fill="white")
    sheet.save(out / "poses_sheet.png")
    print(len(thumbs), "poses")


if __name__ == "__main__":
    main(sys.argv[1])
