local occupiedRooms = {}
TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)

MySQL.ready(function ()
    MySQL.Sync.execute("UPDATE `motel_rooms` SET `occupied` = 0, `occupier` = 0", {})
    MySQL.Async.fetchAll("SELECT * FROM `motel_rooms`", {}, function(rm)
        for i = 1, #rm do
            room[tonumber(rm[i].room_id)] = loadMotelRoom(tonumber(rm[i].room_id))
        end
    end)
end)

PW.RegisterServerCallback('pw_motels:server:requestRooms', function(source, cb)
    cb(motelRooms)
end)

PW.RegisterServerCallback('pw_motels:server:requestMotelRooms', function(source, cb, motelId)
    cb(MySQL.Sync.fetchAll("SELECT * FROM `motel_rooms` WHERE `motel_id` = @motelId AND `motel_type` = 'Door'", { ['@motelId'] = motelId }))
end)
 
PW.RegisterServerCallback('pw_motels:server:requestMotels', function(source, cb)
    cb(MySQL.Sync.fetchAll("SELECT * FROM `motels`", {}))
end)

RegisterServerEvent('pw_motels:server:toggleDoor')
AddEventHandler('pw_motels:server:toggleDoor', function(k)
    if room[tonumber(k)] then
        room[tonumber(k)].toggleLock()
    end
end)

RegisterServerEvent('pw_motels:server:assignRoom')
AddEventHandler('pw_motels:server:assignRoom', function(src, cid, cb)
    local found = false
    local freeRooms = {}
    print(' ^1[PixelWorld Motels] ^5- ^4Assigning Motel Room to ^6'..tonumber(cid)..'^7')

    for k, v in pairs(room) do
        if v.getOccupier() == nil then
            table.insert(freeRooms, k)
        end
    end

    local selectRandomRoom = math.random(1, #freeRooms)

    if selectRandomRoom ~= nil and selectRandomRoom > 0 and room[selectRandomRoom].getOccupier() == nil then
        room[selectRandomRoom].occupyRoom(src, tonumber(cid))
        occupiedRooms[tonumber(cid)] = i
        local info = room[selectRandomRoom].getMotelRoomInfo()
        print(' ^1[PixelWorld Motels] ^5- ^6'..info.motelName..' ^4Room ^6#'..info.room..' ^4has been assigned to ^6'..tonumber(cid)..'^7')
        cb(room[selectRandomRoom].spawnInfo())
        found = true
    end

    if not found then
        print(' ^1[PixelWorld Motels] ^5- ^4No Unoccupied Motel Room could be located^7')
        cb(nil)
    end
    freeRooms = {}
end)

RegisterServerEvent('pw_motels:server:requestRoom')
AddEventHandler('pw_motels:server:requestRoom', function(cid, cb)
    local found = false
    for k, v in pairs(room) do
        if v.getOccupier() == tonumber(cid) then
            cb(v.spawnInfo())
            found = true
            break
        end
    end

    if not found then
        cb(nil)
    end
end)

PW.RegisterServerCallback('pw_motels:server:selectOutfits', function(source, cb)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    cb(_char:Character().getOutfits())
end)

RegisterServerEvent('pw_motels:server:changeClothing')
AddEventHandler('pw_motels:server:changeClothing', function(data)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    local _skin = _char:Character().setSkin(tonumber(data.outfit))
    TriggerClientEvent('pw_base:charCreator:setSkin', _src, json.decode(_skin))
end)

RegisterServerEvent('pw_motels:server:changeClothing')
AddEventHandler('pw_motels:server:changeClothing', function(data)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    local _skin = _char:Character().setSkin(tonumber(data.outfit))
    TriggerClientEvent('pw_base:charCreator:setSkin', _src, json.decode(_skin))
end)

RegisterServerEvent('pw_motels:server:deleteClothing')
AddEventHandler('pw_motels:server:deleteClothing', function(data)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    local _skin = _char:Character().deleteOutfit(tonumber(data.outfit))

    if _skin then
        TriggerClientEvent('pw_motels:client:selectClothing', _src)
    end
end)

RegisterServerEvent('pw_motels:server:unassignRoom')
AddEventHandler('pw_motels:server:unassignRoom', function(src, cid, motel)
    local found = false
    for k, v in pairs(room) do
        if v.getOccupier() == tonumber(cid) then
            local info = v.getMotelRoomInfo()
            v.resetRoom()
            print(' ^1[PixelWorld Motels] ^5- ^6'..info.motelName..' ^4Room ^6#'..info.room..' ^4has been unassigned from ^6'..tonumber(cid)..'^7')
            found = true
            break
        end
    end

    if not found then
        print(' ^1[PixelWorld Motels] ^5- ^4There was no motel room assigned to ^6'..cid..'^7')
    end
end)