PW = nil
playerData, playerLoaded = nil, false
currentWeapon = nil
local holstered  = true
local blocked	 = false
local previousAmmo = 0
local disableFire = false

Citizen.CreateThread(function()
	while PW == nil do
		TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)
		Citizen.Wait(1)
    end
end)

function loadAnimDict(dict)
	while ( not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(0)
	end
end

RegisterNetEvent('pw_weapons:removeWeapon')
AddEventHandler('pw_weapons:removeWeapon', function(serial, current)
    if current then
        if currentWeapon ~= nil and currentWeapon.serial == serial then
            sendNUIOpen(false)
            local removeWeapon = currentWeapon
            currentWeapon = nil
            SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
            RemoveWeaponFromPed(PlayerPedId(), removeWeapon.hash)
            Citizen.Wait(500)
            SetPedAmmo(PlayerPedId(), removeWeapon.hash, 0)
            removeWeapon = nil
        end
    else
        disarmPlayer()
    end
end)

function disarmPlayer()
    if currentWeapon ~= nil then
        sendNUIOpen(false)
        local removeWeapon = currentWeapon
        currentWeapon = nil
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
        RemoveWeaponFromPed(PlayerPedId(), removeWeapon.hash)
        Citizen.Wait(500)
        SetPedAmmo(PlayerPedId(), removeWeapon.hash, 0)
        removeWeapon = nil
    end
end

function CheckWeapon(ped)
	if IsEntityDead(ped) then
		blocked = false
			return false
		else
			for i = 1, #Config.Weapons do
				if GetHashKey(Config.Weapons[i]) == GetSelectedPedWeapon(ped) then
					return true
				end
			end
		return false
	end
end

function manageWeapon(serial)
    local _serial = serial
    local currentAmmo
    local notRegiven = false
    Citizen.CreateThread(function()
        while currentWeapon ~= nil do
            local playerPed = GetPlayerPed(-1)
            if IsPedShooting(PlayerPedId()) then
                local weaType = retreiveWeapon(currentWeapon.name).type
                if Config.WeaponStress[weaType] ~= nil then
                    exports['pw_needs']:updateNeeds("stress", "add", Config.WeaponStress[weaType])
                end
            end

            if currentWeapon.serial ~= nil then
                currentAmmo = GetAmmoInPedWeapon(PlayerPedId(), currentWeapon.hash)
                if currentAmmo ~= previousAmmo then
                    previousAmmo = currentAmmo
                    local max, total = GetMaxAmmo(PlayerPedId(), currentWeapon.hash)
                    SendNUIMessage({
                        status = "updateAmmo",
                        ammo = currentAmmo,
                        max = total
                    })
                    TriggerServerEvent('pw_weapons:server:updateAmmoCount', currentWeapon.serial, currentAmmo)
                end
            end
            Citizen.Wait(10)
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        -- Hide Components On Screen
        Citizen.Wait(1)
        HideHudComponentThisFrame(2)
        HideHudComponentThisFrame(19)
        HideHudComponentThisFrame(20)
        HideHudComponentThisFrame(21)
        HideHudComponentThisFrame(22)
        HideHudComponentThisFrame(14)
        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(9)
        HideHudComponentThisFrame(8)
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(data)
    disarmPlayer()
    loadAnimDict("rcmjosh4")
	loadAnimDict("reaction@intimidation@cop@unarmed")
	playerData = data
    playerLoaded = true
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    disarmPlayer()
	playerLoaded = false
    playerData = nil
end)

function tprint (t, s)
    for k, v in pairs(t) do
        local kfmt = '["' .. tostring(k) ..'"]'
        if type(k) ~= 'string' then
            kfmt = '[' .. k .. ']'
        end
        local vfmt = '"'.. tostring(v) ..'"'
        if type(v) == 'table' then
            tprint(v, (s or '')..kfmt)
        else
            if type(v) ~= 'string' then
                vfmt = tostring(v)
            end
            print(type(t)..(s or '')..kfmt..' = '..vfmt)
        end
    end
end

function sendNUIOpen(open)
    if open then
        if currentWeapon ~= nil then
            local max, total = GetMaxAmmo(PlayerPedId(), currentWeapon.hash)
            SendNUIMessage({
                status = "showhud",
                weapon = currentWeapon,
                max = total
            })
        end
    else
        SendNUIMessage({
            status = "hidehud",
        })
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if disableFire then
            DisablePlayerFiring(GetPlayerPed(-1), true)
        end
    end
end)

RegisterNetEvent('pw_weapons:client:addAmmoForce')
AddEventHandler('pw_weapons:client:addAmmoForce', function(amt)
    if currentWeapon ~= nil then
        AddAmmoToPed(PlayerPedId(), currentWeapon.hash, amt)
        TriggerServerEvent('pw_weapons:server:addAmmo', currentWeapon.serial, amt)  
    end
end)

RegisterNetEvent('pw_weapons:client:setAmmoForce')
AddEventHandler('pw_weapons:client:setAmmoForce', function(amt)
    if currentWeapon ~= nil then
        TriggerServerEvent('pw_weapons:server:setAmmo', amt)
        SetPedAmmo(PlayerPedId(), currentWeapon.hash, amt)
    end
end)

