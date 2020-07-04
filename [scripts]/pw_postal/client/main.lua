local onDelivery, deliveryNumber, deliveryAmount, deliveryblip, waitingforvan, waitingforfoot, packagefromvan, maxDeliveries, lastdelivery, blips = false, 1, 1, {}, false, false, false, 5, nil, {}
local playerCurrentlyAnimated, playerCurrentlyHasProp, firstAnim, playerPropList = false, false, true, {}
local showing, showingMarker, showingText, showingMarkerDepot  = false, false, false, false

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
    GLOBAL_PED = PlayerPedId()
    GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
    if playerData.job.job == "postal" then
        createBlips()
    end
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    characterLoaded = false
    playerData = nil
    destroyBlips()
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
        if playerData.job.job == "postal" then
            createBlips()
        else
            destroyBlips()
        end
    end    
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if characterLoaded then
            GLOBAL_PED = PlayerPedId()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if characterLoaded and GLOBAL_PED then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)


function MarkerDrawDepot()
    Citizen.CreateThread(function()
        while showingMarkerDepot do
            Citizen.Wait(1)
            if characterLoaded and playerData then
                for k,v in pairs(Config.PostalPoints) do
                    if v.public or (not v.public and playerData.job.job == 'postal' and (not v.dutyNeeded or (v.dutyNeeded and playerData.job.duty))) then
                        DrawMarker(Config.Marker.postalPoints.markerType, v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.postalPoints.markerSize.x, Config.Marker.postalPoints.markerSize.y, Config.Marker.postalPoints.markerSize.z, Config.Marker.postalPoints.markerColor.r, Config.Marker.postalPoints.markerColor.g, Config.Marker.postalPoints.markerColor.b, 100, false, true, 2, true, nil, nil, false)
                    end    
                end 
            end                 
        end
    end)
end


function MarkerDraw(type, x, y, z)
    Citizen.CreateThread(function()
        while showingMarker and characterLoaded do
            Citizen.Wait(1)   
            if type == 1 then
                DrawMarker(Config.Marker.vanMarker.markerType, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.vanMarker.markerSize.x, Config.Marker.vanMarker.markerSize.y, Config.Marker.vanMarker.markerSize.z, Config.Marker.vanMarker.markerColor.r, Config.Marker.vanMarker.markerColor.g, Config.Marker.vanMarker.markerColor.b, 100, true, true, 2, true, nil, nil, false)
            elseif type == 2 then
                DrawMarker(Config.Marker.footMarker.markerType, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.footMarker.markerSize.x, Config.Marker.footMarker.markerSize.y, Config.Marker.footMarker.markerSize.z, Config.Marker.footMarker.markerColor.r, Config.Marker.footMarker.markerColor.g, Config.Marker.footMarker.markerColor.b, 100, true, true, 2, true, nil, nil, false) 
            end           
        end
    end)
end

function TextDraw(text, x, y, z)
    Citizen.CreateThread(function()
        while showingText and characterLoaded do
            Citizen.Wait(1)
            PW.Game.DrawText3D(x, y, z, text)
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if characterLoaded and playerData then

            for k,v in pairs(Config.PostalPoints) do
                if v.public or (not v.public and playerData.job.job == 'postal' and (not v.dutyNeeded or (v.dutyNeeded and playerData.job.duty))) then
                    local dist = #(GLOBAL_COORDS - vector3(v.coords.x, v.coords.y, v.coords.z))
                    if dist < 40 then
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



function DrawFText(type, var)
    local title, message, icon
    
    if type == 'duty' then
        title = "GoPostal Duty"
        message = "<span style='font-size:25px'>Go <b><span class='text-"..(playerData.job.duty and "danger'>Off" or "success'>On").."</span></b> Duty</span>"
        icon = "far fa-mail-bulk"
    elseif type == 'garage' then
        title = "GoPostal Garage"
        message = "<span style='font-size:20px'>Access <b><span class='text-primary'>GoPostal Garage</span></b></span>"
        icon = "fad fa-warehouse"
    elseif type == 'startDeliver' then
        title = "Start Delivery"
        message = "<span style='font-size:20px'>Fill Truck And <b><span class='text-primary'> Start a Delivery</span></b></span>"
        icon = "fad fa-truck-loading"
    elseif type == 'van' then
        title = "Delivery Point"
        message = "<span style='font-size:20px'>Park <b><span class='text-primary'>Vehicle</span> And <span class='text-primary'>Deliver Package</span></b></span>"
        icon = "fad fa-mailbox"
    elseif type == 'removeitem' then 
        title = "Van Door"
        message = "<span style='font-size:20px'><b>Get Package From Vehicle</b>"
        icon = "fad fa-truck-loading"
    elseif type == 'footdoor' then
        title = "Delivery Package"
        message = "<span style='font-size:20px'><b>Deliver Package</b>"
        icon = "fad fa-mailbox"
    end    
    if title ~= nil and message ~= nil and icon ~= nil then
        TriggerEvent('pw_drawtext:showNotification', { title = title, message = message, icon = icon })
    end

    Citizen.CreateThread(function()
        while showing == var do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                if type == 'duty' then
                    TriggerServerEvent('pw_postal:server:toggleDuty')
                elseif type == 'garage' then
                    if IsPedInAnyVehicle(GLOBAL_PED) then
                        ParkVehicle()
                    else
                        OpenGarage()
                    end
                elseif type == 'startDeliver' then
                    if not onDelivery then
                        if InCorrectVeh() then
                            OpenPostStartMenu()
                        else
                            TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'You are not in a vehicle, or are not in the correct vehicle!', length = 8000})
                        end
                    else
                        DeliveryDone(true)
                        onDelivery = false  
                    end      
                elseif type == 'van' then
                    DeliveryParkVan()
                elseif type == 'removeitem' then
                    RemovePackageFromVan()
                elseif type == 'footdoor' then    
                    PackageAtDoor()
                end    
            end
        end
    end)
