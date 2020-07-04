PW = nil

TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)

AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() then
        repeat Wait(0) until exports['pw_base']:checkScriptStart() == true
    end
end)

PW.RegisterServerCallback('pw_blips:server:getBlips', function(source, cb)
    local _src = source
    local cid = exports.pw_base:Source(_src):Character().getCID()
    MySQL.Async.fetchScalar("SELECT `blips` FROM `characters` WHERE `cid` = @cid", { ['@cid'] = cid }, function(blips)
        if blips then
            local sendBlips = json.decode(blips)
            cb(sendBlips)
        end
    end)
end)

RegisterServerEvent('pw_blips:server:saveBlip')
AddEventHandler('pw_blips:server:saveBlip', function(newTable)
    local _src = source
    local cid = exports.pw_base:Source(_src):Character().getCID()
    local blips = json.encode(newTable)
    local processed = false
    MySQL.Async.execute("UPDATE `characters` SET `blips` = @info WHERE `cid` = @cid", { ['@info'] = blips, ['@cid'] = cid }, function()
        
    end)
end)

exports.pw_chat:AddChatCommand('blips', function(source, args, rawCommand)
    local _src = source
    
    TriggerClientEvent('pw_blips:client:mainMenu', _src)
end, {
    help = "Open self blips menu",
    params = {}
}, -1)