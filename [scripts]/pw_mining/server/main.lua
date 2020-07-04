PW = nil
TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)


RegisterServerEvent('pw_mining:server:toggleDuty')
AddEventHandler('pw_mining:server:toggleDuty', function()
    local _src = source
    local _char = exports.pw_base:Source(_src)
    _char:Job().toggleDuty()
end)

RegisterServerEvent('pw_mining:server:addRock')
AddEventHandler('pw_mining:server:addRock', function(type)
    local _src = source 
    local _char = exports.pw_base:Source(_src)

    if type == 'coal' then
        local amount = math.random(1, 5)
        _char:Inventories():AddItem():Player().Single('coal_ore', amount) 
    elseif type == 'copper' then
        local amount = math.random(1, 3)
        _char:Inventories():AddItem():Player().Single('copper_ore', amount)   
    elseif type == 'iron' then
        _char:Inventories():AddItem():Player().Single('iron_ore', 1)     
    end             
end)

RegisterServerEvent('pw_mining:server:processRock')
AddEventHandler('pw_mining:server:processRock', function(data)
    local indexid = data.processid
    local ore_item = Config.RockProcessing[indexid].item
    local ore_label = Config.RockProcessing[indexid].label
    local processed = Config.RockProcessing[indexid].recieve_item
    local _src = source 
    local _char = exports.pw_base:Source(_src)
    local oreAmount = _char:Inventories().getItemCount(ore_item)
    if oreAmount ~= 0 then -- should never even be 0 anyway (it is checked on the client)
        _char:Inventories():Remove().byName(ore_item, oreAmount)
        Citizen.Wait(1000)
        _char:Inventories():AddItem():Player().Single(processed, oreAmount)
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = "You Have Processed Your " .. ore_label, length = 5000})
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You Have 0!", length = 5000})     
    end       
end)

RegisterServerEvent('pw_mining:server:smeltItem')
AddEventHandler('pw_mining:server:smeltItem', function(data)
    local _src = source 
    local _char = exports.pw_base:Source(_src)
    local indexid = data.smeltid
    local item = Config.RockSmelting[indexid].item
    local item_label = Config.RockSmelting[indexid].label
    local smelted_item = Config.RockSmelting[indexid].smelted_item
    local itemAmount = _char:Inventories().getItemCount(item)
    if itemAmount ~= 0 then -- should never even be 0 anyway (it is checked on the client)
        _char:Inventories():Remove().byName(item, itemAmount)
        Citizen.Wait(1000)
        _char:Inventories():AddItem():Player().Single(smelted_item, itemAmount)
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = "You Have Smelted Your " .. item_label, length = 7000})
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You Don't Have anything to smelt!", length = 5000})     
    end       
end)


RegisterServerEvent('pw_mining:server:inspectRock')
AddEventHandler('pw_mining:server:inspectRock', function(data)
    local _src = source 
    local _char = exports.pw_base:Source(_src)
    local indexid = data.inspectid
    local processed_item = Config.RockInspection[indexid].item
    local processed_label = Config.RockInspection[indexid].label
    local min_price = Config.RockInspection[indexid].price_min
    local max_price = Config.RockInspection[indexid].price_max
    local final_price = math.random(min_price, max_price)
    local itemAmount = _char:Inventories().getItemCount(processed_item)
    if itemAmount ~= 0 then -- should never even be 0 anyway (it is checked on the client)
        _char:Inventories():Remove().byName(processed_item, itemAmount)
        local cash = (final_price * itemAmount)
        local _balance = _char:Cash().Add(cash)
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = "You had your " .. processed_label .. " inspected, They were happy with what you produced and you were paid $".. cash, length = 8000})
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You Have None to Sell!", length = 5000})     
    end       
end)