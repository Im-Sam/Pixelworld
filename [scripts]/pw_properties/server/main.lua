registeredProperties = {}
propsLoaded = false
PW = nil
propertiesLoaded = false

TriggerEvent('pw:getSharedObject', function(obj)
    PW = obj
end)

function RetrieveFurnitureOnHold(hid, owner)
    MySQL.Async.fetchScalar("SELECT `furniture` FROM `furniture_hold` WHERE `cid` = @cid", {['@cid'] = owner}, function(furniture)
        if furniture ~= nil then
            local meta = json.decode(furniture)
            local cidSource = exports.pw_base:checkOnline(owner)
            if cidSource then
                TriggerClientEvent('pw_properties:client:askForFurnitureOnHold', cidSource, hid, meta)
            end
        end
    end)
end

function PutFurnitureOnHold(hid, owner)
    local house = registeredProperties[hid]
    local furniture = house.getFurniture()
    local ownedFurniture = {}
    for k,v in pairs(furniture) do
        if v.buyer == owner then
            v.placed = false
            v.position = { ['x'] = 0.0, ['y'] = 0.0, ['z'] = 0.0, ['h'] = 0.0 }
            table.insert(ownedFurniture, v)
            furniture[k] = nil
        end
    end
    if #furniture == 0 then furniture = {}; end
    house.updateFurnitureAfterEviction(furniture, ownedFurniture, owner)
end

function Evict (house)
    local statusOwner = exports.pw_base:checkOnline(house.getOwner())
    if statusOwner then
        TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = "inform", text = "The tenant of your house at "..house.getName().." has now been evicted." })
    end
    local statusRentor = exports.pw_base:checkOnline(house.getRentor())
    if statusRentor then
        TriggerEvent('pw_properties:server:lockHouse', house.getPropertyId(), true)
        TriggerClientEvent('pw_properties:client:rentTerminated', statusRentor, house.getPropertyId())
    end
    PutFurnitureOnHold(house.getPropertyId(), house.getRentor())
    TriggerEvent('pw_keys:revokeKeys', 'Property', house.getPropertyId(), house.getRentor())
    house.updateStatus('rented')
    house.updateRentor(0)
    house.updateRent('evicting', false)
    house.updateRent('evictingLeft', Config.EvictionCooldown)
    
end

function CheckEvictions(d, h, m)
    if #registeredProperties == 0 then return; end
    for i = 1, #registeredProperties do
        local house = registeredProperties[i]
        if house.getRent('evicting') then
            local timeleft = house.getRent('evictingLeft')
            if timeleft == 0 then
                Evict(house)
            else
                house.updateRent('evictingLeft')
                local statusRentor = exports.pw_base:checkOnline(house.getRentor())
                if statusRentor then
                    TriggerClientEvent('pw:notification:SendAlert', statusRentor, {type = "inform", text = "You have "..(timeleft - 1).."h to leave the house at "..house.getName()})
                    TriggerClientEvent('pw:notification:SendAlert', statusRentor, {type = "inform", text = "Make sure you pick up all your belongings before the time runs out."})
                end
            end
        end
    end
end

function StartEvict(house)
    house.updateRent('evicting', true)
    local statusRentor = exports.pw_base:checkOnline(house.getRentor())
    if statusRentor then
        TriggerClientEvent('pw:notification:SendAlert', statusRentor, {type = "inform", text = "An evict order for "..house.getName().." was started. You have 72h to leave the house as of this moment."})
        TriggerClientEvent('pw:notification:SendAlert', statusRentor, {type = "inform", text = "Make sure you pick up all your belongings before leaving."})
    end
end

function CheckFurniture(d, h, m)
    MySQL.Async.fetchAll("SELECT * FROM `furniture_pending`", {}, function(result)
        if result ~= nil and #result > 0 then
            for k,v in pairs(result) do
                local meta = json.decode(v.metainformation)
                if meta.order and meta.order[1] ~= nil and #meta.order > 0 then
                    meta.left = meta.left - Config.PendingFurnitureRate
                    if meta.left <= 0 and not meta.complete then
                        MySQL.Async.execute("DELETE FROM `furniture_pending` WHERE `id` = @id", {['@id'] = v.id}, function() 
                            DeliverFurniture(v.house, meta.order, true, false)
                        end)
                    else
                        MySQL.Async.execute("UPDATE `furniture_pending` SET `metainformation` = @meta WHERE `id` = @id", {['@meta'] = json.encode(meta), ['@id'] = v.id }, function() end)
                    end
                else
                    meta.left = meta.left - Config.PendingFurnitureRate
                    if meta.left <= 0 and not meta.delivered then
                        meta.delivered = true
                        MySQL.Async.execute("DELETE FROM `furniture_pending` WHERE `id` = @id", {['@id'] = v.id}, function()
                            DeliverFurniture(v.house, meta, false, true)
                        end)
                    else
                        MySQL.Async.execute("UPDATE `furniture_pending` SET `metainformation` = @meta WHERE `id` = @id", {['@meta'] = json.encode(meta), ['@id'] = v.id }, function() end)
                    end
                end
            end
        end
    end)
end

function DeliverFurniture(house, meta, multiple, msg)
    if multiple then
        registeredProperties[house].addMultiFurniture(meta)
    else
        registeredProperties[house].addFurniture(meta)
    end
    
    if msg then
        local statusBuyer = exports.pw_base:checkOnline(meta.buyer)
        if statusBuyer then
            TriggerClientEvent('pw:notification:SendAlert', statusBuyer, {type = 'inform', text = 'A new piece of furniture has just arrived at '..registeredProperties[house].getName()})
        end
    end
