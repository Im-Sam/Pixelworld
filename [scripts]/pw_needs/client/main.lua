-- Starting Variables
PW, characterLoaded, playerData = nil, false, nil
local allowBar = false
local blips = {}

local showingNotification = false
local doingExcercise = false
local excerciseCooldown = false
local stressEffect, drugsEffect = false, false

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
    allowBar = true
    createBlips()
    SendNUIMessage({
        action = "updatePlayer",
        name = playerData.name,
        cash = playerData.cash,
        id = GetPlayerServerId(PlayerId())
    })
    loadCharacterInfo(playerData.needs)
    loadKeyCheck()
end)

function loadKeyCheck()
    Citizen.CreateThread(function()
        while allowBar do
            if IsDisabledControlJustReleased(2, 37) or IsControlJustReleased(2, 37) then
                SendNUIMessage({
                    action = "showBar",
                })
            end
            Citizen.Wait(5)
        end
    end)
end

exports('getNeedsLevel', function(need)
    if characterLoaded and playerData then
        local currentHunger = math.ceil(playerData.needs.hunger / Config.MaxValues.hunger * 100)
        local currentThirst = math.ceil(playerData.needs.thirst / Config.MaxValues.thirst * 100)
        local currentDrug = math.ceil(playerData.needs.drugs / Config.MaxValues.drugs * 100)
        local currentStress = math.ceil(playerData.needs.stress / Config.MaxValues.stress * 100)
        local tempTable = { ['hunger'] = currentHunger, ['thirst'] = currentThirst, ['drugs'] = currentDrug, ['stress'] = currentStress }

        if need ~= nil then
            if (tempTable[need]) then
                return tempTable[need]
            else
                return 0
            end
        else
            return tempTable
        end
    end
end)

RegisterNetEvent('pw_banking:updateCash')
AddEventHandler('pw_banking:updateCash', function(data)
    if characterLoaded and playerData then
        playerData.cash = data
        SendNUIMessage({
            action = "updatePlayer",
            cash = playerData.cash,
        })
    end
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    local playerPed = GetPlayerPed(-1)
    if characterLoaded and playerData then
        TriggerServerEvent('pw_needs:updateCharacterNeeds', playerData.needs)
        if stressEffect then
            StopScreenEffect('Rampage')
            stressEffect = false
        end
    
        if drugsEffect then
            SetTimecycleModifier("default")
            SetPedMotionBlur(playerPed, false)
            SetPedMovementClipset(playerPed, "move_m@hipster@a", false)
            drugsEffect = false
        end
        allowBar = false
        destroyBlips()
        characterLoaded = false
        playerData = nil
    end
end)


--==========================================================================================
-- UPDATE FUNCTIONS
--==========================================================================================
Citizen.CreateThread(function()
    while true do
        -- Database Updates for Character
        if characterLoaded and playerData then
            if not IsPedFatallyInjured(PlayerPedId()) then
                TriggerServerEvent('pw_needs:updateCharacterNeeds', playerData.needs)
            end
        end
        Citizen.Wait((Config.ServerUpdateTime*1000))
    end
end)

function loadCharacterInfo(data)
    local playerPed = GetPlayerPed(-1)
    local currentHunger = math.ceil(playerData.needs.hunger / Config.MaxValues.hunger * 100)
    local currentThirst = math.ceil(playerData.needs.thirst / Config.MaxValues.thirst * 100)
    local currentDrug = math.ceil(playerData.needs.drugs / Config.MaxValues.drugs * 100)
    local currentStress = math.ceil(playerData.needs.stress / Config.MaxValues.stress * 100)
    local currentHealth = math.ceil(GetEntityHealth(playerPed) - 100)
    local currentStamina = math.ceil(100 - GetPlayerSprintStaminaRemaining(PlayerId()))
    local currentArmour = GetPedArmour(playerPed)
    SendNUIMessage({
        action = "updateValues",
        hunger = currentHunger,
        thirst = currentThirst,
        stress = currentStress,
        drugs = currentDrug,
        health = currentHealth,
        stamina = currentStamina,
        armour = currentArmour
    })
end

Citizen.CreateThread(function()
    while true do
        -- Local Client Updates
        if characterLoaded and playerData then
            if not IsPedFatallyInjured(PlayerPedId()) then
                for k, v in pairs(playerData.needs) do
                    if k == "stress" then
                        if not doingExcercise and not drugsEffect then
                            playerData.needs[k] = (playerData.needs[k] + Config.ReductionValues[k])
                            if playerData.needs[k] > Config.MaxValues[k] then
                                playerData.needs[k] = Config.MaxValues[k]
                            end
                        end
                    else
                        playerData.needs[k] = (playerData.needs[k] - Config.ReductionValues[k])
                        if playerData.needs[k] < 0 then
                            playerData.needs[k] = 0
                        end
                    end
                end
            end
        end
        Citizen.Wait((Config.ClientUpdateTime*1000))
    end
end)

