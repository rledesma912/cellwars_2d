---
id: D0001
type: decision
status: approved
superseded_by:
links: { gdd: [], decisions: [], spike: }
updated: 2026-10-23
---

# 0001: Modelo de branches develop + main

- Origen: pedido del desarrollador (fuera de spikes y features). Aprobada en la conversación del 2026-10-23 ("Vamos con develop").

## Contexto

Hasta ahora todo el trabajo salía de `main` y volvía a `main` por PR, así que `main` mezclaba lo terminado con lo publicado. El desarrollador quiere que `main` represente solo lo que pasó a "producción" (lo publicado en itch.io).

## Opciones consideradas

- **`main` + tags**: todo se integra en `main` y una versión publicada es un tag `vX.Y.Z`. Una sola branch permanente y menos pasos; pero `main` no distingue lo terminado de lo publicado.
- **`develop` + `main` (Git Flow simplificado)**: el trabajo se integra en `develop` y `main` solo recibe releases. Separación explícita; cuesta un paso extra por release.

## Decisión

`develop` + `main`:

- `develop` es la branch de integración. Toda branch de trabajo (`feat/*`, `spike/*`, `docs/*`, `chore/*`) sale de `develop` y vuelve a `develop` por PR.
- `main` solo recibe releases: PR de `develop` a `main` titulado `release: vX.Y.Z` y, después del merge, tag anotado `vX.Y.Z` sobre `main`. Los builds para itch.io se exportan siempre desde un tag. El release lo decide el desarrollador.
- Hotfix (solo si hace falta corregir algo publicado sin arrastrar lo que está en `develop`): `hotfix/<nombre>` desde `main`, PR a `main` + tag de parche, y después merge de `main` a `develop`.
- Las branches `spike/*` siguen sin mergearse: su código no llega ni a `develop` ni a `main`.

## Consecuencias (qué se actualiza: GDD, architecture.md, specs)

- `CLAUDE.md`: sección Git, principio 1 y ciclo de vida del spike.
- Skills `spike`, `spec-feature`, `close-spike`, `close-feature`, `curate-specs`, `playtest-checklist`, `godot-conventions`: `develop` en lugar de `main` como base y destino de PRs.
- `README.md`: mención de `prototypes/`.
- GitHub (lo hace el desarrollador): branch por defecto `develop`, para que los PRs apunten ahí por defecto.
