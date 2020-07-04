local playerLoaded, playerData = false, nil
local persistentAlerts = {}
local characterSpawned = false

Citizen.CreateThread(function()
	while true do   
        Citizen.Wait(10)
        if NetworkIsSessionStarted() then
            skyCam()
            DisplayRadar(false)
            TriggerEvent('pw_base:client:closeBackground')
            TriggerServerEvent('pw_base:server:startNetworkSession')
            Wait(1000)
			return
		end
	end
end)

RegisterNetEvent('pw_base:addPersistentID')
AddEventHandler('pw_base:addPersistentID', function(alertid)
    table.insert(persistentAlerts, { ['id'] = alertid })
end)

function closePersistentNotifications()
    for k, v in pairs(persistentAlerts) do
        exports['pw_notify']:PersistentAlert('end', v.id)
    end
    TriggerEvent('pw_drawtext:hideNotification')
    TriggerServerEvent('pw_items:server:showUsable', false  )
    persistentAlerts = {}
end

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
    if playerData then
        playerData.job.duty = toggle
    end
end)

RegisterNetEvent('pw_base:joinRadio')
AddEventHandler('pw_base:joinRadio', function(action, job)
    local radioStation
    if job == "police" then
        radioStation = 1
    elseif job == "ems" then
        radioStation = 2
    elseif job == "doctor" then
        radioStation = 2
    elseif job == "fire" then
        radioStation = 3
    end

    if radioStation ~= nil then
        if action == "add" then
            exports['pw_voip']:addPlayerToRadio(radioStation)
        elseif action == "remove" then
            if exports['pw_voip']:isPlayerInChannel(radioStation) then
                exports['pw_voip']:removePlayerFromRadio(radioStation)
            end
        end
    end
end)

RegisterNetEvent('pw:playerSpawned')
AddEventHandler('pw:playerSpawned', function()
    characterSpawned = true
end)

RegisterNetEvent('pw_base:client:sendToCity')
AddEventHandler('pw_base:client:sendToCity', function(spawn)
    local playerPed = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerPed)
    FreezeEntityPosition(playerPed, true)
    SetEntityCoords(playerPed, tonumber(spawn.x), tonumber(spawn.y), tonumber(spawn.z), 0.0, 0.0, 0.0, false)
    SetEntityHeading(playerPed, tonumber(spawn.h))
    local interiorId = GetInteriorAtCoords(tonumber(spawn.x), tonumber(spawn.y), tonumber(spawn.z))
    
    if interiorId ~= 0 then
        LoadInterior(interiorId)
        Citizen.Wait(10) -- for the slow pc fuckers
    end

    FreezeEntityPosition(playerPed, false)
    
    TriggerServerEvent('pw:playerSpawned', true)
end)

Citizen.CreateThread( function()
    while true do
      Citizen.Wait(100)		
      if characterLoaded then
        local playerPed = GetPlayerPed(-1)
        local playerVeh = GetVehiclePedIsUsing(playerPed)
        
        if playerVeh ~= 0 then RemovePedHelmet(playerPed,true) end
      end
    end	
  end)

RegisterNetEvent('pw_base:admin:spawnVehicle')
AddEventHandler('pw_base:admin:spawnVehicle', function(model)
    if playerLoaded then
        local playerPed = GetPlayerPed(-1)
        local playerCoords = GetEntityCoords(playerPed)
        local playerHeading = GetEntityHeading(playerPed)
        PW.Game.SpawnOwnedVehicle(model, {x = playerCoords.x+2.0, y = playerCoords.y+2.0, z = playerCoords.z}, playerHeading, function(vehicle)
            if vehicle ~= nil and vehicle ~= 0 then
                local vehDet = PW.Game.GetVehicleProperties(vehicle)
                PW.TriggerServerCallback('pw_vehicleshop:server:registerPotentialVin', function(vin)
                    TriggerServerEvent('pw_keys:issueKey', 'Vehicle', vin, false, false, false)
                    TaskEnterVehicle(playerPed, vehicle, -1, -1, 1.5, 1, 0)
                end, vehDet, vehicle)
            end
        end)
    end
end)

