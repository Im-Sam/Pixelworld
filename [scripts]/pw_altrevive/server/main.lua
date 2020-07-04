PW = nil

TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)

RegisterServerEvent('pw_altrevive:server:payment')
AddEventHandler('pw_altrevive:server:payment', function()

    local _src = source
    local _char = exports.pw_base:Source(_src)
    
    local _balance = _char:Cash().Remove(Config.ReviveCost)
end)


