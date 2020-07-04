PWInv = PWInv or {}
PWInv.Inventory = PWInv.Inventory or {}
PW = nil
shops = nil
stations = nil
shopBlips = {}
playerData = nil

local isLoggedIn = false
local trunkData = nil
local trunkOpen = false
local isInInventory = false
local openCooldown = false
local myInventory = nil
local secondaryInventory = nil
local secondaryInRange = nil
local currentSecondary = nil

PlayerVeh = nil
Callbacks = nil

RegisterNetEvent('pw_banking:updateCash')
AddEventHandler('pw_banking:updateCash', function(data)
    if isLoggedIn and playerData then
        playerData.cash = data
    end
end)

RegisterNetEvent('pw_inventory:client:secondarySetup')
AddEventHandler('pw_inventory:client:secondarySetup', function(sec, data)
    secondaryInRange = data
    currentSecondary = sec
end)

RegisterNetEvent('pw:playerTeleported')
AddEventHandler('pw:playerTeleported', function()
    if currentSecondary ~= nil then
        secondaryInRange = nil
        currentSecondary = nil
    end
end)

RegisterNetEvent('pw_items:showUsableItems')
AddEventHandler('pw_items:showUsableItems', function(show, items)
    if show then
        SendNUIMessage({
            action = 'showUsableBar',
            items = items
        })
    else
        SendNUIMessage({
            action = 'hideUsableBar',
            method = 'items'
        })
    end
end)

RegisterNetEvent('pw_items:showUsableKeys')
AddEventHandler('pw_items:showUsableKeys', function(show, keys)
    if show then
        SendNUIMessage({
            action = 'showUsableBar',
            keys = keys
        })
    else
        SendNUIMessage({
            action = 'hideUsableBar',
            method = 'keys'
        })
    end
end)

RegisterNetEvent('pw_inventory:client:removeSecondary')
AddEventHandler('pw_inventory:client:removeSecondary', function(sec)
    if currentSecondary == sec then
        secondaryInRange = nil
        currentSecondary = nil
    end
end)

Citizen.CreateThread(function()
	while PW == nil do
		TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)
		Citizen.Wait(1)
    end
end)

