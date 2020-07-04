RegisterNetEvent('pw:core:nui:receiveCharacters')
AddEventHandler('pw:core:nui:receiveCharacters', function(Characters)
    DisplayHud(false)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openui",
        characters = Characters,
    })
end)

RegisterNetEvent('pw:fw:nui:refreshCharacters')
AddEventHandler('pw:fw:nui:refreshCharacters', function()
    TriggerServerEvent('pw:core:refreshCharacters')
end)

RegisterNUICallback("CharacterChosen", function(data, cb)
    DoScreenFadeOut(1)
    Citizen.Wait(50)
    SetNuiFocus(false,false)
    TriggerServerEvent('pw:core:selectedCharacter', tonumber(data.char))
    cb("ok")
end)

RegisterNetEvent('pw:core:nui:refreshCharacters')
AddEventHandler('pw:core:nui:refreshCharacters', function()
    TriggerServerEvent('pw:core:refreshCharacters')
end)

RegisterNUICallback("DeleteCharacter", function(data, cb)
    TriggerServerEvent('pw:core:nui:deleteCharacter', tonumber(data.char))
end)

RegisterNUICallback("refreshCharacter", function(data, cb)
    TriggerServerEvent('pw:core:refreshCharacters')
    cb("ok")
end)

RegisterNUICallback("Disconnect", function(data, cb)
    SetNuiFocus(false, false)
    RestartGame()
    cb("ok")
end)

RegisterNUICallback("createCharacter", function(data, cb)
    if data.firstname == nil or data.firstname == '' then 
        TriggerServerEvent('pw:core:refreshCharacters')
        Citizen.Wait(350)
        SendNUIMessage({
            action = "senderror",
            message = "You need to enter a First Name",
        })
    elseif data.lastname == nil or data.lastname == '' then 
        TriggerServerEvent('pw:core:refreshCharacters')
        Citizen.Wait(350)
        SendNUIMessage({
            action = "senderror",
            message = "You need to enter a Last Name",
        })
    elseif data.biography == nil or data.biography == '' then
        TriggerServerEvent('pw:core:refreshCharacters')
        Citizen.Wait(350)
        SendNUIMessage({
            action = "senderror",
            message = "You need to enter a Biography",
        })
    elseif data.dob == nil or data.dob == '' then
        TriggerServerEvent('pw:core:refreshCharacters')
        Citizen.Wait(350)
        SendNUIMessage({
            action = "senderror",
            message = "You need to enter a Date of Birth",
        })
    elseif data.sex == nil or data.sex == '' then
        TriggerServerEvent('pw:core:refreshCharacters')
        Citizen.Wait(350)
        SendNUIMessage({
            action = "senderror",
            message = "You need to select a Sex",
        })
    else
        TriggerServerEvent('pw:core:nui:createCharacter', data)
        cb("ok")
    end
end)