PW = nil
garages, privateGarages, units = {}, {}, {}
propsLoaded = false

TriggerEvent('pw:getSharedObject', function(obj)
    PW = obj
end)

RegisterServerEvent('pw_garage:server:propsLoaded')
AddEventHandler('pw_garage:server:propsLoaded', function(state)
    propsLoaded = state
end)

MySQL.ready(function ()
    repeat Wait(0) until exports.pw_properties:propertiesLoadedCheck() == true
    
    MySQL.Async.fetchAll("SELECT * from `garages`", {}, function(res)
        if res[1] ~= nil then
            for i = 1, #res do
                garages[i] = {  ['name'] = res[i].name, ['type'] = res[i].type, ['location'] = json.decode(res[i].location), 
                                ['maxSlots'] = res[i].maxslots, ['curSlots'] = res[i].curslots, ['spawnPoint'] = json.decode(res[i].spawnpoint)
                            }
            end 
        end
    end)

    MySQL.Async.fetchAll("SELECT * FROM `properties`", {}, function(res)
        if res[1] ~= nil then
            for i = 1, #res do
                local meta = json.decode(res[i].metainformation)
                privateGarages[i] = {   ['name'] = res[i].name, ['maxSlots'] = res[i].garageLimit, ['curSlots'] = res[i].garageSlots,
                                        ['spawnPoint'] = { ['x'] = meta.locations.garage.x, ['y'] = meta.locations.garage.y, ['z'] = meta.locations.garage.z, ['h'] = meta.locations.garage.h },
                                    }
            end
        end
    end)

    MySQL.Async.fetchAll("SELECT * FROM `garage_units`", {}, function(res)
        if res[1] ~= nil then
            for i = 1, #res do
                units[i] = {    ['name'] = res[i].name, ['location'] = json.decode(res[i].location), ['spawnPoint'] = json.decode(res[i].spawnPoint),
                                ['price'] = res[i].price or 10000, ['maxSlots'] = res[i].limit or 1, ['curSlots'] = res[i].slots or 0, ['owner'] = res[i].owner
                            }
            end
        end
    end)
end)

-- CRONS
function payInsurances(d, h, m)
    local vehicles = exports.pw_vehicleshop:getVehicles()
    if vehicles ~= nil then
        for k,v in pairs(vehicles) do
            local info = v.GetInsurance()
            if info.plan > 0 then
                local owner = exports.pw_base:checkOnline(v.GetOwner())
                local online = false
                local _char
                if owner then
                    _char = exports.pw_base:Source(owner)
                    online = owner
                else
                    _char = exports.pw_base:Offline(v.GetOwner())
                end
                
                local bankBalance = _char:Bank().getBalance()
                if bankBalance >= info.cost then
                    local planInfo = Config.Insurance.plans[info.plan]
                    _char.Bank().Remove(info.cost, "Monthly Payment of Insurance for Vehicle "..v.GetPlate())
                    v.UpdateInsurance('tows', planInfo.tows)
                    v.UpdateInsurance('fuel', planInfo.fuel)
                    
                    if info.cooldown then
                        v.UpdateInsurance('cooldown', false)
                    end
                    
                    if online then
                        TriggerClientEvent('pw:notification:SendAlert', online, { type = 'success', text = 'Paid insurance for vehicle '..v.GetPlate(), length = 5000 })
                    end
                else
                    v.ResetInsurance()
                    if online then
                        TriggerClientEvent('pw:notification:SendAlert', online, { type = 'error', text = 'Not enough money to pay insurance for vehicle '..v.GetPlate()..' ($'..info.cost..')<br>Your insurance was cancelled.', length = 7000 })
                    end
                end
            end
        end
    end
end

TriggerEvent('cron:runAt', 01, 00, payInsurances) -- Insurance Payment
--
RegisterServerEvent('pw_garage:server:endInsurance')
AddEventHandler('pw_garage:server:endInsurance', function(data)
    local _src = source
    local veh = exports.pw_vehicleshop:getVehicleByVin(data.vin.value)
    veh.ResetInsurance()
    TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'Your insurance contract for '.. veh.GetPlate().. ' has been terminated.', length = 5000 })
end)