RegisterNetEvent('pw_weapons:client:addAmmo')
AddEventHandler('pw_weapons:client:addAmmo', function(item)
    local items = {}
    local returnItems = {}
    if currentWeapon ~= nil then
        if currentWeapon.requiredInformation.accepts == item.name then
            local maxAva, max = GetMaxAmmo(PlayerPedId(), currentWeapon.hash)
            if maxAva and GetAmmoInPedWeapon(PlayerPedId(), currentWeapon.hash) + item.itemMeta.contents <= max then 
                table.insert(items, { ['name'] = item.name, ['qty'] = 1 })
                AddAmmoToPed(PlayerPedId(), currentWeapon.hash, item.itemMeta.contents)
                MakePedReload(PlayerPedId())
                TaskReloadWeapon(PlayerPedId())
                TriggerServerEvent('pw_weapons:server:addAmmo', currentWeapon.serial, item.itemMeta.contents)
            else
                exports.pw_notify:SendAlert('error', "This weapon only supports "..max.." ammo max, adding "..item.itemMeta.contents.." will go beyond the weapon limits.", 5000)
                table.insert(returnItems, { ['name'] = item.name, ['qty'] = 1 })
            end
        else
            local itemName = exports.pw_inv:itemInfo(currentWeapon.requiredInformation.accepts)
            exports.pw_notify:SendAlert('error', 'The equipped weapon only accepts '..itemName.item_label..', you have tried using '..item.label..'.')
        end
    else
        exports.pw_notify:SendAlert('error', 'You need to equip a weapon to reload.')
    end
    TriggerServerEvent('pw_inv:removeItem', 0, true, items)
    TriggerServerEvent('pw_inv:giveItem', 0, true, returnItems)
end)

RegisterNetEvent('pw_weapons:client:loadWeapon')
AddEventHandler('pw_weapons:client:loadWeapon', function(serial)
    disableFire = true
    local ped = GetPlayerPed(-1)
    loadAnimDict("rcmjosh4")
	loadAnimDict("reaction@intimidation@cop@unarmed")
    if currentWeapon == nil or (currentWeapon ~= nil and currentWeapon.serial ~= serial) then
        PW.TriggerServerCallback('pw_weapons:server:retreiveWeapon', function(weapon)
            Citizen.CreateThread(function()
                previousAmmo = weapon.ammo
                local proceed = false
                if currentWeapon ~= nil and currentWeapon.serial ~= serial then
                    if (currentWeapon.hash ~= 883325847) then
                        TaskPlayAnim(PlayerPedId(), "reaction@intimidation@cop@unarmed", "outro", 8.0, 2.0, -1, 50, 2.0, 0, 0, 0 ) -- Change 50 to 30 if you want to stand still when holstering weapon
                        RemoveWeaponFromPed(PlayerPedId(), currentWeapon.hash)
                    end
                    currentWeapon = weapon
                    proceed = true
                else
                    currentWeapon = weapon
                    proceed = true
                end
                while not proceed do Citizen.Wait(0) end
                GiveWeaponToPed(PlayerPedId(), weapon.hash, 0, false, true)
                SetPedAmmo(PlayerPedId(), weapon.hash, weapon.ammo)
                SetPedCurrentWeaponVisible(PlayerPedId(), 0, 0, 1, 1)
                if (currentWeapon.hash ~= 883325847) then
                    TaskPlayAnim(PlayerPedId(), "reaction@intimidation@cop@unarmed", "intro", 8.0, 2.0, -1, 50, 2.0, 0, 0, 0 ) -- Change 50 to 30 if you want to stand still when removing weapon
                    Citizen.Wait(1)
                    while IsEntityPlayingAnim(PlayerPedId(), "reaction@intimidation@cop@unarmed", "intro", 0) do Citizen.Wait(100) end
                end
                SetPedCurrentWeaponVisible(PlayerPedId(), 1, 0, 1, 1)
                if (currentWeapon.hash ~= 883325847) then
                    TaskPlayAnim(PlayerPedId(), "rcmjosh4", "josh_leadout_cop2", 8.0, 2.0, -1, 48, 10, 0, 0, 0 )
                    Citizen.Wait(2400)
                    while IsEntityPlayingAnim(PlayerPedId(), "rcmjosh4", "josh_leadout_cop2", 48) do Citizen.Wait(100) end
                end
                PedSkipNextReloading(ped)
                manageWeapon(weapon.serial)
                sendNUIOpen(true)
                disableFire = false
            end)
        end, serial)
    else
        PW.TriggerServerCallback('pw_weapons:server:saveWeapon', function(toggle)
            DisablePlayerFiring(ped, true)
            if (currentWeapon.hash ~= 883325847) then
                TaskPlayAnim(PlayerPedId(), "rcmjosh4", "josh_leadout_cop2", 8.0, 2.0, -1, 48, 10, 0, 0, 0 )
                    Citizen.Wait(500)
                TaskPlayAnim(PlayerPedId(), "reaction@intimidation@cop@unarmed", "outro", 8.0, 2.0, -1, 50, 2.0, 0, 0, 0 ) -- Change 50 to 30 if you want to stand still when holstering weapon
                --TaskPlayAnim(ped, "reaction@intimidation@cop@unarmed", "outro", 8.0, 2.0, -1, 30, 2.0, 0, 0, 0 ) Use this line if you want to stand still when holstering weapon
                    Citizen.Wait(60)
                ClearPedTasks(PlayerPedId())
            end
            if toggle then
                SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
                SetPedAmmo(PlayerPedId(), currentWeapon.hash, 0)
                RemoveWeaponFromPed(PlayerPedId(), currentWeapon.hash)
                currentWeapon = nil
            else
                SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
                SetPedAmmo(PlayerPedId(), currentWeapon.hash, 0)
                RemoveWeaponFromPed(PlayerPedId(), currentWeapon.hash)
                currentWeapon = nil
            end
            sendNUIOpen(false)
            disableFire = false
        end, currentWeapon.serial)
    end
end)

exports('retreiveWeapon', function(name)
	return retreiveWeapon(name)
end)

exports('retreiveWeaponByHash', function(hash)
	return retreiveWeaponByHash(hash)
end)