PWInv.Inventory.Setup = {
    Startup = function(self)
        Citizen.CreateThread(function()
            while isLoggedIn do
                BlockWeaponWheelThisFrame()
                Citizen.Wait(1)
            end
        end)
    
        Citizen.CreateThread(function()
            Citizen.Wait(100)
            while isLoggedIn do
                Citizen.Wait(10)
                if not PWInv.Inventory.Locked then
                    if IsControlJustReleased(0, 289) then
                        local _vin = false
                        if not openCooldown then
                            if IsPedInAnyVehicle(PlayerPedId(), true) then
                                local veh = GetVehiclePedIsIn(PlayerPedId())
                                local plate = GetVehicleNumberPlateText(veh)
                                _vin = PW.Vehicles.GetVinNumber(plate)
    
                                if DecorExistOn(veh, 'HasFakePlate') then
                                    plate = exports['mythic_veh']:TraceBackPlate(plate)
                                end
                                
                               -- if PlayerVeh:IsPlayerOwnedVeh(veh) then
                               --     if plate ~= nil then
                               --         secondaryInventory = { type = 4, owner = plate }
                               --     end
                               -- else
                                    if _vin ~= false then
                                        secondaryInventory = { type = 6, owner = _vin, plate = plate }
                                    end
                               -- end
    
                                if _vin ~= false then
                                    PWInv.Inventory.Load:Secondary()
                                end
                            else
                                local veh = PWInv.Inventory.Checks:Vehicle()
    
                                if veh and IsEntityAVehicle(veh) then
                                    local plate = GetVehicleNumberPlateText(veh)
                                    local _vin = PW.Vehicles.GetVinNumber(plate)
    
                                    if DecorExistOn(veh, 'HasFakePlate') then
                                        plate = exports['mythic_veh']:TraceBackPlate(plate)
                                    end
                                    
                                    if GetVehicleDoorLockStatus(veh) == 1 then
                                        trunkOpen = true
                                       -- if PlayerVeh:IsPlayerOwnedVeh(veh) then
                                       --     secondaryInventory = { type = 5, owner = plate }
                                       -- else
                                            if _vin ~= false then
                                                secondaryInventory = { type = 7, owner = _vin, plate = plate }
                                            end
                                       -- end
                                        
                                        if vin ~= false then
                                            SetVehicleDoorOpen(veh, 5, true, false)
                                            PWInv.Inventory.Load:Secondary()
                                            PWInv.Inventory.Checks:TrunkDistance(veh)
                                        end
                                    else
                                        exports['pw_notify']:SendAlert('error', 'Vehicle Is Locked')
                                        if bagId ~= nil then
                                            openDrop()
                                        else
                                            local container = ScanContainer()
                                            if container then
                                                openContainer()
                                            else
                                                PWInv.Inventory.Open:Personal()
                                            end
                                        end
                                    end
                                else
                                    if bagId ~= nil then
                                        openDrop()
                                    else
                                        local container = ScanContainer()
                                        if container then
                                            openContainer()
                                        elseif currentSecondary ~= nil then
                                            secondaryInventory = secondaryInRange
                                            PWInv.Inventory.Load:Secondary()
                                        else
                                            PWInv.Inventory.Open:Personal()
                                        end
                                    end
                                end
                            end
                        end
                    elseif IsDisabledControlJustReleased(2, 157) then -- 1
                        PWInv.Inventory:Hotkey(1)
                    elseif IsDisabledControlJustReleased(2, 158) then -- 2
                        PWInv.Inventory:Hotkey(2)
                    elseif IsDisabledControlJustReleased(2, 160) then -- 3
                        PWInv.Inventory:Hotkey(3)
                    elseif IsDisabledControlJustReleased(2, 164) then -- 4
                        PWInv.Inventory:Hotkey(4)
                    elseif IsDisabledControlJustReleased(2, 165) then -- 5
                        PWInv.Inventory:Hotkey(5)
                    elseif IsDisabledControlJustReleased(2, 37) or IsControlJustReleased(2, 37) then
                        PW.TriggerServerCallback('pw_inventory:server:GetHotkeys', function(items)
                            SendNUIMessage({
                                action = 'showActionBar',
                                items = items
                            })
                        end)
                    end
                end
            end
        end)
    end,
    Primary = function(self, data)
        items = {}
        inventory = data.inventory
    
        SendNUIMessage( { action = "setItems", itemList = inventory, invOwner = data.invId, invTier = data.invTier } )
    end,
    Secondary = function(self, data)
        items = {}
        inventory = data.inventory
    
        if #inventory == 0 and data.invId.type == 2 then
            MYTY.Inventory.Close:Secondary()
        else
            secondaryInventory = data.invId
            SendNUIMessage( { action = "setSecondInventoryItems", itemList = inventory, invOwner = data.invId, invTier = data.invTier } )
            PWInv.Inventory.Open:Secondary()
        end
    end
}

RegisterNetEvent('pw_inventory:client:LockInventory')
AddEventHandler('pw_inventory:client:LockInventory', function(state)
    PWInv.Inventory:LockInventory(state)
end)

function PWInv.Inventory.LockInventory(self, state)
    PWInv.Inventory.Locked = not PWInv.Inventory.Locked
end

local cooldown = false
function PWInv.Inventory.Hotkey(self, index)
    if not cooldown and not PWInv.Inventory.Locked then
        TriggerServerEvent('pw_inventory:server:UseItemFromSlot', index)
        PW.TriggerServerCallback('pw_inventory:server:UseHotkey', function(success)
            cooldown = true

            Citizen.CreateThread(function()
                Citizen.Wait(1000)
                cooldown = false
            end)
            
            PW.TriggerServerCallback('pw_inventory:server:GetHotkeys', function(items)
                SendNUIMessage({
                    action = 'showActionBar',
                    items = items,
                    timer = 500,
                    index = index
                })
            end)
        end, { slot = index })
    end