RegisterServerEvent('pw_garage:server:useInsurance')
AddEventHandler('pw_garage:server:useInsurance', function(plate, vehNet)
    local veh = exports.pw_vehicleshop:getVehicle(plate)
    if veh then
        local vehTows = veh.GetInsurance('tows')
        if vehTows > 0 or vehTows == -1 then
            if vehTows ~= -1 then
                veh.UpdateInsurance('tows', vehTows - 1)
            end
            veh.UpdateInsurance('insured', true)

            -- make a random player delete the vehicle
            local onlinePlayers = exports.pw_base:getOnlineCharacters()
            local randomPlayer = math.random(1,#onlinePlayers)
            TriggerClientEvent('pw_garage:client:insureVeh', onlinePlayers[randomPlayer].source, vehNet)
        end
    end
end)

RegisterServerEvent('pw_garage:server:buyUnit')
AddEventHandler('pw_garage:server:buyUnit', function(data)
    local _src = source
    local id = tonumber(data.unitId.value)
    if data.contractReview.value then
        local _char = exports.pw_base:Source(_src)
        if _char:Cash().getCash() >= units[id].price then
            _char:Cash().Remove(units[id].price)
            local cid = _char:Character():getCID()
            units[id].owner = cid
            MySQL.Async.execute("UPDATE `garage_units` SET `owner` = @owner, `slots` = 0 WHERE `id` = @id", {['@owner'] = cid, ['@id'] = id}, function()
                TriggerEvent('pw_keys:issueKey', 'Unit', id, false, false, false, _src)
                TriggerClientEvent('pw_garage:client:boughtUnit', -1, id, cid)
            end)
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'Not enough money to buy this Garage Unit'})
        end
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'Make sure you sign the form if you agree with the Garage Unit buying terms'})
    end
end)

