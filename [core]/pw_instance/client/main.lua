local instance, instancedPlayers, registeredInstanceTypes, playersToHide = {}, {}, {}, {}
local instanceInvite, insideInstance
PW = nil

Citizen.CreateThread(function()
	while PW == nil do
		TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)
		Citizen.Wait(0)
	end
end)

function GetInstance()
	return instance
end

function CreateInstance(type, data)
	
	TriggerServerEvent('pw_instance:create', type, data)
end

function CloseInstance()
	instance = {}
	TriggerServerEvent('pw_instance:close')
	insideInstance = false
end

function EnterInstance(instance)
	insideInstance = true
	TriggerServerEvent('pw_instance:enter', instance.host)

	if registeredInstanceTypes[instance.type].enter then
		registeredInstanceTypes[instance.type].enter(instance)
	end
end

function LeaveInstance()
	if instance.host then
		if #instance.players > 1 then

		end

		if registeredInstanceTypes[instance.type].exit then
			registeredInstanceTypes[instance.type].exit(instance)
		end

		TriggerServerEvent('pw_instance:leave', instance.host)
	end
	insideInstance = false
end

function InviteToInstance(type, player, data)
	TriggerServerEvent('pw_instance:invite', instance.host, type, player, data)
end

function RegisterInstanceType(type, enter, exit)
	registeredInstanceTypes[type] = {
		enter = enter,
		exit  = exit
	}
end

AddEventHandler('pw_instance:get', function(cb)
	cb(GetInstance())
end)

AddEventHandler('pw_instance:create', function(type, data)
	CreateInstance(type, data)
end)

AddEventHandler('pw_instance:close', function()
	CloseInstance()
end)

AddEventHandler('pw_instance:enter', function(_instance)
	EnterInstance(_instance)
end)

AddEventHandler('pw_instance:leave', function()
	LeaveInstance()
end)

AddEventHandler('pw_instance:invite', function(type, player, data)
	InviteToInstance(type, player, data)
end)

AddEventHandler('pw_instance:registerType', function(name, enter, exit)
	RegisterInstanceType(name, enter, exit)
end)

RegisterNetEvent('pw_instance:onInstancedPlayersData')
AddEventHandler('pw_instance:onInstancedPlayersData', function(_instancedPlayers)
	instancedPlayers = _instancedPlayers
end)

RegisterNetEvent('pw_instance:onCreate')
AddEventHandler('pw_instance:onCreate', function(_instance)
	instance = {}
end)

RegisterNetEvent('pw_instance:onEnter')
AddEventHandler('pw_instance:onEnter', function(_instance)
	instance = _instance
end)

RegisterNetEvent('pw_instance:onLeave')
AddEventHandler('pw_instance:onLeave', function(_instance)
	instance = {}
end)

RegisterNetEvent('pw_instance:onClose')
AddEventHandler('pw_instance:onClose', function(_instance)
	instance = {}
end)

RegisterNetEvent('pw_instance:onPlayerEntered')
AddEventHandler('pw_instance:onPlayerEntered', function(_instance, player)
	instance = _instance
	local playerName = GetPlayerName(GetPlayerFromServerId(player))
end)

RegisterNetEvent('pw_instance:onPlayerLeft')
AddEventHandler('pw_instance:onPlayerLeft', function(_instance, player)
	instance = _instance
	local playerName = GetPlayerName(GetPlayerFromServerId(player))
end)

RegisterNetEvent('pw_instance:onInvite')
AddEventHandler('pw_instance:onInvite', function(_instance, type, data)
	instanceInvite = {
		type = type,
		host = _instance,
		data = data
	}

	Citizen.CreateThread(function()
		Citizen.Wait(10000)

		if instanceInvite then
			instanceInvite = nil
		end
	end)
end)

RegisterInstanceType('default')

-- Controls for invite
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if instanceInvite then
			if IsControlJustReleased(0, 38) then
				EnterInstance(instanceInvite)
				instanceInvite = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)

-- Instance players
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		playersToHide = {}

		if instance.host then
			-- Get players and sets them as pairs
			for k,v in ipairs(GetActivePlayers()) do
				playersToHide[GetPlayerServerId(v)] = true
			end

			-- Dont set our instanced players invisible
			for _,player in ipairs(instance.players) do
				playersToHide[player] = nil
			end
		else
			for player,_ in pairs(instancedPlayers) do
				playersToHide[player] = true
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local playerPed = PlayerPedId()
		-- Hide all these players
		for serverId,_ in pairs(playersToHide) do
			local player = GetPlayerFromServerId(serverId)

			if NetworkIsPlayerActive(player) then
				local otherPlayerPed = GetPlayerPed(player)
				SetEntityVisible(otherPlayerPed, false, false)
				SetEntityNoCollisionEntity(playerPed, otherPlayerPed, false)
			end
		end
	end
end)

Citizen.CreateThread(function()
	TriggerEvent('pw_instance:loaded')
end)

-- Fix vehicles randomly spawning nearby the player inside an instance
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0) -- must be run every frame

		if insideInstance then
			SetVehicleDensityMultiplierThisFrame(0.0)
			SetParkedVehicleDensityMultiplierThisFrame(0.0)

			local pos = GetEntityCoords(PlayerPedId())
			RemoveVehiclesFromGeneratorsInArea(pos.x - 900.0, pos.y - 900.0, pos.z - 900.0, pos.x + 900.0, pos.y + 900.0, pos.z + 900.0)
		else
			Citizen.Wait(500)
		end
	end
end)