local ResizeMe = dofile(minetest.get_modpath("resizeme").."/api.lua")

minetest.register_privilege("resizeme_resize", {
    give_to_singleplayer = false,
    give_to_admin = true,
})

minetest.register_chatcommand("resizeme", {
    privs = { resizeme_resize = true },
    description = "Change your size",
    params = "<size>",
    func = function (name, params)
        local size = tonumber(params)
        local player = minetest.get_player_by_name(name)
        if player ~= nil and size ~= nil then
            if size <= 0.0 then
                minetest.chat_send_player(name, "size cannot be negative or 0")
                return false
            end
            ResizeMe.resize(player, size)
            return true
        end
        return false
    end
})

minetest.register_on_joinplayer(function(player, last_login)
    if player ~= nil then
        minetest.after(0, function ()
            ResizeMe.resize(player, ResizeMe.get_size(player), true)
        end)
    end
end)