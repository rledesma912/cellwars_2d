---
name: playtest-checklist
description: Genera el playtest.md de una feature de cellwars_2d desde sus criterios [manual] y [feel], con pasos concretos y qué mirar en el overlay F3, y abre el PR con ese checklist. Usala cuando todas las tasks de código de una feature estén cerradas.
---

# Playtest checklist

Plantilla: `specs/templates/playtest.md`.

## 1. Precondiciones

- Todas las tasks de código cerradas, suite de gdUnit4 en verde.
- Smoke run vía MCP sin errores en consola (hacelo de nuevo ahora; si hay errores, volvé a `implement-task`).

## 2. Generar

`specs/features/NNN-<nombre>/playtest.md` (vía completa). En vía liviana no hay archivo: el checklist va directo en el PR.

- **Preparación**: qué escena abrir (o `main.tscn`), cómo activar el overlay (F3) y qué `.tres` editar para tunear.
- **Checklist [manual]**: un ítem por criterio, con su ID. Formato `- [ ] FNNN-ACnn: <pasos concretos> → <resultado esperado> (overlay: <qué línea mirar>)`.
- **Checklist [feel]**: un ítem por criterio, como pregunta, con qué parámetros del `.tres` mueven esa sensación.
- **Notas del playtest**: vacío; lo llena el desarrollador.

## 3. PR

Commit `docs: playtest FNNN`, push y `gh pr create --base develop`:

- Título: `feat: FNNN <nombre>`.
- Cuerpo: resumen; decisiones de Godot no obvias explicadas (el desarrollador está aprendiendo); criterios `[unit]` con el test que los cubre; checklist de playtest (`[manual]` y `[feel]`) copiado; al final: "**No mergees.** Cuando termines de jugar y tildar, escribile al agente que confirmás: él hace el cierre en esta misma branch y mergea."

Avisale al desarrollador con esta frase: **"Todo finalizado, espero tu test y confirmación para mergear."** (más el enlace al PR).

Nunca marques ítems `[manual]` ni `[feel]`. El desarrollador juega, marca **en el checklist del PR** (es la fuente de verdad que lee `close-feature`) y te confirma. Si reporta bugs o cambios, volvé a `implement-task` en la misma branch; si son de tuning, los ajusta él en el `.tres`.

Con su confirmación explícita: `close-feature`, que cierra en esta misma branch y mergea. Un solo PR por feature.