end





-- Vehicle Spawner
function OpenGarage()
    local menu = {}
        table.insert(menu, { ['label'] = GetVehNameByModel(Config.PostalPoints.garage.availableVehicle), ['action'] = 'pw_postal:client:spawnVeh', ['value'] = { ['model'] = Config.PostalPoints.garage.availableVehicle }, ['triggertype'] = 'client', ['color'] = 'primary' })
    TriggerEvent('pw_interact:generateMenu', menu, "GoPostal Garage")
end


RegisterNetEvent('pw_postal:client:spawnVeh')
AddEventHandler('pw_postal:client:spawnVeh', function(data)
    local coords = Config.PostalPoints.garage.spawnCoords
    local cV = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
    if cV == 0 or cV == nil then
        PW.Game.SpawnOwnedVehicle(data.model, coords, coords.h, function(spawnedVeh)
            local props = PW.Game.GetVehicleProperties(spawnedVeh)
            PW.TriggerServerCallback('pw_vehicleshop:server:registerPotentialVin', function(vin)
                TriggerServerEvent('pw_keys:issueKey', "Vehicle", vin, false, true)
                TriggerEvent('pw:notification:SendAlert', {type = "success", text = 'Spawned Vehicle', length = 7000})
            end, props, spawnedVeh)
        end)
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'There\'s a vehicle blocking the vehicle exit', length = 8000})
    end
end)

function ParkVehicle()
    if InCorrectVeh() then
        local pedVeh = GetVehiclePedIsIn(GLOBAL_PED)
        local vin = PW.Vehicles.GetVinNumber(PW.Game.GetVehicleProperties(pedVeh).plate)
        TriggerServerEvent('pw_keys:revokeKeys', 'Vehicle', vin, true, nil)
        SetEntityAsMissionEntity(pedVeh, true, true)
        DeleteEntity(pedVeh)
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'This is not where that vehicle is from, you can\'t return it here!', length = 8000})
    end
end

function InCorrectVeh()
    local found = false
    if GetHashKey(Config.PostalPoints.garage.availableVehicle) == GetEntityModel(GetVehiclePedIsIn(GLOBAL_PED)) then
        found = true
    end
    return found
end    





function OpenPostStartMenu()  
    local menu = {}

    for i = 1, #Config.DeliveryType do
        table.insert(menu, { ['label'] = Config.DeliveryType[i], ['action'] = 'pw_postal:client:startpostal', ['value'] = { Config.DeliveryType[i] }, ['triggertype'] = 'client', ['color'] = 'primary' })
    end

    TriggerEvent('pw_interact:generateMenu', menu, "<strong>How Many Packages Would You Like To Deliver?</strong>")   
end

RegisterNetEvent('pw_postal:client:startpostal')
AddEventHandler('pw_postal:client:startpostal', function(data)
    local vehicle = GetVehiclePedIsIn(GLOBAL_PED)
    lastdelivery = GLOBAL_COORDS
    maxDeliveries = data[1]

    SetVehicleDoorOpen(vehicle, 2, false, false)
    SetVehicleDoorOpen(vehicle, 3, false, false)
    TriggerEvent('pw:progressbar:progress',
    {
        name = 'fillingTruck',
        duration = 15000,
        label = 'Filling the Truck',
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
    },
    function(status)
        if not status then
            SetVehicleDoorsShut(vehicle, false)
            Citizen.Wait(1000)
            onDelivery = true
            DeliveryStart()
        else
            TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'Cancelled', length = 5000})
            SetVehicleDoorsShut(vehicle, false)
        end    
    end)
end)


