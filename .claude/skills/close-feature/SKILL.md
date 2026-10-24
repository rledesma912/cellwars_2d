---
name: close-feature
description: Cierra una feature de cellwars_2d en su propia branch y mergea su PR - consolida la spec como as-built, actualiza INDEX.md, GDD y backlog, y archiva plan, tasks y playtest. Usala cuando el desarrollador confirme que jugó y aprueba el PR de una feature.
---

# Close feature

Un solo PR por feature: el cierre es el último commit del PR de la feature, antes del merge.

Precondiciones (si alguna falla, detenete y reportá):

- El desarrollador **confirmó explícitamente** que jugó y que se puede mergear (citá su mensaje).
- El PR de `FNNN` está **abierto** contra `develop`; estás en su branch `feat/NNN-*`, con working tree limpio y la branch al día con su remota.

Fuente de verdad del playtest: el checklist del PR, marcado por el desarrollador (`gh pr view <N> --json body`).

Plan B: si el PR ya se mergeó sin cierre, hacelo en una branch `docs/close-feature-NNN` desde `develop` actualizado y abrí un PR chico con el mismo contenido; el desarrollador lo mergea.

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

## 4. Commit y merge

1. Commit `docs: cierre FNNN` en la branch de la feature y push. Agregá al cuerpo del PR una sección corta "Cierre" con los documentos tocados y las desviaciones aceptadas.
2. Mergeá: `gh pr merge <N> --merge --delete-branch` (la confirmación del desarrollador incluye borrar la branch ya mergeada, local y remota).
3. Volvé a `develop` actualizado (`git checkout develop && git pull`) y avisale en lenguaje llano qué quedó cerrado.

El agente nunca borra documentos: los mueve a `archive/`.