function GetControlOfVeh(veh)
    local tNet = NetworkGetNetworkIdFromEntity(veh)
    SetNetworkIdCanMigrate(tNet, true)
    NetworkRegisterEntityAsNetworked(VehToNet(veh))
    
    local timeout = 2000
    NetworkRequestControlOfNetworkId(tNet)
    while not NetworkHasControlOfNetworkId(tNet) do
        if timeout <= 0 then
            break
        else
            timeout = timeout - 100
        end
        NetworkRequestControlOfNetworkId(tNet);
        Wait(100);
    end
    SetEntityAsMissionEntity(NetworkGetEntityFromNetworkId(tNet), true, true)
    return tNet
end

RegisterNetEvent('pw_base:admin:deleteVehicle')
AddEventHandler('pw_base:admin:deleteVehicle', function()
    local playerPed = GetPlayerPed(-1)
    local deleted = false
    local tNet
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        tNet = GetControlOfVeh(vehicle)
        DeleteVehicle(NetworkGetEntityFromNetworkId(tNet))
        deleted = true
    else
        local vehicle, distance, info = PW.Game.GetClosestVehicle()
        if distance < 5.0 then
            tNet = GetControlOfVeh(vehicle)
            DeleteVehicle(NetworkGetEntityFromNetworkId(tNet))
            deleted = true
        end
    end

    if deleted then
        exports['pw_notify']:SendAlert("success", "Vehicle has been deleted successfully.", 5000)
    else
        exports['pw_notify']:SendAlert("error", "Vehicle can not be deleted.", 5000)
    end
end)

RegisterNetEvent('pw_base:client:characterCreation')
AddEventHandler('pw_base:client:characterCreation', function(sex, steam)
    local playerPed = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerPed)
    TriggerEvent('pw_instance:create', 'charCreator', {owner = steam})
    TriggerEvent('pw_base:client:startCreationCharacter', sex)
end)

RegisterNetEvent('pw_base:doSpawnCameras')
AddEventHandler('pw_base:doSpawnCameras', function(destroy)
    if destroy then
        DoScreenFadeOut(2000)
        Citizen.Wait(2501)
    end
    RenderScriptCams(false, false, 500, true, true)
    DestroyAllCams( false )
    Citizen.Wait(1500)
    DoScreenFadeIn(1001)
    Citizen.Wait(1500)
    TriggerEvent('pw:playerSpawned')
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(data)
    playerData = data
    playerLoaded = true
    if playerData.permission == "Admin" or playerData.permission == "Owner" or playerData.permission == "Developer" then
        TriggerEvent('pw_base:openAdminMenu')
    end
end)

RegisterNetEvent('pw_base:teleportFromMenu')
AddEventHandler('pw_base:teleportFromMenu', function(data)
    local playerPed = GetPlayerPed(-1)
    SetEntityCoords(playerPed, tonumber(data.x), tonumber(data.y), tonumber(data.z))
    SetEntityHeading(playerPed, tonumber(data.h))
end)

RegisterNetEvent('pw_base:admin:testParticleFX')
AddEventHandler('pw_base:admin:testParticleFX', function(args)

    local dict = args[1]
    local name = args[2]
    local loop = tostring(args[3])
    
    if dict == nil or name == nil then
        Citizen.Trace('[Particles] Invalid arguments.')
        TriggerEvent('chatMessage', '', {255,255,255}, '[Particles] ^8Error: ^1Invalid arguments.')
    else
        RequestNamedPtfxAsset(dict)
        while not HasNamedPtfxAssetLoaded(dict) do
            Citizen.Wait(0)
        end
        Citizen.Trace("[Particles] Dict loaded.")
        TriggerEvent('chatMessage', '', {255,255,255}, '[Particles] ^8Dict loaded.')
        
        UseParticleFxAsset(dict)
        
        local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, 0.5)
        
        if loop == "true" or loop == "1" then
            Citizen.Trace("[Particles] Starting looped particle effect")
            TriggerEvent('chatMessage', '', {255,255,255}, '[Particles] ^8Starting ^*looped^r^8 particle effect.')
            local particle = StartParticleFxLoopedAtCoord(name, coords, 1.0, 1.0, 1.0, 1.0, false, false)
            
            Citizen.Wait(5000) -- wait 5 seconds before stopping the particle effect.
            
            StopParticleFxLooped(particle)
            Citizen.Trace("[Particles] Stopping looped particle effect")
            TriggerEvent('chatMessage', '', {255,255,255}, '[Particles] ^8Stopping ^*looped ^r^8particle effect.')
        else
            Citizen.Trace("[Particles] Starting non-looped particle effect")
            TriggerEvent('chatMessage', '', {255,255,255}, '[Particles] ^8Starting ^*non-looped^r^8 particle effect.')
            local particle = StartParticleFxNonLoopedAtCoord(name, coords, 1.0, 1.0, 1.0, 1.0, false, false)
        end
    end

