PW = nil
characterLoaded, playerData = false, nil
Houses = {}
Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(data)
    PW.TriggerServerCallback('pw_properties:server:sendHousesToRE', function(housesTable)
        Houses = housesTable
        playerData = data
        characterLoaded = true
    end)
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    characterLoaded = false
    playerData = nil
end)

RegisterNetEvent('pw:setJob')
AddEventHandler('pw:setJob', function(data)
    if characterLoaded and playerData then
        playerData.job = data
    end
end)

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
    if playerData then
        playerData.job.duty = toggle
    end
end)

RegisterNetEvent('pw_properties:client:setSellPrice')
AddEventHandler('pw_properties:client:setSellPrice', function(house, price)
    Houses[house].price = price
end)

RegisterNetEvent('pw_realestate:client:propertySettings')
AddEventHandler('pw_realestate:client:propertySettings', function(house)
    HouseMenu(house)
end)

RegisterNetEvent('pw_realestate:client:setSellValue')
AddEventHandler('pw_realestate:client:setSellValue', function(house)
    local form = {
        { ['type'] = "range", ['label'] = "Current: <b><span class='text-primary'>$".. Houses[house].price .."</span></b><br>Min: <b><span class='text-success'>$" .. math.ceil(Houses[house].basePrice * 0.80) .. "</span></b><br>Max: <b><span class='text-success'>$" .. math.ceil(Houses[house].basePrice * 1.20) .. "</span>", ['default'] = Houses[house].price, ['min'] = math.ceil(Houses[house].basePrice * 0.80), ['max'] = math.ceil(Houses[house].basePrice * 1.20), ['name'] = 'sellPrice', ['step'] = 100, ['suffix'] = "$" },
        { ['type'] = "hidden", ['name'] = "houseId", ['value'] = house }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_realestate:server:setSellValue', 'server', form, "Set New Sell Price | " .. Houses[house].name)
end)

RegisterNetEvent('pw_realestate:client:reviewRent')
AddEventHandler('pw_realestate:client:reviewRent', function(data)
    local form = {}

    table.insert(form, { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Yadayada rent house " .. data.property.houseID .. "for $" .. Houses[data.property.houseID].rentPrice .. "/week ?" })
    table.insert(form, { ['type'] = 'hr' })
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Send contract?</b>" })
    table.insert(form, { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'info', ['data'] = data })

    TriggerEvent('pw_interact:generateForm', 'pw_realestate:server:sendRentContract', 'server', form, 'Review Contract', {}, false, '350px')
end)

RegisterNetEvent('pw_realestate:client:reviewSell')
AddEventHandler('pw_realestate:client:reviewSell', function(data)
    local form = {}

    table.insert(form, { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Yadayada sell house " .. data.property.houseID .. "for $" .. Houses[data.property.houseID].price .. " ?" })
    table.insert(form, { ['type'] = 'hr' })
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Send contract?</b>" })
    table.insert(form, { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'info', ['data'] = data })

    TriggerEvent('pw_interact:generateForm', 'pw_realestate:server:sendSellContract', 'server', form, 'Review Contract', {}, false, '350px')
end)

RegisterNetEvent('pw_realestate:client:getRentContract')
AddEventHandler('pw_realestate:client:getRentContract', function(data)
    local form = {}

    table.insert(form, { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Yadayada rent house " .. data.property.houseID .. "for $" .. Houses[data.property.houseID].rentPrice .. "/week ?" })
    table.insert(form, { ['type'] = 'hr' })
    table.insert(form, { ['type'] = 'checkbox', ['label'] = 'Yadayada accept<br><i>(Tenant) <u>&nbsp;&nbsp;'..playerData.name..'&nbsp;&nbsp;</u></i>', ['name'] = 'contractReview', ['value'] = 'yes'})
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'info', ['data'] = data })

    TriggerEvent('pw_interact:generateForm', 'pw_realestate:server:signedRentContract', 'server', form, 'Review Contract', {}, false, '350px')
end)

RegisterNetEvent('pw_realestate:client:getSellContract')
AddEventHandler('pw_realestate:client:getSellContract', function(data)
    local form = {}

    table.insert(form, { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Yadayada buy house " .. data.property.houseID .. "for $" .. Houses[data.property.houseID].price .. " ?" })
    table.insert(form, { ['type'] = 'hr' })
    table.insert(form, { ['type'] = 'checkbox', ['label'] = 'Yadayada accept<br><i>(Buyer) <u>&nbsp;&nbsp;'..playerData.name..'&nbsp;&nbsp;</u></i>', ['name'] = 'contractReview', ['value'] = 'yes'})
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'info', ['data'] = data })

    TriggerEvent('pw_interact:generateForm', 'pw_realestate:server:signedContract', 'server', form, 'Review Contract', {}, false, '350px')
end)

RegisterNetEvent('pw_realestate:client:showRentPayments')
AddEventHandler('pw_realestate:client:showRentPayments', function(buyer, agent, house)
    local menu = {}

    table.insert(menu, { ['label'] = "<b>Total Payment</b>: </span><span class='text-primary'><b>$" .. house.cost .. "</b></span>", ['color'] = 'warning disabled' })
    table.insert(menu, { ['label'] = "Pay with Cash", ['action'] = 'pw_realestate:server:usePaymentRent', ['triggertype'] = 'server', ['value'] = { ['method'] = 'cash', ['buyer'] = buyer, ['agent'] = agent, ['house'] = house }, ['color'] = 'primary' })
    table.insert(menu, { ['label'] = "Pay with Debit Card", ['action'] = 'pw_realestate:server:usePaymentRent', ['triggertype'] = 'server', ['value'] = { ['method'] = 'debit', ['buyer'] = buyer, ['agent'] = agent, ['house'] = house }, ['color'] = 'primary' })

    TriggerEvent('pw_interact:generateMenu', menu, 'Choose Payment Method')
end)

RegisterNetEvent('pw_realestate:client:showPayments')
AddEventHandler('pw_realestate:client:showPayments', function(buyer, agent, house)
    local menu = {}

    table.insert(menu, { ['label'] = "<b>Total Payment</b>: </span><span class='text-primary'><b>$" .. house.cost .. "</b></span>", ['color'] = 'warning disabled' })
    table.insert(menu, { ['label'] = "Pay with Cash", ['action'] = 'pw_realestate:server:usePayment', ['triggertype'] = 'server', ['value'] = { ['method'] = 'cash', ['buyer'] = buyer, ['agent'] = agent, ['house'] = house }, ['color'] = 'primary' })
    table.insert(menu, { ['label'] = "Pay with Debit Card", ['action'] = 'pw_realestate:server:usePayment', ['triggertype'] = 'server', ['value'] = { ['method'] = 'debit', ['buyer'] = buyer, ['agent'] = agent, ['house'] = house }, ['color'] = 'primary' })

    TriggerEvent('pw_interact:generateMenu', menu, 'Choose Payment Method')
end)

function HouseMenu(house)
    local menu = {}
    local subMenu = {}
    table.insert(subMenu, { ['label'] = 'Current: <b><span class="text-success">$' .. Houses[house].price .. '</span></b>', ['color'] = 'primary' })
    table.insert(subMenu, { ['label'] = '<b><span class="text-primary">Set New Price</span></b>', ['action'] = 'pw_realestate:client:setSellValue', ['value'] = house, ['triggertype'] = 'client', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = 'Sell Price', ['color'] = 'primary', ['subMenu'] = subMenu })
    
    TriggerEvent('pw_interact:generateMenu', menu, "House Management | " .. Houses[house].name)
end