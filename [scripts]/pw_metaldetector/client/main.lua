
local checkingPlayer = false
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

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    characterLoaded = false
    playerData = nil
end)

RegisterNetEvent('pw:setJob')
AddEventHandler('pw:setJob', function(data)
    if characterLoaded and playerData then
        playerData.job = data
    end
end)

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
    if playerData then
        playerData.job.duty = toggle
    end
end)

Citizen.CreateThread(function()
    while true do
        local letSleep = true
        if characterLoaded then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local checkJob = false
            for k, v in pairs(Config.WhitelistedJobs) do
                if (v == playerData.job.job) and playerData.job.duty then
                    checkJob = true
                end
            end

            if not checkJob then
                for k, v in pairs(Config.Points) do
                    local distance = #(playerCoords - vector3(v.detector.x, v.detector.y, v.detector.z))
                    if distance < 5.0 then
                        letSleep = false
                        if distance < 1.0 then
                            if not checkingPlayer then
                                checkingPlayer = true
                                PW.TriggerServerCallback('pw_metaldetector:server:checkMetalicItems', function(any)
                                    if any > 0 then
                                        TriggerServerEvent('pw_sound:server:PlayWithinDistance', 3.0, 'metaldetect', 0.8)
                                    end
                                    Citizen.Wait(5000)
                                    checkingPlayer = false
                                end)
                            end
                        end
                    end
                end
            end
        end

        if letSleep then
            Citizen.Wait(1000)
        else
            Citizen.Wait(100)
        end
    end
end)