end)

function openAdminMenu()
    PW.TriggerServerCallback('pw_base:getAllOnlineForMenu', function(players, disconnects)
        PW.TriggerServerCallback('pw_base:getDefaultSpawns', function(locations)
            local curPlayers = {}
            local recentDcs = {}
            local loca = {}
            for i = 1, #players do
                table.insert(curPlayers, { ['label'] = "["..players[i].source.."] "..players[i].name, ['action'] = "", ['triggertype'] = "", ['color'] = "danger" })
            end
            for i = 1, #disconnects do
                table.insert(recentDcs, { ['label'] = "["..disconnects[i].source.."] ["..disconnects[i].name.."] "..disconnects[i].reason, ['action'] = "", ['triggertype'] = "", ['color'] = "danger" })
            end
            for k, v in pairs(locations) do
                table.insert(loca, { ['label'] = v.name, ['action'] = "pw_base:teleportFromMenu", ['triggertype'] = "client", ['value'] = v.coords })
            end

            local menu = {
                { ['label'] = "Online Players", ['action'] = "testAction", ['triggertype'] = "triggerType", ['color'] = "primary", ['subMenu'] = curPlayers },
                { ['label'] = "Recent Disconnects", ['action'] = "testAction", ['triggertype'] = "triggerType", ['color'] = "warning", ['subMenu'] = recentDcs },
                { ['label'] = "Toggle Job Duty", ['action'] = "pw_base:toggleAdminDuty", ['triggertype'] = "server", ['color'] = "info" },
                { ['label'] = "Spawn Vehicle", ['action'] = "pw_base:client:openSpawnVehForm", ['triggertype'] = "client", ['color'] = "info" },
                { ['label'] = "Teleport To", ['action'] = "testAction", ['triggertype'] = "client", ['color'] = "danger", ['subMenu'] = loca },
                { ['label'] = "Switch Character", ['action'] = "pw_base:switchCharacter", ['triggertype'] = "client", ['color'] = "success" },
                { ['label'] = "Take Screenshot", ['action'] = "pw_base:takeScreenshot", ['triggertype'] = "client", ['color'] = "info"},
            }
            TriggerEvent('pw_interact:generateMenu', menu, "PixelWorld Admin Menu")
        end)
    end)
end

RegisterNetEvent('pw_base:openAdminMenu')
AddEventHandler('pw_base:openAdminMenu', function()
    Citizen.CreateThread(function()
        while playerLoaded do
            if IsControlJustPressed(0, 57) then
                openAdminMenu()
            end
            Citizen.Wait(10)
        end
    end)
end)

RegisterNetEvent('pw_base:switchCharacter')
AddEventHandler('pw_base:switchCharacter', function()
    DisplayRadar(false)
    closePersistentNotifications()
    DoScreenFadeOut(1000)
    Citizen.Wait(1050)
    skyCam()
    characterSpawned = false
    SetEntityCoords(PlayerPedId(), 9.45, 10.16, -153.70, 0.0, 0.0, 0.0, true)
    SetEntityHeading(PlayerPedId(), 91.00)
    TriggerServerEvent('pw_base:switchCharacter')
    DoScreenFadeIn(1000)
    Citizen.Wait(1500)
end)

exports('hasCharacterSpawned', function()
    return characterSpawned
end)

