---
name: close-spike
description: Cierra un spike de cellwars_2d una vez aprobada su decisión - consolida las consecuencias en los documentos vivos, archiva el informe, registra lo descartado, lleva los docs a develop por PR y archiva la branch con un tag. Usala cuando el desarrollador apruebe la decisión de un spike.
---

# Close spike

Precondición: el spike `SNNN` tiene `status: done` y su decisión `DNNNN` fue aprobada por el desarrollador con un mensaje explícito (citalo; si no hay aprobación explícita, detenete). Hasta que esta skill termine, el spike cuenta como abierto.

## 1. Branch de cierre

Precondiciones (si alguna falla, detenete, mostrá el estado o el diff y pedí intervención):

- Working tree limpio (`git status --porcelain` vacío).
- `develop` local igual a `origin/develop` (`git fetch` primero).
- La branch del spike está pusheada (sin commits locales pendientes).
- Las rutas a traer **no existen** en `develop` (`git ls-tree develop -- <ruta>` vacío). Si existen, no las pises: mostrá `git diff develop spike/NNN-<nombre> -- <ruta>` y esperá instrucciones.

Desde `develop`, creá `docs/close-spike-NNN`. Traé solo los documentos desde la branch del spike, **nunca `prototypes/`**:

```bash
git checkout spike/NNN-<nombre> -- specs/spikes/NNN-<nombre>.md specs/decisions/NNNN-<titulo>.md
git diff --cached --stat   # debe listar solo esos dos archivos de specs/
```

## 2. Consolidar

1. Decisión: `status: approved`, `updated`. A partir de acá no se edita más.
2. Aplicá cada ítem de "Consecuencias" a los documentos vivos: `specs/gdd/`, `specs/architecture.md`, specs de features afectadas (si alguna está `approved`, **proponé** el cambio, no lo apliques), `backlog.md`. Los vivos describen la verdad actual: reescribí, no agregues "antes era X".
3. Si la decisión reemplaza a otra: la vieja pasa a `status: superseded`, `superseded_by: DNNNN`, se mueve a `specs/archive/decisions/` y todo vivo que la citaba apunta a la nueva.
4. Ideas o alternativas descartadas: una línea por cada una en `specs/discarded.md` (fecha, idea, motivo, referencia `archive/spikes/NNN-<nombre>.md, DNNNN`) y quitadas de los documentos vivos.
5. Mové el informe: `git mv specs/spikes/NNN-<nombre>.md specs/archive/spikes/`.
6. Actualizá `specs/INDEX.md` si cambió algo visible para el jugador (normalmente no).

## 3. PR

Commit `docs: cierre de spike SNNN y decisión DNNNN`, push y PR a `develop` con: resumen de la decisión, lista de documentos tocados, líneas agregadas a `discarded.md`. El desarrollador mergea.

## 4. Archivar la branch (después del merge)

1. `git tag archive/spike-NNN spike/NNN-<nombre>` y `git push origin archive/spike-NNN`.
2. **Pedí confirmación** y recién entonces borrá la branch local y remota (`git branch -D`, `git push origin --delete`).

## 5. Verificar y reportar

- `specs/spikes/` ya no contiene el spike; está en `specs/archive/spikes/`.
- La branch no existe (local ni remota) y el tag sí.
- Ningún documento vivo referencia contenido descartado.
- Reportá cada punto como verificado o no.

El agente nunca borra documentos: los mueve a `archive/`.
