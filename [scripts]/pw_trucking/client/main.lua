local showing, showingMarkerDepot, showingDeliveryMarker, specialdelivery, regulardelivery, fueldelivery, awaitingreturn, usedTruck, usedTrailer, deliverytonnes, fueldeliverynum, blips, deliverylocation, seenSpecial = false, false, false, false, false, false, false, nil, nil, 30, 1, {}, {}, false  

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
    if playerData.job.job == "trucker" then
        createBlips()
    end
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    characterLoaded = false
    playerData = nil
    destroyBlips()
    RemoveDeliveryBlip()
end)

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
    if characterLoaded and playerData then
        playerData.job.duty = toggle
        showing = false
    end
end)

RegisterNetEvent('pw:setJob')
AddEventHandler('pw:setJob', function(data)
    if characterLoaded and playerData then
        playerData.job = data
        if playerData.job.job == "trucker" then
            createBlips()
        else
            destroyBlips()
        end
    end    
end)

-- Depot Draw Markers
function MarkerDrawDepot()
    Citizen.CreateThread(function()
        while showingMarkerDepot do
            Citizen.Wait(1)
            if playerData and characterLoaded then
                for k,v in pairs(Config.HaulagePoints) do
                    if v.public or (not v.public and playerData.job.job == 'trucker' and (not v.dutyNeeded or (v.dutyNeeded and playerData.job.duty))) then
                        DrawMarker(Config.Marker.markerType, v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.markerSize.x, Config.Marker.markerSize.y, Config.Marker.markerSize.z, Config.Marker.markerColor.r, Config.Marker.markerColor.g, Config.Marker.markerColor.b, 100, false, true, 2, true, nil, nil, false)
                    end    
                end  
            end               
        end
    end)
end
-- Delivery Draw Markers
function MarkerDrawDelivery(x, y, z)
    Citizen.CreateThread(function()
        while characterLoaded and showingDeliveryMarker do
            Citizen.Wait(1)   
            DrawMarker(Config.DeliveryMarker.markerType, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.DeliveryMarker.markerSize.x, Config.DeliveryMarker.markerSize.y, Config.DeliveryMarker.markerSize.z, Config.DeliveryMarker.markerColor.r, Config.DeliveryMarker.markerColor.g, Config.DeliveryMarker.markerColor.b, 100, true, true, 2, true, nil, nil, false)          
        end
    end)
end

-- Depot Location Loop
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if characterLoaded and playerData then
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            for k,v in pairs(Config.HaulagePoints) do
                if v.public or (not v.public and playerData.job.job == 'trucker' and (not v.dutyNeeded or (v.dutyNeeded and playerData.job.duty))) then
                    local dist = #(pedCoords - vector3(v.coords.x, v.coords.y, v.coords.z))
                    if dist < 70 then
                        if not showingMarkerDepot then
                            showingMarkerDepot = true
                            MarkerDrawDepot()
                        end
                        if dist < v.drawDistance then
                            if not showing then
                                showing = k
                                DrawFText(k, showing)
                            end
                        elseif showing == k then
                            showing = false
                            TriggerEvent('pw_drawtext:hideNotification')
                        end
                    elseif showingMarkerDepot then 
                        showingMarkerDepot = false
                    end        
                elseif showing == k then
                    showing = false
                    TriggerEvent('pw_drawtext:hideNotification')
                end
            end
        end  
    end
end)