RegisterNetEvent('pw:teleport')
AddEventHandler('pw:teleport', function(coords)
    local success = false
	Citizen.CreateThread(function()
		if coords.x ~= false then
			local xPos = tonumber(x)
			local yPos = tonumber(y)
			local zPos = tonumber(z)
			PW.Game.Teleport(coords.x,coords.y,coords.z)
		else
			local entity = PlayerPedId()
			
			if IsPedInAnyVehicle(entity, false) then
				entity = GetVehiclePedIsUsing(entity)
			end

			local blipFound = false
			local blipIterator = GetBlipInfoIdIterator()
			local blip = GetFirstBlipInfoId(8)

			while DoesBlipExist(blip) do
				if GetBlipInfoIdType(blip) == 4 then
					cx, cy, cz = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ReturnResultAnyway(), Citizen.ResultAsVector())) --GetBlipInfoIdCoord(blip)
                    blipFound = true
                    success = true
					break
				end
				blip = GetNextBlipInfoId(blipIterator)
			end

			if blipFound then
				local groundFound = false
				local yaw = GetEntityHeading(entity)
				
				for i = 0, 1000, 1 do
					SetEntityCoordsNoOffset(entity, cx, cy, ToFloat(i), false, false, false)
					SetEntityRotation(entity, 0, 0, 0, 0 ,0)
					SetEntityHeading(entity, yaw)
					SetGameplayCamRelativeHeading(0)
					Citizen.Wait(0)
					--groundFound = true
					if GetGroundZFor_3dCoord(cx, cy, ToFloat(i), cz, false) then --GetGroundZFor3dCoord(cx, cy, i, 0, 0) GetGroundZFor_3dCoord(cx, cy, i)
						cz = ToFloat(i)
						groundFound = true
						break
					end
				end
				if not groundFound then
					cz = -300.0
				end
				success = true
			else
				exports['pw_notify']:SendAlert('error', 'No Coordinates Specified and no WayPoint located.')
			end

			if success then
				SetEntityCoordsNoOffset(entity, cx, cy, cz, false, false, true)
				SetGameplayCamRelativeHeading(0)
				if IsPedSittingInAnyVehicle(PlayerPedId()) then
					if GetPedInVehicleSeat(GetVehiclePedIsUsing(PlayerPedId()), -1) == PlayerPedId() then
						SetVehicleOnGroundProperly(GetVehiclePedIsUsing(PlayerPedId()))
					end
				end
				blipFound = false
                exports['pw_notify']:SendAlert('success', 'Moved successfully')
                TriggerEvent('pw:playerTeleported')
                TriggerServerEvent('pw:playerTeleported')
			end
		
		end
	end)
end)

local nbrDisplaying = 1

RegisterNetEvent('pw:playerTeleported')
AddEventHandler('pw:playerTeleported', function()
    TriggerEvent('pw_drawtext:hideNotification')
    TriggerServerEvent('pw_items:server:showUsable', false  )
end)

RegisterNetEvent('pw_base:startMeText')
AddEventHandler('pw_base:startMeText', function(args)
	local text = ''
	for i = 1, #args do
		text = text..' '..args[i]
	end
	TriggerServerEvent('pw_base:startMeText', text)
end)

RegisterNetEvent('pw_base:broadcastMeText')
AddEventHandler('pw_base:broadcastMeText', function(text, source)
	local offset = 1 + (nbrDisplaying*0.14)
	Display(GetPlayerFromServerId(source), text, offset)
end)

function Display(mePlayer, text, offset)
	local displaying = true
	local displayTime = 7000

    Citizen.CreateThread(function()
        Wait(displayTime)
        displaying = false
	end)
	
    Citizen.CreateThread(function()
        nbrDisplaying = nbrDisplaying + 1
        while displaying do
            Wait(0)
            local coordsMe = GetEntityCoords(GetPlayerPed(mePlayer), false)
            local coords = GetEntityCoords(PlayerPedId(), false)
            local dist = Vdist2(coordsMe, coords)
            if dist < 2500 then
                if HasEntityClearLosToEntity(PlayerPedId(), GetPlayerPed(mePlayer), 17 ) then
                    PW.Game.DrawText3D(coordsMe['x'], coordsMe['y'], coordsMe['z'], text)
                end
            end
        end
        nbrDisplaying = nbrDisplaying - 1
    end)
end