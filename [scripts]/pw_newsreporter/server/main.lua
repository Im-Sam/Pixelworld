PW = nil
TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)


RegisterServerEvent('pw_newsreporter:server:toggleDuty')
AddEventHandler('pw_newsreporter:server:toggleDuty', function()
    local _src = source
    local _char = exports.pw_base:Source(_src)
    _char:Job().toggleDuty()
end)

exports.pw_chat:AddChatCommand('newscam', function(source, args, rawCommand)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    if _char:Job().getJob().job == 'newsreporter' and _char:Job().getDuty() then
        TriggerClientEvent("pw_newsreporter:client:ToggleCam", _src)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You are Not On Duty As a News Reporter!", length = 5000}) 
    end       
end, {
    help = "Use the News Camera (Must be a News Reporter and On Duty)",
    params = {}
}, -1)

exports.pw_chat:AddChatCommand('newsmic', function(source, args, rawCommand)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    if _char:Job().getJob().job == 'newsreporter' and _char:Job().getDuty() then
        TriggerClientEvent("pw_newsreporter:client:ToggleMic", _src)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You are Not On Duty As a News Reporter!", length = 5000}) 
    end       
end, {
    help = "Use the News Microphone (Must be a News Reporter and On Duty)",
    params = {}
}, -1)

exports.pw_chat:AddChatCommand('newsboommic', function(source, args, rawCommand)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    if _char:Job().getJob().job == 'newsreporter' and _char:Job().getDuty() then
        TriggerClientEvent("pw_newsreporter:client:ToggleBMic", _src)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You are Not On Duty As a News Reporter!", length = 5000}) 
    end       
end, {
    help = "Use the News Boom Microphone (Must be a News Reporter and On Duty)",
    params = {}
}, -1)