end

function PWInv.Inventory.ItemUsed(self, alerts)
    SendNUIMessage({
        action = 'itemUsed',
        alerts = alerts
    })
end

RegisterNetEvent('pw_inventory:client:ShowItemUse')
AddEventHandler('pw_inventory:client:ShowItemUse', function(alerts)
    PWInv.Inventory:ItemUsed(alerts)
end)

PWInv.Inventory.Checks = {
    Vehicle = function(self)
        local player = PlayerPedId()
        local startPos = GetOffsetFromEntityInWorldCoords(player, 0, 0.5, 0)
        local endPos = GetOffsetFromEntityInWorldCoords(player, 0, 5.0, 0)
    
        local rayHandle = StartShapeTestRay(startPos['x'], startPos['y'], startPos['z'], endPos['x'], endPos['y'], endPos['z'], 10, player, 0)
        local a, b, c, d, veh = GetShapeTestResult(rayHandle)
    
        if veh ~= 2 then
            local plyCoords = GetEntityCoords(player)
            local offCoords = GetOffsetFromEntityInWorldCoords(veh, 0.0, -2.5, 1.0)
            local dist = #(vector3(offCoords.x, offCoords.y, offCoords.z) - plyCoords)
    
            if dist < 2.5 then
                return veh
            end
        else
            return nil
        end
    end,
    Trunk = function(self)
        
    end,
    TrunkDistance = function(self, veh)
        Citizen.CreateThread(function()
            while trunkOpen do
                Citizen.Wait(10)
                local pos = GetEntityCoords(PlayerPedId())
                local dist = #(vector3(pos.x, pos.y, pos.z) - GetOffsetFromEntityInWorldCoords(veh, 0.0, -2.5, 1.0))
                if dist > 1 and trunkOpen then
                    PWInv.Inventory.Close:Instantly()
                else
                    Citizen.Wait(500)
                end
            end
        end)
    end,
    HasItem = function(self, items, cb)
        Callbacks:ServerCallback('pw_inventory:server:HasItem', items, function(status)
            cb(status)
        end)
    end
}

PWInv.Inventory.Load = {
    Personal = function(self)
        TriggerServerEvent("pw_inventory:server:GetPlayerInventory")
    end,
    Secondary = function(self, secondary)
        if secondary ~= nil then
            secondaryInventory = secondary
        end

        TriggerServerEvent('pw_inventory:server:GetSecondaryInventory', GetPlayerServerId(PlayerId()), secondaryInventory)
    end
}

PWInv.Inventory.Open = {
    Personal = function(self)
        PWInv.Inventory.Load:Personal()
        isInInventory = true
        SendNUIMessage({
            action = "display",
            type = "normal"
        })
        TransitionToBlurred(1000)

        SetNuiFocus(true, true)
    end,
    Secondary = function(self)
        PWInv.Inventory.Load:Personal()
        isInInventory = true

        TransitionToBlurred(1000)
        SendNUIMessage({
            action = "display",
            type = "secondary"
        })
    
        SetNuiFocus(true, true)
    end
}