-- The pw_drawtext 
function DrawFText(type, var)
    local title, message, icon
    if type == 'duty' then
        title = "Haulage Garage Duty"
        message = "<span style='font-size:25px'>Go <b><span class='text-"..(playerData.job.duty and "danger'>Off" or "success'>On").."</span></b> Duty</span>"
        icon = "far fa-mail-bulk"
    elseif type == 'haulageMenu' then
        title = "Haulage Garage"
        message = "<span style='font-size:20px'>Access <b><span class='text-primary'>Haulage Garage</span></b></span>"
        icon = "fad fa-warehouse"
    elseif type == 'vehicleReturn' then
        title = "Haulage Vehicle Returns"
        message = "<span style='font-size:20px'><b>Access <span class='text-primary'>Haulage Vehicle Returns</span>" .. (awaitingreturn and " and finish delivery</b></span>" or "</b></span>")
        icon = "fad fa-warehouse"    
    elseif type == 'regulardelivery' then
        title = "Park Truck and Unload"
        message = "<span style='font-size:20px'>Park Truck And <b><span class='text-primary'>Unload</span><br>Make Sure to Park Sensibly.</b></span>"
        icon = "fad fa-truck-loading"
    elseif type == 'specialdelivery' then
        title = "Park Truck and Unload the Special Delivery"
        message = "<span style='font-size:20px'>Park Truck And <b><span class='text-primary'>Let the Crew Unload the Trailer</span></b></span>"
        icon = "fad fa-stars"    
    elseif type == 'fueldelivery' then
        title = "Park Truck and Unload Fuel"
        message = "<span style='font-size:20px'>Park Truck And <b><span class='text-primary'>Unload and Deliver Fuel</span></b></span>"
        icon = "fad fa-gas-pump"    
    elseif type == 'fueldeliverypickup' then
        title = "Park Truck and Load Up Fuel"
        message = "<span style='font-size:20px'>Park Truck And <b><span class='text-primary'>Load up Fuel</span></b></span>"
        icon = "fad fa-gas-pump"    
    end    
    if title ~= nil and message ~= nil and icon ~= nil then
        TriggerEvent('pw_drawtext:showNotification', { title = title, message = message, icon = icon })
    end

    Citizen.CreateThread(function()
        while showing == var do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local pedVeh = GetVehiclePedIsIn(playerPed)
                local pedHasTrailer, pedTrailerID = GetVehicleTrailerVehicle(pedVeh)
                if type == 'duty' then
                    TriggerServerEvent('pw_haulage:server:toggleDuty')
                elseif type == 'haulageMenu' then
                    OpenHaulageMenu()
                elseif type == 'vehicleReturn' then
                    ParkVehicle()        
                elseif type == 'regulardelivery' then
                    if pedTrailerID == usedTrailer then
                        TriggerEvent('pw:progressbar:progress',
                        {
                            name = 'unload_reg',
                            duration = (deliverytonnes * 1500),
                            label = 'Unloading the Goods (' .. deliverytonnes .. ' Tonnes)',
                            useWhileDead = false,
                            canCancel = false,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            },
                        },
                        function(status)
                            if not status then
                                awaitingreturn = true
                                deliverylocation = {}
                                RemoveDeliveryBlip()
                                showingDeliveryMarker = false
                                showing = false
                                TriggerEvent('pw:notification:SendAlert', {type = "success", text = 'Return the Truck to Get Paid', length = 10000})
                                CreateDeliveryBlip(Config.HaulagePoints.vehicleReturn.coords.x, Config.HaulagePoints.vehicleReturn.coords.y, Config.HaulagePoints.vehicleReturn.coords.z)
                                TriggerEvent('pw_drawtext:hideNotification')
                            end    
                        end)
                    else    
                        TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'You Don\'t Have a Trailer or Don\'t Have the Correct One', length = 10000}) 
                    end  
                elseif type == 'specialdelivery' then
                    if pedTrailerID == usedTrailer then
                        TriggerEvent('pw:progressbar:progress',
                        {
                            name = 'unload_special',
                            duration = 60000,
                            label = 'Unloading the Equipment',
                            useWhileDead = false,
                            canCancel = false,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            },
                        },
                        function(status)
                            if not status then
                                awaitingreturn = true
                                deliverylocation = {}
                                RemoveDeliveryBlip()
                                showingDeliveryMarker = false
                                showing = false
                                TriggerEvent('pw:notification:SendAlert', {type = "success", text = 'Return the Truck to Get Paid', length = 10000})
                                CreateDeliveryBlip(Config.HaulagePoints.vehicleReturn.coords.x, Config.HaulagePoints.vehicleReturn.coords.y, Config.HaulagePoints.vehicleReturn.coords.z)
                                TriggerEvent('pw_drawtext:hideNotification')
                            end    
                        end)
                    else    
                        TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'You Don\'t Have a Trailer or Don\'t Have the Correct One', length = 10000}) 
                    end       
                elseif type == 'fueldelivery' then
                    if pedTrailerID == usedTrailer then
                        TriggerEvent('pw:progressbar:progress',
                        {
                            name = 'unload_fuel',
                            duration = 30000,
                            label = 'Offloading Fuel',
                            useWhileDead = false,
                            canCancel = false,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            },
                        },
                        function(status)
                            if not status then
                                if fueldeliverynum > 1 and fueldeliverynum <= 7 then
                                    deliverylocation = {}
                                    RemoveDeliveryBlip()
                                    showingDeliveryMarker = false
                                    showing = false
                                    fueldelivery = false
                                    TriggerEvent('pw_drawtext:hideNotification')
                                    fueldeliverynum = fueldeliverynum + 1
                                    deliverylocation = Config.FuelDeliveryPoints[fueldeliverynum]
                                    fueldelivery = true
                                    CreateDeliveryBlip(deliverylocation.x, deliverylocation.y, deliverylocation.z)
                                    TriggerEvent('pw:notification:SendAlert', {type = "success", text = 'Return the Truck to Get Paid', length = 10000})
                                elseif fueldeliverynum == 8 then
                                    deliverylocation = {}
                                    RemoveDeliveryBlip()
                                    showingDeliveryMarker = false
                                    showing = false
                                    TriggerEvent('pw_drawtext:hideNotification')
                                    
                                    awaitingreturn = true
                                    CreateDeliveryBlip(Config.HaulagePoints.vehicleReturn.coords.x, Config.HaulagePoints.vehicleReturn.coords.y, Config.HaulagePoints.vehicleReturn.coords.z)
                                    TriggerEvent('pw:notification:SendAlert', {type = "info", text = 'Return the Truck to Get Paid', length = 10000})
                                end
                            end    
                        end)
                    else    
                        TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'You Don\'t Have a Trailer or Don\'t Have the Correct One', length = 10000}) 
                    end
                elseif type == 'fueldeliverypickup' then
                    if pedTrailerID == usedTrailer then
                        TriggerEvent('pw:progressbar:progress',
                        {
                            name = 'load_fuel',
                            duration = 50000,
                            label = 'Loading Up Fuel',
                            useWhileDead = false,
                            canCancel = false,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            },
                        },
                        function(status)
                            if not status then
                                deliverylocation = {}
                                RemoveDeliveryBlip()
                                showingDeliveryMarker = false
                                showing = false
                                fueldelivery = false
                                TriggerEvent('pw_drawtext:hideNotification')
                                TriggerEvent('pw:notification:SendAlert', {type = "info", text = 'Drop the Fuel Off At RON Gas Stations', length = 10000})
                                fueldeliverynum = 2
                                deliverylocation = Config.FuelDeliveryPoints[2]
                                fueldelivery = true
                                CreateDeliveryBlip(deliverylocation.x, deliverylocation.y, deliverylocation.z)
                            end    
                        end)
                    else    
                        TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'You Don\'t Have a Trailer or Don\'t Have the Correct One', length = 10000}) 
                    end
                end    

            end
        end
    end)
