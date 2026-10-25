"""Paso final: arma la hoja de sprites de una animación completa a un tamaño dado.

A diferencia de to_sprite.py (una imagen suelta), acá todos los cuadros comparten:
- la misma escala, tomada del cuadro de referencia (quieto): un cuadro agachado queda
  más bajo en vez de estirarse;
- la misma paleta, para que los colores no parpadeen entre cuadros;
- el mismo punto de apoyo: pies abajo, cadera al centro del lienzo de 64x64.

Uso:
    python3 anim_sprites.py <carpeta_con_cuadros> <salida.png> --height 40
Los cuadros se llaman <animacion>_<n>.png (como los esqueletos). Escribe además
<salida>.json con el mismo formato que silhouette.json.
"""

import argparse
import json
import pathlib
import sys

from PIL import Image

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
import make_silhouette as sil  # noqa: E402
from to_sprite import remove_background  # noqa: E402

CELL = 64


def opaque_bbox(im: Image.Image) -> tuple:
    return im.getchannel("A").point(lambda v: 255 if v > 128 else 0).getbbox()


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("frames_dir", type=pathlib.Path)
    ap.add_argument("out", type=pathlib.Path)
    ap.add_argument("--height", type=int, default=40)
    ap.add_argument("--colors", type=int, default=16)
    ap.add_argument("--reference", default="quieto_0")
    args = ap.parse_args()

    names = [(a, n) for a, (_, _, poses) in sil.ANIMS.items() for n in range(len(poses))]
    cut = {}
    for a, n in names:
        im = remove_background(Image.open(args.frames_dir / f"{a}_{n}.png"))
        cut[(a, n)] = im.crop(opaque_bbox(im))

    ref_anim, ref_n = args.reference.rsplit("_", 1)
    ref_img = cut[(ref_anim, int(ref_n))]
    scale = args.height / ref_img.height

    small = {}
    for key, img in cut.items():
        w, h = max(1, round(img.width * scale)), max(1, round(img.height * scale))
        small[key] = img.resize((w, h), Image.BOX)

    # Paleta común: se calcula sobre todos los cuadros juntos.
    mosaic = Image.new("RGB", (sum(i.width for i in small.values()), max(i.height for i in small.values())))
    x = 0
    for img in small.values():
        mosaic.paste(img.convert("RGB"), (x, 0))
        x += img.width
    palette = mosaic.quantize(colors=args.colors, dither=Image.Dither.NONE)

    sheet = Image.new("RGBA", (CELL * len(names), CELL), (0, 0, 0, 0))
    meta, index = {}, 0
    for a, (fps, loop, poses) in sil.ANIMS.items():
        meta[a] = {"start": index, "count": len(poses), "fps": fps, "loop": loop}
        for n in range(len(poses)):
            img = small[(a, n)]
            alpha = img.getchannel("A").point(lambda v: 255 if v > 110 else 0)
            flat = img.convert("RGB").quantize(palette=palette, dither=Image.Dither.NONE).convert("RGBA")
            flat.putalpha(alpha)
            # Pies abajo; centrado horizontal por el ancho del recorte (simple para la prueba).
            ox = index * CELL + (CELL - img.width) // 2
            sheet.paste(flat, (ox, CELL - img.height), flat)
            index += 1
    sheet.save(args.out)
    args.out.with_suffix(".json").write_text(json.dumps({"frame_size": [CELL, CELL], "animations": meta}, indent=1))
    print(args.out, f"escala {scale:.4f}")


if __name__ == "__main__":
    main()
