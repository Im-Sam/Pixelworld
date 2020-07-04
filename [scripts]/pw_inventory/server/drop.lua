PWInv.Inventory.Drops = {
    Process = function(self, source, item, count, coords)
        local mPlayer = exports['pw_base']:Source(source)
        if mPlayer ~= nil then
            local char = mPlayer:Character()
            Citizen.CreateThread(function()
                MySQL.Async.fetchAll('SELECT * FROM `stored_items` WHERE `inventoryType` = 1 AND `identifier` = @charid AND `slot` = @slot LIMIT 1', { ['slot'] = item.slot, ['charid'] = char:getCID() }, function(dbItem)
                    if dbItem[1] ~= nil then
                        if count > tonumber(dbItem[1].count) then
                            count = tonumber(dbItem[1].count)
                        end
    
                        local dropinv = nil
                        for k, v in pairs(PWInv.Inventory.Drops.Store) do
                            local dist = #(vector3(tonumber(v.position.x), tonumber(v.position.y), tonumber(v.position.z)) - coords)
                            if dist < 2.0 then
                                PWInv.Inventory.Drops:Add(source, mPlayer, v.owner, item, count, function()
                                    TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, v, v)
                                end)
                                return
                            end
                        end
    
                        PWInv.Inventory.Drops:Create(source, mPlayer, item, count, coords, function(drop)
                            TriggerEvent('pw_inventory:server:GetSecondaryInventory', source, drop)
                        end)
                        
                        --TriggerClientEvent('pw_inventory:client:RefreshInventory', src)
                        --TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, dropinv)
                    end
                end)
            end)
        
        end
    end,
    Create = function(self, src, mPlayer, item, count, coords, cb)
        local fuck = {
            x = coords.x,
            y = coords.y,
            z = coords.z,
        }
        
        MySQL.Async.insert("INSERT INTO `drop_zones` (`x`, `y`, `z`) VALUES (@x, @y, @z)", {['x'] = fuck.x, ['y'] = fuck.y, ['z'] = fuck.z}, function(newDrop)
            if newDrop > 0 then
                PWInv.Inventory.Drops.Store[newDrop] = { type = 2, owner = tonumber(newDrop), position = fuck }
                mPlayer:Inventories():AddItem().Drop(tonumber(newDrop), item, count, function(s)
                    if item.type == 1 then
                        TriggerClientEvent("pw_inventory:client:RemoveWeapon", src, item.name)
                    end
            
                    TriggerClientEvent('pw_inventory:client:DropCreateForAll', -1, newDrop, PWInv.Inventory.Drops.Store[newDrop])
            
                    cb(PWInv.Inventory.Drops.Store[newDrop])
                end)
            end
        end)
        --local newDrop = { type = 2, owner = (#PWInv.Inventory.Drops.Store + 1), position = fuck }
        --table.insert(PWInv.Inventory.Drops.Store, newDrop)
    end,
    Add = function(self, src, mPlayer, owner, item, count, cb)
        if PWInv.Inventory.Drops.Store[owner] ~= nil then
            mPlayer:Inventories():AddItem().Drop(owner, item, count, function(s)
                if item.type == "Weapon" then
                    TriggerClientEvent("pw_inventory:client:RemoveWeapon", src, item.name)
                end
                cb(s)
            end)
        end
    end,
    Store = {}
}
drops = {}

MySQL.ready(function ()
    MySQL.Async.fetchAll("SELECT * FROM `drop_zones`", {}, function(dropssql)
        for k, v in pairs(dropssql) do
            PWInv.Inventory.Drops.Store[v.drop_id] = { type = 2, owner = v.drop_id, position = {x = tonumber(v.x), y = tonumber(v.y), z = tonumber(v.z)} }
        end
        processed = true
    end)
end)

RegisterServerEvent('pw_inventory:server:GetActiveDrops')
AddEventHandler('pw_inventory:server:GetActiveDrops', function()
    for k, v in pairs(PWInv.Inventory.Drops.Store) do
        TriggerClientEvent('pw_inventory:client:DropCreateForAll', source, k, v)
    end
end)

RegisterServerEvent('pw_inventory:server:Drop')
AddEventHandler('pw_inventory:server:Drop', function(item, count, coords)
    PWInv.Inventory.Drops:Process(source, item, count, coords)
end)

RegisterServerEvent('pw_inventory:server:RemoveBag')
AddEventHandler('pw_inventory:server:RemoveBag', function(dropInv)
    MySQL.Async.execute("DELETE FROM `drop_zones` WHERE `drop_id` = @owner", {['owner'] = dropInv.owner}, function(success)
        if success > 0 then
            PWInv.Inventory.Drops.Store[dropInv.owner] = nil
            TriggerClientEvent('pw_inventory:client:RemoveBag', -1, dropInv)
        end
    end)
end)