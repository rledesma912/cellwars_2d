---
name: close-feature
description: Cierra una feature de cellwars_2d después del merge - consolida la spec como as-built, actualiza INDEX.md, GDD y backlog, y archiva plan, tasks y playtest. Usala cuando el desarrollador haya mergeado el PR de una feature.
---

# Close feature

Precondición: el PR de `FNNN` está mergeado en `main` y el playtest marcado por el desarrollador.

Branch `docs/close-feature-NNN` desde `main` actualizado.

## 1. Spec as-built

En `specs/features/NNN-<nombre>/spec.md`:

- `status: done`, `updated`.
- Cada criterio con su resultado final (✅ / ajustado / no cumplido + motivo). Los `[manual]` y `[feel]` según lo que marcó el desarrollador en el playtest; nunca los marques vos.
- Sin "Preguntas abiertas": cada una resuelta en la spec o en una decisión. Si queda alguna sin resolver, detenete y preguntá.
- Parámetros de tuning: reemplazá la tabla de valores por una referencia al `.tres` (`game/data/<x>.tres`) con la lista de parámetros, sin números.
- Sección corta "Notas finales": lo aprendido en el playtest que valga la pena recordar.

## 2. Documentos vivos

- `specs/INDEX.md`: línea de la feature bajo su categoría, con enlace a la spec; quitala de "En curso".
- `specs/gdd/`: reflejá el comportamiento real si difiere de lo diseñado (proponé el cambio; el GDD lo aprueba el desarrollador en el PR).
- `specs/backlog.md`: quitá lo hecho; agregá lo que surgió.
- `specs/architecture.md`: si se estableció algo transversal.
- Lo descartado durante la feature: una línea en `specs/discarded.md` y fuera de los vivos.

## 3. Archivar

```bash
mkdir -p specs/archive/features/NNN-<nombre>
git mv specs/features/NNN-<nombre>/{plan,tasks,playtest}.md specs/archive/features/NNN-<nombre>/
```

(Los que existan; en vía liviana solo queda `spec.md`.) En `features/` queda únicamente `spec.md`.

## 4. PR

Commit `docs: cierre FNNN`, push y PR a `main` con la lista de documentos tocados. El desarrollador revisa y mergea. Borrá la branch `feat/NNN-*` solo con confirmación.

El agente nunca borra documentos: los mueve a `archive/`.
