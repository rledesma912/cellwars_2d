"""Pasa una imagen generada a sprite de tamaño real.

Saca el fondo (el color de las esquinas), recorta al personaje, lo achica a la altura
pedida, reduce la paleta y lo apoya con los pies abajo al centro de un lienzo de 64x64.

Uso:
    python3 to_sprite.py entrada.png salida.png --height 40
"""

import argparse

from PIL import Image, ImageChops, ImageDraw


def remove_background(im: Image.Image, tolerance: int = 40) -> Image.Image:
    rgba = im.convert("RGBA")
    # Rellena desde las cuatro esquinas: todo lo parecido al fondo pasa a transparente.
    mask = Image.new("L", im.size, 0)
    rgb = im.convert("RGB")
    for corner in [(0, 0), (im.width - 1, 0), (0, im.height - 1), (im.width - 1, im.height - 1)]:
        probe = rgb.copy()
        ImageDraw.floodfill(probe, corner, (255, 0, 255), thresh=tolerance)
        hit = ImageChops.difference(probe, rgb).convert("L").point(lambda v: 255 if v else 0)
        mask = ImageChops.lighter(mask, hit)
    rgba.putalpha(ImageChops.invert(mask))
    return rgba


def to_sprite(src: Image.Image, height: int, colors: int, canvas: int = 64) -> Image.Image:
    rgba = remove_background(src)
    rgba = rgba.crop(rgba.getchannel("A").point(lambda v: 255 if v > 128 else 0).getbbox())
    width = max(1, round(rgba.width * height / rgba.height))
    small = rgba.resize((width, height), Image.BOX)
    alpha = small.getchannel("A").point(lambda v: 255 if v > 110 else 0)
    flat = small.convert("RGB").quantize(colors=colors, dither=Image.Dither.NONE).convert("RGBA")
    flat.putalpha(alpha)
    out = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    out.paste(flat, ((canvas - width) // 2, canvas - height), flat)
    return out


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("src")
    ap.add_argument("dst")
    ap.add_argument("--height", type=int, default=40)
    ap.add_argument("--colors", type=int, default=12)
    args = ap.parse_args()
    to_sprite(Image.open(args.src), args.height, args.colors).save(args.dst)


if __name__ == "__main__":
    main()
