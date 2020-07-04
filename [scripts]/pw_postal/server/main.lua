PW = nil

TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)

RegisterServerEvent('pw_postal:server:toggleDuty')
AddEventHandler('pw_postal:server:toggleDuty', function()
    local _src = source
    local _char = exports.pw_base:Source(_src)
    
    _char:Job().toggleDuty()
end)

RegisterServerEvent('pw_postal:server:finishdelivery')
AddEventHandler('pw_postal:server:finishdelivery', function(distancetravelled)

    local _src = source
    local _char = exports.pw_base:Source(_src)
    local travelPrice = 1
    local pay = math.random(Config.BaseDeliveryPay.min, Config.BaseDeliveryPay.max)      

    local _balance = _char:Cash().Add(pay)
    TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = 'This Delivery Earnt You $' .. math.ceil(pay) .. ' in Cash!', length = 10000})
end)