Citizen.CreateThread(function()
    while true do
        if characterLoaded and playerData then
            loadCharacterInfo(playerData.needs)
        end
        Citizen.Wait(200)
    end
end)
--==========================================================================================

--==========================================================================================
-- CLIENT UPDATE FUNCTIONS
--==========================================================================================
exports('updateNeeds', function(need, action, amount)
    if characterLoaded and playerData then
        if type(amount) == "number" then
            if playerData.needs[need] then
                if action == "add" then
                    playerData.needs[need] = (playerData.needs[need] + amount)
                    if playerData.needs[need] > Config.MaxValues[need] then
                        playerData.needs[need] = Config.MaxValues[need]
                    end
                elseif action == "remove" then
                    playerData.needs[need] = (playerData.needs[need] - amount)
                    if playerData.needs[need] < 0 then
                        playerData.needs[need] = 0
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('pw_needs:client:resetStats')
AddEventHandler('pw_needs:client:resetStats', function()
    if characterLoaded and playerData then
        if playerData.needs then
            for k, v in pairs(playerData.needs) do
                if k == "stress" or k == "drugs" then
                    playerData.needs[k] = 0
                else
                    playerData.needs[k] = Config.MaxValues[k]
                end
            end
        end
    end
end)

RegisterNetEvent('pw_needs:client:updateNeeds')
AddEventHandler('pw_needs:client:updateNeeds', function(need, action, amount)
    if characterLoaded and playerData then
        if type(amount) == "number" then
            if playerData.needs[need] then
                if action == "add" then
                    playerData.needs[need] = (playerData.needs[need] + amount)
                    if playerData.needs[need] > Config.MaxValues[need] then
                        playerData.needs[need] = Config.MaxValues[need]
                    end
                elseif action == "remove" then
                    playerData.needs[need] = (playerData.needs[need] - amount)
                    if playerData.needs[need] < 0 then
                        playerData.needs[need] = 0
                    end
                end
            end
        end
    end
end)
--==========================================================================================


--==========================================================================================
-- EXCERCISING SCRIPTS
--==========================================================================================

function showNotification(area, show)
    if show then
        if not showingNotification then
            showingNotification = area
            TriggerEvent('pw_drawtext:showNotification', { title = Config.ExcercisePoints[area].label, message = Config.ExcercisePoints[area].msg, icon = Config.ExcercisePoints[area].icon })
        end
    else
        if showingNotification and showingNotification == area then
            TriggerEvent('pw_drawtext:hideNotification')
            showingNotification = false
        end
    end
end

function stopExcercise(exc)
    local playerPed = GetPlayerPed(-1)
    ClearPedTasks(playerPed)
    doingExcercise = false
    if not excerciseCooldown then
        excerciseCooldown = true
        Citizen.CreateThread(function()
            while excerciseCooldown do
                Citizen.Wait(60000)
                excerciseCooldown = false
                if not excerciseCooldown then
                    break 
                end
            end
        end)
    end
end

function doExcercise(k, etype)
    local playerPed = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(-1)
    local scen
    doingExcercise = true
    
    if etype == "yoga" then
        scen = "world_human_yoga"
    elseif etype == "pullup" then
        scen = "prop_human_muscle_chin_ups"
    elseif etype == "pushup" then
        scen = "world_human_push_ups"
    elseif etype == "arms" then
        scen = "world_human_muscle_free_weights"
    elseif etype == "situp" then
        scen = "world_human_sit_ups"
    end

    TaskStartScenarioInPlace(playerPed, scen, 0, true)

    Citizen.CreateThread(function()
        while IsPedUsingScenario(playerPed, scen) do
            if IsControlJustPressed(0, 38) then
                stopExcercise(etype)
            end
            Citizen.Wait(0)
        end
    end)

    Citizen.CreateThread(function()
        while IsPedUsingScenario(playerPed, scen) do
            Citizen.Wait(15000)
        if not IsPedUsingScenario(playerPed, scen) then
            stopExcercise(etype)
            break
        end

        if playerData.needs.stress <= 0 then
            TriggerEvent('pw:notification:SendAlert', {type = "success", text = "You have releived all your stress.", length = 5000})
            stopExcercise(etype)
            break
        end

        TriggerEvent('pw:notification:SendAlert', {type = "info", text = "Stress relieved.", length = 5000})
        local reduction
        if etype == "arms" then
            reduction = 40000
        else
            reduction = math.random(10000,50000)
        end
        exports['pw_needs']:updateNeeds("stress", "remove", reduction)        
        end
    end)
end

function doWeedAnim()
    local playerPed = GetPlayerPed(-1)
    RequestAnimSet("move_m@hipster@a") 
    while not HasAnimSetLoaded("move_m@hipster@a") do
        Citizen.Wait(0)
    end    
    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_SMOKING_POT", 0, 0)
    Citizen.Wait(3000)
    ClearPedTasksImmediately(playerPed)
end

RegisterNetEvent('pw_needs:usedJoint')
AddEventHandler('pw_needs:usedJoint', function()
    local playerPed = GetPlayerPed(-1)
    local currentArmour = GetPedArmour(playerPed)
    local newArmour = currentArmour + 11
    doWeedAnim()
    exports['pw_needs']:updateNeeds("drugs", "add", 10000)
    SetPedArmour(playerPed, newArmour)
    smokedWeed()
end)

Citizen.CreateThread(function()
    while true do
        local letSleep = true

        if characterLoaded and playerData then
            local playerPed = GetPlayerPed(-1)
            local playerCoords = GetEntityCoords(playerPed)

            for k, v in pairs(Config.ExcercisePoints) do
                local distance = #(playerCoords - vector3(v.x, v.y, v.z))
                if distance < v.radius then
                    letSleep = false
                    showNotification(k, true)
                    if not doingExcercise then
                        if IsControlJustPressed(0, 38) then
                            if not excerciseCooldown then
                                doExcercise(k, v.action)
                            else
                                if not doingExcercise then 
                                    exports['pw_notify']:SendAlert("info", "Your currently recovering from a previous excercise", 5000)
                                end
                            end
                        end
                    end
                else
                    showNotification(k, false)
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

function createBlips()
    Citizen.CreateThread(function()
        for k, v in pairs(Config.ExcerciseLocations) do
            blips[k] = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(blips[k], Config.Blips.type)
            SetBlipDisplay(blips[k], 4)
            SetBlipScale  (blips[k], Config.Blips.scale)
            SetBlipColour (blips[k], Config.Blips.color)
            SetBlipAsShortRange(blips[k], true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Excercises")
            EndTextCommandSetBlipName(blips[k])
        end
    end)
end

function destroyBlips()
    for k, v in pairs(blips) do
        RemoveBlip(v)
    end
end

--==========================================================================================


--==========================================================================================
-- Give Character Effects from Needs
--==========================================================================================

Citizen.CreateThread(function()
    while true do
        local letSleep = true
        if characterLoaded and playerData then
            local playerPed = GetPlayerPed(-1)
            if not IsPedFatallyInjured(playerPed) then
                letSleep = false
                local currentDrug = math.ceil(playerData.needs.drugs / Config.MaxValues.drugs * 100)
                local currentStress = math.ceil(playerData.needs.stress / Config.MaxValues.stress * 100)
                ---------------
                -- STRESS
                ---------------
                if currentStress > 80 and not stressEffect then
                    stressEffect = true
                    StartScreenEffect('Rampage', 0, true)
                    exports['pw_notify']:PersistentAlert('start', 'stressAlert', 'error', 'You\'re suffering from extreme stress, try doing some excercise.')
                elseif currentStress <= 80 and stressEffect then
                    exports['pw_notify']:PersistentAlert('end', 'stressAlert')
                    StopScreenEffect('Rampage')
                    stressEffect = false
                end

                if currentDrug <= 13 then
                    drugsEffect = false
                    SetTimecycleModifier("default")
                    SetPedMotionBlur(playerPed, false)
                    SetPedMovementClipset(playerPed, "move_m@hipster@a", false)
                elseif currentDrug >= 14 and currentDrug <= 99 then
                    drugsEffect = true
                    SetTimecycleModifier("spectator5")
                    SetPedMotionBlur(playerPed, true)
                    SetPedMovementClipset(playerPed, "move_m@hipster@a", true)
                elseif currentDrug == 100 then
                    drugsEffect = false
                    SetEntityHealth(playerPed, 99)
                    exports['pw_notify']:PersistentAlert('warning', 'You have overdosed using drugs', 5000)
                    SetTimecycleModifier("default")
                    SetPedMotionBlur(playerPed, false)
                    SetPedMovementClipset(playerPed, "move_m@hipster@a", false)
                    exports['pw_needs']:updateNeeds("drugs", "remove", 10000000)
                end
            else
                exports['pw_notify']:PersistentAlert('end', 'stressAlert')
                exports['pw_notify']:PersistentAlert('end', 'warning')
                if AnimpostfxIsRunning('Rampage') then
                    AnimpostfxStopAll()
                end
            end
        end

        if letSleep then
            Citizen.Wait(1000)
        else
            Citizen.Wait(10)
        end
    end
end)

function smokedWeed()
    Citizen.CreateThread(function()
        while drugsEffect do
            exports['pw_needs']:updateNeeds("stress", "remove", 50)
            Citizen.Wait(500)
        end
    end)
end