PWInv.Inventory.Close = {
    Normal = function(self)
        openCooldown = true
        isInInventory = false
        secondaryInventory = nil

        TransitionFromBlurred(1000)

        SendNUIMessage({ action = "hide" })
        SetNuiFocus(false, false)
    
        if trunkOpen then
            local coords = GetEntityCoords(PlayerPedId())
            local veh = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
    
            TriggerEvent("pw:progressbar:progress", {
                name = "accessing_atm",
                duration = 500,
                label = "Closing Trunk",
                useWhileDead = false,
                canCancel = false,
                controlDisables = {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = false,
                },
                animation = {
                    animDict = "veh@low@front_dsfps@base",
                    anim = "horn_outro",
                    flags = 49,
                },
            }, function(status)
                SetVehicleDoorShut(veh, 5, false)
                trunkOpen = false
            end)
        end
    
        Citizen.Wait(1200)
        openCooldown = false
    end,
    Instant = function(self)
        secondaryInventory = nil
        openCooldown = true
        isInInventory = false
        SendNUIMessage({ action = "hide" })
        SetNuiFocus(false, false)
    
        if trunkOpen then
            trunkOpen = false
        end
    
        openCooldown = false
    end,
    Secondary = function(self)
        secondaryInventory = nil

        SendNUIMessage({ action = "closeSecondary" })
    
        if trunkOpen then
            trunkOpen = false
        end
    
        TriggerEvent('pw_inventory:client:RefreshInventory')
    end
}



RegisterNetEvent("pw_inventory:client:RemoveWeapon")
AddEventHandler("pw_inventory:client:RemoveWeapon", function(weapon)
    PWInv.Inventory.Weapons:Remove(weapon)
end)

RegisterNetEvent("pw_inventory:client:AddWeapon")
AddEventHandler("pw_inventory:client:AddWeapon", function(weapon)
    PWInv.Inventory.Weapons:Add(weapon)
end)

PWInv.Inventory.Weapons = {
    Add = function(self, weapon)
        --GiveWeaponToPed(PlayerPedId(), weapon, 0, false, false)
    end,
    Remove = function(self, weapon)
        --RemoveWeaponFromPed(PlayerPedId(), weapon)
    end
}

exports('invLimit', function(id)
    if (InvSlots[id]) then
        return { ['id'] = id, ['slots'] = InvSlots[id].slots, ['weight'] = InvSlots[id].weight }
    else
        return { ['id'] = 0, ['slots'] = 0, ['weight'] = 0.0 }
    end
end)

RegisterNetEvent('mythic_base:client:CharacterDataChanged')
AddEventHandler('mythic_base:client:CharacterDataChanged', function(charData)
    if charData ~= nil then
        if charData:GetData('id') ~= nil then
            myInventory = { type = 1, owner = charData:GetData('id') }
        else
            myInventory = nil
        end
    else
        myInventory = nil
    end
end)

RegisterNetEvent('pw_inventory:client:RobPlayer')
AddEventHandler('pw_inventory:client:RobPlayer', function()
    local ped = exports['mythic_base']:GetPedInFront()

    if ped ~= 0 then
        local pedPlayer = exports['mythic_base']:GetPlayerFromPed(ped)
        if pedPlayer ~= -1 then
            TriggerServerEvent('pw_inventory:server:RobPlayer', GetPlayerServerId(pedPlayer))
        end
    end
end)

function createShopBlips()
    for k, v in pairs(shops) do
        if v.marker then
            shopBlips[k] = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
            SetBlipSprite(shopBlips[k], 59)
            SetBlipDisplay(shopBlips[k], 4)
            SetBlipScale  (shopBlips[k], 0.8)
            SetBlipColour (shopBlips[k], 7)
            SetBlipAsShortRange(shopBlips[k], true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Shop")
            EndTextCommandSetBlipName(shopBlips[k])
        end
    end
end

RegisterNetEvent('pw:setJob')
AddEventHandler('pw:setJob', function(data)
    if isLoggedIn and playerData then
        playerData.job = data
    end    
end)

RegisterNetEvent('pw:setGang')
AddEventHandler('pw:setGang', function(data)
    if isLoggedIn and playerData then
        playerData.gang = data
    end
end)

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
    if playerData and isLoggedIn then
        playerData.job.duty = toggle
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(data)
    PW.TriggerServerCallback('pw_inventory:retreiveShops', function(s, cs)
        shops = s
        stations = cs
        playerData = data
        isLoggedIn = true
        PWInv.Inventory.Setup:Startup()
        createShopBlips()
    end)
end)

