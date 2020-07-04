PW = nil
characterLoaded, playerData = false, nil
local powerPlants = {}
local prisonPoints = {}
local gameOptions = {}
local GLOBAL_PED
local GLOBAL_COORDS
local showing = false
local numberOfCops = 0

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)
        Citizen.Wait(1)
    end
end)

Citizen.CreateThread(function()
    while true do
        if characterLoaded then
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
        Citizen.Wait(200)
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(data)
    PW.TriggerServerCallback('pw_prisonbreak:server:retreivePowerPoints', function(points, prisonPointsReceive, options)
        powerPlants = points
        prisonPoints = prisonPointsReceive
        gameOptions = options
        playerData = data
        characterLoaded = true
    end)
end)

RegisterNetEvent('pw_prisonbreak:client:retreivePoints')
AddEventHandler('pw_prisonbreak:client:retreivePoints', function(points)
    powerPlants = points
end)

RegisterNetEvent('pw_prisonbreak:client:retreivePrisonPoints')
AddEventHandler('pw_prisonbreak:client:retreivePrisonPoints', function(points)
    prisonPoints = points
end)

RegisterNetEvent('pw_prisonbreak:client:retreiveGameOptions')
AddEventHandler('pw_prisonbreak:client:retreiveGameOptions', function(options)
    gameOptions = options
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    characterLoaded = false
    playerData = nil
end)

function countDone(points)
    local done = 0
    local required = 0
    for k, v in pairs(powerPlants) do
        if points == "stage1" then
            if v.order == 1 then 
                required = required + 1
                if v.done == true then
                    done = done + 1
                end
            end
        elseif points == "stage2" then
            if v.order == 2 then 
                required = required + 1
                if v.done == true then
                    done = done + 1
                end
            end
        elseif points == "stage3" then
            if v.order == 3 then 
                required = required + 1
                if v.done == true then
                    done = done + 1
                end
            end
        end
    end
    return required, done
end

function attemptingBox(box, toggle)
    TriggerServerEvent('pw_prisonbreak:server:markAsProcessing', box, toggle)
end

function boxHacked(box, toggle)
    TriggerServerEvent('pw_prisonbreak:server:markAsDone', box, toggle)
    if box == 8 then
        TriggerServerEvent('pw_prisonbreak:server:markAllDone')
    end
    TriggerServerEvent('pw_items:server:showUsable', false  )
    TriggerEvent('pw_drawtext:hideNotification')
end

RegisterNetEvent('pw_prisonbreak:client:updateCops')
AddEventHandler('pw_prisonbreak:client:updateCops', function(nocops)
    numberOfCops = nocops
end)

function processHacking(box, item)
    attemptingBox(box, true)
    if box == 6 or box == 7 then
        time = Config.Difficulty['stage2'].time
        length = Config.Difficulty['stage2'].length
    elseif box == 8 then
        time = Config.Difficulty['stage3'].time
        length = Config.Difficulty['stage3'].length
    else
        time = Config.Difficulty['stage1'].time
        length = Config.Difficulty['stage1'].length
    end

    TriggerEvent("mhacking:show")
    TriggerEvent("mhacking:start", length, time, function(success)
        if success then
            boxHacked(box, true)
        else
            attemptingBox(box, false)
        end
        TriggerEvent('mhacking:hide')
    end)
end

function attemptingGate(gate, toggle)
    TriggerServerEvent('pw_prisonbreak:server:markGateAsProcessing', gate, toggle)
end

function gateHacked(gate, toggle)
    if toggle then
        local gateSelected = prisonPoints[gate]
        exports['pw_doors']:toggleById(gateSelected.doorId)
        TriggerServerEvent('pw_prisonbreak:server:markGateasDone', gate)
    end
    TriggerServerEvent('pw_items:server:showUsable', false  )
    TriggerEvent('pw_drawtext:hideNotification')
end

function processPrisonHacking(gate, item)
    attemptingGate(gate, true)
    if gate == 1 or gate == 2 then
        TriggerEvent("mhacking:show")
        TriggerEvent("mhacking:start", 3, 20, function(success)
            if success then
                gateHacked(gate, true)
            else
                attemptingGate(gate, false)
            end
            TriggerEvent('mhacking:hide')
        end)
    end
end

RegisterNetEvent('pw_prisonbreak:client:cityBlackOut')
AddEventHandler('pw_prisonbreak:client:cityBlackOut', function(toggle)
    SetArtificialLightsState(toggle)
    Wait(300)
    SetArtificialLightsState(not toggle)
    Wait(400)
    SetArtificialLightsState(toggle)
    Wait(300)
    SetArtificialLightsState(not toggle)
    Wait(100)
    SetArtificialLightsState(toggle)
end)

RegisterNetEvent('pw_prisonbreak:client:usedElectronicsKit')
AddEventHandler('pw_prisonbreak:client:usedElectronicsKit', function(item)
    if characterLoaded then
        if not gameOptions.powerPlantDone and gameOptions.powerPlantReady then
            for k, v in pairs(powerPlants) do
                local distance = #(GLOBAL_COORDS - vector3(v.x, v.y, v.z))
                if distance < 1.0 then
                    if v.order == 1 then
                        if v.done == false then
                            processHacking(k, item)
                        end
                    elseif v.order == 2 then
                        local stage21, stage22 = countDone("stage1")
                        if stage21 == stage22 then
                            processHacking(k, item)
                        else
                            exports['pw_notify']:SendAlert('inform', 'You need to complete all stage 1 tasks before attempting this stage', 5000)
                        end
                    elseif v.order == 3 then
                        local stage31, stage32 = countDone("stage2")
                        if stage31 == stage32 then
                            processHacking(k, item)
                        else
                            exports['pw_notify']:SendAlert('inform', 'You need to complete all stage 2 tasks before attempting this stage', 5000)
                        end
                    end
                    break
                end
            end
        end

        if gameOptions.powerPlantDone and gameOptions.prisonReady then
            for t, p in pairs(prisonPoints) do
                local distance = #(GLOBAL_COORDS - vector3(p.x, p.y, p.z))
                if distance < 1.0 then
                    if (t == 1 or t == 2) and not p.done and not p.inprocess then
                        processPrisonHacking(t, item)
                    end
                end
            end
        end
    end
end)

