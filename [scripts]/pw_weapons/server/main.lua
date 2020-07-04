PW = nil

TriggerEvent('pw:getSharedObject', function(obj)
    PW = obj
end)

MySQL.ready(function ()
    MySQL.Async.fetchAll("SELECT * FROM `items_database` WHERE `item_type` = 'Weapon'", {}, function(weaponItems)
        MySQL.Async.fetchAll("SELECT * FROM `items_database` WHERE `item_type` = 'Ammo'", {}, function(ammoItems)
            MySQL.Async.fetchAll("SELECT * FROM `registered_weapons`", {}, function(weaponsSQL)
                for k, v in pairs(weaponItems) do
                    local weaponMeta = json.decode(v.item_reqmeta)
                    if weaponMeta.accepts == nil then
                        weaponMeta.accepts = "None"
                    end
                    weaponTypes[v.item_name] = { ['class'] = weaponMeta.class, ['ammotype'] = weaponMeta.accepts, ['evidenceable'] = v.item_evidence, ['weight'] = v.item_weight, ['label'] = v.item_label }
                end
            
                for k, v in pairs(ammoItems) do
                    local ammoMeta = json.decode(v.item_reqmeta)
                    ammoTypes[v.item_name] = { ['label'] = v.item_label, ['name'] = v.item_name, ['id'] = v.item_id, ['weight'] = v.item_weight, ['rounds'] = ammoMeta.contents }
                end
                
                for k, v in pairs(weaponsSQL) do
                    registeredWeapons[v.weapon_serial] = loadWeapon(v.weapon_serial)
                end
                processed = true
            end)
        end)
    end)
end)

PW.RegisterServerCallback("pw_weapons:server:retreiveWeapon", function(source, cb, serial)
    if registeredWeapons[serial] then
        local weapon = {
            ['serial'] = registeredWeapons[serial].getSerial(),
            ['name'] = registeredWeapons[serial].getName(),
            ['hash'] = registeredWeapons[serial].getHash(),
            ['ammo'] = registeredWeapons[serial].getAmmo(),
            ['label'] = registeredWeapons[serial].getLabel(),
            ['registeredKeeper'] = registeredWeapons[serial].getRegisteredKeeper(),
            ['components'] = registeredWeapons[serial].getComponents(),
            ['numberOfComponents'] = registeredWeapons[serial].numberOfComponents(),
            ['requiredInformation'] = registeredWeapons[serial].returnRequirements(),
        }
        cb(weapon)
    end
end)

RegisterServerEvent('pw_weapons:server:updateAmmoCount')
AddEventHandler('pw_weapons:server:updateAmmoCount', function(serial, ammo)
    if registeredWeapons[serial] then
        registeredWeapons[serial].SetAmmoCount(ammo)
    end
end)

RegisterServerEvent('pw_weapons:server:addAmmo')
AddEventHandler('pw_weapons:server:addAmmo', function(serial, ammo)
    if registeredWeapons[serial] then
        registeredWeapons[serial].AddAmmo(ammo)
    end
end)

RegisterServerEvent('pw_weapons:server:setAmmo')
AddEventHandler('pw_weapons:server:setAmmo', function(serial, ammo)
    if registeredWeapons[serial] then
        registeredWeapons[serial].SetAmmoCount(ammo)
    end
end)

PW.RegisterServerCallback('pw_weapons:server:saveWeapon', function(source, cb, serial)
    if registeredWeapons[serial] then
        cb(registeredWeapons[serial].saveWeapon())
    end
end)

RegisterServerEvent('pw_weapons:server:registerFirearm')
AddEventHandler('pw_weapons:server:registerFirearm', function(weapon, serial, char, crafted)
    registerWeapon(weapon, serial, char, crafted)
end)

exports('requestWeaponDetail', function(name)
    if weaponTypes[name] then
        return weaponTypes[name]
    end
end)

exports('loadRegistered', function(serial)
    if registeredWeapons[serial] then
        return registeredWeapons[serial]
    end
end)