RegisterServerEvent('pw_garage:server:checkPlateForImpound')
AddEventHandler('pw_garage:server:checkPlateForImpound', function(props, entity)
    local _src = source
    if props.plate ~= nil then
        local vin = exports.pw_vehicleshop:getVehicleByPlate(props.plate)
        MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles` WHERE `vin` = @vin", {['@vin'] = vin}, function(res)
            if res[1] ~= nil then
                TriggerClientEvent('pw_garage:client:ownerFoundImpound', _src, props, entity)
            else
                TriggerClientEvent('pw_garage:client:deleteVehicle', _src, entity)
            end
        end)
    end
end)

RegisterServerEvent('pw_garage:server:sendToImpound')
AddEventHandler('pw_garage:server:sendToImpound', function(data)
    local _src = source
    TriggerEvent('pw_garage:server:storeVehicle', 'Impound', data.props, data.garage, data.damage, data.entity, _src)
end)

RegisterServerEvent('pw_garage:server:storeVehicle')
AddEventHandler('pw_garage:server:storeVehicle', function(gtype, props, garage, damage, entity, src)
    local _src = src or source

    local metaDamage = (damage ~= nil and json.encode(damage) or nil)

    local vin = exports.pw_vehicleshop:getVehicleByPlate(props.plate)
    if gtype == 'Public' then
        MySQL.Async.execute("UPDATE `owned_vehicles` SET `damage` = @damage, `vehicle_information` = @props, `stored_garage` = 1, `stored_garagetype` = 'Public', `stored_garageid` = @garage WHERE `vin` = @vin", {['@damage'] = metaDamage, ['@props'] = json.encode(props), ['@garage'] = garage, ['@vin'] = vin }, function()
            UpdateSlots(gtype, garage, 'stored')
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'Vehicle parked successfully at '..garages[garage].name..' garage'})
        end)
    elseif gtype == 'Private' then
        MySQL.Async.execute("UPDATE `owned_vehicles` SET `damage` = @damage, `vehicle_information` = @props, `stored_garage` = 1, `stored_garagetype` = 'Private', `stored_garageid` = @garage WHERE `vin` = @vin", {['@damage'] = metaDamage, ['@props'] = json.encode(props), ['@garage'] = garage, ['@vin'] = vin }, function()
            UpdateSlots(gtype, garage, 'stored')
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'Vehicle parked successfully at '..privateGarages[garage].name..' garage'})
        end)
    elseif gtype == 'Impound' then
        MySQL.Async.execute("UPDATE `owned_vehicles` SET `damage` = @damage, `vehicle_information` = @props, `stored_garage` = 1, `stored_garagetype` = 'Impound', `stored_garageid` = @garage WHERE `vin` = @vin", {['@damage'] = metaDamage, ['@props'] = json.encode(props), ['@garage'] = garage, ['@vin'] = vin }, function()
            UpdateSlots(gtype, garage, 'stored')
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'Vehicle impounded successfully to '..garages[garage].name..' Impound Lot'})
            TriggerClientEvent('pw_garage:client:deleteVehicle', _src, entity)
        end)
    elseif gtype == 'Unit' then
        MySQL.Async.execute("UPDATE `owned_vehicles` SET `damage` = @damage, `vehicle_information` = @props, `stored_garage` = 1, `stored_garagetype` = 'Unit', `stored_garageid` = @garage WHERE `vin` = @vin", {['@damage'] = metaDamage, ['@props'] = json.encode(props), ['@garage'] = garage, ['@vin'] = vin }, function()
            UpdateSlots(gtype, garage, 'stored')
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'Vehicle parked successfully at '..units[garage].name..' garage unit'})
        end)
    end
end)

RegisterServerEvent('pw_garage:server:takeVehicleImpound')
AddEventHandler('pw_garage:server:takeVehicleImpound', function(data)
    local _src = source
    if data.contractReview then
        local _char = exports.pw_base:Source(_src)
        if _char:Cash().getCash() >= Config.PoliceImpoundCost then
            _char:Cash().Remove(Config.PoliceImpoundCost)

            MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles` WHERE `vin` = @vin", {['@vin'] = data.veh.data.plate}, function(veh)
                if veh[1] ~= nil then
                    TriggerClientEvent('pw_garage:client:spawnVehicle', _src, data.veh.data.type, json.decode(veh[1].vehicle_information), tonumber(veh[1].stored_garageid), json.decode(veh[1].insurance), (veh[1].damage ~= nil and json.decode(veh[1].damage) or nil))
                    UpdateSlots(data.veh.data.type, tonumber(veh[1].stored_garageid), 'taken')
                end
            end)
            MySQL.Async.execute("UPDATE `owned_vehicles` SET `stored_garage` = 0, `stored_garagetype` = 'None', `stored_garageid` = 0 WHERE `vin` = @vin", {['@vin'] = data.veh.data.plate }, function() end)
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You don\'t have enough money to release your vehicle (Cost: $'..Config.PoliceImpoundCost..')'})
        end
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You must sign the Release Form'})
    end
end)