RegisterNetEvent('pw_inventory:client:updatePlayerCash')
AddEventHandler('pw_inventory:client:updatePlayerCash', function(cash)
    SendNUIMessage({ action = "updateCash", cash = cash })
end)

Citizen.CreateThread(function()
    local currentShop = nil
    local currentStation = nil

    local function checkAuth(k)
        local auth = false
        local sta = stations[k]
        for k, v in pairs(sta.jobs) do
            if (playerData and playerData.job.job == v and playerData.job.duty) then
                auth = true
            end
        end
        return auth
    end

    local function checkGang(k)
        local auth = false
        local sta = stations[k]
        for t, p in pairs(sta.gangs) do
            if (playerData and playerData.gang == p) then
                auth = true
            end
        end
        return auth
    end

    while true do
        local letSleep = true
        local playerPed = GetPlayerPed(-1)
        local playerCoords = GetEntityCoords(playerPed)

        if (shops ~= nil and shops[1] ~= nil and isLoggedIn) then
            for k, v in pairs(shops) do
                local distance = #(playerCoords - vector3(v.coords.x, v.coords.y, v.coords.z))
                if distance < 5.0 then
                    letSleep = false
                    DrawMarker(27, v.coords.x, v.coords.y, v.coords.z - 0.98, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 1.0, 139, 16, 20, 250, false, false, 2, false, false, false, false)
                    DrawMarker(20, v.coords.x, v.coords.y, v.coords.z, 0, 0, 0, 0, 0, 0, 0.35, 0.35, 0.35, 255, 255, 255, 250, false, false, 2, true, false, false, false)
                    if distance < 1.0 then 
                        if currentShop == nil then
                            TriggerEvent('pw_items:showUsableKeys', true, {{['key'] = "f2", ['label'] = "Use Shop"}})
                            TriggerEvent('pw_drawtext:showNotification', { title = v.name, message = "Press [ <span class='text-danger'>F2</span> ] to access shop.", icon = 'fad fa-shopping-basket' })
                            TriggerEvent('pw_inventory:client:secondarySetup', "shop", { type = 18, owner = k, name = v.name, cash = playerData.cash })
                            currentShop = k
                        end
                    else
                        if currentShop == k then
                            TriggerEvent('pw_items:showUsableKeys', false)
                            TriggerEvent('pw_inventory:client:removeSecondary', "shop")
                            TriggerEvent('pw_drawtext:hideNotification')
                            currentShop = nil
                        end
                    end
                end
            end
        end

        if(stations ~= nil and stations[1] ~= nil and isLoggedIn) then
            for k, v in pairs(stations) do
                if (v.marker and v.gangs[1] == nil and v.jobs[1] == nil) or (v.marker and v.gangs[1] ~= nil and checkGang(k)) or (v.marker and v.jobs[1] ~= nil and checkAuth(k))then
                    local distance = #(playerCoords - vector3(v.coords.x, v.coords.y, v.coords.z))
                    if distance < 5.0 then
                        letSleep = false
                        DrawMarker(27, v.coords.x, v.coords.y, v.coords.z - 0.98, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 1.0, 139, 16, 20, 250, false, false, 2, false, false, false, false)
                        DrawMarker(20, v.coords.x, v.coords.y, v.coords.z, 0, 0, 0, 0, 0, 0, 0.35, 0.35, 0.35, 255, 255, 255, 250, false, false, 2, true, false, false, false)

                        if distance < 1.0 then
                            if currentStation == nil then
                                TriggerEvent('pw_items:showUsableKeys', true, {{['key'] = "f2", ['label'] = "Use Station"}})
                                TriggerEvent('pw_drawtext:showNotification', { title = v.name, message = "Press [ <span class='text-danger'>F2</span> ] to access crafting station.", icon = 'fad fa-drafting-compass' })
                                TriggerEvent('pw_inventory:client:secondarySetup', "cstation", { type = 21, owner = k, name = v.name })
                                currentStation = k
                            end
                        else
                            if currentStation == k then
                                TriggerEvent('pw_items:showUsableKeys', false)
                                TriggerEvent('pw_inventory:client:removeSecondary', "cstation")
                                TriggerEvent('pw_drawtext:hideNotification')
                                currentStation = nil
                            end
                        end
                    end
                end

            end
        end

        if letSleep then
            Citizen.Wait(500)
        else
            Citizen.Wait(1)
        end
    end
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    isLoggedIn = false
    playerData = nil
    shops = nil
    stations = nil
    for k, v in pairs(shopBlips) do
        RemoveBlip(v)
    end
    shopBlips = {}
end)

