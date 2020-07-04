PW = nil
local notified = {}
local cityBlackout = false
local prisonStarted = false

local gameOptions = { ['prisonReady'] = false, ['powerPlantReady'] = true, ['powerPlantDone'] = false, ['prisonDone'] = false }

TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)

AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() then
        CheckCops()
    end
end)

function CheckCops()
    PW.SetTimeout(10000, function()
        TriggerClientEvent('pw_prisonbreak:client:updateCops', -1, #PW.CheckOnlineDuty('police'))
        CheckCops()
    end)
end

-- Game Start Options
PW.RegisterServerCallback('pw_prisonbreak:server:retreivePowerPoints', function(source, cb)
    if Config.DoCityBlackout then
        TriggerClientEvent('pw_prisonbreak:client:cityBlackOut', source, cityBlackout)
    end
    TriggerClientEvent('pw_prisonbreak:client:updateCops', source, #PW.CheckOnlineDuty('police'))
    cb(Config.PowerPoints, Config.PrisonPoints, gameOptions)
end)

RegisterServerEvent('pw_base:itemUsed')
AddEventHandler('pw_base:itemUsed', function(_src, data)
    if data.item == "electronicskit" then
        TriggerClientEvent('pw_prisonbreak:client:usedElectronicsKit', _src, data)
    elseif data.item == "screwdriver" then
        TriggerClientEvent('pw_prisonbreak:client:usedLockpick', _src, data)
    end
end)

--- PowerPlant Events --
RegisterServerEvent('pw_prisonbreak:server:markAsProcessing')
AddEventHandler('pw_prisonbreak:server:markAsProcessing', function(box, toggle)
    if Config.PowerPoints[box] then
        Config.PowerPoints[box].inprocess = toggle
        TriggerClientEvent('pw_prisonbreak:client:retreivePoints', -1, Config.PowerPoints)
    end
end)

RegisterServerEvent('pw_prisonbreak:server:markAsDone')
AddEventHandler('pw_prisonbreak:server:markAsDone', function(box, toggle)
    if Config.PowerPoints[box] then
        Config.PowerPoints[box].done = toggle
        Config.PowerPoints[box].source = tonumber(source)
        TriggerClientEvent('pw_prisonbreak:client:retreivePoints', -1, Config.PowerPoints)
    end
end)

RegisterServerEvent('pw_prisonbreak:server:markAllDone')
AddEventHandler('pw_prisonbreak:server:markAllDone', function()
    gameOptions.prisonReady = true
    gameOptions.powerPlantReady = false
    gameOptions.powerPlantDone = true
    gameOptions.prisonDone = false
    if Config.DoCityBlackout then
        TriggerClientEvent('pw_prisonbreak:client:cityBlackOut', -1, true)  
    end
    cityBlackout = true
    TriggerClientEvent('pw_prisonbreak:client:retreivePoints', -1, Config.PowerPoints)
    TriggerClientEvent('pw_prisonbreak:client:retreiveGameOptions', -1, gameOptions)
    math.randomseed(os.time())
    local selectedGate = math.random(3,5)

    for k, v in pairs(Config.PrisonPoints) do
        if k == selectedGate then
            v.gateToDo = true
            TriggerClientEvent('pw_prisonbreak:client:retreivePrisonPoints', -1, Config.PrisonPoints)
            break;
        end
    end

    for k, v in pairs(Config.PowerPoints) do
        if v.source > 0 and not notified[tonumber(v.source)] then
            notified[v.source] = true
            TriggerClientEvent('pw:notification:SendAlert', v.source, {type = "info", text = "The PowerPlant has been powered down, you have "..Config.PlantToPrisonTimer.." minutes to begin the next stage, the Police will be alerted within 10 minutes.", length = 5000})
        end
    end
    notified = {}
    startTimer()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait((Config.PoliceNotifyTime * 60000))

            Citizen.Wait(0)
            break;
        end
    end)
end)

-- Prison Events
function checkPrisonStarted()
    if not prisonStarted then 
        for k, v in pairs(Config.PrisonPoints) do
            if v.inprocess == true then
                prisonStarted = true
            end
        end
    end
end

RegisterServerEvent('pw_prisonbreak:server:markGateAsProcessing')
AddEventHandler('pw_prisonbreak:server:markGateAsProcessing', function(gate, toggle)
    if Config.PrisonPoints[gate] then
        Config.PrisonPoints[gate].inprocess = toggle
        TriggerClientEvent('pw_prisonbreak:client:retreivePrisonPoints', -1, Config.PrisonPoints)
    end
    checkPrisonStarted()
end)

RegisterServerEvent('pw_prisonbreak:server:markGateasDone')
AddEventHandler('pw_prisonbreak:server:markGateasDone', function(gate)
    if Config.PrisonPoints[gate] then
        Config.PrisonPoints[gate].done = true
        TriggerClientEvent('pw_prisonbreak:client:retreivePrisonPoints', -1, Config.PrisonPoints)
        if(gate > 2)then
            gameComplete()
        end
    end
end)

function gameComplete()
    gameOptions.prisonDone = true
    TriggerClientEvent('pw_prisonbreak:client:retreiveGameOptions', -1, gameOptions)
    TriggerEvent('pw_prison:server:jailBreakComplete', true)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(300000)
            resetGame()
        end
    end)
end


-- Game Option Changers
function startTimer()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait((Config.PlantToPrisonTimer * 60000))
            if Config.DoCityBlackout then
                TriggerClientEvent('pw_prisonbreak:client:cityBlackOut', -1, false)
            end
            cityBlackout = false
            if not prisonStarted then
                for k, v in pairs(Config.PowerPoints) do
                    if v.source > 0 and not notified[tonumber(v.source)] then
                        TriggerClientEvent('pw:notification:SendAlert', v.source, {type = "info", text = "You have not started the next stage in time, the powerplant has restored its power.", length = 5000})
                    end
                end
                notified = {}
                resetGame()
            end
            Citizen.Wait(0)
            break;
        end
    end)
end

function resetGame()
    for k, v in pairs(Config.PowerPoints) do
        v.source = 0
        v.done = false
        v.inprocess = false
    end

    for k, v in pairs(Config.PrisonPoints) do
        v.gateToDo = false
        v.inprocess = false
        v.done = false
        v.source = 0
        exports['pw_doors']:toggleById(v.doorId, true)
    end

    gameOptions.prisonReady = false
    gameOptions.powerPlantReady = true
    gameOptions.powerPlantDone = false
    gameOptions.prisonDone = false

    TriggerClientEvent('pw_prisonbreak:client:retreivePoints', -1, Config.PowerPoints)
    TriggerClientEvent('pw_prisonbreak:client:retreivePrisonPoints', -1, Config.PrisonPoints)
    TriggerClientEvent('pw_prisonbreak:client:retreiveGameOptions', -1, gameOptions)
    TriggerEvent('pw_prison:server:jailBreakComplete', false)
end