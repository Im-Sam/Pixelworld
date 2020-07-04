PW = nil

TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)

PW.RegisterServerCallback('pw_clothing:server:checkMoney', function(source, cb)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    cb(_char:Cash().getCash())
end)

RegisterServerEvent('pw_clothing:client:processPayment')
AddEventHandler('pw_clothing:client:processPayment', function()
    local _src = source
    _char = exports['pw_base']:Source(_src)
    _char:Cash().Remove(Config.requiredCash)
end)