end

-- Delivery Start Menu
function OpenHaulageMenu()
    local menu = {}
    table.insert(menu, { ['label'] = 'Regular Delivery ' .. (regulardelivery and '(Current - Press Again to Cancel)' or ''), ['action'] = 'pw_haulage:client:delivery', ['value'] = 'regular', ['triggertype'] = 'client', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = 'Fuel Delivery' .. (fueldelivery and '(Current - Press Again to Cancel)' or ''), ['action'] = 'pw_haulage:client:fueldelivery', ['triggertype'] = 'client', ['color'] = 'primary' })

    local chance = math.random(1, 100)
    if not seenSpecial and chance < Config.SpecialDeliveryChance then
        seenSpecial = true
        table.insert(menu, { ['label'] = 'Special Delivery' .. (specialdelivery and '(Current - Press Again to Cancel)' or ''), ['action'] = 'pw_haulage:client:delivery', ['value'] = 'special', ['triggertype'] = 'client', ['color'] = 'primary' })
    end
    TriggerEvent('pw_interact:generateMenu', menu, "Haulage Warehouse")
end

-- Cancel Delivery
function CancelDelivery()
    TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'You Are On a Delivery, Cancelling it!', length = 8000})
    specialdelivery = false
    regulardelivery = false
    fueldelivery = false
    deliverylocation = {}
    RemoveDeliveryBlip()
    showingDeliveryMarker = false
    showing = false
    TriggerEvent('pw_drawtext:hideNotification')  
end      