function DeliveryStart()
    onDelivery = true
    deliveryNumber = math.random(1, #Config.DeliveryPoints)
    print(deliveryNumber)
    local zone = Config.DeliveryPoints[deliveryNumber]
    if zone.van ~= nil then
        CreateDeliveryBlip(zone.van)

        local street, cross = GetStreetNameAtCoord(zone.van.x, zone.van.y, zone.van.z)
        local streetName = GetStreetNameFromHashKey(street)
        TriggerEvent('pw:notification:SendAlert', {type = "info", text = 'Delivery Point Has Been Set On Your GPS! Location: ' .. streetName, length = 10000})

        waitingforvan = true
    end    
end

function DeliveryDone(cancel)
	RemoveDeliveryBlip()
	if cancel then
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'Delivery Cancelled, Return to GoPostal!', length = 8000})
        onDelivery = false
        deliveryAmount = 1
	else
        if deliveryAmount < maxDeliveries then
            deliveryAmount = deliveryAmount + 1
            TriggerEvent('pw:notification:SendAlert', {type = "info", text = 'This is Delivery ' .. deliveryAmount .. ' of '.. maxDeliveries .. '!', length = 8000})
            Citizen.Wait(1000)
            DeliveryStart()
        else
            onDelivery = false
            deliveryAmount = 1
            TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'Delivery Finished, Return to GoPostal!', length = 8000})
        end
	end
end






function DeliveryParkVan()
    if IsPedInAnyVehicle(GLOBAL_PED, false) then
        if InCorrectVeh() then
            TriggerEvent('pw:notification:SendAlert', {type = "info", text = 'Get the Package Out of the Vehicle', length = 8000})
            showing = false
            TriggerEvent('pw_drawtext:hideNotification')
            waitingforvan = false
            showingMarker = false
            packagefromvan = true
        else
            TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'Make Sure to Use the Vehicle Provided', length = 8000})   
        end
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'Get Back in the Vehicle', length = 8000})
    end
end    

function RemovePackageFromVan()
    local vehicle = GetVehiclePedIsIn(GLOBAL_PED, true)
    local bone = GetEntityBoneIndexByName(vehicle, 'platelight')
    local locationofbone = GetWorldPositionOfEntityBone(vehicle, bone) 
    SetVehicleDoorOpen(vehicle, 2, false, false)
    SetVehicleDoorOpen(vehicle, 3, false, false)
    TriggerEvent('pw:progressbar:progress',
    {                                     
        name = 'remove_package',
        duration = 5000,
        label = 'Finding Package',
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
    },
    function(status)
        if not status then
            TriggerEvent('pw_postal:Animation', 'anim@heists@box_carry@', 'idle', 49) -- Load/Start animation
            loadPropDict('hei_prop_heist_box')
            TriggerEvent('pw_postal:AttachProp', 'hei_prop_heist_box', 60309, 0.025, 0.08, 0.255, -145.0, 290.0, 0.0)

            TriggerEvent('pw:notification:SendAlert', {type = "info", text = 'Found Package, Look Around For Where to Deliver', length = 8000})
            packagefromvan = false
            SetVehicleDoorsShut(vehicle, false)
            showing = false
            TriggerEvent('pw_drawtext:hideNotification')
            showingText = false
            waitingforfoot = true
        end    
    end)
end  

function PackageAtDoor()
    TriggerEvent('pw:progressbar:progress',
    {
        name = 'deliver_package',
        duration = 4000,
        label = 'Delivering Package',
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
    },
    function(status)
        if not status then
            TriggerEvent('pw_postal:StopAnimation') -- stop carrying box
            waitingforfoot = false
            TriggerServerEvent('pw_postal:server:finishdelivery')
            DeliveryDone()
            showingText = false
            showing = false
            TriggerEvent('pw_drawtext:hideNotification')
        end    
    end)
end





