---
name: close-feature
description: Cierra una feature de cellwars_2d después del merge - consolida la spec como as-built, actualiza INDEX.md, GDD y backlog, y archiva plan, tasks y playtest. Usala cuando el desarrollador haya mergeado el PR de una feature.
---

# Close feature

Precondiciones (si alguna falla, detenete y reportá): el PR de `FNNN` está mergeado en `main`; working tree limpio; `main` al día con `origin/main`.

Fuente de verdad del playtest: el checklist del PR, marcado por el desarrollador (`gh pr view <N> --json body`).

Branch `docs/close-feature-NNN` desde `main` actualizado.

## 1. Spec as-built

**Regla de `done`**: la spec pasa a `done` solo si todos los criterios están cumplidos, o si cada desviación (criterio no cumplido, ajustado o sin marcar en el PR) tiene una **aceptación explícita** del desarrollador. Si falta alguna, listá las desviaciones y preguntá; no cierres.

En `specs/features/NNN-<nombre>/spec.md`:

- `status: done`, `updated`.
- Cada criterio con su resultado final (✅ / ajustado / no cumplido). Los `[manual]` y `[feel]` según lo que marcó el desarrollador en el PR; nunca los marques vos.
- Cada desviación aceptada, en "Notas finales": criterio, qué pasó, motivo y que fue aceptada por el desarrollador.
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

Mové solo los archivos que existan (en vía liviana puede no haber ninguno):

```bash
src=specs/features/NNN-<nombre>; dst=specs/archive/features/NNN-<nombre>
for f in plan.md tasks.md playtest.md; do
  if [ -f "$src/$f" ]; then mkdir -p "$dst" && git mv "$src/$f" "$dst/"; fi
done
ls "$src"   # debe listar únicamente spec.md
```

Si `ls` muestra algo más que `spec.md`, detenete y preguntá qué hacer con ese archivo.

## 4. PR

Commit `docs: cierre FNNN`, push y PR a `main` con la lista de documentos tocados. El desarrollador revisa y mergea. Borrá la branch `feat/NNN-*` solo con confirmación.

El agente nunca borra documentos: los mueve a `archive/`.