end

-- CRONS
TriggerEvent('cron:runAt', 01, 00, rentDue) -- Rent Payment

function StartCronEviction()
    for i = 0, 23 do
        for j = 0, 59 do
            TriggerEvent('cron:runAt', i, j, CheckEvictions) -- Eviction Checking
        end
    end
end

function StartCronFurniture()
    for i = 0, 23 do
        for j = 0, 59 do
            if j % Config.PendingFurnitureRate == 0 then
                TriggerEvent('cron:runAt', i, j, CheckFurniture) -- Furniture Delivery Checking
            end
        end
    end
end
--

MySQL.ready(function ()
    MySQL.Async.fetchAll("SELECT * FROM `properties`", {}, function(properties)
        local tasks = {}
        for i = 1, #properties do
            local task = function(cb)
                local result = registerProperty(tonumber(properties[i].property_id))
                cb(result)
            end
            table.insert(tasks, task)
        end
    
        Async.parallel(tasks, function(results)
            for i = 1, #results do
                registeredProperties[results[i].getPid()] = results[i]
            end
            totalProperties = #properties
            propertiesLoaded = true
        end)
    end)
    repeat Wait(0) until propertiesLoaded == true 
    print(' ^1[PixelWorld Properties]^3 - We have successfully loaded ^5'..totalProperties..'^3 properties')
    TriggerEvent('pw_garage:server:propsLoaded', true)
    StartCronEviction()
    StartCronFurniture()
end)

exports('propertiesLoadedCheck', function()
    repeat Wait(0) until propertiesLoaded == true
    return true
end)

RegisterServerEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(src)
    local _src = src or source
    local _char = exports.pw_base:Source(_src):Character()
    TriggerClientEvent('pw_properties:client:loadHouses', _src, Houses)
    for i = 1, #registeredProperties do
        local house = registeredProperties[i]
        if house.getRent('evicting') and house.getRentor() == _char.getCID() then
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'Your landlord at '..house.getName()..' has filled an evict order', length = 10000})
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You still have '..house.getRent('evictingLeft')..'h left to leave the house with all your belongings', length = 10000})
        end
    end        
end)

RegisterServerEvent('pw_properties:server:lockHouse')
AddEventHandler('pw_properties:server:lockHouse', function(house, status)
    registeredProperties[house].toggleLock(status)
end)

exports('toggleLock', function(house)
    if registeredProperties[tonumber(house)] then
        registeredProperties[tonumber(house)].toggleLockPhone()
    end
end)

RegisterServerEvent('pw_properties:server:checkMoneyForStashes')
AddEventHandler('pw_properties:server:checkMoneyForStashes', function(data)
    local _src = source
    local _char = exports.pw_base:Source(_src)
    local curCash = _char:Cash().getCash()
    if curCash >= Config.StashPrices[data.type] then
        _char:Cash().Remove(Config.StashPrices[data.type])
        registeredProperties[data.house].toggleLuxary(data.type)
        TriggerClientEvent('pw_properties:client:openFurnitureMenu', _src, {house = data.house})
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'success', text = 'You just bought a '..registeredProperties[data.house].getLuxaryLabel(data.type), length = 3500})
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'Select it and choose "Change Position" to set it up', length = 3500})
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You don\'t have enough money to buy this'})
    end
end)

RegisterServerEvent('pw_properties:server:setRentPrice')
AddEventHandler('pw_properties:server:setRentPrice', function(result)
    local _src = source
    local price = tonumber(result.rentPrice.value)
    local house = registeredProperties[tonumber(result.houseId.value)]
    local rentLimit = math.floor(house.getPurchaseCost() / 100)
    if price < 1 then
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'The rent price must be higher than $0'} )
    elseif price >= rentLimit then
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'The rent price for this house can\'t be higher than $'..rentLimit, length = 3500} )
    else
        house.setRentPrice(price)
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'success', text = 'Rent price changed to $'..price, length = 3500} )
    end
end)

RegisterServerEvent('pw_properties:server:changeRentStatus')
AddEventHandler('pw_properties:server:changeRentStatus', function(data)
    local _src = source
    registeredProperties[data.house].updateStatus(data.type)
end)

RegisterServerEvent('pw_properties:server:toggleAutoLock')
AddEventHandler('pw_properties:server:toggleAutoLock', function(data, lockpick)
    local _src = source
    registeredProperties[data.house].setOptions('autolock', data.state, _src, lockpick)
end)

PW.RegisterServerCallback('pw_properties:server:getOwnedProperties', function(source, cb)
    local _src = source
    local _char = exports.pw_base:Source(_src):Character()
    cb(_char:myProperties())
end)

RegisterServerEvent('pw_properties:server:toggleLuxaryRent')
AddEventHandler('pw_properties:server:toggleLuxaryRent', function(data)
    registeredProperties[data.house].toggleLuxaryRent(data.type)
end)

RegisterServerEvent('pw_properties:server:saveMarkerPos')
AddEventHandler('pw_properties:server:saveMarkerPos', function(type, house, pedCoords, h)
    registeredProperties[house].moveMarker(type, pedCoords, h)
end)

RegisterServerEvent('pw_properties:server:changeOutfit')
AddEventHandler('pw_properties:server:changeOutfit', function(data)
    local _src = source
    local _char = exports.pw_base:Source(_src):Character()
    _char.ChangeOutfit(tonumber(data.outfitid))
end)

