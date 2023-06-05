r = menu.my_root()

local fov = 0.05
local ABdist = 170
local DEheight = 100
local center = 0.5
local circle = true
local X, Y = memory.alloc(4), memory.alloc(4)
local Wveh = {970385471,-1281684762,-638562243,1483171323,884483972,2069146067,1181327175,-42959138,-82626025,1565978651,-1386191424,1692272545,-1700874274}

--[[
X-Axis: Pitch        (Rotation or movement left or right)
Y-Axis: Roll         (Rotation or movement up or down)
Z-Axis: Yaw/Heading  (Rotation or movement from side to side)
]]

local function get_hash(entity)native_invoker.begin_call()native_invoker.push_arg_int(entity)native_invoker.end_call("9F47B058362C84B5")return native_invoker.get_return_value_int()end
local function pid_to_ped(player)native_invoker.begin_call();native_invoker.push_arg_int(player);native_invoker.end_call("50FAC3A3E030A6E1");return native_invoker.get_return_value_int();end
local function get_vehicle_ped_is_using(ped)native_invoker.begin_call();native_invoker.push_arg_int(ped);native_invoker.end_call("6094AD011A2EA87D");return native_invoker.get_return_value_int();end
local function get_entity_heading(entity)native_invoker.begin_call();native_invoker.push_arg_int(entity);native_invoker.end_call("E83D4F9BA2A38914");return native_invoker.get_return_value_float();end
local function get_entity_velocity(entity)native_invoker.begin_call();native_invoker.push_arg_int(entity);native_invoker.end_call("4805D2B1D8CF94A9");return native_invoker.get_return_value_vector3();end
local function get_height_above_ground(entity)native_invoker.begin_call();native_invoker.push_arg_int(entity);native_invoker.end_call("1DD55701034110E5");return native_invoker.get_return_value_float();end
local function ped_dead_or_dying(ped, p1)native_invoker.begin_call();native_invoker.push_arg_int(ped);native_invoker.push_arg_bool(p1);native_invoker.end_call("3317DEDB88C95038");return native_invoker.get_return_value_bool();end
local function get_entity_coords(entity, alive)native_invoker.begin_call();native_invoker.push_arg_int(entity);native_invoker.push_arg_bool(alive);native_invoker.end_call("3FEF770D40960D5A");return native_invoker.get_return_value_vector3();end
local function clear_los_to_entity(entity1, entity2, traceType)native_invoker.begin_call();native_invoker.push_arg_int(entity1);native_invoker.push_arg_int(entity2);native_invoker.push_arg_int(traceType);native_invoker.end_call("FCDFF7B72D23A1AC");return native_invoker.get_return_value_bool();end
local function set_entity_rotation(entity, pitch, roll, yaw, rotationOrder, p5)native_invoker.begin_call();native_invoker.push_arg_int(entity);native_invoker.push_arg_float(pitch);native_invoker.push_arg_float(roll);native_invoker.push_arg_float(yaw);native_invoker.push_arg_int(rotationOrder);native_invoker.push_arg_bool(p5);native_invoker.end_call("8524A8B0171D5E07");end
local function get_bone_coords(ped, boneId, offsetX, offsetY, offsetZ)native_invoker.begin_call();native_invoker.push_arg_int(ped);native_invoker.push_arg_int(boneId);native_invoker.push_arg_float(offsetX);native_invoker.push_arg_float(offsetY);native_invoker.push_arg_float(offsetZ);native_invoker.end_call("17C07FC640E86B4E");return native_invoker.get_return_value_vector3();end
local function get_screen_coord_from_world_coord(worldX,worldY,worldZ, screenX,screenY)native_invoker.begin_call();native_invoker.push_arg_float(worldX);native_invoker.push_arg_float(worldY);native_invoker.push_arg_float(worldZ);native_invoker.push_arg_pointer(screenX);native_invoker.push_arg_pointer(screenY);native_invoker.end_call("34E82F05DF2974F5");return native_invoker.get_return_value_bool();end

function intable(t, k)
    for _, v in t do
        if v == k then
            return true
        end
    end
    return false
end

function veh()
    return get_vehicle_ped_is_using(players.user_ped())
end

function inArea(x,y,z, x2,y2,z2, off)
    local distance = math.sqrt((x - x2)^2 + (y - y2)^2 + (z - z2)^2)
    return distance <= off 
end

function set_heading(pid)
    local vc = get_entity_coords(veh())
    local p,v
    if get_vehicle_ped_is_using(pid_to_ped(pid)) > 0 then
        p = get_entity_coords(get_vehicle_ped_is_using(pid_to_ped(pid)))
        v = v3(get_entity_velocity(get_vehicle_ped_is_using(pid_to_ped(pid))))
    else
        p = get_bone_coords(pid_to_ped(pid),0, 0,0,0)
        v = v3(get_entity_velocity(pid_to_ped(pid)))
    end
    local a = v3(vc.x, vc.y, vc.z)
    local b = v3(p.x,p.y,p.z)
    local Fp = v3(b.x + (v:getX() * 0.05), b.y + (v:getY() * 0.05), b.z + (v:getZ() * 0.05))
    local Fb = v3(Fp:getX(), Fp:getY(), Fp:getZ())
    local lookRotation = v3.lookAt(a, Fb)
    set_entity_rotation(veh(), lookRotation:getX(), lookRotation:getY(), lookRotation:getZ(), 1, false)
end

function draw_circle() 
    local sX, sY = directx.get_client_size()
    local radius = fov
    local rad = 180
    
    for i = 1, rad do
        local angle1 = (i - 1) * (2 * math.pi/rad)
        local x1 = center + radius * math.cos(angle1) * sY/sX
        local y1 = center + radius * math.sin(angle1)
  
        local angle2 = i * (2 * math.pi/rad)
        local x2 = center + radius * math.cos(angle2) * sY/sX
        local y2 = center + radius * math.sin(angle2)

    directx.draw_line(x1,y1,x2,y2, 1,1,1,0.8)
    end
end

function target()

    local radius = fov

    for _, pid in pairs(players.list(false)) do 
        
        local height = get_height_above_ground(veh())
        local vc = get_entity_coords(veh())
        local e = get_entity_coords(pid_to_ped(pid))
        get_screen_coord_from_world_coord(e.x,e.y,e.z, X,Y)
        local xx, yy = memory.read_float(X), memory.read_float(Y)
        local sdist = (xx-center)*(xx-center)+(yy-center)*(yy-center)
        local srad  = radius*radius
            if inArea(e.x,e.y,e.z, vc.x,vc.y,vc.z, ABdist) and intable(Wveh, get_hash(veh())) and sdist <= srad and clear_los_to_entity(veh(),pid_to_ped(pid),17) and not 
                (ped_dead_or_dying(pid_to_ped(pid), 1) or height < DEheight or players.is_in_interior(pid)) 
            then
                set_heading(pid)
            break
        end
    end
end

r:toggle_loop("Aircraft Aimbot", {'aa'}, "", function()
    target()
end)
r:slider_float("Aim FOV", {'aimfov'}, '', 0, 50, 5, 1, function(state)
    fov = state/100
end)
r:slider("Activation Distance", {'acdist'}, 'when to aim at Player', 0, 500, 170, 10, function(state)
    ABdist = state
end)
r:slider('Deactivate Distance', {'deacdist'}, 'when to stop when near to ground5', 0,500,70,10, function(state)
    DEheight = state
end)
r:toggle_loop("Circle", {'c'}, "", function()
    draw_circle()
end)


util.keep_running()
