PW = nil
playerLoaded = false
playerData = nil
currentSeatbeltState = false
local directions = { [0] = 'North Bound', [45] = 'North-West', [90] = 'West Bound', [135] = 'South-West', [180] = 'South Bound', [225] = 'South-East', [270] = 'East Bound', [315] = 'North-East', [360] = 'North Bound', } 

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(data)
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(PlayerPedId(), true, true)
    playerData = data
    playerLoaded = true
    repeat Wait(0) until exports['pw_base']:hasCharacterSpawned() == true
    SendNUIMessage({
        status = "showhud",
    })
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    SendNUIMessage({
        status = "hidehud",
    })
    playerLoaded = false
    playerData = nil
end)

function updateClock()
    local hour, minute
    if GetClockHours() < 10 then
        hour = '0'..GetClockHours()
    else
        hour = GetClockHours()
    end
    if GetClockMinutes() < 10 then
        minute = '0'..GetClockMinutes()
    else
        minute = GetClockMinutes()
    end
    local time = hour..':'..minute
    SendNUIMessage({
        status = "updateClock",
        time = time
    })
end

function IsCar(veh)
    local vc = GetVehicleClass(veh)
    return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end

function Fwv(entity)
    local hr = GetEntityHeading(entity) + 90.0
    if hr < 0.0 then hr = 360.0 + hr end
    hr = hr * 0.0174533
    return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end



function updatePosition()
    local playerPed = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerPed)
    local street, cross = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
    local streetName = GetStreetNameFromHashKey(street)
    local crossName
    if cross ~= nil then
        crossName =  ', '..GetStreetNameFromHashKey(cross)
    else
        crossName = ''
    end

    for k,v in pairs(directions)do
        direction = GetEntityHeading(playerPed)
        if(math.abs(direction - k) < 22.5)then
            direction = v
            break
        end
    end

    SendNUIMessage({
        status = "updateStreet",
        street = streetName..crossName,
        direction = direction
    })
end

Citizen.CreateThread(function()
    while true do
        updateClock()
        updatePosition()
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    local wasInCar = false
    while true do
        if playerLoaded and playerData then
            local playerPed = GetPlayerPed(-1)
            if IsPedInAnyVehicle(playerPed, false) then
                wasInCar = true
                local vehicle = GetVehiclePedIsIn(playerPed)
                local speed = GetEntitySpeed(vehicle)
                local mph = tostring(math.ceil(speed * 2.236936))
                SetVehicleRadioEnabled(vehicle, false)
                DisplayRadar(true)
                local lights, lowbeam, highbeam = GetVehicleLightsState(vehicle)
                local tempature = GetVehicleEngineTemperature(vehicle)

                if lights then
                    light = 0
                    if lowbeam == 1 then
                        light = 1
                        if highbeam == 1 then
                            light = 2
                        end
                    end
                end

                local engineStat = GetIsVehicleEngineRunning(vehicle)
                SendNUIMessage({
                    status = "minimap"
                })
                local fuelLevel = math.floor(DecorGetFloat(vehicle, "pw_vehicles_fuelLevel")) or 100
                local fuelType = DecorGetInt(vehicle, "pw_vehicles_fuelType") or 1
                
                SendNUIMessage({
                    status = "updateVehicle",
                    speed = mph..' MPH',
                    showfuel = fuelType,
                    fuel = fuelLevel,
                    seatbelt = currentSeatbeltState,
                    lights = light,
                    engineStatus = engineStat
                })
                SendNUIMessage({
                    status = "showVehicle"
                })
            else
                if wasInCar then
                    wasInCar = false
                    DisplayRadar(false)
                    SendNUIMessage({
                        status = "nominimap"
                    })
                end
                SendNUIMessage({
                    status = "hideVehicle"
                })
            end
        end
        Citizen.Wait(500)
    end
end)

function toggleMiniMap(toggle)
    if toggle then
        SendNUIMessage({
            status = "minimap"
        })
    else
        SendNUIMessage({
            status = "nominimap"
        })
    end
end

function toggleHud(toggle)
    if toggle then
        SendNUIMessage({
            status = "showhud",
        })
    else
        SendNUIMessage({
            status = "hidehud",
        })
    end
end

exports('toggleHud', function(toggle)
    toggleHud(toggle)
end)

exports('toggleMiniMap', function(toggle)
    toggleMiniMap(toggle)
end)


local wasInCar = false
local speedBuffer = {}
local velBuffer = {}


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if playerLoaded and playerData then
            local ped = GetPlayerPed(-1)
            local car = GetVehiclePedIsIn(ped)
            
            if car ~= 0 and (wasInCar or IsCar(car)) then
                wasInCar = true
            
                if currentSeatbeltState then 
                    DisableControlAction(0, 75, true)  -- Disable exit vehicle when stop
                    DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
                end

                speedBuffer[2] = speedBuffer[1]
                speedBuffer[1] = GetEntitySpeed(car)

                local mph = tonumber(math.ceil(speedBuffer[1] * 2.236936))

                if mph >= 125 and GetPedInVehicleSeat(car, -1) == ped and not currentSeatbeltState then
                    TriggerServerEvent('pw_needs:adjustNeed', "add", "stress", mph / 12)
                end
                
                if speedBuffer[2] ~= nil and not currentSeatbeltState and GetEntitySpeedVector(car, true).y > 1.0 and speedBuffer[1] > 19.25 and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * 0.255) then
                    local co = GetEntityCoords(ped)
                    local fw = Fwv(ped)
                    SetEntityCoords(ped, co.x + fw.x, co.y + fw.y, co.z - 0.47, true, true, true)
                    SetEntityVelocity(ped, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
                    Citizen.Wait(1)
                    SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
                end
                    
                velBuffer[2] = velBuffer[1]
                velBuffer[1] = GetEntityVelocity(car)
                
            elseif wasInCar then
                wasInCar = false
                currentSeatbeltState = false
                speedBuffer[1], speedBuffer[2] = 0.0, 0.0
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if playerLoaded and playerData then
            local playerPed = GetPlayerPed(-1)
            if IsControlJustPressed(0, 170) and IsPedInAnyVehicle(playerPed, false) then
                currentSeatbeltState = not currentSeatbeltState
            end        
        end
        Citizen.Wait(3)
    end
end)

