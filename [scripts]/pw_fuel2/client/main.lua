local showing = false
local canUsePump = false
local pumpAction
local currentCost = 0
local currentLevel = nil
local refueling = false

Citizen.CreateThread(function()
    -- this thread registers the decorators to the client, and will update the clients ped id and coordinates.
    for k, v in pairs(Config.DecorsRequired) do
        DecorRegister(k, v)
    end
    while true do
        if characterLoaded then
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
        Citizen.Wait(50)
    end
end)

function setFuelLevel(veh, lvl)
    if veh ~= nil and lvl ~= nil then
        local vehicleProps = PW.Game.GetVehicleProperties(veh)
        TriggerServerEvent('pw_fuel:server:setVehicleFuel', vehicleProps.plate, lvl)
        return true
    end

    return false
end

exports('setFuelLevel', function(veh, lvl)
    return setFuelLevel(veh, lvl)
end)

Citizen.CreateThread(function()
    -- This Thread creates a decorator for the fuel, incase the vehicle has never been used by anyone, and sets it globally if not set,
    -- any passenger or driver will trigger this event if its not set
    local processing = false
    while true do
        local letSleep = false
        if characterLoaded and GLOBAL_PED then
            if IsPedInAnyVehicle(GLOBAL_PED, false) then
                local vehicle = GetVehiclePedIsIn(GLOBAL_PED, false)
                if vehicle ~= nil then
                    if not DecorExistOn(vehicle, "pw_vehicles_fuelLevel") then
                        if not processing then
                            local vehicleProps = PW.Game.GetVehicleProperties(vehicle)
                            if vehicleProps ~= nil then
                                processing = true
                                PW.TriggerServerCallback('pw_fuel:server:getVehicleFuel', function(lvl)
                                    local fuelType = getVehicleType(vehicle)
                                    DecorSetFloat(vehicle, "pw_vehicles_fuelLevel", (lvl+0.0))
                                    DecorSetInt(vehicle, "pw_vehicles_fuelType", Config.DecorValues[fuelType])
                                    processing = false
                                end, vehicleProps.plate)
                            end
                        end
                    else
                        letSleep = true
                    end
                end
            end
        else
            letSleep = true
        end
        if letSleep then
            Citizen.Wait(100)
        else
            Citizen.Wait(1)
        end
    end
end)

Citizen.CreateThread(function()
    -- This thread manages the fuel for only the driver of the vehicle, and is only called if the client is sitting in the vehicle in the drivers seat.
    while true do
        if characterLoaded and GLOBAL_PED then
            if IsPedInAnyVehicle(GLOBAL_PED, false) and GetPedInVehicleSeat(GetVehiclePedIsIn(GLOBAL_PED, false), -1) == GLOBAL_PED then
                if not managingFuel then
                    local veh = GetVehiclePedIsIn(GLOBAL_PED, false)
                    managingFuel = veh
                    manageFuel(managingFuel)
                end
            else
                if managingFuel then
                    managingFuel = false
                end
            end
        end

        Citizen.Wait(100)
    end
end)

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(data)
    playerData = data
    GLOBAL_PED = PlayerPedId()
    GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
    characterLoaded = true
end)

RegisterNetEvent('pw_banking:updateCash')
AddEventHandler('pw_banking:updateCash', function(data)
    if characterLoaded and playerData then
        playerData.cash = data
    end
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    characterLoaded = false
    playerData = nil
    GLOBAL_PED = nil
    GLOBAL_COORDS = nil
    loadedVehicles = {}
end)

exports('getVehicleFuel', function(plate)
    if loadedVehicles[plate] then
        return loadedVehicles[plate].level
    else
        return 0
    end
end)

function getVehicleType(veh)
    local pedVeh = GetEntityModel(GetVehiclePedIsIn(PlayerPedId()))
    for k,v in pairs(Config.VehicleTypes) do
        for i = 1, #v do
            if pedVeh == GetHashKey(v[i]) then
                return k
            end
        end
    end

    return "gas"
end



Citizen.CreateThread(function()
    local currentGasBlip = 0
    while true do
        Citizen.Wait(5000)
        if characterLoaded and GLOBAL_PED then
            local closest = 1000
            local closestCoords

            for k,v in pairs(Config.GasStations) do
                local dstcheck = GetDistanceBetweenCoords(GLOBAL_COORDS, v)

                if dstcheck < closest then
                    closest = dstcheck
                    closestCoords = v
                end
            end

            if DoesBlipExist(currentGasBlip) then
                RemoveBlip(currentGasBlip)
            end

            currentGasBlip = CreateBlip(closestCoords)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if characterLoaded and GLOBAL_PED then
            local pumpObject, pumpDistance = FindNearestFuelPump()

            if pumpDistance < 2.5 then
                isNearPump = pumpObject
            else
                isNearPump = false
                Citizen.Wait(math.ceil(pumpDistance * 20))
            end
        end
        Citizen.Wait(150)
	end
end)