RegisterServerEvent('pw_properties:server:deleteOutfit')
AddEventHandler('pw_properties:server:deleteOutfit', function(data)
    local _src = source
    local _char = exports.pw_base:Source(_src):Character()
    _char.RemoveOutfit(tonumber(data.outfitid))
end)

PW.RegisterServerCallback('pw_properties:getPlayerOutfits', function(source, cb)
    local _src = source
    local _char = exports.pw_base:Source(_src):Character()
    local outfits = _char.GetOutfits()

    if outfits ~= nil then
        cb(outfits)
    else
        cb(nil)
    end
end)

RegisterServerEvent('pw_properties:server:toggleAlarm')
AddEventHandler('pw_properties:server:toggleAlarm', function(data)
    local _src = source
    registeredProperties[data.house].setOptions('alarm', data.state, _src)
end)

RegisterServerEvent('pw_properties:server:buyAlarm')
AddEventHandler('pw_properties:server:buyAlarm', function(data)
    local _src = source
    local _char = exports.pw_base:Source(_src)
    local curCash = _char:Cash().getCash()
    if curCash >= Config.AlarmPrice then
        _char:Cash().Remove(Config.AlarmPrice)
        registeredProperties[data.house].toggleLuxary('alarm')
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'success', text = 'You just bought an Alarm System', length = 3500})
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You don\'t have enough money to buy this'})
    end
end)

RegisterServerEvent('pw_properties:server:terminateRent')
AddEventHandler('pw_properties:server:terminateRent', function(result)
    local _src = source
    local house = registeredProperties[tonumber(result.houseId.value)]
    if result.checkTerminate.value then
        local securityDeposit = house.getRent('securityDeposit')
        local _char = exports.pw_base:Source(_src)
        local curArrears = house.getRent('arrears')
        local toAdd = securityDeposit - curArrears
        if toAdd < 0 then
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "inform", text = "Since your Arrears are bigger than the Security Deposit, you won\'t receive anything back", length = 3500})
        else
            _char:Cash().Add(toAdd)
            if toAdd == securityDeposit then
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = "inform", text = "Your Security Deposit of $"..toAdd.." was returned to you", length = 3500})
            else
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = "inform", text = "You received $"..toAdd.." back from the Security Deposit", length = 3500})
            end
        end
        PutFurnitureOnHold(tonumber(result.houseId.value), house.getRentor())
        TriggerEvent('pw_keys:revokeKeys', 'Property', house.getPropertyId(), house.getRentor())
        house.updateRent('deposit', 'remove')
        house.updateStatus('rented')
        house.updateRentor(0)
        if house.getRent('evicting') then
            house.updateRent('evicting', false)
            house.updateRent('evictingLeft', Config.EvictionCooldown)
        end
        TriggerEvent('pw_properties:server:lockHouse', tonumber(result.houseId.value), true)
        TriggerClientEvent('pw_properties:client:rentTerminated', _src, tonumber(result.houseId.value))
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You must tick the checkbox if you agree with the tenancy termination terms", length = 3500})
    end
end)

RegisterServerEvent('pw_properties:server:sendRentContract')
AddEventHandler('pw_properties:server:sendRentContract', function(result)
    local _src = source
    if result.contractReview.value then
        local target = tonumber(result.target.value)
        local house = tonumber(result.houseId.value)
        local rentPrice = tonumber(result.rentPrice.value)

        TriggerClientEvent('pw_properties:client:sendFinalContract', target, house, rentPrice, result.terms.value)
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You\'ve showed the tenancy contract'})
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You must agree to the terms by ticking the box'})
    end
end)

RegisterServerEvent('pw_properties:server:sendTerminateRent')
AddEventHandler('pw_properties:server:sendTerminateRent', function(result)
    local _src = source
    if result.terminateReview.value then
        local house = registeredProperties[tonumber(result.houseId.value)]
        local target = house.getRentor()
        StartEvict(house)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You must agree to the terms by ticking the box'})
    end
end)

RegisterServerEvent('pw_properties:server:processStashMoney')
AddEventHandler('pw_properties:server:processStashMoney', function(data)
    local _src = source
    local houseIdent = tonumber(data.houseId.value)
    local amount = tonumber(data.amount.value)

    if registeredProperties[houseIdent] then
        local house = registeredProperties[houseIdent]
        if data.action.value == "withdraw" then
            local success = house.RemoveMoney(_src, amount)
            if success then
                TriggerClientEvent('pw_properties:openMoneyStash', _src, houseIdent)
            end
        end

        if data.action.value == "deposit" then
            local success = house.AddMoney(_src, amount)
            if success then 
                TriggerClientEvent('pw_properties:openMoneyStash', _src, houseIdent)
            end
        end
    end
end)

function rentDue(d, h, m)
    if d == 1 then
        for i = 1, #registeredProperties do
            local house = registeredProperties[i]
            if house.getStatus('rented') then
                house.rentDue()
                local statusRentor = exports.pw_base:checkOnline(house.getRentor())
                if statusRentor then
                    TriggerClientEvent('pw:notification:SendAlert', statusRentor, {type = "inform", text = "Rent is now due for "..house.getName()})
                end
                Wait(1)
            end
        end
    end
end

PW.RegisterServerCallback('pw_properties:retreiveStashedMoney', function(source, cb, house)
    local houseId = tonumber(house)
    local limit = registeredProperties[houseId].GetLimits('money')
    cb({['name'] = registeredProperties[houseId].getName(), ['currentCash'] = registeredProperties[houseId].GetStoredCash(), ['limit'] = limit})

end)