RegisterNetEvent("pw_inventory:client:SetupUI")
AddEventHandler("pw_inventory:client:SetupUI", function(data)
    PWInv.Inventory.Setup:Primary(data)
end)

RegisterNetEvent("pw_inventory:client:SetupSecondUI")
AddEventHandler("pw_inventory:client:SetupSecondUI", function(data)
    PWInv.Inventory.Setup:Secondary(data)
end)

RegisterNetEvent("pw_inventory:client:RefreshInventory")
AddEventHandler("pw_inventory:client:RefreshInventory", function()
    PWInv.Inventory.Load:Personal()
    
    if trunkOpen then
        local veh = PWInv.Inventory.Checks:Vehicle()
        if veh and IsEntityAVehicle(veh) then
            local plate = GetVehicleNumberPlateText(veh)
            if GetVehicleDoorLockStatus(veh) == 1 then
                SetVehicleDoorOpen(veh, 5, true, false)
                PWInv.Inventory.Load:Secondary()
            end
        end
    elseif secondaryInventory ~= nil then
        PWInv.Inventory.Load:Secondary()
    end
end)

RegisterNetEvent("pw_inventory:client:RefreshInventory2")
AddEventHandler("pw_inventory:client:RefreshInventory2", function(origin, destination)
    if (myInventory ~= nil and origin ~= nil and myInventory.type == origin.type and myInventory.owner == origin.owner) or
    (myInventory ~= nil and myInventory.type == destination.type and myInventory.owner == destination.owner) or
    (secondaryInventory ~= nil and origin ~= nil and secondaryInventory.type == origin.type and secondaryInventory.owner == origin.owner) or
    (secondaryInventory ~= nil and secondaryInventory.type == destination.type and secondaryInventory.owner == destination.owner) then
        PWInv.Inventory.Load:Personal()
        
        if trunkOpen then
            local veh = PWInv.Inventory:Vehicle()
            if veh and IsEntityAVehicle(veh) then
                local plate = GetVehicleNumberPlateText(veh)
                if GetVehicleDoorLockStatus(veh) == 1 then
                    SetVehicleDoorOpen(veh, 5, true, false)
                    PWInv.Inventory.Load:Secondary()
                end
            end
        elseif secondaryInventory ~= nil then
            PWInv.Inventory.Load:Secondary()
        end
    end
end)

RegisterNetEvent("pw_inventory:client:CloseUI")
AddEventHandler("pw_inventory:client:CloseUI", function()
    PWInv.Inventory.Close:Instantly()
end)

RegisterNetEvent("pw_inventory:client:CloseUI2")
AddEventHandler("pw_inventory:client:CloseUI2", function(owner)
    if secondaryInventory.type == owner.type and secondaryInventory.owner == owner.owner then
        PWInv.Inventory.Close:Instantly()
    end
end)

RegisterNetEvent("pw_inventory:client:CloseSecondary")
AddEventHandler("pw_inventory:client:CloseSecondary", function(owner)
    if secondaryInventory == nil or (secondaryInventory.type == owner.type and secondaryInventory.owner == owner.owner) then
        PWInv.Inventory.Close:Secondary()
    end
end)

