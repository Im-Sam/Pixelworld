PW = nil

TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)

RegisterServerEvent('pw_realestate:server:propertySettings')
AddEventHandler('pw_realestate:server:propertySettings', function(src, house)
    TriggerClientEvent('pw_realestate:client:propertySettings', src, house)
end)

RegisterServerEvent('pw_realestate:server:processSale')
AddEventHandler('pw_realestate:server:processSale', function(src, data)
    if data.property.method == 'rent' then
        TriggerClientEvent('pw_realestate:client:reviewRent', src, data)
    else
        TriggerClientEvent('pw_realestate:client:reviewSell', src, data)
    end
end)

RegisterServerEvent('pw_realestate:server:sendSellContract')
AddEventHandler('pw_realestate:server:sendSellContract', function(data)
    TriggerClientEvent('pw_realestate:client:getSellContract', data.info.data.buyer.source, data.info.data)
end)

RegisterServerEvent('pw_realestate:server:sendRentContract')
AddEventHandler('pw_realestate:server:sendRentContract', function(data)
    TriggerClientEvent('pw_realestate:client:getRentContract', data.info.data.buyer.source, data.info.data)
end)