PW.RegisterServerCallback('pw_properties:getPropertyInventory', function(source, cb, houseid, invtype)
    cb(registeredProperties[houseid].GetInventory(invtype))
end)

RegisterServerEvent('pw_properties:server:finalContractAgreed')
AddEventHandler('pw_properties:server:finalContractAgreed', function(result)
    local _src = source
    if result.contractReview.value then
        local rentPrice = tonumber(result.rentPrice.value)
        local securityDeposit = math.floor(rentPrice * 2)
        local _char = exports.pw_base:Source(_src)
        if _char ~= nil then
            if _char:Cash().getCash() >= securityDeposit then
                _char:Cash().Remove(securityDeposit)
                local house = registeredProperties[tonumber(result.houseId.value)]
                house.setRentPrice(rentPrice)
                house.updateRent('deposit', 'add')
                house.updateStatus('rented')
                house.updateStatus('forRent')
                house.updateRentor(_char:Character():getCID())
                TriggerEvent('pw_keys:issueKey', 'Property', tonumber(result.houseId.value), false, false, false, _src)
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'success', text = 'You are now a tenant of this house'})
                RetrieveFurnitureOnHold(tonumber(result.houseId.value), _char:Character().getCID())
            else
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'Not enough money to pay the security deposit'})
            end
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'An error occurred'})
        end
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You must agree to the tenancy terms by ticking the box'})
    end
end)

RegisterServerEvent('pw_properties:server:processCollection')
AddEventHandler('pw_properties:server:processCollection', function(result)
    local _src = source
    local amountToTake = tonumber(result.potAmount.value)
    local houseId = tonumber(result.houseId.value)
    local house = registeredProperties[houseId]
    if amountToTake > 0 and amountToTake <= house.getRent('pot') then
        local _char = exports.pw_base:Source(_src)
        _char:Cash().Add(amountToTake)
        house.updateRent('pot', amountToTake * -1)
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'success', text = 'You collected $'..amountToTake..' worth of rent payments'})
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'Invalid amount'})
    end

end)

RegisterServerEvent('pw_properties:server:processPayment')
AddEventHandler('pw_properties:server:processPayment', function(result)
    local _src = source
    local method = result.houseId.data.method
    local house = registeredProperties[result.houseId.data.house]
    local _char, paid
    if method == "payArrears" then
        paid = tonumber(result.checkPay.value)
        if paid ~= nil and paid > 0 and paid <= house.getRent('arrears') then
            _char = exports.pw_base:Source(_src)
            if _char:Cash().getCash() >= paid then
                _char:Cash().Remove(paid)
                local rentalCost = house.getRentalCost()
                local arrearsToMonths = house.getRent('arrears') / rentalCost   -- checks how many months are the arrears worth
                local remaining = arrearsToMonths - math.floor(arrearsToMonths) -- gets the remaining of the math 0.xxxx
                local addRemainingArrears = math.floor(remaining * rentalCost)  -- converts 0.xxxx months into cash
                local finalArrears = paid * -1 + addRemainingArrears
                arrearsToMonths = math.floor(arrearsToMonths)                   -- gets the full months we paid
                house.updateRent('missed', arrearsToMonths * -1)                -- subtract the months from missed payments
                house.updateRent('arrears', finalArrears)                       -- subtract what we paid and add the remaining that doesn't get up to 1 full month as arrears
                house.updateRent('pot', finalArrears)
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'success', text = 'You paid $'..paid..' of rent arrears'})
                local statusOwner = exports.pw_base:checkOnline(house.getOwner())
                if statusOwner then
                    TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = "inform", text = "Your tenant at "..house.getName().." just paid $"..paid.." towards arrears. Arrears left: $"..house.getRent('arrears')})
                end
            else
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'Insufficient cash'})
            end
        end
    else
        if result.checkPay.value then
            _char = exports.pw_base:Source(_src)
            paid = tonumber(result.houseId.data.amount)
            if _char:Cash().getCash() >= paid then
                _char:Cash().Remove(paid)
                local missedMonths = house.getRent('missed')
                house.updateRent('paid', missedMonths)
                Wait(50)
                house.updateRent('missed', 0)
                house.updateRent('arrears', paid * -1)
                house.updateRent('pot', paid)
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'success', text = 'You paid $'..paid..' for the missing months of your rent'})
                local statusOwner = exports.pw_base:checkOnline(house.getOwner())
                if statusOwner then
                    TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = "inform", text = "Your tenant at "..house.getName().." just paid all "..missedMonths.." months that were due for payment."})
                end
            else
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'Insufficient cash'})
            end
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You must confirm the payment by ticking the box'})
        end
    end
end)

RegisterServerEvent('pw_properties:server:pinEntered')
AddEventHandler('pw_properties:server:pinEntered', function(data)
    local _src = data.data.src
    local _char = exports.pw_base:Source(_src):Character()
    
    local targetHouse = data.data.house
    local deliveryMethod = data.data.deliveryMethod
    local bought = data.data.bought
    
    registeredProperties[targetHouse].addMultiplePendingFurniture(bought, deliveryMethod, _char.getCID())
    TriggerClientEvent('pw_properties:client:clearCart', _src)
    TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'Order confirmed and on its way to your house' })
    TriggerClientEvent('pw_properties:client:deleteDisplayed', _src)
end)

