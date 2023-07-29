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

return ResizeMe