-- Start Regular/Fuel Delivery
RegisterNetEvent('pw_haulage:client:delivery')
AddEventHandler('pw_haulage:client:delivery', function(type)
    if type == 'regular' then
        if fueldelivery or regulardelivery or specialdelivery then
            CancelDelivery()
        else    
            local truckcoords = Config.HaulagePoints.haulageMenu.truckSpawnCoords
            local trailercoords = Config.HaulagePoints.haulageMenu.trailerSpawnCoords
            local cV = GetClosestVehicle(trailercoords.x, trailercoords.y, trailercoords.z, 9.0, 0, 71)
            local truckmodel = Config.Trucks.regular[math.random(1, #Config.Trucks.regular)]
            local trailermodel = Config.Trailers.regular[math.random(1, #Config.Trailers.regular)]
            if cV == 0 or cV == nil then
                PW.Game.SpawnOwnedVehicle(truckmodel, truckcoords, truckcoords.h, function(spawnedTruck)
                    local props = PW.Game.GetVehicleProperties(spawnedTruck)
                    usedTruck = spawnedTruck
                    PW.TriggerServerCallback('pw_vehicleshop:server:registerPotentialVin', function(vin)
                        TriggerServerEvent('pw_keys:issueKey', "Vehicle", vin, false, true)
                    end, props, spawnedTruck)
                end)
                PW.Game.SpawnOwnedVehicle(trailermodel, trailercoords, trailercoords.h, function(spawnedTrailer)
                    local props = PW.Game.GetVehicleProperties(spawnedTrailer)
                    usedTrailer = spawnedTrailer
                end)
                Citizen.Wait(500)
                AttachVehicleToTrailer(usedTruck, usedTrailer, 100)


                regulardelivery = true
                deliverytonnes = math.random(15, 30)
                deliverylocation = Config.RegularDeliveryPoints[math.random(1, #Config.RegularDeliveryPoints)]

                CreateDeliveryBlip(deliverylocation.x, deliverylocation.y, deliverylocation.z)

                local street, cross = GetStreetNameAtCoord(deliverylocation.x, deliverylocation.y, deliverylocation.z)
                local streetName = GetStreetNameFromHashKey(street)


                TriggerEvent('pw:notification:SendAlert', {type = "info", text = 'Regular Delivery Started, You Will Be Delivering ' .. deliverytonnes .. ' Tonnes Of Goods to ' .. streetName .. '! Get in the Vehicle!', length = 15000})


            else
                TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'There\'s a vehicle blocking the vehicle exit', length = 8000})
            end
        end
    elseif type == 'special' then
        if fueldelivery or regulardelivery or specialdelivery then
            CancelDelivery()
        else    

            local truckcoords = Config.HaulagePoints.haulageMenu.truckSpawnCoords
            local trailercoords = Config.HaulagePoints.haulageMenu.trailerSpawnCoords
            local cV = GetClosestVehicle(trailercoords.x, trailercoords.y, trailercoords.z, 9.0, 0, 71)
            local truckmodel = Config.Trucks.special[math.random(1, #Config.Trucks.special)]
            local trailermodel = Config.Trailers.special[math.random(1, #Config.Trailers.special)]

            if cV == 0 or cV == nil then
                PW.Game.SpawnOwnedVehicle(truckmodel, truckcoords, truckcoords.h, function(spawnedTruck)
                    local props = PW.Game.GetVehicleProperties(spawnedTruck)
                    usedTruck = spawnedTruck
                    PW.TriggerServerCallback('pw_vehicleshop:server:registerPotentialVin', function(vin)
                        TriggerServerEvent('pw_keys:issueKey', "Vehicle", vin, false, true)
                    end, props, spawnedTruck)
                end)
                PW.Game.SpawnOwnedVehicle(trailermodel, trailercoords, trailercoords.h, function(spawnedTrailer)
                    local props = PW.Game.GetVehicleProperties(spawnedTrailer)
                    usedTrailer = spawnedTrailer
                end)

                Citizen.Wait(500)
                AttachVehicleToTrailer(usedTruck, usedTrailer, 100)
                
                specialdelivery = true
                deliverylocation = Config.SpecialDeliveryPoints[math.random(1, #Config.SpecialDeliveryPoints)]
                CreateDeliveryBlip(deliverylocation.x, deliverylocation.y, deliverylocation.z)


                local street, cross = GetStreetNameAtCoord(deliverylocation.x, deliverylocation.y, deliverylocation.z)
                local streetName = GetStreetNameFromHashKey(street)

                TriggerEvent('pw:notification:SendAlert', {type = "info", text = 'Specialised Delivery Started, You Will Be Delivering to ' .. streetName .. '! Get in the Vehicle!', length = 15000})

            else
                TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'There\'s a vehicle blocking the vehicle exit', length = 8000})
            end
        end  
    end          
end)
-- Start Fuel Delivery
RegisterNetEvent('pw_haulage:client:fueldelivery')
AddEventHandler('pw_haulage:client:fueldelivery', function()
    if fueldelivery or regulardelivery or specialdelivery then
        CancelDelivery()
    else

        fueldeliverynum = 1
        local truckcoords = Config.HaulagePoints.haulageMenu.truckSpawnCoords
        local trailercoords = Config.HaulagePoints.haulageMenu.trailerSpawnCoords
        local cV = GetClosestVehicle(trailercoords.x, trailercoords.y, trailercoords.z, 9.0, 0, 71)
        local truckmodel = Config.Trucks.fuel[math.random(1, #Config.Trucks.fuel)]
        local trailermodel = Config.Trailers.fuel[math.random(1, #Config.Trailers.fuel)]

        if cV == 0 or cV == nil then
            PW.Game.SpawnOwnedVehicle(truckmodel, truckcoords, truckcoords.h, function(spawnedTruck)
                local props = PW.Game.GetVehicleProperties(spawnedTruck)
                usedTruck = spawnedTruck
                PW.TriggerServerCallback('pw_vehicleshop:server:registerPotentialVin', function(vin)
                    TriggerServerEvent('pw_keys:issueKey', "Vehicle", vin, false, true)
                end, props, spawnedTruck)
            end)
            PW.Game.SpawnOwnedVehicle(trailermodel, trailercoords, trailercoords.h, function(spawnedTrailer)
                local props = PW.Game.GetVehicleProperties(spawnedTrailer)
                usedTrailer = spawnedTrailer
            end)
            Citizen.Wait(500)

            AttachVehicleToTrailer(usedTruck, usedTrailer, 100)

            fueldelivery = true
            deliverylocation = Config.FuelDeliveryPoints[1]
            CreateDeliveryBlip(deliverylocation.x, deliverylocation.y, deliverylocation.z)
            TriggerEvent('pw:notification:SendAlert', {type = "info", text = 'Fuel Delivery Started, Go and Collect Fuel', length = 15000})
        else
            TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'There\'s a vehicle blocking the vehicle exit', length = 8000})
        end
    end         
end)
-- Park Vehicle/Finish Delivery and get paid
function ParkVehicle()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        if awaitingreturn then
            if regulardelivery then
                deliverylocation = {}
                RemoveDeliveryBlip()
                awaitingreturn = false
                regulardelivery = false
                TriggerEvent('pw:notification:SendAlert', {type = "success", text = 'Delivery Completed', length = 5000})
                TriggerServerEvent('pw_haulage:server:finishdelivery', 'regular')
            elseif specialdelivery then
                deliverylocation = {}
                RemoveDeliveryBlip()
                awaitingreturn = false
                specialdelivery = false
                TriggerEvent('pw:notification:SendAlert', {type = "success", text = 'Special Delivery Completed', length = 5000})
                TriggerServerEvent('pw_haulage:server:finishdelivery', 'special') 
            elseif fueldelivery then
                deliverylocation = {}
                RemoveDeliveryBlip()
                awaitingreturn = false
                fueldelivery = false
                fueldeliverynum = 1
                TriggerEvent('pw:notification:SendAlert', {type = "success", text = 'Fuel Delivery Completed', length = 5000})
                TriggerServerEvent('pw_haulage:server:finishdelivery', 'fuel')
            end 
        else    
            if regulardelivery or specialdelivery then
                CancelDelivery() 
            end
        end 

        local playerPed = PlayerPedId()
        local found = false  
        for k,v in pairs(Config.Trucks) do
            for i = 1, #v do
                if GetHashKey(v[i]) == GetEntityModel(GetVehiclePedIsIn(playerPed)) then
                    found = true
                    break
                end
            end
        end
        if found then
            local playerPed = PlayerPedId()
            local pedVeh = GetVehiclePedIsIn(playerPed)
            local vin = PW.Vehicles.GetVinNumber(PW.Game.GetVehicleProperties(pedVeh).plate)
            TriggerServerEvent('pw_keys:revokeKeys', 'Vehicle', vin, true, nil)
            SetEntityAsMissionEntity(pedVeh, true, true)
            DeleteEntity(pedVeh)
        else
            TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'This is not a Job Vehicle', length = 8000})
        end 
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'Your are not in a Vehicle!', length = 5000})
    end         
end


-- Delivery Markers Loop
Citizen.CreateThread(function()
	while true do
        Citizen.Wait(500)
        if characterLoaded and playerData and not awaitingreturn then
            if regulardelivery then
                local player = GetPlayerPed(-1)
                local coords = GetEntityCoords(player) 
                if GetDistanceBetweenCoords(coords, deliverylocation.x, deliverylocation.y, deliverylocation.z, true) < 30.0 then
                    if not showingDeliveryMarker then
                        showingDeliveryMarker = true
                        MarkerDrawDelivery(deliverylocation.x, deliverylocation.y, deliverylocation.z)
                    end
                    if GetDistanceBetweenCoords(coords, deliverylocation.x, deliverylocation.y, deliverylocation.z, true) < 2.0 then
                        if not showing then
                            showing = true
                            DrawFText('regulardelivery', showing)
                        end
                    elseif showing then
                        showing = false
                        TriggerEvent('pw_drawtext:hideNotification')
                    end   
                elseif showingDeliveryMarker then
                    showingDeliveryMarker = false
                end          
            elseif specialdelivery then
                local player = GetPlayerPed(-1)
                local coords = GetEntityCoords(player) 
                if GetDistanceBetweenCoords(coords, deliverylocation.x, deliverylocation.y, deliverylocation.z, true) < 30.0 then
                    if not showingDeliveryMarker then
                        showingDeliveryMarker = true
                        MarkerDrawDelivery(deliverylocation.x, deliverylocation.y, deliverylocation.z)
                    end
                    if GetDistanceBetweenCoords(coords, deliverylocation.x, deliverylocation.y, deliverylocation.z, true) < 2.0 then
                        if not showing then
                            showing = true
                            DrawFText('specialdelivery', showing)
                        end
                    elseif showing then
                        showing = false
                        TriggerEvent('pw_drawtext:hideNotification')
                    end   
                elseif showingDeliveryMarker then
                    showingDeliveryMarker = false
                end
            elseif fueldelivery then
                local player = GetPlayerPed(-1)
                local coords = GetEntityCoords(player) 
                if GetDistanceBetweenCoords(coords, deliverylocation.x, deliverylocation.y, deliverylocation.z, true) < 30.0 then
                    if not showingDeliveryMarker then
                        showingDeliveryMarker = true
                        MarkerDrawDelivery(deliverylocation.x, deliverylocation.y, deliverylocation.z)
                    end
                    if GetDistanceBetweenCoords(coords, deliverylocation.x, deliverylocation.y, deliverylocation.z, true) < 2.0 then
                        if not showing then
                            showing = true
                            if fueldeliverynum == 1 then
                                DrawFText('fueldeliverypickup', showing)
                            else
                                DrawFText('fueldelivery', showing)
                            end    
                        end
                    elseif showing then
                        showing = false
                        TriggerEvent('pw_drawtext:hideNotification')
                    end   
                elseif showingDeliveryMarker then
                    showingDeliveryMarker = false
                end
            end                     
        end 		
	end
end)

-- Delivery Blips
function CreateDeliveryBlip(coordsx, coordsy, coordsz)
    deliveryblip = AddBlipForCoord(coordsx, coordsy, coordsz)
    SetBlipColour(deliveryblip, 57)
    SetBlipRoute(deliveryblip, true)
    SetBlipRouteColour(deliveryblip, 57)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Delivery Location')
    EndTextCommandSetBlipName(deliveryblip)   
end

function RemoveDeliveryBlip()
    if deliveryblip ~= nil then
	    RemoveBlip(deliveryblip)
	    deliveryblip = nil
    end
end 

-- Location Blips
function createBlips()
    Citizen.CreateThread(function()
        for k, v in pairs(Config.HaulagePoints) do
            if v.blip then
                blips[k] = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
                SetBlipSprite(blips[k], Config.Blips.type)
                SetBlipDisplay(blips[k], 4)
                SetBlipScale  (blips[k], Config.Blips.scale)
                SetBlipColour (blips[k], Config.Blips.color)
                SetBlipAsShortRange(blips[k], true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(Config.Blips.name)
                EndTextCommandSetBlipName(blips[k])
            end    
        end
    end)
end

function destroyBlips()
    for k, v in pairs(blips) do
        RemoveBlip(v)
    end
end

