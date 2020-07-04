RegisterNetEvent('pw_phone:client:loadData')
AddEventHandler('pw_phone:client:loadData', function(act, data)
    if act == "getNearbyPlayers" then
        data['players'] = PW.Game.GetNearbyPlayers(20.0)
        SendNUIMessage({
            status = "phonePopulation",
            sub = act,
            data = data
        })
    else
        SendNUIMessage({
            status = "phonePopulation",
            sub = act,
            data = data
        })
    end
end)

RegisterNUICallback("requestData", function(data, cb)
    PW.TriggerServerCallback('pw_phone:server:retreiveMeta', function()
    end, data.request, true, data.number, data)
end)

RegisterNUICallback("loseFocus", function(data, cb)
    SetNuiFocus(false, false)
end)

RegisterNUICallback("setWaypoint", function(data, cb)
    if data then
        if IsWaypointActive() then
            ClearGpsPlayerWaypoint()
        end
        local x = tonumber(data.x)
        local y = tonumber(data.y)
        SetNewWaypoint(x, y)
        exports['pw_notify']:SendAlert('success', 'Marker has been set on your map', 5000)
    else
        exports['pw_notify']:SendAlert('error', 'Failed to set Marker on map', 5000)
    end
end)

RegisterNetEvent('pw_phone:client:connectCall')
AddEventHandler('pw_phone:client:connectCall', function(callid, name, with)
    if callid == false then
        print('CALL ENDED:', 'CALLID:', name)
            if exports['pw_voip']:isPlayerInChannel(tonumber(name)) then
                exports['pw_voip']:removePlayerFromRadio(tonumber(name))
            end
        SendNUIMessage({
            status = "callEnded",
        }) 
    else
        print('CALL CONNECTED:', 'CALLID:', callid, 'WITH:', name)
        exports['pw_voip']:addPlayerToRadio(tonumber(callid))
        SendNUIMessage({
            status = "callConnected",
            name = name,
            with = with,
        })   
    end
end)

RegisterNetEvent('pw_phone:client:ringPhone')
AddEventHandler('pw_phone:client:ringPhone', function(name, incoming, failed, reason, terminate, number)
    if incoming then
        print('receiving call event received client side?')
        SendNUIMessage({
            status = "receiving",
            name = name,
            incomming = incoming,
            failed = failed,
            reason = reason,
            terminate = terminate,
            mynumber = number,
        })
        if terminate == false then

        else

        end
    else
        SendNUIMessage({
            status = "makingCall",
            name = name,
            incomming = incoming,
            failed = failed,
            reason = reason,
            terminate = terminate
        })
    end
end)

Citizen.CreateThread(function()
    local pauseActive = false
    while true do
        if IsPauseMenuActive() then
            if not pauseActive then
                SendNUIMessage({
                    status = "hideHud",
                })
            pauseActive = true
            end
        else
            if pauseActive then
                SendNUIMessage({
                    status = "showHud",
                })
            pauseActive = false
            end
        end
        Citizen.Wait(1)
    end
end)

function tprint (t, s)
    for k, v in pairs(t) do
        local kfmt = '["' .. tostring(k) ..'"]'
        if type(k) ~= 'string' then
            kfmt = '[' .. k .. ']'
        end
        local vfmt = '"'.. tostring(v) ..'"'
        if type(v) == 'table' then
            tprint(v, (s or '')..kfmt)
        else
            if type(v) ~= 'string' then
                vfmt = tostring(v)
            end
            print(type(t)..(s or '')..kfmt..' = '..vfmt)
        end
    end
end

RegisterNUICallback("setRadioChannel", function(data, cb)
    if data then
        if data.toggle then
            exports['pw_voip']:addPlayerToRadio(tonumber(data.channel))
        else
            if exports['pw_voip']:isPlayerInChannel(tonumber(data.channel)) then
                exports['pw_voip']:removePlayerFromRadio(tonumber(data.channel))
            end
        end
    end
end)

RegisterNUICallback("sendData", function(data, cb)
    if data.request == "removeSim" then
        phoneNumber = nil
    end
    if data.request == "loadSim" then
        phoneNumber = tonumber(data.number)
    end
    TriggerServerEvent('pw_phone:server:sendData', data)
end)

RegisterNUICallback("addContact", function(data, cb)
    TriggerServerEvent('pw_phone:server:addContact', data)
end)