# RosterFilter

a WoW 1.12.1 guild frame. based on aux.

access with `/rf`. or set a keybinding in the standard Key Bindings menu.

`/rf scale 0.8` change the window scale

resize the window with CTRL+drag

### filters

```
class/<class name>
rank/<rank name>
rank/<rank name>+
rank/<rank name>-
zone/<zone name>
raid
raid-
online
offline/<days>
lvl/<level>
lvl/<min>-<max>
role/<heal/tank/dps/melee/ranged/caster>

```

### examples
filters are combined with `/`

`class/rogue/rank/raider+/raid` all rogues with rank `raider` or higher that are currently in your raid group.

`online/lvl/60/raid-` online level 60s not currently in your raid group.
