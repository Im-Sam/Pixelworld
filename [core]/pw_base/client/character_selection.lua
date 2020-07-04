local Ran = false

RegisterNetEvent('pw_base:client:processCharacters')
AddEventHandler('pw_base:client:processCharacters', function(characters)
    if not Ran then
        ShutdownLoadingScreen()
        ShutdownLoadingScreenNui()
        Ran = true
    end
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openui",
        characters = characters,
    })
end)

RegisterNetEvent('pw_base:client:closeBackground')
AddEventHandler('pw_base:client:closeBackground', function()
    SendNUIMessage({
        action = "closebackground",
    })
end)

RegisterNUICallback("createCharacter", function(data, cb)
    TriggerServerEvent('pw_base:server:createCharacter', data)
    cb("ok")
end)

RegisterNUICallback("refreshCharacter", function(data, cb)
    TriggerServerEvent('pw_base:server:refreshCharacters')
    cb("ok")
end)

RegisterNUICallback("spawnCharacter", function(data, cb)
    TriggerServerEvent('pw_base:server:finaliseCharacterSelect', tonumber(data.sid))
    cb("ok")
end)

RegisterNUICallback("newCharacter", function(data, cb)
    TriggerServerEvent('pw_base:server:finaliseNewCharacter', tonumber(data.sid))
    cb("ok")
end)

RegisterNUICallback("selectCharacter", function(data, cb)
    TriggerServerEvent('pw_base:server:characterSelected', data.cid)
    cb("ok")
end)

RegisterNetEvent('pw_base:client:sendSpawns')
AddEventHandler('pw_base:client:sendSpawns', function(spawns, cid)
    SendNUIMessage({
        action = "selectSpawn",
        spawns = spawns
    })
end)

RegisterNUICallback("deleteCharacter", function(data, cb)
    TriggerServerEvent('pw_base:server:deleteCharacter', tonumber(data.cid))
    cb("ok")
end)

RegisterNetEvent('pw_base:client:spawnCharacter')
AddEventHandler('pw_base:client:spawnCharacter', function()
    exports.spawnmanager:forceRespawn()
    DisplayRadar(false)
    local continueSpawn = false
    PW.TriggerServerCallback('pw_base:server:loadCharacterSkin', function(skin)
        if skin ~= nil then
            continueSpawn = setPlayerSpawn(skin)
        else
            continueSpawn = true
        end
    end)
    repeat Citizen.Wait(0) until continueSpawn == true
    TriggerServerEvent('pw_base:server:continueSpawn')
end)

RegisterNetEvent('pw_base:client:destroyNUI')
AddEventHandler('pw_base:client:destroyNUI', function()
    SendNUIMessage({
        action = "closeui",
    })
    SetNuiFocus(false, false)
end)