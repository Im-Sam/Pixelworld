PW = nil
characterLoaded, playerData = false, nil
properties = {}
local GLOBAL_PED, GLOBAL_COORDS
local showing = false
local currentlyRobbing
local npcWoken = false
local npcPedId

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
            if GLOBAL_PED > 0 then
                GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            end
        end
        Citizen.Wait(100)
    end
end)

function teleportIntoProperty(pro, ret)
    PW.TriggerServerCallback('pw_houserobbery:server:selectProperty', function(prop)
        local showingInterior = false
        currentlyRobbing = prop 
        DoScreenFadeOut(1500)
        Citizen.Wait(1501)
        SetEntityCoords(PlayerPedId(), prop.coords.entrance.x, prop.coords.entrance.y, prop.coords.entrance.z, 0.0, 0.0, 0.0, false)
        SetEntityHeading(PlayerPedId(), prop.coords.entrance.h)
        
        npcWoken = false
        createNPCPed(prop.coords.npc.start.x,prop.coords.npc.start.y, prop.coords.npc.start.z, prop.coords.npc.start.h)
        Citizen.Wait(1500)
        DoScreenFadeIn(1500)
        
        local function wakeNPC()
            local function fleeped()
                Citizen.CreateThread(function()
                    local reachedDistance1 = false
                    local reachedDistance2 = false
                    --TaskGoToCoordAnyMeans(npcPedId, prop.coords.npc['waypoint'].x, prop.coords.npc['waypoint'].y, prop.coords.npc['waypoint'].z, 5.0, 0, 0, 786603, 0xbf800000)
                    --while not reachedDistance do
                    TaskGoStraightToCoord(npcPedId,	prop.coords.npc['end'].x, prop.coords.npc['end'].y, prop.coords.npc['end'].z, 4.0, 1000, 0.0, 1.0)
                        while not reachedDistance1 do
                            local pedCords = GetEntityCoords(npcPedId)
                            local dist = #(pedCords - vector3(prop.coords.npc['end'].x, prop.coords.npc['end'].y, prop.coords.npc['end'].z))
                            print('End', dist)
                            if dist < 0.5 then
                                TaskGoStraightToCoord(npcPedId,	prop.coords.entrance.x, prop.coords.entrance.y, prop.coords.entrance.z, 4.0, 1000, 0.0, 1.0)
                                reachedDistance1 = true
                            end
                            Citizen.Wait(10)
                        end

                        while not reachedDistance2 do
                            local pedCords = GetEntityCoords(npcPedId)
                            local dist = #(pedCords - vector3(prop.coords.entrance.x, prop.coords.entrance.y, prop.coords.entrance.z))
                            print('Delete', dist)
                            if dist < 0.5 then
                                DeletePed(npcPedId)
                                reachedDistance2 = true
                            end
                            Citizen.Wait(10)
                        end
                        --local npcCoords = GetEntityCoords(npcPedId)
                        --local distance = #(npcCoords - vector3(prop.coords.npc['waypoint'].x, prop.coords.npc['waypoint'].y, prop.coords.npc['waypoint'].z))
                        --print(distance)
                        --if distance < 0.4 then
                         --   TaskGoToCoordAnyMeans(npcPedId, prop.coords.npc['end'].x, prop.coords.npc['end'].y, prop.coords.npc['end'].z, 5.0, 0, 0, 786603, 0xbf800000)
                        --    reachedDistance = true
                        --end
                        Citizen.Wait(10)
                   -- end
                end)
            end

            npcWoken = true
            ClearPedTasks(npcPedId)
            local weaponChance = math.random(100)

            if weaponChance < 101 then
                GiveWeaponToPed(npcPedId, GetHashKey('WEAPON_PISTOL'), 25, false, true)
                TaskShootAtEntity(npcPedId, PlayerPedId(), -1, GetHashKey('FIRING_PATTERN_DELAY_FIRE_BY_ONE_SEC'))
                Citizen.CreateThread(function()
                    while currentlyRobbing do
                        if IsPedShooting(npcPedId) then
                            if IsPedFatallyInjured(PlayerPedId()) then
                                ClearPedTasks(npcPedId)
                                RemoveWeaponFromPed(npcPedId, GetHashKey('WEAPON_PISTOL'))
                                --TaskReactAndFleePed(npcPedId --[[ Ped ]], PlayerPedId() --[[ Ped ]])
                                fleeped()
                            end
                        end
                        Citizen.Wait(1)
                    end
                end)
            else
                TaskCombatPed(npcPedId, PlayerPedId(), 0, 16)
            end
        end
        
        local function exitTeleport(house)
            DoScreenFadeOut(1500)
            Citizen.Wait(1501)
            SetEntityCoords(PlayerPedId(), properties[house].x, properties[house].y, properties[house].z, 0.0, 0.0, 0.0, false)
            SetEntityHeading(PlayerPedId(), properties[house].h)
            SendNUIMessage({
                action = "hide",
            })
        
            Citizen.Wait(1500)
            DoScreenFadeIn(1500)
            
            showingInterior = false
            currentlyRobbing = nil
            npcWoken = false
            npcPedId = nil
            TriggerServerEvent('pw_houserobbery:server:updateRobHouse', pro, "inuse", false)
            TriggerServerEvent('pw_houserobbery:server:updateRobHouse', pro, "useby", 0)
            TriggerServerEvent('pw_houserobbery:server:updateProperty', house, "robbing", false)
            TriggerServerEvent('pw_houserobbery:server:updateProperty', house, "propertyid", 0)
            TriggerServerEvent('pw_houserobbery:server:updateProperty', house, "by", 0)
            TriggerServerEvent('pw_houserobbery:server:updateProperty', house, "canrob", "startTimer")
            TriggerEvent('pw_items:showUsableKeys', false)
        end

        local function processSearch(k)
            prop.coords.search[k].searched = true
            TriggerEvent('pw:progressbar:progress',
                {
                    name = 'accessing_atm',
                    duration = 12000,
                    label = 'Searching',
                    useWhileDead = false,
                    canCancel = true,
                    controlDisables = {
                        disableMovement = false,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    },
                },
                function(status)
                    if not status then
                        local selectedItem
                        local rewardItem = math.random(#Config.Rewards)
                        selectedItem = Config.Rewards[rewardItem]
                        local chanceGen = math.random(100)
                        if selectedItem ~= nil then
                            if chanceGen < selectedItem.chance then
                                local randomAmount = math.random(1, selectedItem.max)
                                TriggerServerEvent('pw_houserobbery:server:awardPlayer', selectedItem, randomAmount)
                                if selectedItem.item == "cash" then
                                    exports['pw_notify']:SendAlert("info", "You have found $"..randomAmount.." in cash")
                                end
                                selectedItem = nil
                            else
                                exports['pw_notify']:SendAlert('error', "You have not found anthing in this location", 5000)
                            end
                        else
                            exports['pw_notify']:SendAlert('error', "You have not found anthing in this location", 5000)
                        end
                    end
                end)
        end

        local function toggleKeys(k)
            Citizen.CreateThread(function()
                while showingInterior do
                    if IsControlJustPressed(0, 38) then
                        if showingInterior == 'exit' then
                            exitTeleport(ret)
                        end

                        if k ~= nil and showingInterior == 'search-'..k then
                            processSearch(k)
                        end
                    end
                    Citizen.Wait(5)
                end
            end)
        end

        Citizen.CreateThread(function()
            SendNUIMessage({
                action = "show",
            })
            while currentlyRobbing do
                local currentNoise = GetPlayerCurrentStealthNoise(PlayerId())
                local percentage = math.floor((currentNoise * 100 / 8.0))
                SendNUIMessage({
                    action = "update",
                    amount = percentage
                })
                if percentage > 85 then
                    if not npcWoken then
                        wakeNPC()
                    end
                end
                Citizen.Wait(10)
            end
        end)

        Citizen.CreateThread(function()
            while currentlyRobbing do
                if GLOBAL_COORDS then
                    local distanceExit = #(GLOBAL_COORDS - vector3(prop.coords.entrance.x, prop.coords.entrance.y, prop.coords.entrance.z))
                    if distanceExit < 1.0 then
                        if not showingInterior then
                            TriggerEvent('pw_items:showUsableKeys', true, {{['key'] = "e", ['label'] = "Leave"}})
                            showingInterior = 'exit'
                            toggleKeys()
                        end
                    else
                        if showingInterior == 'exit' then
                            TriggerEvent('pw_items:showUsableKeys', false)
                            showingInterior = false
                        end
                    end

                    for k, v in pairs(prop.coords.search) do
                        if v.searched == nil then
                            local distance = #(GLOBAL_COORDS - vector3(v.x, v.y, v.z))
                            if distance < 1.0 then
                                if not showingInterior then
                                    TriggerEvent('pw_items:showUsableKeys', true, {{['key'] = "e", ['label'] = "Search"}})
                                    showingInterior = 'search-'..k
                                    toggleKeys(k)
                                end
                            else
                                if showingInterior == 'search-'..k then
                                    TriggerEvent('pw_items:showUsableKeys', false)
                                    showingInterior = false
                                end
                            end
                        else
                            if showingInterior == 'search-'..k then
                                TriggerEvent('pw_items:showUsableKeys', false)
                                showingInterior = false
                            end
                        end
                    end
                end
                Citizen.Wait(100)
            end
        end)
    end, pro)
end

RegisterNetEvent('pw_houserobbery:client:sendOutProperties')
AddEventHandler('pw_houserobbery:client:sendOutProperties', function(props)
    properties = props
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(data)
    PW.TriggerServerCallback('pw_houserobbery:server:requestProperties', function(locations)
        properties = locations
        playerData = data
        GLOBAL_PED = PlayerPedId()
        GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        characterLoaded = true
    end)
end)

RegisterNetEvent('pw_houserobbery:client:useScrewdriver')
AddEventHandler('pw_houserobbery:client:useScrewdriver', function(items)
    if showing then
        local currentHouse = showing
        PW.TriggerServerCallback('pw_houserobbery:server:checkAvalProperty', function(pro)
            if pro ~= false then
                TriggerServerEvent('pw_houserobbery:server:updateProperty', currentHouse, "canrob", false)
                TriggerEvent('pw_lockpick:client:startGame', function(success)
                    if success then
                        TriggerServerEvent('pw_houserobbery:server:updateProperty', currentHouse, "robbing", true)
                        TriggerServerEvent('pw_houserobbery:server:updateProperty', currentHouse, "propertyid", pro)
                        TriggerServerEvent('pw_houserobbery:server:updateProperty', currentHouse, "by", GetPlayerServerId(PlayerId()))
                        TriggerServerEvent('pw_houserobbery:server:updateRobHouse', pro, "inuse", true)
                        TriggerServerEvent('pw_houserobbery:server:updateRobHouse', pro, "useby", GetPlayerServerId(PlayerId()))
                        teleportIntoProperty(pro, currentHouse)
                    else
                        TriggerServerEvent('pw_houserobbery:server:updateProperty', currentHouse, "canrob", true)
                        showing = false
                    end
                end)
            else
                exports['pw_notify']:SendAlert('info', "This property currently can not be robbed", 5000)
            end
        end)
    end
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    characterLoaded = false
    playerData = nil
    properties = {}
    GLOBAL_PED = nil
    GLOBAL_COORDS = nil
end)

function createNPCPed(x,y,z,h)
    local pedHash = GetHashKey('a_f_y_business_02')
    while not HasModelLoaded(pedHash) do
        RequestModel(pedHash)
        Wait(10)
    end
    npcPedId = CreatePed(5, pedHash, x,y,(z-1.2),h, true, true)
    SetBlockingOfNonTemporaryEvents(npcPedId, true)
    SetPedFleeAttributes(npcPedId, 0, 0)
    Wait(2000)
    SetEntityCoords(npcPedId, x,y,(z-1.2))
    Citizen.CreateThread(function()
        local dict = "amb@world_human_bum_slumped@male@laying_on_left_side@base"
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(5)
            RequestAnimDict(dict)
        end
        TaskPlayAnim(npcPedId, dict, 'base', 8.0, 1.0, -1, 2, 0, 0, 0, 0)
    end)
end
--[[
Citizen.CreateThread(function()
    while true do
        if IsControlJustPressed(0,38) then
            print('wtf?', GetHashKey('a_f_y_business_02'))
            createNPCPed(1859.39, -960.75, 77.23, 335.47)
            
        end
        Citizen.Wait(5)
    end
end)]]  

Citizen.CreateThread(function()
    while true do
        if characterLoaded and playerData and GLOBAL_PED and GLOBAL_COORDS then
            for k, v in pairs(properties) do
                if v.canrob and not v.robbing then
                    local distance = #(GLOBAL_COORDS - vector3(v.x, v.y, v.z))
                    if distance < 1.0 then
                        if not showing then
                            TriggerServerEvent('pw_items:server:showUsable', true, {"screwdriver"})
                            showing = k
                        end
                    else
                        if showing == k then
                            TriggerServerEvent('pw_items:server:showUsable', false)
                            showing = false
                        end
                    end
                else
                    if showing == k then
                        TriggerServerEvent('pw_items:server:showUsable', false)
                        showing = false
                    end
                end
            end
        end
        Citizen.Wait(100)
    end
end)