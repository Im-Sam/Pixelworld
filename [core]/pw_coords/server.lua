PW = nil

TriggerEvent('pw:getSharedObject', function(obj)
    PW = obj
end)

PW.RegisterServerCallback('pw_coords:checkPermission', function(source, cb)
    local _src = source
    local _user = exports.pw_base:Source(_src)
    cb(_user:User():getPermission())
end)

RegisterServerEvent('pw_coords:saveCoords')
AddEventHandler('pw_coords:saveCoords', function(data)
    local _src = source
    if data ~= nil then
        local _user = exports.pw_base:Source(_src)

        MySQL.Async.insert("INSERT INTO saved_coords (`name`,`x`,`y`,`z`,`h`,`type`, `description`,`savedby`) VALUES (@name, @x, @y, @z, @h, @type, @description, @by)", {
            ['@name']           = data.name,
            ['@x']              = data.xpos,
            ['@y']              = data.ypos,
            ['@z']              = data.zpos,
            ['@h']              = data.hpos,
            ['@type']           = data.type,
            ['@description']    = data.description,
            ['@by']             = _user:Character():getName(),
        }, function(inserted)
            if inserted > 0 then
                if data.type == "spawn" then
                    MySQL.Async.insert("INSERT INTO default_spawns (`spawn_name`,`x`,`y`,`z`,`h`) VALUES (@name, @x, @y, @z, @h)", {
                        ['@name'] = data.name,
                        ['@x']    = data.xpos,
                        ['@y']    = data.ypos,
                        ['@z']    = data.zpos,
                        ['@h']    = data.hpos, 
                    }, function() end)
                end
            end
        end)
    end
end)