RegisterServerEvent('pw_garage:server:takeVehicle')
AddEventHandler('pw_garage:server:takeVehicle', function(type, vin)
    local _src = source
    
    MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles` WHERE `vin` = @vin", {['@vin'] = vin}, function(veh)
        if veh[1] ~= nil then
            TriggerClientEvent('pw_garage:client:spawnVehicle', _src, type, json.decode(veh[1].vehicle_information), tonumber(veh[1].stored_garageid), json.decode(veh[1].insurance), (veh[1].damage ~= nil and json.decode(veh[1].damage) or nil))
            UpdateSlots(type, tonumber(veh[1].stored_garageid), 'taken')
        end
    end)
    MySQL.Async.execute("UPDATE `owned_vehicles` SET `stored_garage` = 0, `stored_garagetype` = 'None', `stored_garageid` = 0 WHERE `vin` = @vin", {['@vin'] = vin }, function() end)
end)

RegisterServerEvent('pw_garage:server:abandonUnit')
AddEventHandler('pw_garage:server:abandonUnit', function(data)
    local _src = source
    local id = tonumber(data.id.value)
    if data.contractReview.value then
        local _char = exports.pw_base:Source(_src)
        if _char:Character().getCID() == units[id].owner then
            MySQL.Async.execute("UPDATE `garage_units` SET `owner` = NULL WHERE `id` = @id", {['@id'] = id}, function()
                TriggerEvent('pw_keys:revokeKeys', 'Unit', id, _char.GetCID())
                TriggerClientEvent('pw_garage:client:boughtUnit', -1, id, nil)
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You abandoned this garage unit'})
            end)
        end
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You need to sign the form'})
    end
end)

RegisterServerEvent('pw_garage:server:createContract')
AddEventHandler('pw_garage:server:createContract', function(data)
    local _src = source

    if data.contractReview.value then
        local veh = exports.pw_vehicleshop:getVehicleByVin(data.info.data.vin)
        data['src'] = _src
        TriggerClientEvent('pw_debitcard:openPinTerminal', _src, 'pw_garage:server:pinEntered', 'server', { ['amount'] = data.info.data.payment, ['to'] = "Insurance Company", ['statement'] = 'Payment of first month of Insurance for vehicle ' .. veh.GetPlate() }, { ['data'] = data })
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'You must agree to the proposed terms', length = 5000 })
    end
end)

RegisterServerEvent('pw_garage:server:pinEntered')
AddEventHandler('pw_garage:server:pinEntered', function(data)
    local info = data.data.info.data

    local veh = exports.pw_vehicleshop:getVehicleByVin(info.vin)
    veh.UpdateInsurance('plan', info.plan)
    veh.UpdateInsurance('tows', Config.Insurance.plans[info.plan].tows)
    veh.UpdateInsurance('fuel', Config.Insurance.plans[info.plan].fuel)
    veh.UpdateInsurance('cost', info.payment)
    veh.UpdateInsurance('cooldown', true)

    TriggerClientEvent('pw:notification:SendAlert', data.data.src, { type = 'success', text = 'Your vehicle is now insured under our '.. Config.Insurance.plans[info.plan].label ..' terms for a monthly cost of <b>$'.. info.payment ..'</b>', length = 5000 })
end)

RegisterServerEvent('pw_garage:server:sendVehToPickup')
AddEventHandler('pw_garage:server:sendVehToPickup', function(data)
    local _src = source
    MySQL.Async.execute("UPDATE `owned_vehicles` SET `stored_garage` = 1, `stored_garagetype` = 'Public', `stored_garageid` = @garage WHERE `vin` = @vin", {['@garage'] = data.info.data.garage, ['@vin'] = data.info.data.vin }, function()
        UpdateSlots('Public', data.info.data.garage, 'stored')
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'Your vehicle will be delivered to '..garages[data.info.data.garage].name..' garage'})
    end)
end)

function UpdateSlots(gType, id, type)
    local gid = tonumber(id)
    if gType == 'Public' or gType == 'Impound' then
        if type == 'stored' then
            garages[gid].curSlots = garages[gid].curSlots + 1
        else
            if garages[gid].curSlots > 0 then
                garages[gid].curSlots = garages[gid].curSlots - 1
            end
        end
        MySQL.Async.execute("UPDATE `garages` SET `curslots` = @curSlots WHERE `id` = @id", {['@curSlots'] = garages[gid].curSlots, ['@id'] = gid }, function()
            TriggerClientEvent('pw_garage:client:updateSlots', -1, gType, gid, type)
        end)
    elseif gType == 'Private' then
        if type == 'stored' then
            privateGarages[gid].curSlots = privateGarages[gid].curSlots + 1
        else
            if privateGarages[gid].curSlots > 0 then
                privateGarages[gid].curSlots = privateGarages[gid].curSlots - 1
            end
        end
        MySQL.Async.execute("UPDATE `properties` SET `garageSlots` = @curSlots WHERE `property_id` = @id", {['@curSlots'] = privateGarages[gid].curSlots, ['@id'] = gid }, function()
            TriggerClientEvent('pw_garage:client:updateSlots', -1, gType, gid, type)
        end)
    elseif gType == 'Unit' then
        if type == 'stored' then
            units[gid].curSlots = units[gid].curSlots + 1
        else
            if units[gid].curSlots > 0 then
                units[gid].curSlots = units[gid].curSlots - 1
            end
        end
        MySQL.Async.execute("UPDATE `garage_units` SET `slots` = @curSlots WHERE `id` = @id", {['@curSlots'] = units[gid].curSlots, ['@id'] = gid }, function()
            TriggerClientEvent('pw_garage:client:updateSlots', -1, gType, gid, type)
        end)
    end
end

PW.RegisterServerCallback('pw_garage:server:getParkedVehicles', function(source, cb, type, garage)
    MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles` WHERE `stored_garage` = 1 AND `stored_garagetype` = @type AND `stored_garageid` = @id", {['@type'] = type, ['@id'] = garage}, function(vehs)
        if #vehs > 0 then
            cb(vehs)
        else
            cb(false)
        end
    end)