RegisterServerEvent('pw_properties:server:payForFurniture')
AddEventHandler('pw_properties:server:payForFurniture', function(result)
    local _src = source
    local _char = exports.pw_base:Source(_src)

    local data = result.cart.data
    local paymentMethod = result.cart.value
    local deliveryMethod = result.delivery.value
    local targetHouse = tonumber(result.house.value)
    local price = SumBasket(data)
    if price then
        price = price + Config.DeliveryMethods[deliveryMethod]['fee']
        if paymentMethod == 'cash' then
            local curCash = _char:Cash().getCash()
            if curCash >= price then
                _char:Cash().Remove(price)
                registeredProperties[targetHouse].addMultiplePendingFurniture(data, deliveryMethod, _char:Character():getCID())
                TriggerClientEvent('pw_properties:client:clearCart', _src)
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'Order confirmed and on its way to your house' })
            else
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'Not enough money'})
            end
            TriggerClientEvent('pw_properties:client:deleteDisplayed', _src)
        elseif paymentMethod == 'debit' then
            TriggerClientEvent('pw_debitcard:openPinTerminal', _src, 'pw_properties:server:pinEntered', 'server', { ['amount'] = price, ['to'] = "Furniture Store", ['statement'] = 'Purchase of '..CountBasketItems(data)..' items at the Furniture Store' }, { ['data'] = {bought = data, paymentMethod = paymentMethod, deliveryMethod = deliveryMethod, house = targetHouse, src = _src}})
        end
    end
end)

RegisterServerEvent('pw_properties:server:changeFurnitureLabel')
AddEventHandler('pw_properties:server:changeFurnitureLabel', function(data)
    local _src = source
    
    local house = data.info.data.house
    local fid = data.info.data.fid
    local newName = data.newName.value
    local default = false
    if string.len(newName) == 0 then
        newName = GetFurnitureLabel(Houses[house].furniture[fid].prop)
        default = true
    end
    if (string.len(newName) > 3 and string.len(newName) < 16) or default then
        registeredProperties[house].updateFurniture(fid, 'name', newName)
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'success', text = 'Saved as: '..newName })
    else
        TriggerClientEvent('pw_properties:client:changeFurnitureLabel', _src, house, fid)
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'Make sure your new label length is between 4 and 15 characters' })
    end
end)

RegisterServerEvent('pw_properties:server:deleteFurnitureForEveryone')
AddEventHandler('pw_properties:server:deleteFurnitureForEveryone', function(house, fid)
    TriggerClientEvent('pw_properties:client:deleteFurnitureForEveryone', -1, house, fid)
end)

RegisterServerEvent('pw_properties:server:updateFurniturePlaced')
AddEventHandler('pw_properties:server:updateFurniturePlaced', function(house, fid, status)
    local _src = source
    registeredProperties[house].updateFurniture(fid, 'placed', status)
    TriggerClientEvent('pw:notification', _src, {type = 'inform', text = 'Object stored away successfully'})
end)

RegisterServerEvent('pw_properties:server:updateFurniturePos')
AddEventHandler('pw_properties:server:updateFurniturePos', function(house, fid, pos)
    local _src = source
    registeredProperties[house].updateFurniture(fid, 'position', pos)
    TriggerClientEvent('pw:notification', _src, {type = 'inform', text = 'Object placed successfully'})
end)

RegisterServerEvent('pw_properties:server:disposeFurniture')
AddEventHandler('pw_properties:server:disposeFurniture', function(data)
    local _src = source
    
    local house = data.info.data.house
    local fid = data.info.data.fid
    registeredProperties[house].removeFurniture(fid)
    TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'Object disposed'})
end)

RegisterServerEvent('pw_properties:server:importFurniture')
AddEventHandler('pw_properties:server:importFurniture', function(data)
    local _src = source
    if data.data.data.meta ~= nil and #data.data.data.meta > 0 then
        local _char = exports.pw_base:Source(_src):Character()
        MySQL.Async.execute("DELETE FROM `furniture_hold` WHERE `cid` = @cid", {['@cid'] = _char.getCID()}, function()
            if #data.data.data.meta > 1 then
                registeredProperties[data.data.data.house].addMultipleFurniture(data.data.data.meta)
            else
                registeredProperties[data.data.data.house].addFurniture(data.data.data.meta[1])
            end
        end)
    end
end)

function GetPropPrice(prop)
    for k,v in pairs(Config.Furniture) do
        for j,b in pairs(Config.Furniture[k].props) do
            if b.prop == prop then
                return b.price
            end
        end
    end
    return false
end

function GetFurnitureLabel(prop)
    for k,v in pairs(Config.Furniture) do
        for j,b in pairs (Config.Furniture[k].props) do
            if b.prop == prop then
                return b.label
            end
        end
    end
    return "Piece of Furniture"
end

function SumBasket(items)
    local sum = 0
    if items and #items > 0 then
        for i = 1, #items do
            sum = sum + (items[i]['qty'] * GetPropPrice(items[i]['prop']))
        end
    end

    return sum
end

function CountBasketItems(basket)
    local sum = 0
    if basket and #basket > 0 then
        for i = 1, #basket do
            sum = sum + basket[i]['qty']
        end
    end

    return sum
end

