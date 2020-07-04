PW = nil
characterLoaded, playerData = false, nil
GLOBAL_PED, GLOBAL_COORDS = nil, nil
loadedVehicles = {}
managingFuel = false
isNearPump = false
isFueling = false

function manageFuel(vehicle)
    Citizen.CreateThread(function()
        while manageFuel do
            if GLOBAL_PED and IsPedInAnyVehicle(GLOBAL_PED, false) and vehicle then
                if GetIsVehicleEngineRunning(vehicle) and DecorGetInt(vehicle, "pw_vehicles_fuelType") == 2 then
					local currentFuel = DecorGetFloat(vehicle, "pw_vehicles_fuelLevel")
					local newLevel = (currentFuel - Config.FuelUsage[Round(GetVehicleCurrentRpm(vehicle), 1)] * (Config.Classes[GetVehicleClass(vehicle)] or 1.0) / 10)
					DecorSetFloat(vehicle, "pw_vehicles_fuelLevel", newLevel)
					SetVehicleFuelLevel(vehicle, newLevel)
                    TriggerServerEvent('pw_fuel:server:updateFuelLevel', PW.Game.GetVehicleProperties(vehicle).plate, newLevel)
					--print(DecorGetFloat(vehicle, "pw_vehicles_fuelLevel"))
				end
            end
            Citizen.Wait(1000)
        end    
    end)
end

function getNearestPump(ped)
    local closest = 1000
    local closestCoords

    for k,v in pairs(Config.GasStations) do
        local dstcheck = #(GetEntityCoords(ped) - v)

        if dstcheck < closest then
            closest = dstcheck
            closestCoords = v
        end
    end

    return closestCoords
end

function FindNearestFuelPump(target)
	local coords
	if target then
		coords = GetEntityCoords(target)
	else
		coords = GLOBAL_COORDS
	end
	local fuelPumps = {}
	local handle, object = FindFirstObject()
	local success

	repeat
		if Config.PumpModels[GetEntityModel(object)] then
			table.insert(fuelPumps, object)
		end

		success, object = FindNextObject(handle, object)
	until not success

	EndFindObject(handle)

	local pumpObject = 0
	local pumpDistance = 1000

	for k,v in pairs(fuelPumps) do
		local dstcheck = GetDistanceBetweenCoords(coords, GetEntityCoords(v))

		if dstcheck < pumpDistance then
			pumpDistance = dstcheck
			pumpObject = v
		end
	end

	return pumpObject, pumpDistance
end

exports('findNearPump', function(target)
	return FindNearestFuelPump(target)
end)

function CreateBlip(coords)
	local blip = AddBlipForCoord(coords)

	SetBlipSprite(blip, 361)
	SetBlipScale(blip, 0.9)
	SetBlipColour(blip, 1)
	SetBlipDisplay(blip, 4)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Fuel Station")
	EndTextCommandSetBlipName(blip)

	return blip
end

function LoadAnimDict(dict)
	if not HasAnimDictLoaded(dict) then
		RequestAnimDict(dict)

		while not HasAnimDictLoaded(dict) do
			Citizen.Wait(1)
		end
	end
end