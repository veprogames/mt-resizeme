local ResizeMe = {}

local function scale_collision_box(box, size)
    for i = 1, #box do
        box[i] = box[i] * size
    end
    return box
end

function ResizeMe.get_size(player)
    local meta = player:get_meta()
    if meta:contains("resizeme_size") then
        return meta:get_float("resizeme_size")
    end
    return 1.0
end

ResizeMe.resize = function(player, size, absolute)
    local props = player:get_properties()
    local meta = player:get_meta()
    local previous_size = ResizeMe.get_size(player)
    local factor = size / previous_size
    if absolute then
        factor = size
    end

    local oldsize = props.visual_size
    props.visual_size = {
        x = oldsize.x * factor,
        y = oldsize.y * factor,
        z = oldsize.z * factor,
    }

    props.eye_height = props.eye_height * factor

    local oldphysics = player:get_physics_override()
    local new_jump_height = oldphysics.jump * factor
    player:set_physics_override({
        speed = oldphysics.speed * factor,
        jump = oldphysics.jump * factor,
        gravity = oldphysics.gravity * factor,
    })

    local oldcol = props.collisionbox
    props.collisionbox = scale_collision_box(oldcol, factor)

    local oldsel = props.selectionbox
    props.selectionbox = scale_collision_box(oldsel, factor)

    props.stepheight = 0.01 + new_jump_height / 2

    meta:set_float("resizeme_size", size)
    player:set_properties(props)
end

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

return ResizeMe