RegisterServerEvent('pw_properties:server:getThisHoldPiece')
AddEventHandler('pw_properties:server:getThisHoldPiece', function(data)
    local _src = source
    local _char = exports.pw_base:Source(_src):Character()
    if data.from == 'hold' then
        table.remove(data.meta, data.fid)
        if #data.meta == 0 then
            MySQL.Async.execute("DELETE FROM `furniture_hold` WHERE `cid` = @cid", {['@cid'] = _char.getCID() }, function()
                data.piece.placed = false
                data.piece.position = { ['x'] = 0.0, ['y'] = 0.0, ['z'] = 0.0, ['h'] = 0.0 }
                registeredProperties[data.house].addFurniture(data.piece)
            end)
        else
            MySQL.Async.execute("UPDATE `furniture_hold` SET `furniture` = @meta WHERE `cid` = @cid", {['@cid'] = _char.getCID(), ['@meta'] = json.encode(data.meta) }, function()
                data.piece.placed = false
                data.piece.position = { ['x'] = 0.0, ['y'] = 0.0, ['z'] = 0.0, ['h'] = 0.0 }
                registeredProperties[data.house].addFurniture(data.piece)
            end)
        end
    else
        registeredProperties[data.from].removeFurniture(data.fid)

        data.piece.placed = false
        data.piece.position = { ['x'] = 0.0, ['y'] = 0.0, ['z'] = 0.0, ['h'] = 0.0 }
        registeredProperties[data.house].addFurniture(data.piece)
    end
end)

RegisterServerEvent('pw_properties:server:toggleBroken')
AddEventHandler('pw_properties:server:toggleBroken', function(house, state)
    registeredProperties[house].toggleBroken(state)
end)

RegisterServerEvent('pw_properties:server:setPetAlert')
AddEventHandler('pw_properties:server:setPetAlert', function(owner, house, coords)
    local _src = source
    TriggerClientEvent('pw_pets:client:setPetAlert', owner, house, coords, _src)
end)

RegisterServerEvent('pw_properties:server:retrieveFurniture')
AddEventHandler('pw_properties:server:retrieveFurniture', function(house)
    local _src = source
    local _char = exports.pw_base:Source(_src):Character()
    local sendHold, sendProps = nil, {}
    local cid = _char.getCID()
    
    MySQL.Async.fetchScalar("SELECT `furniture` FROM `furniture_hold` WHERE `cid` = @cid", {['@cid'] = cid }, function(res)
        if res ~= nil then
            sendHold = res
        end
        local myProps = _char.myProperties()
        if myProps ~= nil and myProps[1] ~= nil then
            for k,v in pairs(myProps) do
                if house ~= v.property_id then
                    local furniture = registeredProperties[v.property_id].getFurniture()
                    for j,b in pairs(furniture) do
                        if b.buyer == cid then
                            table.insert(sendProps, v.property_id)
                            break
                        end
                    end
                end
            end
        end
        TriggerClientEvent('pw_properties:client:recieveRetrievedFurniture', _src, sendProps, house, sendHold)
    end)
end)

RegisterServerEvent('pw_base:itemUsed')
AddEventHandler('pw_base:itemUsed', function(_src, data)
    if data.item == "screwdriver" then
        TriggerClientEvent('pw_properties:usedScrewdriver', _src)
    end
end)

RegisterServerEvent('pw_properties:server:toggleRentRealEstate')
AddEventHandler('pw_properties:server:toggleRentRealEstate', function(data)
    registeredProperties[data.house].rentRealEstate(data.state)
end)

RegisterServerEvent('pw_properties:server:alertOwner')
AddEventHandler('pw_properties:server:alertOwner', function(owner, house)
    TriggerClientEvent('pw:notification:SendAlert', owner, { type = 'warning', text = "The alarm of the house you are staying at ("..registeredProperties[house].getName()..") was triggered!", length = 7000 })
end)

---------- // REAL ESTATE SHIT // ----------

RegisterServerEvent('pw_realestate:server:setSellValue')
AddEventHandler('pw_realestate:server:setSellValue', function(data)
    local _src = source

    local newPrice = tonumber(data.sellPrice.value)
    local basePrice = registeredProperties[tonumber(data.houseId.value)].getBasePrice()

    if newPrice >= basePrice * ((100 - Config.SellMargins) / 100) and newPrice <= basePrice * ((100 + Config.SellMargins) / 100) then
        registeredProperties[tonumber(data.houseId.value)].setSellPrice(newPrice, _src)
    end
end)

RegisterServerEvent('pw_realestate:server:usePaymentRent')
AddEventHandler('pw_realestate:server:usePaymentRent', function(data)
    local _src = source
    local _char = exports['pw_base']:Source(_src)

    if registeredProperties[data.house.houseID].getOwner() ~= 0 and registeredProperties[data.house.houseID].getRentor() == 0 then
        local houseCost = registeredProperties[data.house.houseID].getRentalCost() * 2
        if houseCost ~= data.house.cost then
            -- LOG: Tried exploit
        else
            if data.method == 'cash' then
                local charBalance = _char:Cash().getCash()
                if charBalance >= houseCost then
                    _char:Cash().Remove(houseCost)
                    RentHouse(_src, data.house.houseID, registeredProperties[data.house.houseID].getRentalCost())
                end
            elseif data.method == 'debit' then
                TriggerClientEvent('pw_debitcard:openPinTerminal', _src, 'pw_realestate:server:pinEnteredRent', 'server', { ['amount'] = houseCost, ['to'] = "Real Estate Agency", ['statement'] = 'Down payment of ' .. registeredProperties[data.house.houseID].getName() }, { ['data'] = data })
            end
        end
    end
end)

