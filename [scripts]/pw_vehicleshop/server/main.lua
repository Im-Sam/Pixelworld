local displayedVeh, chosenVehicle = 0, nil
local activeFinances = {}
local testDriveDeposit = {}

MySQL.ready(function ()
    local vehCount = 0
    local catCount = 0
    MySQL.Async.fetchAll("SELECT * FROM `vehicle_categories` WHERE `name` != 'custom'", {}, function(categorys)
        for i = 1, #categorys do
            vehicles[categorys[i].name] = { ['name'] = categorys[i].name, ['label'] = categorys[i].label }
            vehicles[categorys[i].name].vehicles = {}
            local vegPro = false
            MySQL.Async.fetchAll("SELECT * FROM `avaliable_vehicles` WHERE `category` = @cat ORDER BY `name` ASC", { ['@cat'] = categorys[i].name }, function(veh)
                for j = 1, #veh do
                    vehicles[categorys[i].name].vehicles[veh[j].model] = veh[j]
                    vehCount = vehCount + 1
                end
                catCount = catCount + 1
                vegPro = true
            end)
            repeat Wait(0) until vegPro == true
        end
        print(' ^1[PixelWorld Vehicles] ^3- We have loaded ^4'..vehCount..' ^3vehicles in ^5'..catCount..'^3 different vehicle categories.')
        MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles`", {}, function(vehs)
            for k, v in pairs(vehs) do
                registeredVehicles[v.vin] = loadVehicle(v.vin)
            end

            MySQL.Async.fetchAll("SELECT * FROM `vehicle_financing`", {}, function(res)
                if #res > 0 then
                    for i = 1, #res do
                        table.insert(activeFinances, res[i])
                    end
                    print(' ^1[PixelWorld Vehicles] ^3- We have loaded ^4'..#res..' ^3vehicle financing contracts.')
                end
                StartPayments()

                MySQL.Async.fetchScalar("SELECT `settings` FROM `config` WHERE `resource` = 'cardealer'", {}, function(res)
                    if res then
                        local Settings = json.decode(res)
                        for k, v in pairs(Settings) do
                            Config.MySQL[k] = v
                        end
                    else
                        local sendMeta = json.encode(Config.MySQL)
                        MySQL.Async.execute("UPDATE `config` SET `settings` = @meta WHERE `resource` = 'cardealer'", {['@meta'] = sendMeta})
                    end
                    exports.pw_banking:createBuisnessAccount('cardealer', 1)
                    processed = true
                end)
            end)
        end)
    end)
end)


function StartPayments()
    for i = 0, 59 do
        TriggerEvent('cron:runAt', 21, i, PaymentDue)
    end
end

function getVehicleByPlate(plate)
    for k, v in pairs(registeredVehicles) do
        if v.getCurrentPlate() == plate then
            return k
        end
    end
    return nil
end

function loadVehicleByPlate(plate)
    for k, v in pairs(registeredVehicles) do
        if v.getCurrentPlate() == plate then
            return v
        end
    end
    return nil
end

exports('loadVehicleByPlate', function(plate)
    for k, v in pairs(registeredVehicles) do
        if v.getCurrentPlate() == plate then
            return v
        end
    end
    
    return nil
end)

exports('loadVehicleByVin', function(vin)
    if registeredVehicles[vin] then 
        return registeredVehicles[vin]
    else
        return nil
    end
end)

RegisterServerEvent('baseevents:enteringVehicle')
AddEventHandler('baseevents:enteringVehicle', function(veh, one, two, network)
    local _src = source
    TriggerClientEvent('pw_vehicleshop:client:enteringVehicle', _src, veh, network)
end)

RegisterServerEvent('pw_vehicleshop:server:decideToRegisterVehicle')
AddEventHandler('pw_vehicleshop:server:decideToRegisterVehicle', function(properties, veh, net)
    local _src = source
    local _vehicle = getVehicleByPlate(properties.plate)
    if _vehicle == nil then
        createTemporaryVehicle(properties)
        _vehicle = getVehicleByPlate(properties.plate)
    end
    repeat Wait(0) until _vehicle ~= nil 

    TriggerClientEvent('pw_vehicleshop:client:setDecor', _src, veh, "pw_veh_playerOwned", registeredVehicles[_vehicle].getVehicleStatus(), "bool") 
end)

PW.RegisterServerCallback('pw_vehicleshop:server:registerPotentialVin', function(source, cb, props, veh)
    local _src = source
    local _vehicle = getVehicleByPlate(props.plate)
    if _vehicle == nil then
        createTemporaryVehicle(props)
        _vehicle = getVehicleByPlate(props.plate)
    end
    repeat Wait(0) until _vehicle ~= nil 
    TriggerClientEvent('pw_vehicleshop:client:setDecor', _src, veh, "pw_veh_playerOwned", registeredVehicles[_vehicle].getVehicleStatus(), "bool") 
    cb(_vehicle)
end)

exports('getVehicles', function()
    return registeredVehicles
end)

exports('getVehicleByPlate', function(plate)
    return getVehicleByPlate(plate)
end)

PW.RegisterServerCallback('pw_vehicleshop:server:requestConfig', function(source, cb)
    cb(Config)
end)

PW.RegisterServerCallback('pw_vehicleshop:server:getDisplayed', function(source, cb)
    local _src = source
    cb(displayedVeh, chosenVehicle)
end)

RegisterServerEvent('pw_vehicleshop:server:updateDisplayed')
AddEventHandler('pw_vehicleshop:server:updateDisplayed', function(obj, chosen)
    displayedVeh = obj
    chosenVehicle = chosen
    TriggerClientEvent('pw_vehicleshop:client:updateDisplayed', -1, displayedVeh, chosenVehicle)
end)

RegisterServerEvent('pw_vehicleshop:server:newModel')
AddEventHandler('pw_vehicleshop:server:newModel', function(spot, pos, price, props)
    TriggerClientEvent('pw_vehicleshop:client:newModel', -1, spot, pos, price, props)
end)

RegisterServerEvent('pw_vehicleshop:server:getShowroom')
AddEventHandler('pw_vehicleshop:server:getShowroom', function()
    local _src = source
    MySQL.Async.fetchAll('SELECT * FROM `showroom_vehicles`', {}, function(res)
        TriggerClientEvent('pw_vehicleshop:client:spawnShowroomVehs', _src, res)
    end)
end)

PW.RegisterServerCallback('pw_vehicleshop:server:checkOwnedVehicle', function(source, cb, plate)
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE `plate` = @plate", {['@plate'] = plate}, function(res)
        if res[1] ~= nil then
            cb(true)
        else
            cb(false)
        end
    end)
end)

RegisterServerEvent('pw_vehicleshop:server:storeVehicle')
AddEventHandler('pw_vehicleshop:server:storeVehicle', function(plate, vehinfo)
    if plate ~= nil then
        local vin = getVehicleByPlate(plate)
        if registeredVehicles[vin] then
            registeredVehicles[vin].SetVehicleProperties(vehinfo)
            registeredVehicles[vin] = nil
        end
    end
end)

exports('getVehicle', function(plate)
    local vin = getVehicleByPlate(plate)
    if registeredVehicles[vin] then
        return registeredVehicles[vin]
    else
        return false
    end
end)

exports('getVehicleByVin', function(vin)
    if registeredVehicles[vin] then
        return registeredVehicles[vin]
    else
        return false
    end
end)

RegisterServerEvent('pw_vehicleshop:toggleSignOn')
AddEventHandler('pw_vehicleshop:toggleSignOn', function(toggle)
    local _src = source
    local _char = exports.pw_base:Source(_src)
    _char:Job().toggleDuty()
end)

RegisterServerEvent('pw_vehicleshop:server:processPriceShowroom')
AddEventHandler('pw_vehicleshop:server:processPriceShowroom', function(data)
    local _src = source
    local spot = tonumber(data.veh.data.veh.spot)
    local oldPrice = tonumber(data.veh.data.veh.price)
    local defaultPrice = tonumber(data.veh.data.veh.defaultPrice)
    local inputedPrice = tonumber(data.price.value)
    local min = math.floor(defaultPrice * ((100 - Config.MySQL.Margin) / 100))
    local max = math.floor(defaultPrice * ((100 + Config.MySQL.Margin) / 100))
    if inputedPrice >= min and inputedPrice <= max then
        data.veh.data.veh.price = inputedPrice
        MySQL.Async.execute('UPDATE `showroom_vehicles` SET `price` = @price WHERE `spot` = @spot', {['@price'] = inputedPrice, ['@spot'] = spot }, function()
            TriggerClientEvent('pw_vehicleshop:client:updatePriceShowroom', -1, inputedPrice, spot, _src, data.veh.data.veh)
        end)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'Your set price exceeds the margin'})
        TriggerClientEvent('pw_vehicleshop:client:modifyPriceForm', _src)
    end
end)

RegisterServerEvent('pw_vehicleshop:server:processPrice')
AddEventHandler('pw_vehicleshop:server:processPrice', function(data)
    local _src = source

    local oldPrice = tonumber(data.veh.data.veh.price)
    local defaultPrice = tonumber(data.veh.data.veh.defaultPrice)
    local inputedPrice = tonumber(data.price.value)
    local min = math.floor(defaultPrice * ((100 - Config.MySQL.Margin) / 100))
    local max = math.floor(defaultPrice * ((100 + Config.MySQL.Margin) / 100))
    if inputedPrice >= min and inputedPrice <= max then
        TriggerClientEvent('pw_vehicleshop:client:updatePrice', _src, inputedPrice)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'Your set price exceeds the margin'})
        TriggerClientEvent('pw_vehicleshop:client:modifyPriceForm', _src)
    end
end)

function CheckStock(model)
    local result
    local processed = false
    MySQL.Async.fetchAll('SELECT * FROM `avaliable_vehicles` WHERE `model` = @model', {['@model'] = model}, function(res)
        result = res
        processed = true
    end)
    repeat Wait(0) until processed == true
    return (result[1].maxStock - result[1].sold)
end

RegisterServerEvent('pw_vehicleshop:server:pullPaymentType')
AddEventHandler('pw_vehicleshop:server:pullPaymentType', function(data, spawn)
    local _char = exports.pw_base:Source(data.target)
    local jobData = _char:Job():getJob().grade
    if jobData == "boss" then
        TriggerClientEvent('pw_vehicleshop:client:pullVehicleUse', data.target, data, spawn) -- data.target
    else
        TriggerClientEvent('pw_vehicleshop:client:pullPaymentType', data.target, data, spawn) --data.target
    end
end)

RegisterServerEvent('pw_vehicleshop:server:paymentType')
AddEventHandler('pw_vehicleshop:server:paymentType', function(data)
    local _src = source
    local _char = exports.pw_base:Source(_src)
    local veh = data.data.veh
    if CheckStock(veh.model) > 0 then
        bank = exports.pw_banking:buisness('cardealer', 1)
        local curBalance = bank.getBalance()
        local dealerCarCost = veh.defaultPrice * (Config.MySQL.DealershipBuyMargin / 100)
        if curBalance >= dealerCarCost then
            if data.type == 'cash' then
                local curMoney = _char:Cash().getCash()
                if curMoney >= veh.price then
                    _char:Cash().Remove(veh.price)
                    bank.deductBalance(dealerCarCost, 'Purchase of a '..veh.name)
                    bank.addBalance(veh.price, 'Selling of a '..veh.name)
                    local dealerProfit = ((veh.price - (veh.defaultPrice * (Config.MySQL.DealershipBuyMargin / 100))) * (Config.MySQL.DealerMargin / 100)) 
                    _dealer = exports.pw_base:Source(data.data.dealer)
                    bank.deductBalance(dealerProfit, 'Commission for '.._dealer:Character():getName() .. ' for selling a '..veh.name)
                    _dealer:Cash().Add(dealerProfit)
                    TriggerClientEvent('pw_vehicleshop:client:deleteDisplayed', data.data.dealer)
                    TriggerEvent('pw_vehicleshop:server:registerThis', data.data.props, 'cash', data.data.props.color1, veh.model, _src, data.spawn, _dealer:Character().getCID(), veh.price, data.use)
                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'success', text = 'Transaction successful'})
                else
                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'Not enough cash in your pocket'})
                end
            elseif data.type == 'debit' then
                data.src = _src
                TriggerClientEvent('pw_debitcard:openPinTerminal', _src, 'pw_vehicleshop:server:pinEntered', 'server', { ['amount'] = veh.price, ['to'] = "Car Dealership", ['statement'] = 'Purchase of '..veh.name.. ' from Dealership' }, { ['data'] = data})
            end
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'Transaction failed'})
            TriggerClientEvent('pw:notification:SendAlert', data.data.dealer, {type = 'error', text = 'Your business account hasn\'t enough money for purchasing the car' })
        end
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'There are no more available units of that model'})
    end
end)

RegisterServerEvent('pw_vehicleshop:server:pinEntered')
AddEventHandler('pw_vehicleshop:server:pinEntered', function(data)
    local _src = source
    local veh = data.data.data.veh
    bank = exports.pw_banking:buisness('cardealer', 1)
    bank.deductBalance(dealerCarCost, 'Purchase of '..veh.name)
    bank.addBalance(veh.price, 'Selling of '..veh.name)

    local dealerProfit = ((veh.price - (veh.defaultPrice * (Config.MySQL.DealershipBuyMargin / 100))) * (Config.MySQL.DealerMargin / 100)) 
    _dealer = exports.pw_base:Source(data.data.data.dealer)
    bank.deductBalance(dealerProfit, 'Commission for '.._dealer:Character().getName() .. ' for selling a '..veh.name)
    _dealer:Cash().Add(dealerProfit)

    TriggerClientEvent('pw_vehicleshop:client:deleteDisplayed', data.data.data.dealer)
    TriggerEvent('pw_vehicleshop:server:registerThis', data.data.data.props, 'debit', data.data.data.props.color1, veh.model, data.data.src, data.data.spawn, _dealer:Character().getCID(), veh.price, data.data.use)
end)

RegisterServerEvent('pw_vehicleshop:server:downPaymentPaid')
AddEventHandler('pw_vehicleshop:server:downPaymentPaid', function(data)
    local _src = source
    local _char = exports.pw_base:Source(_src)
    local res = data.data.veh.data
    local veh = res.veh
    local props = res.props
    
    bank = exports.pw_banking:buisness('cardealer', 1)
    local curBalance = bank.getBalance()
    local dealerCarCost = veh.defaultPrice * (Config.MySQL.DealershipBuyMargin / 100)
    if curBalance >= dealerCarCost then
        bank.deductBalance(dealerCarCost, 'Purchase of a '..veh.name)
        bank.addBalance(res.downPayment, 'Down Payment of a '..veh.name..' made by '.._char:Character().getName())
        _dealer = exports.pw_base:Source(res.dealer)
        local dealerProfit = ((veh.price - (veh.defaultPrice * (Config.MySQL.DealershipBuyMargin / 100))) * (Config.MySQL.DealerMargin) / 100) 
        bank.deductBalance(dealerProfit, 'Commission for '.._dealer:Character():getName() .. ' for selling a '..veh.name)
        _dealer:Cash().Add(dealerProfit)
        TriggerClientEvent('pw_vehicleshop:client:deleteDisplayed', res.dealer)
        TriggerEvent('pw_vehicleshop:server:registerThis', props, 'finance', props.color1, veh.model, _src, res.spawn, _dealer.GetCID(), res.total, res.use)
        
        StartFinance(props.plate, _char:Character().getCID(), res.weeks, res.total, res.cost, res.downPayment, _src)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'Transaction failed'})
        TriggerClientEvent('pw:notification:SendAlert', res.dealer, {type = 'error', text = 'Your business account hasn\'t enough money for purchasing the car' })
    end
end)

function PaymentDue(d, h, m)
    if #activeFinances == 0 then return; end
    for i = 1, #activeFinances do
        local statusOwner = exports.pw_base:checkOnline(activeFinances[i].cid)
        if activeFinances[i].remainingWeeks == 0 then
            if activeFinances[i].failedPayments > 0 then
                TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = 'error', text = 'The vehicle with the plate '..activeFinances[i].plate.. ' is flagged for Repossession for failing to make payments on legal terms', length = 6000})
            else
                MySQL.Async.execute('DELETE FROM `vehicle_financing` WHERE `plate` = @plate', {['@plate'] = activeFinances[i].plate}, function()
                    table.remove(activeFinances, i)
                    registeredVehicles[activeFinances[i].plate] = loadVehicle(activeFinances[i].plate)
                    registeredVehicles[activeFinances[i].plate].UpdateMeta('paid', true)
                end)
                if statusOwner then
                    TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = 'inform', text = 'Your financing period has ended and your debt is now fully paid for the vehicle with the plate '..activeFinances[i].plate})
                end
            end
        else
            local status
            if statusOwner then
                local _char = exports.pw_base:Source(statusOwner)
                local curBank = _char:Bank():getBalance()
                if curBank >= activeFinances[i].weeklyCost then
                    _char:Bank().Remove(activeFinances[i].weeklyCost, 'Weekly financing payment for the plate '..activeFinances[i].plate)
                    status = true
                else
                    status = false
                end
            else
                local playerBank = exports.pw_banking:current(activeFinances[i].cid)

                if playerBank.GetBalance() >= activeFinances[i].weeklyCost then
                    playerBank.RemoveMoney(amount, 'Weekly financing payment for the plate '..activeFinances[i].plate)
                    status = true
                else
                    status = false
                end
            end

            if status then
                MySQL.Async.execute('UPDATE `vehicle_financing` SET `remainingWeeks` = `remainingWeeks` - 1, `amountLeft` = `amountLeft` - `weeklyCost` WHERE `plate` = @plate', {['@plate'] = activeFinances[i].plate}, function()
                    activeFinances[i].remainingWeeks = activeFinances[i].remainingWeeks - 1
                    activeFinances[i].amountLeft = activeFinances[i].amountLeft - activeFinances[i].weeklyCost
                    if statusOwner then
                        TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = 'inform', text = 'The weekly payment for your vehicle with the plate '..activeFinances[i].plate..' has been deducted from your bank account', length = 10000})
                        TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = 'inform', text = 'Status: '..(activeFinances[i].period - activeFinances[i].remainingWeeks)..'/'..activeFinances[i].period..' weeks | Amount left: $'..math.floor(activeFinances[i].amountLeft), length = 12500})
                        TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = 'error', text = 'Failed payments: '..activeFinances[i].failedPayments, length = 15000})
                    end
                end)
            else
                MySQL.Async.execute('UPDATE `vehicle_financing` SET `remainingWeeks` = `remainingWeeks` - 1, `failedPayments` = `failedPayments` + 1 WHERE `plate` = @plate', {['@plate'] = activeFinances[i].plate}, function()
                    activeFinances[i].remainingWeeks = activeFinances[i].remainingWeeks - 1
                    activeFinances[i].failedPayments = activeFinances[i].failedPayments + 1
                    if statusOwner then
                        TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = 'error', text = 'Failed to process the payment of your weekly financing obligations for the vehicle with the plate '..activeFinances[i].plate, length = 10000})
                        TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = 'inform', text = 'Status: '..activeFinances[i].remainingWeeks..'/'..activeFinances[i].period..' weeks | Amount left: $'..math.floor(activeFinances[i].amountLeft), length = 12500})
                        TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = 'error', text = 'Failed payments: '..activeFinances[i].failedPayments, length = 15000})
                    end
                end)
            end
        end
    end
end

function StartFinance(plate, ownerCid, period, total, weeklyCost, downPayment, _src)
    MySQL.Async.insert('INSERT INTO `vehicle_financing` (plate, cid, period, remainingWeeks, totalAmount, amountLeft, weeklyCost, failedPayments) VALUES (@plate, @ownerCid, @period, @period, @total, @left, @weeklyCost, 0)', 
    {   ['@plate'] = plate,
        ['@ownerCid'] = ownerCid,
        ['@period'] = period,
        ['@total'] = total,
        ['@left'] = total - downPayment,
        ['@weeklyCost'] = weeklyCost
    }, function()
        table.insert(activeFinances, { ['plate'] = plate, ['cid'] = ownerCid, ['period'] = period, ['remainingWeeks'] = period, ['totalAmount'] = total, ['amountLeft'] = total - downPayment, ['weeklyCost'] = weeklyCost, ['failedPayments'] = 0 })
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'Your financing period of '..period..' weeks has started. Make sure you have the money in your bank account by the time we deduct the weekly expenses.', length = 10000})
    end)
end

RegisterServerEvent('pw_vehicleshop:server:financeAgreed')
AddEventHandler('pw_vehicleshop:server:financeAgreed', function(data)
    local _src = source
    if data.contractReview.value then
        if CheckStock(data.veh.data.veh.model) > 0 then
            TriggerClientEvent('pw_debitcard:openPinTerminal', _src, 'pw_vehicleshop:server:downPaymentPaid', 'server', { ['amount'] = data.veh.data.downPayment, ['to'] = "Car Dealership", ['statement'] = 'Down Payment of a '..data.veh.data.veh.name }, { ['data'] = data })
        else
            TriggerClientEvent('pw:notification:SendAlert', data.veh.data.dealer, {type = 'error', text = 'There are no more available units of that model'})
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'There are no more available units of that model'})
        end
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You must agree to the terms by ticking the checkbox'})
    end
end)

RegisterServerEvent('pw_vehicleshop:server:calculateFinance')
AddEventHandler('pw_vehicleshop:server:calculateFinance', function(data)
    local _src = source
    local veh = data.veh.data.data.veh
    local dealer = data.veh.data.data.dealer
    local weeks = tonumber(data.weeks.value)
    local totalAmount = veh.price * ((100+Config.MySQL.FinancingMargin) / 100)
    local downPayment = math.floor(totalAmount * (Config.MySQL.Downpayment / 100))
    local weeklyCost = math.floor((totalAmount - downPayment) / weeks)

    TriggerClientEvent('pw_vehicleshop:client:sendFinance', _src, weeks, totalAmount, weeklyCost, downPayment, data.veh.data.data, dealer, data.veh.data.spawn, data.veh.data.use)
end)

RegisterServerEvent('pw_vehicleshop:server:registerThis')
AddEventHandler('pw_vehicleshop:server:registerThis', function(vehProps, method, color, model, source, spawn, dealer, price, use)
    local _src = source
    local _char = exports.pw_base:Source(_src)
    local sendMeta = {  ['owner'] = (use == 'Personal' and _char:Character():getCID() or use), ['originalColor'] = color, ['purchaseDate'] = os.date('%c'), ['model'] = model, ['price'] = price,
                        ['paid'] = ((method == 'cash' or method == 'debit') and true or false), ['paymentMethod'] = method, ['soldBy'] = dealer
                    }
    registerVehicle(vehProps, sendMeta, use, _src)
    TriggerClientEvent('pw_vehicleshop:client:vehicleSold', _src, model, vehProps, spawn)
end)

RegisterServerEvent('pw_vehicleshop:server:registerSpot')
AddEventHandler('pw_vehicleshop:server:registerSpot', function(spot, props, price)
    local _src = source
    local props = json.encode(props)
    MySQL.Async.execute('UPDATE `showroom_vehicles` SET `vehicle` = @vehProps, `price` = @price, `defaultPrice` = @price WHERE `spot` = @spot', {['@vehProps'] = props, ['@price'] = price, ['spot'] = spot }, function()
        TriggerClientEvent('pw_vehicleshop:client:addedSpot', _src, spot, props, price)
    end)
end)

RegisterServerEvent('pw_vehicleshop:server:removeShowroom')
AddEventHandler('pw_vehicleshop:server:removeShowroom', function(spot)
    local _src = source
    MySQL.Async.execute('UPDATE `showroom_vehicles` SET `vehicle` = NULL, `price` = 0 WHERE `spot` = @spot', {['@spot'] = spot}, function()
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'Vehicle removed from showroom spot #'..spot})
        TriggerClientEvent('pw_vehicleshop:client:deleteShowroom', -1, spot)
    end)
end)

RegisterServerEvent('pw_vehicleshop:server:updateSpotProps')
AddEventHandler('pw_vehicleshop:server:updateSpotProps', function(spot, props)
    local _src = source
    local jProps = json.encode(props)
    MySQL.Async.execute('UPDATE `showroom_vehicles` SET `vehicle` = @props WHERE `spot` = @spot', {['@props'] = jProps, ['@spot'] = spot }, function()
        TriggerClientEvent('pw_vehicleshop:client:updateColorShowroom', -1, spot, props)
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'Vehicle color changed successfully'})
    end)
end)

RegisterServerEvent('pw_vehicleshop:server:sendMargin')
AddEventHandler('pw_vehicleshop:server:sendMargin', function(data)
    local _src = source
    local type = data.margin.value
    if type == 'FinanceWeeks' then
        Config.MySQL.FinanceWeeks = { tonumber(data.week1.value), tonumber(data.week2.value), tonumber(data.week3.value) }
    else
        Config.MySQL[type] = tonumber(data.range.value)
    end
    UpdateSettings(_src, 'margins')
    
end)

RegisterServerEvent('pw_vehicleshop:server:contractSigned')
AddEventHandler('pw_vehicleshop:server:contractSigned', function(res)
    local _src = source
    local _char = exports.pw_base:Source(_src)
    _char:Job().setJob('cardealer', tonumber(res.grade.value))
    TriggerClientEvent('pw:notification:SendAlert', tonumber(res.bossSrc.value), {type = 'inform', text = _char:Character().getName() .. " signed the contract and is now one of your employees"})
end)

RegisterServerEvent('pw_vehicleshop:server:sendContractForm')
AddEventHandler('pw_vehicleshop:server:sendContractForm', function(res)
    local target = tonumber(res.target.value)
    local salary = tonumber(res.salary.value)
    local grade = tonumber(res.grade.value)
    local bossSrc = tonumber(res.bossSrc.value)
    local formCopy = res.formCopy.data
    TriggerClientEvent('pw_vehicleshop:client:sendContractForm', target, formCopy, salary, grade, bossSrc)
end)

RegisterServerEvent('pw_vehicleshop:server:setNewSalary')
AddEventHandler('pw_vehicleshop:server:setNewSalary', function(data)
    local _src = source
    local statusEmployee = exports.pw_base:checkOnline(data.data.data.cid)
    local _char
    if statusEmployee then
        _char = exports.pw_base:Source(statusEmployee)
    else
        _char = exports.pw_base:Offline(data.data.data.cid)
    end
    _char:Job().setJob('cardealer', _char:Job().getJob().grade, tonumber(data.range.value))
    local raise = tonumber(data.range.value) - data.data.data.job.wages
    if raise > 0 then
        if statusEmployee then
            TriggerClientEvent('pw:notification:SendAlert', statusEmployee, {type = 'inform', text = 'You received a $'..raise..' raise! (New salary: $'..tonumber(data.range.value)..')'})
        end
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You raised '.. data.data.data.name ..'\'s salary to $'..tonumber(data.range.value)})
    else
        if statusEmployee then
            TriggerClientEvent('pw:notification:SendAlert', statusEmployee, {type = 'inform', text = 'Your salary was lowered by $'..(raise * -1)..' (New salary: $'..tonumber(data.range.value)..')'})
        end
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You lowered '.. data.data.data.name ..'\'s salary to $'..tonumber(data.range.value)})
    end
end)

RegisterServerEvent('pw_vehicleshop:server:setNewGrade')
AddEventHandler('pw_vehicleshop:server:setNewGrade', function(data)
    local _src = source
    local statusEmployee = exports.pw_base:checkOnline(data.data.data.result.cid)
    local _char
    if statusEmployee then
        _char = exports.pw_base:Source(statusEmployee)
    else
        _char = exports.pw_base:Offline(data.data.data.result.cid)
    end
    --local grades = json.decode(data.data.data.grades[1].grades)
    local gradeName
    
    for k, v in pairs(data.data.data.grades) do
        if v.grade == data.grades.value then
            gradeName = v.label
        end
    end    
    _char:Job().setJob('cardealer', data.grades.value)
    if statusEmployee then
        TriggerClientEvent('pw:notification:SendAlert', statusEmployee, {type = 'inform', text = 'You were promoted/demoted to '..gradeName})
    end
    TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You promoted/demoted '.. data.data.data.result.name ..' to '..gradeName})
end)

RegisterServerEvent('pw_vehicleshop:server:fireStaff')
AddEventHandler('pw_vehicleshop:server:fireStaff', function(data)
    local _src = source
    local pSrc = exports.pw_base:checkOnline(data.data.data.cid)
    local _char
    if pSrc > 0 then
        _char = exports.pw_base:Source(pSrc)
    else
        _char = exports.pw_base:getOfflineCharacter(data.data.data.cid)
    end
    if data.fire.value then
        _char:Job().setJob("unemployed", "unemployed")
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You have fired '..data.data.data.name})
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You have to sign the contract termination form'})
    end
end)

RegisterServerEvent('pw_vehicleshop:server:updateTestDriveTimer')
AddEventHandler('pw_vehicleshop:server:updateTestDriveTimer', function(data)
    local _src = source
    Config.MySQL.TestDriveTimer = tonumber(data.range.value)
    UpdateSettings(_src, 'boss')
end)

RegisterServerEvent('pw_vehicleshop:server:returnTestDriveDeposit')
AddEventHandler('pw_vehicleshop:server:returnTestDriveDeposit', function(props)
    local _src = source
    local _char = exports.pw_base:Source(_src)
    local totalDamage = math.abs(2000 - props.bodyHealth - props.engineHealth) / 2000
    local depositToReturn, overDamage
    if totalDamage > 0.10 then
        depositToReturn = math.ceil(testDriveDeposit[_src] * (1-totalDamage))
        overDamage = true
    else
        depositToReturn = testDriveDeposit[_src]
    end
    _char:Cash().Add(depositToReturn)
    testDriveDeposit[_src] = 0
    if overDamage then
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You delivered the car with '..(math.ceil(totalDamage * 100))..'% of damage', length = 6000})
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You received $'..depositToReturn..' back (' .. (math.floor((1-totalDamage) * 100))..'% of your deposit)', length = 6000})
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You delivered the car with less than 10% of damage', length = 6000})
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You received $'..depositToReturn..' back (full deposit)', length = 6000})
    end
end)

RegisterServerEvent('pw_vehicleshop:server:resetTestDriveDeposit')
AddEventHandler('pw_vehicleshop:server:resetTestDriveDeposit', function()
    local _src = source
    testDriveDeposit[_src] = 0
end)

function UpdateSettings(_src, menu)
    local sendMeta = json.encode(Config.MySQL)
    MySQL.Async.execute("UPDATE `config` SET `settings` = @meta WHERE `resource` = 'cardealer'", {['@meta'] = sendMeta}, function()
        TriggerClientEvent('pw_vehicleshop:client:updateConfig', -1, Config)
        if _src then
            if menu == 'margins' then
                TriggerClientEvent('pw_vehicleshop:client:openMargins', _src)
            elseif menu == 'boss' then
                TriggerClientEvent('pw_vehicleshop:bossMenu', _src)
            end
        end
    end)
end

PW.RegisterServerCallback('pw_vehicleshop:server:checkMoneyForTestDrive', function(source, cb, data)
    local _src = source
    local _char = exports.pw_base:Source(_src)
    local cost = tonumber(data.price)
    if cost > 0 then
        local maths = cost * 0.01
        local calcCost = (maths > 500 and math.ceil(maths) or 500)
        testDriveDeposit[_src] = calcCost
        if _char:Cash().getCash() >= testDriveDeposit[_src] then
            _char:Cash().Remove(testDriveDeposit[_src])
            cb(true, testDriveDeposit[_src])
        else
            testDriveDeposit[_src] = 0
            cb(false, calcCost)
        end
    end
end)

PW.RegisterServerCallback('pw_vehicleshop:server:getSalary', function(source, cb, id)
    local statusId = exports.pw_base:checkOnline(id)
    local _char
    if statusId then
        _char = exports.pw_base:Source(statusId)
    else
        _char = exports.pw_base:Offline(id)
    end
    cb(_char:Job().getJob().salery)
end)

PW.RegisterServerCallback('pw_vehicleshop:server:getStaff', function(source, cb)
    local staffList = exports.pw_base:getStaff('cardealer')
    cb(staffList)
end)

PW.RegisterServerCallback('pw_vehicleshop:server:getGrades', function(source, cb)
    MySQL.Async.fetchAll("SELECT * FROM `avaliable_jobs` WHERE `job_name` = 'cardealer'", {}, function(res)
        cb(res)
    end)
end)

PW.RegisterServerCallback('pw_vehicleshop:server:getNearbyName', function(source, cb, id)
    local _char = exports.pw_base:Source(id)
    if _char == nil then cb(false); end
    local name = _char:Character().getName()
    if name ~= nil then
        cb(name)
    else
        cb(false)
    end
end)

PW.RegisterServerCallback('pw_vehicleshop:server:currentShowroom', function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM `showroom_vehicles`', {}, function(res)
        cb(res)
    end)
end)

PW.RegisterServerCallback('pw_vehicleshop:server:requestVehicles', function(source, cb)
    cb(vehicles)
end)

PW.RegisterServerCallback('pw_vehicleshop:server:checkEnoughMoney', function(source, cb, money)
    local _src = source
    local _char = exports.pw_base:Source(_src)
    if _char:Cash().getCash() >= money then
        cb(true)
    else
        cb(false)
    end
end)

exports('vehicleMakes', function(model)
    for k, v in pairs(Config.Makes) do
        for meh, teh in pairs(v) do
            if string.lower(teh) == string.lower(model) then
                return k
            end
        end
    end
    return nil    
end)