local currentMessage
Citizen.CreateThread(function()
    while true do
        if characterLoaded and GLOBAL_PED then
            if isNearPump then
                local message
                local pumpCoords = GetEntityCoords(isNearPump)
                local pumpHealth = GetEntityHealth(isNearPump)
                local vehicle = GetClosestVehicle(GLOBAL_COORDS, 2.7, 0, 71)
                local vehicleCoords = GetEntityCoords(vehicle)
                local icon = "fad fa-gas-pump"
                if pumpHealth > 700 then
                    if vehicle ~= nil and vehicle > 0 then
                        if IsPedInVehicle(GLOBAL_PED, vehicle, true) and GetPedInVehicleSeat(vehicle, -1) == GLOBAL_PED then
                            message = "<span class='text-danger'>Exit your Vehicle First</span>"
                            canUsePump = false
                            pumpAction = nil
                            if DecorGetInt(vehicle, "pw_vehicles_fuelType") == 3 then
                                icon = "fad fa-charging-station"
                            end
                        elseif IsPedInVehicle(GLOBAL_PED, vehicle, true) then
                            message = "<span class='text-danger'>Waiting for Driver to Refuel</span>"
                            canUsePump = false
                            pumpAction = nil
                            if DecorGetInt(vehicle, "pw_vehicles_fuelType") == 3 then
                                icon = "fad fa-charging-station"
                                message = "<span class='text-danger'>Waiting for Driver to Recharge</span>"
                            end
                        else
                            local distance = #(pumpCoords - vehicleCoords)
                            local vehicleProps = PW.Game.GetVehicleProperties(vehicle)
                            if distance < 2.5 and DecorGetInt(vehicle, "pw_vehicles_fuelType") == 2 then
                                message = "Press [ <span class='text-danger'>E</span> ] to refuel."
                                canUsePump = true
                                pumpAction = "vehicleRefuel"
                            elseif distance < 2.5 and DecorGetInt(vehicle, "pw_vehicles_fuelType") == 3 then
                                message = "Press [ <span class='text-danger'>E</span> ] to recharge."
                                canUsePump = true
                                pumpAction = "vehicleRefuelElectric"
                                icon = "fad fa-charging-station"
                            else
                                message = "Press [ <span class='text-danger'>E</span> ] to purchase a jerrycan.<br>Cost: $<span class='text-danger'>"..Config.JerryCanCost.."</span>"
                                canUsePump = true
                                pumpAction = "jerrycan"
                            end
                        end
                    else
                        if GetPlayersLastVehicle() then
                            local veh = GetPlayersLastVehicle()
                            if IsPedInVehicle(GLOBAL_PED, veh, false) and GetPedInVehicleSeat(veh, -1) == GLOBAL_PED then
                                message = "<span class='text-danger'>Exit your Vehicle First</span>"
                                canUsePump = false
                                pumpAction = nil
                                if DecorGetInt(veh, "pw_vehicles_fuelType") == 3 then
                                    icon = "fad fa-charging-station"
                                end
                            elseif IsPedInVehicle(GLOBAL_PED, veh, false) then
                                message = "<span class='text-danger'>Waiting for Driver to Refuel</span>"
                                canUsePump = false
                                pumpAction = nil
                                if DecorGetInt(veh, "pw_vehicles_fuelType") == 3 then
                                    icon = "fad fa-charging-station"
                                    message = "<span class='text-danger'>Waiting for Driver to Recharge</span>"
                                end
                            end
                        else
                            message = "Press [ <span class='text-danger'>E</span> ] to purchase a jerrycan.<br>Cost: $<span class='text-danger'>"..Config.JerryCanCost.."</span>"
                            canUsePump = true
                            pumpAction = "jerrycan"
                        end
                    end
                else
                    print('this one?')
                    message = "<span class='text-danger'>Pump is Out of Order</span>"
                    canUsePump = false
                    pumpAction = nil
                end


                if currentMessage ~= message then
                    TriggerEvent('pw_drawtext:showNotification', { title = "Fuel Station", message = message, icon = icon })
                    showing = isNearPump
                    currentMessage = message
                    if canUsePump then
                        startKeyPress()
                    end
                end
            else
                if showing and currentMessage then
                    TriggerEvent('pw_drawtext:hideNotification')
                    showing = false
                    currentMessage = nil
                    canUsePump = false
                    pumpAction = nil
                    refueling = false
                end
            end
        end
        Citizen.Wait(100)
    end
end)

