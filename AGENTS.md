# AGENTS.md — BGObjectiveBars

Addon de World of Warcraft Mists of Pandaria 5.4.8 (`## Interface: 50400`): barras
de objetivos de campos de batalla (capturas de bandera / puntos de equipo).
Ported from the PandaWoW custom `WorldStateFrame` patch. Barra izquierda = Alianza,
barra derecha = Horda.

## Layout del repo (importante)

Este repo **contiene** al addon, no es el addon. La carpeta que WoW carga es
`Interface/AddOns/BGObjectiveBars/`, y es una **copia desplegada** (sync manual),
NO la fuente. La fuente de verdad es este repo:

- `BGObjectiveBars/` — fuente del addon (esto es lo que se copia al cliente).
- `images/` — screenshots para el README.
- Raíz: `README.md`, `CHANGELOG.md`, `LICENSE`, `.gitignore`, este `AGENTS.md`.

Para probar cambios en el juego, copiar la fuente a la carpeta live:

```powershell
Copy-Item -Recurse -Force .\BGObjectiveBars "N:\Games\Mists of Pandaria\Interface\AddOns\BGObjectiveBars"
```

Luego `/rl` en el cliente. **No edites la carpeta live**: los cambios se pierden en
el próximo sync. Editá siempre `BGObjectiveBars-MoP/BGObjectiveBars/`.

## Estructura del addon

- `BGObjectiveBars.lua` es **todo** el addon (barras, iconos POI, eventos, slash
  command). Es el único archivo en `BGObjectiveBars.toc`; un `.lua` nuevo **no** se
  carga salvo que se agregue al `.toc`.
- `textures/*.blp` son atlases de iconos incluidos. Las coordenadas de la tabla
  `ATLAS` (arriba del `.lua`) son **dumps hardcodeados de PandaWoW** — editar con
  cuidado; `SetBundledTexture` cae a colores sólidos si falta un nombre.

## Quirks del cliente (solo 5.4.x — no "modernizar")

- **No hay `C_Timer`** en 5.4.7/18273. El ticker de refresco de POIs usa un throttle
  `OnUpdate` común (ver el frame `ticker`). No reemplazar por `C_Timer`.
- Los world states se leen vía el custom de PandaWoW `C_PandaWoWAPI.GetWorldState`,
  con fallback a `GetWorldState` / `GetWorldStateInfo` (ver `GetWorldStateValue`).
- Los map area IDs de los BGs están hardcodeados arriba del `.lua`; al agregar un BG
  nuevo hay que sumarlo ahí y en `BattlegroundPOITextureIdxToAtlas` /
  `BattlegroundWorldStateToAtlas`.

## Orden de carga / dependencia del UI stock

El addon hace `hooksecurefunc("WorldStateAlwaysUpFrame_Update", ...)` y lee
`_G["AlwaysUpFrame"..i]` a nivel de archivo, así que depende de que el código de
Blizzard `WorldStateFrame` esté cargado primero. Si esa función es nil al cargar,
tira error — tenerlo en cuenta antes de agregar `## LoadOnDemand` o reordenar.

## Testing

No hay build/lint/test. Lanzar el cliente, habilitar el addon, `/rl`,
`/console scriptErrors 1`, y `/bgbars` (el slash command alterna la visibilidad).
Los cambios toman efecto tras `/rl`, no en caliente.
