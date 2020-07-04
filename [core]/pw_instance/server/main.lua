local instances = {}

function GetInstancedPlayers()
	local players = {}

	for k,v in pairs(instances) do
		for k2,v2 in ipairs(v.players) do
			players[v2] = true
		end
	end

	return players
end

AddEventHandler('playerDropped', function(reason)
	if instances[source] then
		CloseInstance(source)
	end
end)

function CreateInstance(type, player, data)
	instances[player] = {
		type    = type,
		host    = player,
		players = {},
		data    = data
	}

	TriggerEvent('pw_instance:onCreate', instances[player])
	TriggerClientEvent('pw_instance:onCreate', player, instances[player])
	TriggerClientEvent('pw_instance:onInstancedPlayersData', -1, GetInstancedPlayers())
end

function CloseInstance(instance)
	if instances[instance] then

		for i=1, #instances[instance].players do
			TriggerClientEvent('pw_instance:onClose', instances[instance].players[i])
		end

		instances[instance] = nil

		TriggerClientEvent('pw_instance:onInstancedPlayersData', -1, GetInstancedPlayers())
		TriggerEvent('pw_instance:onClose', instance)
	end
end

function AddPlayerToInstance(instance, player)
	local found = false

	for i=1, #instances[instance].players do
		if instances[instance].players[i] == player then
			found = true
			break
		end
	end

	if not found then
		table.insert(instances[instance].players, player)
	end

	TriggerClientEvent('pw_instance:onEnter', player, instances[instance])

	for i=1, #instances[instance].players do
		if instances[instance].players[i] ~= player then
			TriggerClientEvent('pw_instance:onPlayerEntered', instances[instance].players[i], instances[instance], player)
		end
	end

	TriggerClientEvent('pw_instance:onInstancedPlayersData', -1, GetInstancedPlayers())
end

function RemovePlayerFromInstance(instance, player)
	if instances[instance] then
		TriggerClientEvent('pw_instance:onLeave', player, instances[instance])

		if instances[instance].host == player then
			for i=1, #instances[instance].players do
				if instances[instance].players[i] ~= player then
					TriggerClientEvent('pw_instance:onPlayerLeft', instances[instance].players[i], instances[instance], player)
				end
			end

			CloseInstance(instance)
		else
			for i=1, #instances[instance].players do
				if instances[instance].players[i] == player then
					instances[instance].players[i] = nil
				end
			end

			for i=1, #instances[instance].players do
				if instances[instance].players[i] ~= player then
					TriggerClientEvent('pw_instance:onPlayerLeft', instances[instance].players[i], instances[instance], player)
				end

			end

			TriggerClientEvent('pw_instance:onInstancedPlayersData', -1, GetInstancedPlayers())
		end
	end
end

function InvitePlayerToInstance(instance, type, player, data)
	TriggerClientEvent('pw_instance:onInvite', player, instance, type, data)
end

RegisterServerEvent('pw_instance:create')
AddEventHandler('pw_instance:create', function(type, data)
	CreateInstance(type, source, data)
end)

RegisterServerEvent('pw_instance:close')
AddEventHandler('pw_instance:close', function()
	CloseInstance(source)
end)

RegisterServerEvent('pw_instance:enter')
AddEventHandler('pw_instance:enter', function(instance)
	AddPlayerToInstance(instance, source)
end)

RegisterServerEvent('pw_instance:leave')
AddEventHandler('pw_instance:leave', function(instance)
	RemovePlayerFromInstance(instance, source)
end)

RegisterServerEvent('pw_instance:invite')
AddEventHandler('pw_instance:invite', function(instance, type, player, data)
	InvitePlayerToInstance(instance, type, player, data)
end)
