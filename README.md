# BGObjectiveBars

Addon de World of Warcraft: Mists of Pandaria (5.4.8, `## Interface: 50400`) que
reemplaza los indicadores numéricos de objetivos de campo de batalla por **dos
barras** en la parte superior de la pantalla:

- **Alianza** a la izquierda (azul)
- **Horda** a la derecha (rojo)

Cada barra muestra el progreso del objetivo del BG (capturas de bandera, puntos de
equipo, orbes, vagonetas, etc.) en formato `actual/máximo`, junto con iconos POI
sobre las bases.

![BGObjectiveBars](images/BGObjectiveBars.png)

## Campos de batalla soportados

Warsong Gulch, Twin Peaks, Arathi Basin, Battle for Gilneas, Eye of the Storm,
Deepwind Gorge, Windvale Market, Alterac Valley, Isle of Conquest, Temple of
Kotmogu, Silver Shard Mines y Seething Shore.

## Instalación

1. Copiá la carpeta `BGObjectiveBars/` (la que está dentro de este repo) a
   `World of Warcraft/Interface/AddOns/`:

   ```powershell
   Copy-Item -Recurse -Force .\BGObjectiveBars "N:\Games\Mists of Pandaria\Interface\AddOns\BGObjectiveBars"
   ```

2. Reiniciá la interfaz en el juego con `/rl`.
3. Activalo en la lista de addons si hace falta ("Load out of date addons" puede ser
   necesario según el cliente).

## Uso

- `/bgbars` — muestra u oculta las barras.

Las barras solo aparecen en los campos de batalla soportados.

## Cómo funciona

- Lee los world states del BG a través de la API custom de PandaWoW
  (`C_PandaWoWAPI.GetWorldState`), con fallback a `GetWorldState` /
  `GetWorldStateInfo`.
- Oculta los indicadores numéricos stock (`AlwaysUpFrame1..N`) mientras las barras
  están visibles.
- Los iconos POI se dibujan con atlases de texturas incluidos
  (`textures/*.blp`); si falta un atlas cae a colores sólidos.

## Estructura del repositorio

Este repositorio **contiene** al addon; no es la carpeta live que carga el cliente.

```
BGObjectiveBars-MoP/
├── BGObjectiveBars/     # fuente del addon (se copia a Interface/AddOns/)
│   ├── BGObjectiveBars.lua
│   ├── BGObjectiveBars.toc
│   └── textures/
├── images/              # screenshots
├── AGENTS.md            # notas de desarrollo
├── CHANGELOG.md
├── LICENSE
└── README.md
```

## Créditos y licencia

- Código bajo licencia MIT (ver `LICENSE`).
- Portado del parche custom `WorldStateFrame` de PandaWoW.
- Usa únicamente la API estándar de 5.4 y atlases de texturas del UI stock.
