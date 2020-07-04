PW = nil

TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)


RegisterServerEvent('pw_needs:updateCharacterNeeds')
AddEventHandler('pw_needs:updateCharacterNeeds', function(needs)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    _char:Character().updateNeeds(needs)
end)

RegisterServerEvent('pw_base:itemUsed')
AddEventHandler('pw_base:itemUsed', function(_src, data)
    if data.item == "joint" then
        TriggerClientEvent('pw_needs:usedJoint', _src)
        local _char = exports.pw_base:Source(_src)
        _char:Inventories():Remove().Item(data, 1)
    end
end)

exports.pw_chat:AddAdminChatCommand('resetstats', function(source, args, rawCommand)
    local _src = source
    if args[1] ~= nil then
        if exports['pw_base']:checkSource(tonumber(args[1])) then
            TriggerClientEvent('pw_needs:client:resetStats', tonumber(args[1]))
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "The requested Player ID is not online", length = 5000})
        end
    else
        TriggerClientEvent('pw_needs:client:resetStats', _src)
    end
end, {
    help = "Reset Basic Needs",
    params = {
    {
        name = "PlayerID",
        help = "This is optional, if left blank it will reset your own."
    },
}
}, -1)