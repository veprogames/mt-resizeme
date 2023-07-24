local ResizeMe = {}

local function scale_collision_box(box, size)
    for i = 1, #box do
        box[i] = box[i] * size
    end
    return box
end

local function get_player_size(player)
    local meta = player:get_meta()
    if meta:contains("resizeme") then
        return meta:get_float("resizeme")
    end
    return 1.0
end

ResizeMe.resize = function(player, size, absolute)
    local props = player:get_properties()
    local meta = player:get_meta()
    local previous_size = get_player_size(player)
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
    player:set_physics_override({
        speed = oldphysics.speed * factor,
        jump = oldphysics.jump * factor,
        gravity = oldphysics.gravity * factor,
    })

    meta:set_float("resizeme", size)
    player:set_properties(props)
end

minetest.register_chatcommand("ResizeMe", {
    params = "size - float",
    func = function (name, params)
        local size = tonumber(params)
        local player = minetest.get_player_by_name(name)
        if player then
            ResizeMe.resize(player, size)
        end
    end
})

minetest.register_on_joinplayer(function(player, last_login)
    if player then
        print(get_player_size(player))
        minetest.after(0, function ()
            ResizeMe.resize(player, get_player_size(player), true)
        end)
    end
end)

return ResizeMe