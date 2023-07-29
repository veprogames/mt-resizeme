# resizeme

Minetest Mod

Lets you scale the player with a command or through Lua.

Example: `/resizeme 0.5` sets your scale to 0.5

This mod also exposes an API, and should be used something like this:

```lua
local ResizeMe = dofile(minetest.get_mod_path("resizeme").."/api.lua")

-- scale singleplayer to 3x
ResizeMe.resize("singleplayer", 3)
```