Citizen.CreateThread(function()
	while true do
        Citizen.Wait(500)
        if characterLoaded and playerData and onDelivery then
            local zone = Config.DeliveryPoints[deliveryNumber]
            if waitingforvan then
                local dist = #(GLOBAL_COORDS - vector3(zone.van.x, zone.van.y, zone.van.z))
                if dist < 40.0 then
                    if not showingMarker then
                        showingMarker = true
                        MarkerDraw(1, zone.van.x, zone.van.y, zone.van.z)
                    end
                    if dist < 3.0 then
                        if not showing then
                            showing = true
                            DrawFText('van', showing)
                        end
                    elseif showing then
                        showing = false
                        TriggerEvent('pw_drawtext:hideNotification')
                    end   
                elseif showingMarker then
                    showingMarker = false
                end  


            elseif packagefromvan then
                local vehicle = GetVehiclePedIsIn(GLOBAL_PED, true)
                local bone = GetEntityBoneIndexByName(vehicle, 'platelight')
                local locationofbone = GetWorldPositionOfEntityBone(vehicle, bone) 
                local dist = #(GLOBAL_COORDS - vector3(locationofbone.x, locationofbone.y, locationofbone.z))
                if dist < 10.0 then
                    if not showingText then
                        showingText = true
                        TextDraw('Find Package', locationofbone.x, locationofbone.y, locationofbone.z)
                    end
                    if dist < 3.0 then
                        if not showing then
                            showing = true
                            DrawFText('removeitem', showing)
                        end
                    elseif showing then
                        showing = false
                        TriggerEvent('pw_drawtext:hideNotification')
                    end   
                elseif showingText then
                    showingText = false
                end   



            elseif waitingforfoot then
                local vectorcoords = vector3(zone.foot.x, zone.foot.y, zone.foot.z + 1)
                local distancetravelled = 1609 -- in meters so that is a mile
                lastdelivery = coords
                local dist = #(GLOBAL_COORDS - vector3(zone.foot.x, zone.foot.y, zone.foot.z))
                if dist < 100.0 then
                    if not showingMarker then
                        showingMarker = true
                        MarkerDraw(2, zone.foot.x, zone.foot.y, zone.foot.z)
                    end
                    if not showingText then
                        showingText = true
                        TextDraw('Delivery Point', vectorcoords.x, vectorcoords.y, vectorcoords.z)
                    end
                    if dist < 3.0 then
                        if not showing then
                            showing = true
                            DrawFText('footdoor', showing)
                        end
                    elseif showing then
                        showing = false
                        TriggerEvent('pw_drawtext:hideNotification')
                    end   
                elseif showingMarker then
                    showingMarker = false
                elseif showingText then
                    showingText = false
                end         
            end       
        end 		
	end
end)




function CreateDeliveryBlip(coords)
    if coords ~= nil then
        deliveryblip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipColour(deliveryblip, 1)
        SetBlipRoute(deliveryblip, true)
        SetBlipRouteColour(deliveryblip, 1)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('Delivery Point')
        EndTextCommandSetBlipName(deliveryblip)
    end    
end

function RemoveDeliveryBlip()
    if deliveryblip ~= nil then
	    RemoveBlip(deliveryblip)
	    deliveryblip = nil
    end
end  


function createBlips()
    Citizen.CreateThread(function()
        for k, v in pairs(Config.PostalPoints) do
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



function GetVehNameByModel(model)
    local hashVehicle = (type(model) ~= "number" and GetHashKey(model) or model)
    hashVehicle = string.gsub(GetDisplayNameFromVehicleModel(hashVehicle), "%s", "_")
    local vehicleName = GetLabelText(hashVehicle)
    if vehicleName == "NULL" or vehicleName == "CARNOTFOUND" then
        vehicleName = GetDisplayNameFromVehicleModel(hashVehicle)
    end
    return vehicleName
end


-- Animation Stuff

RegisterNetEvent('pw_postal:Animation')
AddEventHandler('pw_postal:Animation', function(ad, anim, body)
	if firstAnim then
		LastAD = ad
		firstAnim = false
	end
	loadAnimDict(ad)
	TaskPlayAnim(GLOBAL_PED, ad, anim, 4.0, 1.0, -1, body, 0, 0, 0, 0 )  
	RemoveAnimDict(ad)
	playerCurrentlyAnimated = true
end)

RegisterNetEvent('pw_postal:AttachProp')
AddEventHandler('pw_postal:AttachProp', function(prop_one, boneone, x1, y1, z1, r1, r2, r3)
	local x,y,z = table.unpack(GetEntityCoords(GLOBAL_PED))
	if not HasModelLoaded(prop_one) then
		loadPropDict(prop_one)
	end
	prop = CreateObject(GetHashKey(prop_one), x, y, z+0.2,  true,  true, true)
	AttachEntityToEntity(prop, GLOBAL_PED, GetPedBoneIndex(GLOBAL_PED, boneone), x1, y1, z1, r1, r2, r3, true, true, false, true, 1, true)
	SetModelAsNoLongerNeeded(prop_one)
	table.insert(playerPropList, prop)
	playerCurrentlyHasProp = true
end)

RegisterNetEvent('pw_postal:StopAnimation')
AddEventHandler('pw_postal:StopAnimation', function()
    if playerCurrentlyAnimated then
        if LastAD then
            RemoveAnimDict(LastAD)
        end
        if playerCurrentlyHasProp then
            for _,v in pairs(playerPropList) do
                DeleteEntity(v)
            end
            playerCurrentlyHasProp = false
        end
        ClearPedTasks(GLOBAL_PED)
        playerCurrentlyAnimated = false
    end
end)

function loadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(500)
	end
end
function loadPropDict(model)
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Citizen.Wait(500)
	end
end



