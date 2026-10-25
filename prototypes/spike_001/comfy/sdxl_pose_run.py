"""Paso 1 del flujo de animación: SDXL + ControlNet OpenPose + IP-Adapter.

Toma un esqueleto OpenPose (la pose) y la vista de perfil de Elyon (el diseño) y genera
al personaje en esa pose. El workflow se arma acá mismo, en formato API.

Uso:
    python3 sdxl_pose_run.py --pose poses/pose_correr_0.png --ref elyon_side_right.png --out salida.png
"""

import argparse
import pathlib
import random
import time
import urllib.parse
import urllib.request

from kontext_run import SERVER, queue, upload, wait

POSITIVE = (
    "pixel art, game sprite, full body side view of a futuristic soldier facing right, "
    "white and light grey armor plates over a black bodysuit, dark grey helmet with clear visor, "
    "thin flat armored backpack tight against his back, "
    "(thick black hose from the backpack to the gun:1.45), (black submachine gun held in his hands:1.3), "
    "small helmet, normal adult proportions, plain white background"
)
NEGATIVE = (
    "blurry, 3d render, photo, realistic, multiple people, cropped, text, watermark, shadow, "
    "large backpack, big head, chibi, front view, back view"
)


def build(pose: str, ref: str, args: argparse.Namespace, seed: int) -> dict:
    return {
        "ckpt": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": "sd_xl_base_1.0.safetensors"}},
        "lora": {
            "class_type": "LoraLoader",
            "inputs": {
                "model": ["ckpt", 0],
                "clip": ["ckpt", 1],
                "lora_name": "pixel-art-xl.safetensors",
                "strength_model": args.lora,
                "strength_clip": args.lora,
            },
        },
        "ipa_loader": {
            "class_type": "IPAdapterUnifiedLoader",
            "inputs": {"model": ["lora", 0], "preset": "PLUS (high strength)"},
        },
        "ref": {"class_type": "LoadImage", "inputs": {"image": ref}},
        "ipa": {
            "class_type": "IPAdapterAdvanced",
            "inputs": {
                "model": ["ipa_loader", 0],
                "ipadapter": ["ipa_loader", 1],
                "image": ["ref", 0],
                "weight": args.ipa,
                "weight_type": "linear",
                "combine_embeds": "concat",
                "start_at": 0.0,
                "end_at": 0.8,
                "embeds_scaling": "V only",
            },
        },
        "pos": {"class_type": "CLIPTextEncode", "inputs": {"clip": ["lora", 1], "text": POSITIVE}},
        "neg": {"class_type": "CLIPTextEncode", "inputs": {"clip": ["lora", 1], "text": NEGATIVE}},
        "cn_loader": {"class_type": "ControlNetLoader", "inputs": {"control_net_name": "xinsir_openpose_sdxl.safetensors"}},
        "pose": {"class_type": "LoadImage", "inputs": {"image": pose}},
        "cn": {
            "class_type": "ControlNetApplyAdvanced",
            "inputs": {
                "positive": ["pos", 0],
                "negative": ["neg", 0],
                "control_net": ["cn_loader", 0],
                "image": ["pose", 0],
                "strength": args.cn,
                "start_percent": 0.0,
                "end_percent": 1.0,
            },
        },
        "latent": {"class_type": "EmptyLatentImage", "inputs": {"width": 832, "height": 1216, "batch_size": 1}},
        "sampler": {
            "class_type": "KSampler",
            "inputs": {
                "model": ["ipa", 0],
                "positive": ["cn", 0],
                "negative": ["cn", 1],
                "latent_image": ["latent", 0],
                "seed": seed,
                "steps": 30,
                "cfg": 6.0,
                "sampler_name": "dpmpp_2m",
                "scheduler": "karras",
                "denoise": 1.0,
            },
        },
        "decode": {"class_type": "VAEDecode", "inputs": {"samples": ["sampler", 0], "vae": ["ckpt", 2]}},
        "save": {"class_type": "SaveImage", "inputs": {"images": ["decode", 0], "filename_prefix": "cw2d/" + args.out.stem}},
    }


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--pose", required=True, type=pathlib.Path)
    ap.add_argument("--ref", required=True, type=pathlib.Path)
    ap.add_argument("--out", required=True, type=pathlib.Path)
    ap.add_argument("--seed", type=int, default=None)
    ap.add_argument("--cn", type=float, default=0.9, help="fuerza del ControlNet (pose)")
    ap.add_argument("--ipa", type=float, default=0.45, help="fuerza del IP-Adapter (parecido)")
    ap.add_argument("--lora", type=float, default=0.8, help="fuerza del LoRA de pixel art")
    args = ap.parse_args()

    seed = args.seed if args.seed is not None else random.randrange(2**48)
    wf = build(upload(args.pose), upload(args.ref), args, seed)
    t0 = time.time()
    result = wait(queue(wf))
    if result["status"].get("status_str") != "success":
        raise SystemExit(f"falló: {result['status']}")
    img = result["outputs"]["save"]["images"][0]
    args.out.write_bytes(urllib.request.urlopen(f"{SERVER}/view?{urllib.parse.urlencode(img)}").read())
    print(f"{args.out} (semilla {seed}, {time.time() - t0:.0f} s)")


if __name__ == "__main__":
    main()
