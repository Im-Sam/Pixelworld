local requestedSpawns = {}

RegisterServerEvent('pw_base:server:createCharacter')
AddEventHandler('pw_base:server:createCharacter', function(data)
    local _src = src or source
    if Players[_src] and Users[Players[_src]] then
        local created
        created = Users[Players[_src]].createCharacter(data)
        repeat Wait(0) until created ~= nil
        TriggerClientEvent('pw_base:client:processCharacters', _src, Users[Players[_src]].retreiveCharacters())
    end
end)

RegisterServerEvent('pw_base:server:characterSelected')
AddEventHandler('pw_base:server:characterSelected', function(cid, sid)
    local _src = src or source
    if Players[_src] and Users[Players[_src]] then
        local loaded = Users[Players[_src]].loadCharacter(_src, cid)
        repeat Wait(0) until loaded == true
        TriggerClientEvent('pw_base:client:spawnCharacter', _src)
    end
end)

RegisterServerEvent('pw_base:server:refreshCharacters')
AddEventHandler('pw_base:server:refreshCharacters', function(src)
    local _src = src or source
    if Players[_src] and Users[Players[_src]] then
        TriggerClientEvent('pw_base:client:processCharacters', _src, Users[Players[_src]].retreiveCharacters())
    end
end)

PW.RegisterServerCallback('pw_base:charCreator:saveSkin', function(source, cb, skin, label, shop)
    local _src = source
    if Players[_src] and Users[Players[_src]] then
        local success = Users[Players[_src]]:Character().saveOutfit(skin, label)
        if success and not shop then
            local newChar = Users[Players[_src]]:Character().toggleNewCharacter()
        end
        cb(success)
    end
end)

RegisterServerEvent('pw_base:server:deleteCharacter')
AddEventHandler('pw_base:server:deleteCharacter', function(cid)
    local _src = source
    if Players[_src] and Users[Players[_src]] then
        local deleted = Users[Players[_src]].deleteCharacter(cid)
        if deleted then
            TriggerClientEvent('pw_base:client:processCharacters', _src, Users[Players[_src]].retreiveCharacters())
        end
    end
end)

PW.RegisterServerCallback('pw_base:server:loadCharacterSkin', function(source, cb)
    local _src = source
    if Players[_src] and Users[Players[_src]] then
    -- The Skin for the Ped will get loaded here. This is well before the person should actually see anything on the screen. --
        cb(Users[Players[_src]]:Character():getSkin())
    end
end)

RegisterServerEvent('pw_base:server:continueSpawn')
AddEventHandler('pw_base:server:continueSpawn', function()
    local _src = source
    if Users[Players[_src]]:Character():newCharacter() then
        local steam = GetPlayerIdentifiers(_src)[1]
        TriggerClientEvent('pw_base:client:characterCreation', _src, Users[Players[_src]]:Character():getGender(), steam)
        TriggerClientEvent('pw_base:client:destroyNUI', _src)
    else
        TriggerEvent('pw_base:server:loadAvaliableSpawns', _src)
    end
end)

RegisterServerEvent('pw_base:server:finaliseCharacterSelect')
AddEventHandler('pw_base:server:finaliseCharacterSelect', function(spawnid)
    local _src = source
    if requestedSpawns[_src][spawnid].type == "Property" then
        TriggerClientEvent('pw_properties:spawnedInHome', _src, tonumber(requestedSpawns[_src][spawnid].pid))
    end
    TriggerClientEvent('pw_base:client:sendToCity', _src, requestedSpawns[_src][spawnid].coords)
    TriggerClientEvent('pw_base:client:destroyNUI', _src)
    requestedSpawns[_src] = nil
end)

RegisterServerEvent('pw_base:server:finaliseNewCharacter')
AddEventHandler('pw_base:server:finaliseNewCharacter', function()
    local _src = source
    TriggerClientEvent('pw_base:client:characterCreation', _src)
    TriggerClientEvent('pw_base:client:destroyNUI', _src)
end)

RegisterServerEvent('pw_base:server:loadAvaliableSpawns')
AddEventHandler('pw_base:server:loadAvaliableSpawns', function(src)
    local _src = src
    if Players[_src] and Users[Players[_src]] then
        requestedSpawns[_src] = Users[Players[_src]].spawnPositions()
        TriggerClientEvent('pw_base:client:sendSpawns', _src, requestedSpawns[_src])
    end
end)

PW.RegisterServerCallback('pw_base:getDefaultSpawns', function(source, cb)
    local _src = source
    if Players[_src] and Users[Players[_src]] then
        cb(Users[Players[_src]].spawnPositions(true))
    end
end)

RegisterServerEvent('pw_base:server:saveCharacter')
AddEventHandler('pw_base:server:saveCharacter', function(data)
    local _src = src or source
    if Players[_src] and Users[Players[_src]] then
        local sendSkin = {['name'] = data.outfitName.value, ['skin'] = data.outfitName.data}
        Users[Players[_src]]:Character():saveOutfit(sendSkin)
        Users[Players[_src]]:Character():toggleNewCharacter()
        requestedSpawns[_src] = Users[Players[_src]].spawnPositions()
        TriggerClientEvent('pw_base:client:sendToCity', _src, requestedSpawns[_src][1].coords)
        TriggerClientEvent('pw_base:client:destroyNUI', _src)
        requestedSpawns[_src] = nil
    end
end)

RegisterServerEvent('pw:playerSpawned')
AddEventHandler('pw:playerSpawned', function(destroy)
    local _src = source
    if Players[_src] and Users[Players[_src]] then
        local getCharacterDetails = {
            ['name'] = Users[Players[_src]]:Character():getName(),
            ['cash'] = Users[Players[_src]]:Cash():getCash(),
            ['email'] = Users[Players[_src]]:Character():getEmail(),
            ['sex'] = Users[Players[_src]]:Character():getGender(),
            ['twitter'] = Users[Players[_src]]:Character():getTwitter(),
            ['health'] = Users[Players[_src]]:Character():getHealth(),
            ['dob'] = Users[Players[_src]]:Character():getDob(),
            ['cid'] = Users[Players[_src]]:Character():getCID(),
            ['uid'] = Users[Players[_src]]:User():getUID(),
            ['job'] = Users[Players[_src]]:Job():getJob(),
            ['needs'] = Users[Players[_src]]:Character():getNeeds(),
            ['permission'] = Users[Players[_src]]:User():getPermission(),
            ['gang'] = Users[Players[_src]]:Gang().getGang(),
        }
        TriggerClientEvent('pw:characterLoaded', _src, getCharacterDetails)
        TriggerEvent('pw:characterLoaded', _src)
        if destroy then
            TriggerClientEvent('pw_base:doSpawnCameras', _src, destroy)
        end
    end
end)