function processPrisonLockpick(gate, item)
    attemptingGate(gate, true)
    TriggerEvent('pw_lockpick:client:startGame', function(success)
        if success then
            gateHacked(gate, true)
        else
            attemptingGate(gate, false)
        end
    end)
end

RegisterNetEvent('pw_prisonbreak:client:usedLockpick')
AddEventHandler('pw_prisonbreak:client:usedLockpick', function(item)
    if characterLoaded then
        if gameOptions.powerPlantDone and gameOptions.prisonReady then
            for t, p in pairs(prisonPoints) do
                local distance = #(GLOBAL_COORDS - vector3(p.x, p.y, p.z))
                if distance < 1.0 then
                    if (t > 2 and not p.done and not p.inprocess and p.gateToDo) then
                        processPrisonLockpick(t, item)
                    end
                end
            end
        end
    end
end)

-- PowerPlant Options
Citizen.CreateThread(function()
    while true do
        local letSleep = true
        if characterLoaded and GLOBAL_PED and GLOBAL_COORDS and gameOptions.powerPlantReady and not gameOptions.powerPlantDone and numberOfCops >= Config.NeededPolice then
            for k, v in pairs(powerPlants) do
                local distance = #(GLOBAL_COORDS - vector3(v.x, v.y, v.z))
                if distance < 10.0 then
                    letSleep = false
                end
                if v.order == 1 and distance < 10.0 and not v.done and not v.inprocess then
                    DrawMarker(27, v.x, v.y, v.z-0.99, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, true, nil, nil, false)
                    if distance < 1.0 then
                        if not showing then
                            TriggerServerEvent('pw_items:server:showUsable', true, {"electronicskit"})
                            TriggerEvent('pw_drawtext:showNotification', { title = "Powerplant", message = "Use an [ <span class='text-danger'>Electronics Kit</span> ] to hack.", icon = icon })
                            showing = k.."stage1"
                        end
                    else
                        if showing == k.."stage1" then
                            TriggerServerEvent('pw_items:server:showUsable', false  )
                            TriggerEvent('pw_drawtext:hideNotification')
                            showing = false
                        end
                    end
                end
                local stage21, stage22 = countDone("stage1")
                if v.order == 2 and v.done == false and (stage21 == stage22) and distance < 10.0 and not v.inprocess then
                    DrawMarker(27, v.x, v.y, v.z-0.99, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, true, nil, nil, false)
                    -- Ready
                    if distance < 1.0 then

                    else

                    end
                end
                if v.order == 2 and v.done == false and (stage21 ~= stage22) and distance < 10.0 and not v.inprocess then
                    DrawMarker(27, v.x, v.y, v.z-0.99, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 204, 114, 46, 100, false, true, 2, true, nil, nil, false)
                end
                local stage31, stage32 = countDone("stage2")
                if v.order == 3 and v.done == false and (stage31 == stage32) and distance < 10.0 and not v.inprocess then
                    DrawMarker(27, v.x, v.y, v.z-0.99, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, true, nil, nil, false)
                    -- Ready
                    if distance < 1.0 then

                    else

                    end
                end
                if v.order == 3 and v.done == false and (stage31 ~= stage32) and distance < 10.0 and not v.inprocess then
                    DrawMarker(27, v.x, v.y, v.z-0.99, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 204, 114, 46, 100, false, true, 2, true, nil, nil, false)
                end
            end
        end

        if letSleep then
            Citizen.Wait(500)
        else
            Citizen.Wait(1)
        end
    end
end)

-- Prison Options
Citizen.CreateThread(function()
    while true do
        letSleep = true

        if characterLoaded and GLOBAL_PED and GLOBAL_COORDS and gameOptions.prisonReady and gameOptions.powerPlantDone and numberOfCops >= Config.NeededPolice then
            for k, v in pairs(prisonPoints) do

                if ((k == 2 or k == 1) and not v.inprocess and not v.done) or (k > 2 and not v.inprocess and not v.done and v.gateToDo) then
                    local distance = #(GLOBAL_COORDS - vector3(v.x, v.y, v.z))
                    if distance < 5.0 then
                        letSleep = false
                        DrawMarker(27, v.x, v.y, v.z-0.99, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, true, nil, nil, false)
                        if distance < 1.0 then
                            if not showing then
                                TriggerServerEvent('pw_items:server:showUsable', true, {"electronicskit"})
                                TriggerEvent('pw_drawtext:showNotification', { title = "Federal Prison", message = "Use an [ <span class='text-danger'>Electronics Kit</span> ] to hack.", icon = icon })
                                showing = k.."prisonGate"
                            end
                        else
                            if showing == k.."prisonGate" then
                                TriggerServerEvent('pw_items:server:showUsable', false)
                                TriggerEvent('pw_drawtext:hideNotification')
                                showing = false
                            end
                        end
                    end
                end

            end
        end

        if letSleep then
            Citizen.Wait(500)
        else
            Citizen.Wait(1)
        end
    end
end)