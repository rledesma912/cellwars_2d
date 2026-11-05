---
name: playtest-checklist
description: Genera el playtest.md de una feature de cellwars_2d desde sus criterios [manual] y [feel], con pasos concretos y qué mirar en el overlay F3, abre el PR, guía al director en el chat para que pruebe y anota sus resultados. Usala cuando todas las tasks de código de una feature estén cerradas.
---

# Playtest checklist

Plantilla: `specs/templates/playtest.md`.

## 1. Precondiciones

- Todas las tasks de código cerradas, suite de gdUnit4 en verde.
- Smoke run vía MCP sin errores en consola (hacelo de nuevo ahora; si hay errores, volvé a `implement-task`).

## 2. Generar

`specs/features/NNN-<nombre>/playtest.md`, en las dos vías.

- **Preparación**: qué escena abrir (o `main.tscn`), cómo activar el overlay (F3) y qué `.tres` mueve cada sensación.
- **Checklist [manual]**: un ítem por criterio, con su ID. Formato `- FNNN-ACnn: <pasos concretos> → <resultado esperado> (overlay: <qué línea mirar>)`.
- **Checklist [feel]**: un ítem por criterio, como pregunta, con qué parámetros del `.tres` mueven esa sensación.
- **Resultados**: vacío; lo completás con lo que diga el director.

## 3. PR

Commit `docs: playtest FNNN`, push y `gh pr create --base develop`:

- Título: `feat: FNNN <nombre>`.
- Cuerpo: resumen; decisiones de Godot no obvias explicadas (los directores están aprendiendo); criterios `[unit]` con el test que los cubre; enlace a `playtest.md`; al final: "Los resultados del playtest se anotan en `playtest.md`. El agente cierra y mergea cuando el director confirma en el chat."

## 4. Guiar la prueba

1. Dejá el juego listo para que el director lo pruebe (ver "Probar el juego" en `AGENTS.md`).
2. Avisale con esta frase: **"Todo finalizado, espero tu test y confirmación para mergear."**
3. En el mismo mensaje, explicale en lenguaje llano qué probar: por cada criterio, qué hacer y qué debería ver. El director no necesita abrir el PR.

## 5. Anotar los resultados

- Por cada criterio que comente, en "Resultados": `- FNNN-ACnn: ✅ cumplido | ❌ no cumplido — "<sus palabras>" (YYYY-MM-DD)`.
- **Nunca deduzcas un resultado**, y menos de un `[feel]`. Si no dijo nada de un criterio, preguntale.
- Si reporta bugs o cambios, volvé a `implement-task` en la misma branch. Si son de tuning, el valor lo decide él: lo cambia en el `.tres` o te dicta el valor exacto y lo cambiás vos, citando su mensaje en el commit.
- Commit `docs: resultados playtest FNNN` y push.

Con su confirmación explícita: `close-feature`, que cierra en esta misma branch y mergea. Un solo PR por feature.
