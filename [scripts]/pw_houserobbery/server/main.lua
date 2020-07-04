PW = nil

TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)

PW.RegisterServerCallback('pw_houserobbery:server:requestProperties', function(source, cb)
    cb(Config.OutLocations)
end)

RegisterServerEvent('pw_base:itemUsed')
AddEventHandler('pw_base:itemUsed', function(_src, data)
    if data.item == "screwdriver" then
        TriggerClientEvent('pw_houserobbery:client:useScrewdriver', _src, data)
    end
end)

RegisterServerEvent('pw_houserobbery:server:awardPlayer')
AddEventHandler('pw_houserobbery:server:awardPlayer', function(item, award)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    if item.item == "cash" then
        _char:Cash().Add(award)
    else
        _char:Inventories():AddItem():Player().Single(item.item, award, {['public'] = {}, ['private'] = {} })
    end
end)


RegisterServerEvent('pw_houserobbery:server:updateProperty')
AddEventHandler('pw_houserobbery:server:updateProperty', function(pro, req, toggle)
    if Config.OutLocations[tonumber(pro)] then
        if req == "canrob" and toggle == "startTimer" then
            SetTimeout(tonumber(Config.PropertyCooldown), function()
                Config.OutLocations[tonumber(pro)][req] = true
                TriggerClientEvent('pw_houserobbery:client:sendOutProperties', -1, Config.OutLocations)
            end)
        else
            Config.OutLocations[tonumber(pro)][req] = toggle
            TriggerClientEvent('pw_houserobbery:client:sendOutProperties', -1, Config.OutLocations)
        end
    end
end)

PW.RegisterServerCallback('pw_houserobbery:server:selectProperty', function(source, cb, pro)
    if Config.Properties[tonumber(pro)] then
        cb(Config.Properties[tonumber(pro)])
    end
end)

RegisterServerEvent('pw_houserobbery:server:updateRobHouse')
AddEventHandler('pw_houserobbery:server:updateRobHouse', function(pro, req, toggle)
    if Config.Properties[tonumber(pro)] then
        Config.Properties[tonumber(pro)][req] = toggle
    end
end)

PW.RegisterServerCallback('pw_houserobbery:server:checkAvalProperty', function(source, cb)
    local found = false
    local tbl = {}
    for k, v in pairs (Config.Properties) do
        if not v.inuse and v.useby == 0 then
            table.insert(tbl, k)
        end
    end

    if tbl[1] ~= nil then
        local randomProp = math.random(#tbl)
        cb(tbl[randomProp])
        found = true
    end

    if not found then
        cb(false)
    end
end)

RegisterServerEvent('pw_houserobbery:server:sendOutProperties')
AddEventHandler('pw_houserobbery:server:sendOutProperties', function()
    TriggerClientEvent('pw_houserobbery:client:sendOutProperties', -1, Config.OutLocations)
end)