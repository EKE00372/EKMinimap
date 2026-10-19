# EKMinimap

A square minimap for Titan Reforged 3.80.2 and Mists of Pandaria Classic 5.5.4.

The `Classic` branch maintains both clients in the C4.x release line. Classic Era and Burning Crusade Classic are maintained separately on `Classic_Era`.

## Features

* Square minimap, 1px border and 5px shadow.
* Hide the default minimap border, location text, clock and zoom buttons.
* Keep native mail, tracking, queue and dungeon difficulty indicators.
* Add a square border and shadow to tracking spell icons while preserving transparent service icons.
* Scroll to zoom the map; ALT+scroll temporarily scales the minimap frame.
* Configure the anchor, coordinates and scale in the in-game options; ALT+right click temporarily drags the minimap.
* Right click for the game menu, using Blizzard's current menu framework; middle click opens native tracking.
* Hover over the character icon for experience and watched reputation, including friendship reputation.
* Optional hover clock follows the game's local/server and 12/24-hour settings.
* Style the native WatchFrame with outlined text, a class-colored header, optional star markers and skinned quest item buttons.
* Keep native tracker clicks, context menus, sorting, achievements, scenario objectives and collapse behavior.
* ALT+right drag the tracker header to temporarily move it; leave it untouched when Questie is loaded or styling is disabled.
* Optional world map fade while moving, with configurable opacity; leave native map layout, dragging and scale controls intact.
* Leave the world map untouched when Leatrix Maps or Mapster is loaded.

## Settings

Use `/ekm`, `/ekminimap`, or the right-click menu to open the options.

Feature switches and world map fade settings take effect after reloading the UI.
The apply button updates minimap size/position and tracker position immediately.
Temporary ALT adjustments do not change saved settings. Options close when combat begins.