end)

PW.RegisterServerCallback('pw_garage:server:checkOwner', function(source, cb, vin)
    local _src = source
    local _char = exports.pw_base:Source(_src)
    
    MySQL.Async.fetchScalar("SELECT `vehicle_metainformation` FROM `owned_vehicles` WHERE `vin` = @vin", {['@vin'] = vin}, function(meta)
        if meta ~= nil then
            local dMeta = json.decode(meta)
            if dMeta.owner == _char:Character().getCID() then
                cb(true)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)
end)

PW.RegisterServerCallback('pw_garage:server:getGarages', function(source, cb)
    cb(garages, privateGarages, units)
end)

PW.RegisterServerCallback('pw_garage:server:getOwnedVehs', function(source, cb)
    local _src = source
    local cid = exports.pw_base:Source(_src):Character().getCID()
    
    local vehs = exports.pw_vehicleshop:getVehicles()
    local sendVehs = {}
    local foundOne = false
    for k,v in pairs(vehs) do
        if v.GetOwner() == cid then
            table.insert(sendVehs, { ['vin'] = k, ['plate'] = v.GetPlate(), ['model'] = v.GetMeta('model'), ['cooldown'] = v.GetInsurance('cooldown') })
            if not foundOne then foundOne = true; end
        end
    end
    if foundOne then
        cb(sendVehs)
    else
        cb(false)
    end
end)

PW.RegisterServerCallback('pw_garage:server:loadInsurance', function(source, cb, vin)
    local veh = exports.pw_vehicleshop:getVehicleByVin(vin)
    cb(veh.GetInsurance())
end)

PW.RegisterServerCallback('pw_garage:server:getVehCost', function(source, cb, model)
    MySQL.Async.fetchScalar("SELECT `price` FROM `avaliable_vehicles` WHERE `model` = @model", { ['@model'] = model }, function(cost)
        cb(cost)
    end)
end)

function AutoUpdateSlots()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5000)
            MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles` WHERE `stored_garage` = 1", {}, function(vehs)
                if #vehs > 0 then
                    local publicCount, privateCount = {}, {}
                    for i = 1, #vehs do
                        if vehs[i].stored_garagetype == 'Public' then
                            if publicCount[vehs[i].stored_garageid] then
                                publicCount[vehs[i].stored_garageid] = publicCount[vehs[i].stored_garageid] + 1
                            else
                                publicCount[vehs[i].stored_garageid] = 1
                            end
                        elseif vehs[i].stored_garagetype == 'Private' then
                            if privateCount[tonumber(vehs[i].stored_garageid)] then
                                privateCount[tonumber(vehs[i].stored_garageid)] = privateCount[tonumber(vehs[i].stored_garageid)] + 1
                            else
                                privateCount[tonumber(vehs[i].stored_garageid)] = 1
                            end
                        end
                    end

                    for x,y in pairs(garages) do
                        local found = false
                        for k,v in pairs(publicCount) do
                            if x == k then
                                garages[x].curSlots = v
                                found = true
                            end
                        end
                        if not found then
                            garages[x].curSlots = 0
                        end
                        TriggerClientEvent('pw_garage:client:autoUpdate', -1, 'public', x, garages[x].curSlots)
                    end

                    for x,y in pairs(privateGarages) do
                        local found = false
                        for k,v in pairs(privateCount) do
                            if x == k then
                                privateGarages[x].curSlots = v
                                found = true
                            end
                        end
                        if not found then
                            privateGarages[x].curSlots = 0
                        end
                        TriggerClientEvent('pw_garage:client:autoUpdate', -1, 'private', x, privateGarages[x].curSlots)
                    end
                end
            end)
        end
    end)
end

exports.pw_chat:AddChatCommand('insure', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_garage:client:insureTest', _src)
end, {
    help = "Insurance Test",
    params = {}
}, -1)

exports.pw_chat:AddChatCommand('fuel', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_garage:client:askForFuel', _src)
end, {
    help = "Fuel Test",
    params = {}
}, -1)