RegisterServerEvent('pw_realestate:server:pinEnteredRent')
AddEventHandler('pw_realestate:server:pinEnteredRent', function(data)
    RentHouse(data.data.buyer.source, data.data.house.houseID, registeredProperties[data.data.house.houseID].getRentalCost())
end)

RegisterServerEvent('pw_realestate:server:signedRentContract')
AddEventHandler('pw_realestate:server:signedRentContract', function(data)
    local buyer = data.info.data.buyer
    local agent = data.info.data.agent
    local house = data.info.data.property

    if data.contractReview.value then
        house.cost = registeredProperties[house.houseID].getRentalCost() * 2
        TriggerClientEvent('pw_realestate:client:showRentPayments', buyer.source, buyer, agent, house)
    else
        TriggerClientEvent('pw:notification:SendAlert', buyer.source, { type = 'error', text = 'You must sign the contract by ticking the box.', 5000 })
    end
end)

function RentHouse(src, id, cost)
    local _char = exports['pw_base']:Source(src)
    local house = registeredProperties[id]
    house.setRentPrice(cost)
    house.updateRent('deposit', 'add')
    house.updateStatus('rented')
    house.updateStatus('forRent')
    house.updateRentor(_char:Character().getCID())
    RetrieveFurnitureOnHold(tonumber(id), _char:Character().getCID())
    TriggerEvent('pw_keys:issueKey', 'Property', id, false, false, false, src)
end

RegisterServerEvent('pw_realestate:server:signedContract')
AddEventHandler('pw_realestate:server:signedContract', function(data)
    local buyer = data.info.data.buyer
    local agent = data.info.data.agent
    local house = data.info.data.property

    if data.contractReview.value then
        house.cost = registeredProperties[house.houseID].getPurchaseCost()
        TriggerClientEvent('pw_realestate:client:showPayments', buyer.source, buyer, agent, house)
    else
        TriggerClientEvent('pw:notification:SendAlert', buyer.source, { type = 'error', text = 'You must sign the contract by ticking the box.', 5000 })
    end
end)

RegisterServerEvent('pw_realestate:server:usePayment')
AddEventHandler('pw_realestate:server:usePayment', function(data)
    local _src = source
    local _char = exports['pw_base']:Source(_src)

    if registeredProperties[data.house.houseID].getOwner() == 0 and registeredProperties[data.house.houseID].getRentor() == 0 then
        local houseCost = registeredProperties[data.house.houseID].getPurchaseCost()
        if houseCost ~= data.house.cost then
            -- LOG: Tried exploit
        else
            if data.method == 'cash' then
                local charBalance = _char:Cash().getCash()
                if charBalance >= houseCost then
                    _char:Cash().Remove(houseCost)
                    AssignHouse(_src, data.house.houseID)
                end
            elseif data.method == 'debit' then
                TriggerClientEvent('pw_debitcard:openPinTerminal', _src, 'pw_realestate:server:pinEntered', 'server', { ['amount'] = houseCost, ['to'] = "Real Estate Agency", ['statement'] = 'Payment of ' .. registeredProperties[data.house.houseID].getName() }, { ['data'] = data })
            end
        end
    end
end)

RegisterServerEvent('pw_realestate:server:pinEntered')
AddEventHandler('pw_realestate:server:pinEntered', function(data)
    AssignHouse(data.data.buyer.source, data.data.house.houseID)
end)

function AssignHouse(src, id)
    local _char = exports['pw_base']:Source(src)
    local house = registeredProperties[id]
    house.updateOwner(_char:Character().getCID())
    house.updateRentor(0)
    TriggerEvent('pw_keys:issueKey', 'Property', id, false, false, false, src)
    if not house.getStatus('owned') then house.updateStatus('owned'); end
    if house.getStatus('rented') then house.updateStatus('rented'); end
end









---------------------------------------------

PW.RegisterServerCallback('pw_properties:server:sendHousesToRE', function(source, cb)
    repeat Wait(0) until propertiesLoaded == true
    cb(Houses)
end)

PW.RegisterServerCallback('pw_properties:server:checkOnlineProperty', function(source, cb, house)
    if registeredProperties[house].getStatus('rented') then
        local rentor = registeredProperties[house].getRentor()
        cb(exports.pw_base:checkOnline(rentor))
    elseif registeredProperties[house].getStatus('owned') then
        local owner = registeredProperties[house].getOwner()
        cb(exports.pw_base:checkOnline(owner))
    end
end)

PW.RegisterServerCallback('pw_properties:server:retrieveFurniturePlacesCb', function(source, cb, house)
    local _src = source
    
    MySQL.Async.fetchScalar("SELECT `furniture` FROM `furniture_hold` WHERE `cid` = @cid", {['@cid'] = cid }, function(res)
        local _char = exports.pw_base:Source(_src):Character()
        local sendHold, sendProps = nil, {}
        local cid = _char.getCID()
        if res ~= nil then
            sendHold = res
        end
        local myProps = _char.myProperties()
        if myProps ~= nil and myProps[1] ~= nil then
            for k,v in pairs(myProps) do
                if k ~= house then
                    local furniture = registeredProperties[v.property_id].getFurniture()
                    for j,b in pairs(furniture) do
                        if b.buyer == cid then
                            table.insert(sendProps, v.property_id)
                            break
                        end
                    end
                end
            end
            Wait(200)
            cb(sendHold, sendProps, true)
        else
            cb(sendHold, sendProps, false)
        end
    end)
end)

PW.RegisterServerCallback('pw_properties:server:getBothNames', function(source, cb, house)
    cb(registeredProperties[house].getOwnerName(), registeredProperties[house].getRentorName())
end)

