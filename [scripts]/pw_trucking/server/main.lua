PW = nil
TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)

RegisterServerEvent('pw_haulage:server:toggleDuty')
AddEventHandler('pw_haulage:server:toggleDuty', function()
    local _src = source
    local _char = exports.pw_base:Source(_src)
    _char:Job().toggleDuty()
end)

RegisterServerEvent('pw_haulage:server:finishdelivery')
AddEventHandler('pw_haulage:server:finishdelivery', function(type)
    local _src = source
    local _char = exports.pw_base:Source(_src)
    if type == 'regular' then
        local pay = math.random(Config.RegularDeliveryPay.min, Config.RegularDeliveryPay.max)      
        local _balance = _char:Cash().Add(pay)
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "info", text = 'This Delivery Earnt You $' .. math.ceil(pay) .. ' in Cash!', length = 10000})
    elseif type == 'special' then
        local pay = math.random(Config.RegularDeliveryPay.min, Config.RegularDeliveryPay.max)      
        local _balance = _char:Cash().Add(pay)
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "info", text = 'This Specialist Delivery Earnt You $' .. math.ceil(pay) .. ' in Cash!', length = 10000})
    elseif type == 'fuel' then
        local pay = math.random(Config.FuelDeliveryPay.min, Config.FuelDeliveryPay.max)      
        local _balance = _char:Cash().Add(pay)
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "info", text = 'The Fuel Delivery Run Earnt You $' .. math.ceil(pay) .. ' in Cash!', length = 10000})  
    end       
end)

