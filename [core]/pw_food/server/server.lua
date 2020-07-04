PW = nil

TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)

RegisterServerEvent('pw_base:itemUsed')
AddEventHandler('pw_base:itemUsed', function(_src, data)
    local _char = exports['pw_base']:Source(_src)
    local needsBoost = nil
    if data.details.item_needsboost ~= nil then
        needsBoost = json.decode(data.details.item_needsboost)
    end
    if needsBoost ~= nil and type(needsBoost) == "table" then
        if needsBoost.hunger ~= nil or needsBoost.thirst ~= nil then
            TriggerClientEvent('pw_discord:client:overRide', _src, "Consuming "..data.details.item_label)
            for k, v in pairs(needsBoost) do
                local action = false
                if v ~= 0 then
                    if v == 0 then
                        action = false
                    elseif v < 0 then 
                        action = "remove"
                    elseif v > 0 then
                        action = "add"
                    end
                    if action ~= false then
                        TriggerClientEvent('pw_needs:client:updateNeeds', _src, k, action, v)
                        _char:Inventories():Remove().Item(data, 1)
                    end
                end
            end
        end
    end
end)