RegisterNUICallback("NUIFocusOff",function()
    PWInv.Inventory.Close:Normal()
end)

RegisterNUICallback("doCraftingCheck",function(data, cb)
    PW.TriggerServerCallback('pw_inventory:doCraftingRequiredItemsCheck', function(result)
        cb(result)
    end, data)
end)

RegisterNUICallback("GetSurroundingPlayers", function(data, cb)
    local coords = GetEntityCoords(PlayerPedId(), true)
    local players = {}

    for _, player in ipairs(GetActivePlayers()) do
        if player ~= PlayerId() then
            local ped = GetPlayerPed(player) 
            local targetCoords = GetEntityCoords(ped)
            local distance = #(vector3(targetCoords.x, targetCoords.y, targetCoords.z) - coords)

            if distance <= 3.0 then
                table.insert(players, {
                    name = GetPlayerName(player),
                    id = GetPlayerServerId(player)
                })
            end
        end
    end
    
    PW.TriggerServerCallback('pw_inventory:getPlayerNames', function(player)
        if player ~= nil then
            SendNUIMessage({
                action = "nearPlayers",
                players = player
            })
        end
    end, players)

    cb("ok")
end)

RegisterNUICallback("MoveToEmpty", function(data, cb)
    TriggerServerEvent('pw_inventory:server:MoveToEmpty', data.originOwner, data.originItem, data.destinationOwner, data.destinationItem)
    cb("ok")
end)

RegisterNUICallback("SplitStack", function(data, cb)
    TriggerServerEvent('pw_inventory:server:SplitStack', data.originOwner, data.originItem, data.destinationOwner, data.destinationItem, data.moveQty)
    cb("ok")
end)

RegisterNUICallback("CombineStack", function(data, cb)
    TriggerServerEvent('pw_inventory:server:CombineStack', data.originOwner, data.originItem, data.destinationOwner, data.destinationItem)
    cb("ok")
end)

RegisterNUICallback("MoveQuantity", function(data, cb)
    TriggerServerEvent('pw_inventory:server:CombineStack', data.originOwner, data.originItem, data.destinationOwner, data.destinationItem, data.moveQty)
    cb("ok")
end)

RegisterNUICallback("TopoffStack", function(data, cb)
    TriggerServerEvent('pw_inventory:server:TopoffStack', data.originOwner, data.originItem, data.destinationOwner, data.destinationItem)
    cb("ok")
end)

RegisterNUICallback("SwapItems", function(data, cb)
    TriggerServerEvent('pw_inventory:server:SwapItems', data.originOwner, data.originItem, data.destinationOwner, data.destinationItem)
    cb("ok")
end)

RegisterNUICallback("UseItem", function(data, cb)
    TriggerServerEvent("pw_inventory:server:useItem", GetPlayerServerId(PlayerId()), data.item)
    cb(data.item.closeUi)
end)

RegisterNUICallback("DropItem", function(data, cb)
    if IsPedSittingInAnyVehicle(PlayerPedId()) then
        return
    end

    local coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('pw_inventory:server:Drop', data.item, data.qty, coords)
    local notification = {}
    table.insert(notification, { item = {label = data.item.label, image = data.item.image, slot = data.item.slot}, qty = data.qty, message = 'Item Dropped' })
    PWInv.Inventory:ItemUsed(notification)

    cb("ok")
end)

RegisterNetEvent('pw_inventory:client:useItemNotif')
AddEventHandler('pw_inventory:client:useItemNotif', function(items)
    PWInv.Inventory:ItemUsed(items)
end)

RegisterNUICallback("GiveItem", function(data, cb)
    TriggerServerEvent('pw_inventory:server:GiveItem', data.target, data.item, data.count)
    cb("ok")
end)

AddEventHandler('mythic_base:shared:ComponentRegisterReady', function()
    exports['mythic_base']:CreateComponent('Inventory', PWInv.Inventory)
end)