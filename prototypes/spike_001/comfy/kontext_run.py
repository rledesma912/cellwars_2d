"""Genera una imagen con Flux Kontext Dev a través de la API HTTP de ComfyUI.

Usa el workflow exportado en formato API (kontext_api.json, sacado del historial de
ComfyUI) y le cambia la imagen de entrada, la orden, la semilla y el guidance.

Uso:
    python3 kontext_run.py --image elyon_side_right.png --prompt "..." --out salida.png
"""

import argparse
import json
import pathlib
import random
import time
import urllib.parse
import urllib.request
import uuid

SERVER = "http://127.0.0.1:8188"
WORKFLOW = pathlib.Path(__file__).with_name("kontext_api.json")
# Nodos del workflow que se tocan (ids del formato API).
LOAD_IMAGE, PROMPT, SAMPLER, GUIDANCE, SAVE = "190", "192:6", "192:31", "192:35", "136"
STITCH = "192:146"


def upload(path: pathlib.Path) -> str:
    boundary = uuid.uuid4().hex
    body = (
        f'--{boundary}\r\nContent-Disposition: form-data; name="image"; filename="{path.name}"\r\n'
        "Content-Type: image/png\r\n\r\n"
    ).encode() + path.read_bytes() + f"\r\n--{boundary}--\r\n".encode()
    req = urllib.request.Request(
        f"{SERVER}/upload/image",
        data=body,
        headers={"Content-Type": f"multipart/form-data; boundary={boundary}"},
    )
    return json.load(urllib.request.urlopen(req))["name"]


def queue(workflow: dict) -> str:
    data = json.dumps({"prompt": workflow, "client_id": uuid.uuid4().hex}).encode()
    req = urllib.request.Request(f"{SERVER}/prompt", data=data, headers={"Content-Type": "application/json"})
    return json.load(urllib.request.urlopen(req))["prompt_id"]


def wait(prompt_id: str, timeout: float = 900) -> dict:
    start = time.time()
    while time.time() - start < timeout:
        history = json.load(urllib.request.urlopen(f"{SERVER}/history/{prompt_id}"))
        if prompt_id in history:
            return history[prompt_id]
        time.sleep(2)
    raise TimeoutError(prompt_id)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--image", required=True, type=pathlib.Path)
    ap.add_argument("--prompt", required=True)
    ap.add_argument("--out", required=True, type=pathlib.Path)
    ap.add_argument("--seed", type=int, default=None)
    ap.add_argument("--guidance", type=float, default=2.5)
    ap.add_argument("--steps", type=int, default=20)
    ap.add_argument("--pose", type=pathlib.Path, default=None, help="imagen con la pose a copiar")
    args = ap.parse_args()

    wf = json.loads(WORKFLOW.read_text())
    wf[LOAD_IMAGE]["inputs"]["image"] = upload(args.image)
    wf[PROMPT]["inputs"]["text"] = args.prompt
    if args.pose:
        # Segunda imagen: el workflow la pega a la derecha de la primera (ImageStitch)
        # y Kontext ve las dos juntas.
        wf["pose"] = {"class_type": "LoadImage", "inputs": {"image": upload(args.pose)}}
        wf[STITCH]["inputs"]["image2"] = ["pose", 0]
    seed = args.seed if args.seed is not None else random.randrange(2**48)
    wf[SAMPLER]["inputs"]["seed"] = seed
    wf[SAMPLER]["inputs"]["steps"] = args.steps
    wf[GUIDANCE]["inputs"]["guidance"] = args.guidance
    wf[SAVE]["inputs"]["filename_prefix"] = "cw2d/" + args.out.stem

    t0 = time.time()
    result = wait(queue(wf))
    status = result["status"]
    if status.get("status_str") != "success":
        raise SystemExit(f"falló: {status}")
    img = result["outputs"][SAVE]["images"][0]
    query = urllib.parse.urlencode(img)
    args.out.write_bytes(urllib.request.urlopen(f"{SERVER}/view?{query}").read())
    print(f"{args.out} (semilla {seed}, {time.time() - t0:.0f} s)")


if __name__ == "__main__":
    main()
