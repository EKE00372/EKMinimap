# EKMinimap

A square minimap for Classic Era 1.15.9 and Burning Crusade Classic 2.5.6.

The `Classic_Era` branch maintains both clients in the C2.x release line, replacing the separate `Classic_TBC` branch. Both clients use the same addon package.

## Features

* Square minimap, 1px border and 5px shadow.
* Hide the default minimap border, location text, clock and zoom buttons.
* Indicator:
  * new mail
  * tracking
* Scale
  * Scroll to scale map
  * ALT+scroll to scale frame
* Move
  * Configure the anchor, coordinates and scale in the in-game options.
  * ALT+right click to temporarily drag the minimap.
* Right click for the game menu, using Blizzard's current menu framework.
* Middle click opens the native tracking menu on TBC.
* Hover over the character icon to show experience and watched reputation.
* Optional hover clock follows the game's local/server and 12/24-hour settings.
* Quest watch frame
  * Outline
  * Class color title, optional star markers and clickable quest titles.
  * ALT+right click the title to temporarily drag the tracker.
  * Leaves the tracker untouched when Questie is loaded or styling is disabled.
* Map
  * Movable floating map; ALT+right click to drag.
  * No background
  * Optional fade while moving and configurable scale.
  * Keeps the native maximize, minimize and position reset controls.
  * Automatically leaves the map untouched when Leatrix Maps is loaded.

## Settings

Use `/ekm`, `/ekminimap`, or the right-click menu to open the options.

Feature switches and world map settings take effect after reloading the UI.
The apply button updates minimap size/position and tracker position immediately.
Temporary ALT adjustments do not change saved settings. Options close when combat begins.
