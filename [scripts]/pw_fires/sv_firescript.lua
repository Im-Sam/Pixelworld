RegisterServerEvent("FireScript:FirePutOut")
AddEventHandler("FireScript:FirePutOut", function(x, y, z)
	TriggerClientEvent('FireScript:StopFireAtPosition', -1, x, y, z)
end)

exports['pw_chat']:AddAdminChatCommand('startfire', function(source, args, rawCommand)
	local _src = source
	if args[1] ~= nil and args[2] ~= nil then
		TriggerClientEvent('FireScript:StartFireAtPlayer', -1, _src, tonumber(args[1]), tonumber(args[2]), args[3] == "true")
	end
end, {
	help = "Start a Fire",
	params = {{ name = "NUMFLAMES", help = "Determines the maximum number of flames the fire will have (Max 100)"}, { name = "RADIUS ", help = "Specifies the radius of the fire in metres (maximum 30)"} }
}, -1)

exports['pw_chat']:AddAdminChatCommand('stopfire', function(source, args, rawCommand)
	local _src = source
	TriggerClientEvent('FireScript:StopFiresAtPlayer', -1, _src)
end, {
	help = "Stops all fires within a 35 metre radius of your players location",
}, -1)

exports['pw_chat']:AddAdminChatCommand('stopallfires', function(source, args, rawCommand)
	local _src = source
	TriggerClientEvent('FireScript:StopAllFires', -1)
end, {
	help = "Stop all fires on the map",
}, -1)

exports['pw_chat']:AddAdminChatCommand('startsmoke', function(source, args, rawCommand)
	local _src = source
	if args[1] ~= nil then
		TriggerClientEvent('FireScript:StartSmokeAtPlayer', -1, _src, tonumber(args[1]))
	end
end, {
	help = "You're also able to create 'smoke without fire' e.g. for a call where someone gets concerned for fire over barbecue smoke.",
	params = {{ name = "SCALE", help = "The magnitude of the Smoke between 0.5 and 5.0"}}
}, -1)

exports['pw_chat']:AddAdminChatCommand('stopsmoke', function(source, args, rawCommand)
	local _src = source
	TriggerClientEvent('FireScript:StopSmokeAtPlayer', -1, _src)
end, {
	help = "Stops all smoke without fire within a 35 metre radius of your player.",
}, -1)

exports['pw_chat']:AddAdminChatCommand('stopallsmoke', function(source, args, rawCommand)
	local _src = source
	TriggerClientEvent('FireScript:StopAllSmoke', -1)
end, {
	help = "Stops all smoke without fire on the map.",
}, -1)