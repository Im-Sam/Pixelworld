PW = nil
characterLoaded, playerData = false, nil

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(data)
    playerData = data
    characterLoaded = true
end)

RegisterNUICallback("closeNUI", function(data, cb)
    TriggerEvent('pw_animations:cancelAnim')
    SetNuiFocus(false, false)
end)

RegisterNetEvent('pw_notes:client:openNote')
AddEventHandler('pw_notes:client:openNote', function(id, message)
    SendNUIMessage({
        type = "openNotePadContent",
        message = message,
        id = id
    })
    SetNuiFocus(true, true)
    TriggerEvent('pw_animations:doAnimation', "notes")
end)

RegisterNetEvent('pw_notes:client:newNote')
AddEventHandler('pw_notes:client:newNote', function()
    startNewNote()
end)

function startNewNote()
    TriggerEvent('pw_animations:doAnimation', "notes")
    SendNUIMessage({
        type = "openNotePadBlank",
    })
    SetNuiFocus(true, true)
end

--Citizen.CreateThread(function()
--    while true do
--        if IsControlJustPressed(0, 38) then
--            startNewNote()
--        end
--        Citizen.Wait(1)
--    end
--end)

RegisterNUICallback("saveNote", function(data, cb)
    if data.noteid ~= nil then
        TriggerServerEvent('pw_notes:server:updateNote', data.noteid, data.message)
    else
        TriggerEvent('pw_notes:client:createNote', data.message)
    end
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    characterLoaded = false
    playerData = nil
end)

RegisterNetEvent('pw_notes:client:createNote')
AddEventHandler('pw_notes:client:createNote', function(message)
    TriggerServerEvent('pw_notes:server:createNote', message)
end)