function startKeyPress()
    Citizen.CreateThread(function()
        while canUsePump do
            if IsControlJustReleased(0, 38) and not refueling then
                if pumpAction == "jerrycan" then
                    purchaseJerryCan()
                else
                    startRefuelTick()
                end
            end
            Citizen.Wait(10)
        end
    end)
end

function startRefuelTick()
    refueling = true
    local vehicle = GetPlayersLastVehicle()
    local vehicleProps = PW.Game.GetVehicleProperties(vehicle)
    TaskTurnPedToFaceEntity(GLOBAL_PED, vehicle, 1500)
    Citizen.Wait(1500)
    currentLevel = DecorGetFloat(vehicle, "pw_vehicles_fuelLevel") or 0.00
    currentCost = 0
    if math.floor(currentLevel) < 95 then
        Citizen.CreateThread(function()
            while refueling do
                for k, v in pairs(Config.DisableKeys) do
                    DisableControlAction(0, v, true)
                end
                Citizen.Wait(0)
            end
        end)

        Citizen.CreateThread(function()
            while refueling do
                local finished = false
                local payforFuel = false
                local completeRandom
                if DecorGetInt(vehicle, "pw_vehicles_fuelType") == 3 then
                    completeRandom = math.random(3,5)
                else
                    completeRandom = math.random(5,8)
                end
                local currentBeforeAdd = DecorGetFloat(vehicle, "pw_vehicles_fuelLevel")
                local newAddition = (math.floor(currentBeforeAdd) + (completeRandom + 0.0))
                currentCost = currentCost + (Config.RefuelPerPercentCost * completeRandom)
                local message = "<span class='text-danger'>"..math.floor(newAddition).."%</span> Complete"
                local icon

                if DecorGetInt(vehicle, "pw_vehicles_fuelType") == 3 then
                    message = "Recharging "..message
                    icon = "fad fa-charging-station"
                else
                    message = "Refueling "..message
                    icon = "fad fa-gas-pump"
                end

                if math.floor(newAddition) >= 100 then
                    newAddition = 100.00
                end

                if math.floor(newAddition) >= 100 then
                    if playerData.cash >= currentCost then
                        newAddition = 100.00
                        if DecorGetInt(vehicle, "pw_vehicles_fuelType") == 3 then
                            message = "Recharge Complete <span class='text-danger'>"..math.floor(newAddition).."%</span><br>We have charged you $<span class='text-danger'>"..currentCost.."</span>"
                        else
                            message = "Refuel Complete <span class='text-danger'>"..math.floor(newAddition).."%</span><br>We have charged you $<span class='text-danger'>"..currentCost.."</span>"
                        end
                        finished = true
                        payforFuel = true
                    else
                        newAddition = currentLevel
                        if DecorGetInt(vehicle, "pw_vehicles_fuelType") == 3 then
                            message = "Recharge Failed <span class='text-danger'>Insufficent Funds<br>$"..currentCost.." required.</span>"..currentCost.."</span>"
                        else
                            message = "Refuel Failed <span class='text-danger'>Insufficent Funds<br>$"..currentCost.." required.</span>"..currentCost.."</span>"
                        end
                        finished = true
                    end
                end
                
                TriggerEvent('pw_drawtext:showNotification', { title = "Fuel Station", message = message, icon = icon })
                TriggerServerEvent('pw_fuel:server:updateFuelLevel', vehicleProps.plate, newAddition)
                DecorSetFloat(vehicle, "pw_vehicles_fuelLevel", newAddition)
                SetVehicleFuelLevel(vehicle, newAddition)
                if finished then
                    if payforFuel then
                        TriggerServerEvent('pw_fuel:server:payforFuel', math.floor(currentCost))
                    end
                    currentCost = 0
                    currentLevel = 0.00
                    refueling = false
                end

                

                Citizen.Wait(1500)
            end
        end)
    else
        refueling = false
        TriggerEvent('pw_drawtext:showNotification', { title = "Fuel Station", message = "Your tank is already full.", icon = "fad fa-gas-pump" })
    end
end

RegisterNetEvent('pw_fuel:client:syncVehicles')
AddEventHandler('pw_fuel:client:syncVehicles', function(plate, tab)
    loadedVehicles[plate] = tab
end)

function purchaseJerryCan()
    print('jerrycan purchased')
end