PW.RegisterServerCallback('pw_properties:server:getRentor', function(source, cb, house)
    cb(registeredProperties[house].getRentorName())
end)

PW.RegisterServerCallback('pw_properties:server:getNearbyName', function(source, cb, id)
    local _char = exports.pw_base:Source(id):Character()
    if _char == nil then cb(false); end
    local name = _char.getName()
    if name ~= nil then
        cb(name)
    else
        cb(false)
    end
end)

exports.pw_chat:AddChatCommand('housemenu', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_properties:client:ownerMenuCheck', _src)
end, {
    help = "Your House Menu (Must be near house Menu Marker)",
    params = {}
}, -1)

exports.pw_chat:AddChatCommand('exit', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_properties:client:enterCheck', _src, "exit")
end, {
    help = "Exit a house",
    params = {}
}, -1)

exports.pw_chat:AddChatCommand('enter', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_properties:client:enterCheck', _src, "enter")
    TriggerClientEvent('pw_properties:client:rearenterCheck', _src, "enter")
    TriggerClientEvent('pw_motels:client:enterCheck', _src)
end, {
    help = "Enter a House or Motel Room",
    params = {}
}, -1)

exports.pw_chat:AddChatCommand('rent', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_properties:client:frontDoorRent', _src)
end, {
    help = "Access Tenancy Management",
    params = {}
}, -1)

exports.pw_chat:AddChatCommand('lock', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_properties:client:lockCheck', _src)
    TriggerClientEvent('pw_properties:client:rearlockCheck', _src)
end, {
    help = "Lock / Unlock house doors",
    params = {}
}, -1)

exports.pw_chat:AddChatCommand('knock', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_properties:client:knockDoor', _src, "front")
    TriggerClientEvent('pw_properties:client:knockDoor', _src, "back")
end, {
    help = "Knock on a Property Door",
    params = {}
}, -1)

exports.pw_chat:AddChatCommand('forceentry', function(source, args, rawCommand)
    local _src = source
    if args[1] ~= nil then
        local warrantId = tonumber(args[1])
        MySQL.Async.fetchScalar('SELECT `property_ids` FROM `police_warrants` WHERE `warrant_id` = @id AND `warrant_status` = "Active"', {['@id'] = warrantId }, function(propertyId)
            if propertyId then
                local sendIds = json.decode(propertyId)
                TriggerClientEvent('pw_properties:client:policeForceEntry', _src, warrantId, sendIds)
            end
        end)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You need to provide a valid Warrant ID'})
    end
end, {
    help = "Enter a House using a Search Warrant (Warrant ID must match property address.)",
    params = {{
        name = "Warrant Number",
        help = "The Warrant ID Number"
    }}
}, -1, { "police" } )

----------------------------------------
-- FOR DEV PURPOSES, DELETE WHEN RELEASE
----------------------------------------
exports.pw_chat:AddChatCommand('rentor', function(source, args, rawCommand)
    local _src = source
    local _char = exports.pw_base:Source(_src):Character()
    local house = registeredProperties[1]
    house.updateRentor(_char.getCID())
    house.updateOwner(3535644)
    if not house.getStatus('owned') then house.updateStatus('owned'); end
    if not house.getStatus('rented') then house.updateStatus('rented'); end
end, {
    help = "Set as rentor of house #1",
    params = {}
}, -1)

exports.pw_chat:AddChatCommand('checkfurn', function(source, args, rawCommand)
    local _src = source
    local _char = exports.pw_base:Source(_src):Character()
    RetrieveFurnitureOnHold(1, _char.getCID())
end, {
    help = "Set as rentor of house #1",
    params = {}
}, -1)

exports.pw_chat:AddChatCommand('owner', function(source, args, rawCommand)
    local _src = source
    local _char = exports.pw_base:Source(_src):Character()
    local house = registeredProperties[(tonumber(args[1]) or 1)]
    house.updateOwner(_char.getCID())
    house.updateRentor(3535644)
    TriggerEvent('pw_keys:issueKey', 'Property', (tonumber(args[1]) or 1), false, false, false, _src)
    if not house.getStatus('owned') then house.updateStatus('owned'); end
    if not house.getStatus('rented') then house.updateStatus('rented'); end
end, {
    help = "Set as owner of house #1",
    params = {}
}, -1)

exports.pw_chat:AddChatCommand('ownernorent', function(source, args, rawCommand)
    local _src = source
    local _char = exports.pw_base:Source(_src):Character()
    local house = registeredProperties[(tonumber(args[1]) or 1)]
    house.updateOwner(_char.getCID())
    house.updateRentor(0)
    TriggerEvent('pw_keys:issueKey', 'Property', (tonumber(args[1]) or 1), false, false, false, _src)
    if not house.getStatus('owned') then house.updateStatus('owned'); end
    if house.getStatus('rented') then house.updateStatus('rented'); end
end, {
    help = "Set as owner of house #1",
    params = {}
}, -1)

exports.pw_chat:AddChatCommand('rowner', function(source, args, rawCommand)
    local _src = source
    local _char = exports.pw_base:Source(_src):Character()
    local house = registeredProperties[(tonumber(args[1]) or 1)]
    house.updateOwner(0)
    house.updateRentor(0)
    if not house.getStatus('owned') then house.updateStatus('owned'); end
    if not house.getStatus('rented') then house.updateStatus('rented'); end
end, {
    help = "Set as owner of house #1",
    params = {}
}, -1)

-------------------------------------