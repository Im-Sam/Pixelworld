PW = nil
playerData, playerLoaded = nil, false
phoneStart = false
radioOpen = false
gamePlaying = false
gameResult = false

Citizen.CreateThread(function()
	while PW == nil do
		TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)
        Citizen.Wait(1)
	end
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    playerLoaded = false
    playerData = nil
    phoneStart = false
    SendNUIMessage({
        status = "hideHud",
    })
end)

function gameTest()
    TriggerEvent('pw_phone:games:startNumberGame', {}, function(success)
        if success then
            print('passed')
        else
            print('failed')
        end
    end)
end

RegisterNUICallback("gameResult", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        status = "phoneGame",
        action = "end"
    })
    gameResult = data.result
    gamePlaying = false
end)

RegisterNetEvent('pw_phone:games:startNumberGame')
AddEventHandler('pw_phone:games:startNumberGame', function(options, cb)
    if options ~= nil and type(options) == "table" then
        options.tries = options.tries or 50
        options.failures = options.failures or 10
        options.duration = options.duration or 5000
        options.time = options.time or 2000
    else
        options = {}
        options.tries = 50
        options.failures = 10
        options.duration = 5000
        options.time = 2000
    end

    if not gamePlaying then
        gamePlaying = true
        gameResult = false
        SetNuiFocus(true, true)
        SendNUIMessage({
            status = "phoneGame",
            action = "start",
            tries = options.tries,
            failures = options.failures,
            duration = options.duration,
            time = options.time
        })
        Citizen.CreateThread(function()
            while true do
                    repeat Wait(0) until gamePlaying == false
                    cb(gameResult)
                break
                Citizen.Wait(0)
            end
        end)
    end
end)

--[[
Citizen.CreateThread(function()
    while true do
        if IsControlJustPressed(0, 38) then
            gameTest()
        end
        Citizen.Wait(1)
    end
end)]]

Citizen.CreateThread(function()
    while true do
        if playerLoaded then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local playerHeading = GetEntityHeading(playerPed)
            local coords = { ['x'] = playerCoords.x, ['y'] = playerCoords.y, ['z'] = playerCoords.z, ['h'] = playerHeading}
            SendNUIMessage({
                status = "playerCoords",
                coords = coords
            })
        end
        Citizen.Wait(1000)
    end
end)

RegisterNetEvent('pw:setJob')
AddEventHandler('pw:setJob', function(data)
    if playerLoaded and playerData then
        playerData.job = data
        SendNUIMessage({
            status = "setJob",
            job = playerData.job.job,
            duty = playerData.job.duty,
        })
    end    
end)

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
    if playerLoaded and playerData then
        playerData.job.duty = toggle
        SendNUIMessage({
            status = "setJob",
            job = playerData.job.job,
            duty = playerData.job.duty,
        })
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(data)
    playerData = data
    playerLoaded = true
    phoneStart = true
    SendNUIMessage({
        status = "setJob",
        job = playerData.job.job,
        duty = playerData.job.duty,
    })
    PW.TriggerServerCallback('pw_phone:server:requestActiveNumber', function(num)
        if num ~= nil then
            phoneNumber = num

            PW.TriggerServerCallback('pw_phone:server:checkUnreadMessages', function(unread)
                if unread > 0 then
                    notificationNui("textMessages", true)
                end
            end, phoneNumber)
        end

        Citizen.CreateThread(function()
            SendNUIMessage({
                status = "showHud",
            })
            while phoneStart do
                if IsControlJustPressed(0, 288) then
                    if IsControlPressed(0, 21) then
                        SendNUIMessage({
                            status = "closePhone",
                        })
                        openRadioControl()
                    else
                        SendNUIMessage({
                            status = "closeRadio",
                        })
                        openPhoneControl()
                    end
                end
                Citizen.Wait(1)
            end
        end)
    end)
end)

RegisterNetEvent('pw_phone:client:activeRace')
AddEventHandler('pw_phone:client:activeRace', function(state)
    SendNUIMessage({
        status = "raceActive",
        raceState = state
    })
end)

RegisterNetEvent('pw_phone:client:activeContestants')
AddEventHandler('pw_phone:client:activeContestants', function(status)
    SendNUIMessage({
        status = "toggleContestants",
        state = status
    })
end)

function openRadioControl()
    if not checking then
        checking = true
        PW.TriggerServerCallback('pw_phone:server:openRadio', function(haveone)
            if haveone then
                SetNuiFocus(true, true)
                SendNUIMessage({
                    status = "openRadio",
                })
                checking = false
            else
                exports['pw_notify']:SendAlert("warning", "You do not have a Radio on you.", 5000)
                checking = false
            end
        end)
    end
end

function openPhoneControl()
    if not checking then
        checking = true
        PW.TriggerServerCallback('pw_phone:server:openPhone', function(simactive, number)
            if simactive then
                SetNuiFocus(true, true)
                SendNUIMessage({
                    status = "openPhone",
                    simcard = simactive,
                    activenumber = number
                })
            else
                if number == "nosim" then
                    SetNuiFocus(true, true)
                    SendNUIMessage({
                        status = "openPhone",
                        simcard = simactive,
                        activenumber = nil
                    })
                else
                    exports['pw_notify']:SendAlert("warning", "You do not own a Mobile Phone", 5000)
                end
            end
            checking = false
        end)
    end
end
    
function updateClock()
    local curHour = GetClockHours()
    local curMinute = GetClockMinutes()
    local hour, minute
    if curHour < 10 then
        hour = '0'..curHour
    else
        hour = curHour
    end
    if curMinute < 10 then
        minute = '0'..curMinute
    else
        minute = curMinute
    end
    local time = hour..':'..minute
    SendNUIMessage({
        status = "updateClock",
        time = time
    })
end

RegisterNetEvent('pw_voip:client:updateNUI')
AddEventHandler('pw_voip:client:updateNUI', function(action, message)
    if action == "primary" then
        SendNUIMessage({
            status = "updateVoice",
            mes = message
        })
    elseif action == "secondary" then
        if message == false then
            SendNUIMessage({
                status = "updateVoice2",
                show = false
            })
        else
            SendNUIMessage({
                status = "updateVoice2",
                mes = message,
                show = true
            })
        end
    elseif action == "level" then
        SendNUIMessage({
            status = "updateLevel",
            level = message
        })
    end
end) 

RegisterNetEvent('pw_phone:client:doPhoneActionFromCommand')
AddEventHandler('pw_phone:client:doPhoneActionFromCommand', function(action)
    TriggerServerEvent('pw_phone:server:doPhoneActionFromCommand', action, phoneNumber)
end)

RegisterNUICallback("closePhone", function(data, cb)
    SetNuiFocus(false, false)
end)

Citizen.CreateThread(function()
    while true do
        updateClock()
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        if playerLoaded and phoneNumber ~= nil then
            local playerPed = GetPlayerPed(-1)
            local playerCoords = GetEntityCoords(playerPed)
            TriggerServerEvent('pw_phone:server:updateGPS', phoneNumber, playerCoords.x, playerCoords.y, playerCoords.z)
        end
    end
end)