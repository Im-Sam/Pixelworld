PW = nil
PWInv = PWInv or {}
PWInv.Inventory = PWInv.Inventory or {}
itemsDatabase = {}
shops = {}
craftingStations = {}

local Callbacks = nil

TriggerEvent('pw:getSharedObject', function(obj)
    PW = obj
end)

function PWInv.Inventory.ItemUsed(self, client, alerts)
	TriggerClientEvent('pw_inventory:client:ShowItemUse', client, alerts)
end

MySQL.ready(function ()
    repeat Wait(0) until exports['pw_base']:checkScriptStart() == true
	itemsDatabase = exports['pw_base']:FetchDatabase('items')
	shops = MySQL.Sync.fetchAll("SELECT * FROM `shops`", {})
	craftingStations = MySQL.Sync.fetchAll("SELECT * FROM `crafting_stations`", {})
end)


RegisterServerEvent('pw_items:server:showUsable')
AddEventHandler('pw_items:server:showUsable', function(show, items)
	if show then
		if items ~= nil and items[1] ~= nil then
			local itemsObject = {}
			for k, itemId in pairs(items) do
				local v = itemsDatabase[itemId]
				table.insert(itemsObject, {
					id = v['record_id'],
					itemId = v['item_name'],
					description = v["item_description"],
					qty = 1,
					slot = k,
					label = v['item_label'],
					type = v['item_type'],
					max = v['item_max'],
					image = v['item_image'],
					stackable = v['item_stackable'],
					unique = v['item_unique'],
					usable = false,
					metadata = nil,
					metaprivate = nil,
					itemMeta = nil,
					canRemove = true,
					price = v['item_price'],
					needs = v['item_needsboost'],
					closeUi = v['item_closeui'],
					detector = v['item_metalDetect'],
					crafting = v['item_crafting']
				})
			end
			TriggerClientEvent('pw_items:showUsableItems', source, true, itemsObject)
		end
	else
		TriggerClientEvent('pw_items:showUsableItems', source, false)
	end
end)

PW.RegisterServerCallback('pw_inventory:retreiveShops', function(source, cb)
	local _src = source
	local shops1 = {}
	local stations = {}

	for k, v in pairs(shops) do
		shops1[k] = { ['shop_id'] = v.shop_id, ['name'] = v.shop_name, ['coords'] = json.decode(v.shop_coords), ['items'] = json.decode(v.shop_items), ['marker'] = v.marker }
	end

	for t, p in pairs(craftingStations) do
		stations[t] = { ['station_id'] = p.station_id, ['name'] = p.station_name, ['coords'] = json.decode(p.station_coords), ['items'] = json.decode(p.crafting_items), ['marker'] = p.marker, ['jobs'] = (json.decode(p.jobs) or {}), ['gangs'] = (json.decode(p.gangs) or {}) }
	end
		cb(shops1, stations)
end)

PW.RegisterServerCallback('pw_inventory:server:GetHotkeys', function(source, cb)
	local _src = source
	local mPlayer = exports.pw_base:Source(_src)
	mPlayer:Inventories().getHotBar(function(items)
		cb(items)
	end)
end)

PW.RegisterServerCallback('pw_inventory:server:UseHotkey', function(source, cb, data)
	local _src = source
	local mPlayer = exports['pw_base']:Source(_src)
	if data.slot < 6 and data.slot > 0 then
		mPlayer:Inventories().getSlot(data.slot, function(item)
			if item ~= nil then
				if item.type == "Weapon" then
					mPlayer:Inventories():useItem().equipWeapon(item.metaprivate.serial, function(used)
						if used then
							cb(item.label)
						end
					end)
				elseif item.type == "Ammo" then

				elseif item.type == "Bankcard" then
			
				else
					if item.item == "license" then

					else
						if item.usable then
							mPlayer:Inventories():useItem().bySlot(data.slot, false, function(used)
								if used then
									TriggerEvent('pw_base:itemUsed', _src, used)
									cb(used)
								end
							end)
						end
					end
				end
			end
		end)
	else
		--exports['mythic_base']:FetchComponent('PwnzorLog'):CheatLog('Mythic Inventory', 'User #' .. mPlayer:GetData('data').id .. ' Attempted To Use Item In Slot ' .. data.slot)
		CancelEvent()
	end
end)

exports('invLimit', function(id)
    if (InvSlots[id]) then
        return { ['id'] = id, ['slots'] = InvSlots[id].slots, ['weight'] = InvSlots[id].weight }
    else
        return { ['id'] = 0, ['slots'] = 0, ['weight'] = 0.0 }
    end
end)

RegisterServerEvent('pw_inventory:server:useItem')
AddEventHandler('pw_inventory:server:useItem', function(player, item, cb)
	local _src = source
	local _target = player
	local mPlayer = exports['pw_base']:Source(_target)
	if item.type == "Weapon" then
		mPlayer:Inventories():useItem().equipWeapon(item.metaprivate.serial, function(used)
			if used then
				if cb then
					cb(used)
				end
			end
		end)
	elseif item.type == "Ammo" then

	elseif item.type == "Bankcard" then

	else
		if item.item == "license" then

		else
			mPlayer:Inventories():useItem().bySlot(item.slot, false, function(used)
				if used then
					TriggerEvent('pw_base:itemUsed', _src, used)
					if cb then
						cb(used)
					end
				end
			end)
		end
	end
end)

RegisterServerEvent('pw_inventory:server:useItemScripted')
AddEventHandler('pw_inventory:server:useItemScripted', function(player, how, item, remove, cb)
	local _src = source
	local _target = player
	local mPlayer = exports['pw_base']:Source(_target)
	if item.type == "Weapon" then
		mPlayer:Inventories():useItem().equipWeapon(item.metaprivate.serial, function(used)
			if used then
				cb(used)
			end
		end)
	elseif item.type == "Ammo" then

	elseif item.type == "Bankcard" then

	else
		if item.item == "license" then

		else
			if how == "slot" then
				mPlayer:Inventories():useItem().bySlot(item.slot, false, function(used)
					if used then
						TriggerEvent('pw_base:itemUsed', _src, used)
						cb(used)
					end
				end)
			elseif how == "id" then
				mPlayer:Inventories():useItem().byId(item.id, false, function(used)
					if used then
						TriggerEvent('pw_base:itemUsed', _src, used)
						cb(used)
					end
				end)
			elseif how == "name" then
				mPlayer:Inventories():useItem().byName(item.item, false, function(used)
					if used then
						TriggerEvent('pw_base:itemUsed', _src, used)
						cb(used)
					end
				end)
			end
		end
	end
end)

PW.RegisterServerCallback('pw_inventory:getPlayerNames', function(source, cb, players)
	local newList = {}
	for k, v in pairs(players) do
		local name =  exports['pw_base']:Source(v.id):Character():getName()
		table.insert(newList, {['id'] = v.id, ['name'] = name})
	end
	cb(newList)
end)

function CheckItems(type, id, items, cb)
	local failed = nil
	for k, v in pairs(items) do
		checkItemCount(type, id, v.item, v.count, function(hasItem)
			if not hasItem then
				failed = true
				return
			end

			if k == #items then
				failed = false
			end
		end)
	end

	while failed == nil do
		Citizen.Wait(10)
	end

	if not failed then
		return true
	else
		return false
	end
end

function GetHotkeyItems(source, cb)
	local char = exports['mythic_base']:FetchComponent('Fetch'):Source(source):GetData('character')
	char.Inventory.Get:Hotkeys(function(items)
		cb(items)
	end)
end

function GetPlayerInventory(source)
	local mPlayer = exports['pw_base']:Source(source)

	Citizen.CreateThread(function()
		mPlayer:Inventories().getInventory(function(items)
			local data = {
				invId = { type = 1, owner = mPlayer:Character():getCID(), name = mPlayer:Character():getName() },
				invTier = InvSlots[1],
				inventory = items,
			}
		
			TriggerClientEvent('pw_inventory:client:SetupUI', source, data)
		end)
	end)
end

function GetSecondaryInventory(source, inventory)

end

RegisterServerEvent('pw_inventory:server:MoveToEmpty')
AddEventHandler('pw_inventory:server:MoveToEmpty', function(originOwner, originItem, destinationOwner, destinationItem)
    local src = source
	local mPlayer = exports['pw_base']:Source(src)

	Citizen.CreateThread(function()
		if originOwner.type == 18 then
			-- Bought Items
			local playerBalance = mPlayer:Cash().getCash()
			if(originItem.max * originItem.price <= playerBalance) then
				mPlayer:Cash().Remove((originItem.max * originItem.price))
				TriggerClientEvent('pw_inventory:client:updatePlayerCash', src, mPlayer:Cash().getCash())
				if originItem.type == "Weapon" then
					mPlayer:Inventories():AddItem():Player().Weapon(originItem.itemId, 0, false, destinationItem.slot)
				else
					mPlayer:Inventories():AddItem():Player().Slot(originItem.itemId, originItem.max, destinationItem.slot)
				end
			end
		elseif originOwner.type == 21 then
			local valid = false
			local craftingRequired = json.decode(originItem.crafting)
			for k, v in pairs(craftingRequired) do
				local currentCount = mPlayer:Inventories().getItemCount(k)
				if currentCount < (tonumber(v) * tonumber(destinationItem.qty)) then
					valid = true
				end
			end

			if not valid then
				for k, v in pairs(craftingRequired) do
					mPlayer:Inventories():Remove().byName(k, (tonumber(v) * tonumber(destinationItem.qty)))
				end
				if originItem.type == "Weapon" then
					mPlayer:Inventories():AddItem():Player().Weapon(originItem.itemId, 0, false, destinationItem.slot)
				else
					mPlayer:Inventories():AddItem():Player().Slot(originItem.itemId, originItem.max, destinationItem.slot)
				end
				TriggerClientEvent('pw_inventory:client:RefreshInventory', src)
			end
		else
			-- Other Moves
			mPlayer:Inventories():Move().Empty(originOwner, originItem, destinationOwner, destinationItem, function(status)
				if originOwner.type ~= destinationOwner.type or originOwner.owner ~= destinationOwner.owner then
					if status then
						if destinationItem.type == 1 then
							if originOwner.type == 1 then
								TriggerClientEvent("pw_inventory:client:RemoveWeapon", mPlayer:GetData('source'), destinationItem.itemId)
							end
	
							if destinationOwner.type == 1 then
								if destinationOwner.owner == char:GetData('id') then
									TriggerClientEvent("pw_inventory:client:AddWeapon", mPlayer:GetData('source'), destinationItem.itemId)
									TriggerClientEvent('mythic_base:client:AddComponentFromItem', mPlayer:GetData('source'), GetHashKey(destinationItem.itemId), destinationItem.metadata.components)
								else
									MySQL.Async.fetchScalar('SELECT user FROM characters WHERE id = @charid LIMIT 1', { ['@charid'] = tonumber(destinationOwner.owner) }, function(res)
										if res ~= nil then
											local tPlayer = exports['mythic_base']:FetchComponent('Fetch'):UserId(res)
											if tPlayer ~= nil then
												TriggerClientEvent("pw_inventory:client:AddWeapon", tPlayer:GetData('source'), destinationItem.itemId)
												TriggerClientEvent('mythic_base:client:AddComponentFromItem', tPlayer:GetData('source'), GetHashKey(destinationItem.itemId), destinationItem.metadata.components)
											end
										end
									end)
								end
							end
						end
					end
	
					if originOwner.type == 2 then
						MySQL.Async.fetchScalar('SELECT COUNT(identifier) As DropInventory FROM `stored_items` WHERE `inventoryType` = @type AND `identifier` = @owner', { ['@type'] = originOwner.type, ['@owner'] = tostring(originOwner.owner) }, function(count)
							if tonumber(count) < 1 then
								TriggerClientEvent('pw_inventory:client:CloseSecondary', -1, originOwner)
								TriggerEvent('pw_inventory:server:RemoveBag', originOwner)
							else
								TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
							end
						end)
					else
						TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
					end
				else
					TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
				end
			end)
		end
	end)
end)

RegisterServerEvent('pw_inventory:server:SplitStack')
AddEventHandler('pw_inventory:server:SplitStack', function(originOwner, originItem, destinationOwner, destinationItem, moveQty)
    local src = source
	local mPlayer = exports['pw_base']:Source(src)
	
	Citizen.CreateThread(function()
		if originOwner.type == 18 then
			-- Shop Purchase Item
			local playerBalance = mPlayer:Cash().getCash()
			if(moveQty * originItem.price <= playerBalance) then
				mPlayer:Cash().Remove((moveQty * originItem.price))
				TriggerClientEvent('pw_inventory:client:updatePlayerCash', src, mPlayer:Cash().getCash())
				if originItem.type == "Weapon" then
					mPlayer:Inventories():AddItem():Player().Weapon(originItem.itemId, 0, false, destinationItem.slot)
				else
					mPlayer:Inventories():AddItem():Player().Slot(originItem.itemId, moveQty, destinationItem.slot)
				end
			end
		elseif originOwner.type == 21 then
			local valid = false
			local craftingRequired = json.decode(originItem.crafting)
			for k, v in pairs(craftingRequired) do
				local currentCount = mPlayer:Inventories().getItemCount(k)
				if currentCount < (tonumber(v) * tonumber(moveQty)) then
					valid = true
				end
			end

			if not valid then
				for k, v in pairs(craftingRequired) do
					mPlayer:Inventories():Remove().byName(k, (tonumber(v) * tonumber(moveQty)))
				end
				-- Crafting Item
				if originItem.type == "Weapon" then
					mPlayer:Inventories():AddItem():Player().Weapon(originItem.itemId, 0, false, destinationItem.slot)
				else
					mPlayer:Inventories():AddItem():Player().Slot(originItem.itemId, moveQty, destinationItem.slot)
				end
				TriggerClientEvent('pw_inventory:client:RefreshInventory', src)
			end
		else
			-- Other Moves
			mPlayer:Inventories():Move().Split(originOwner, originItem, destinationOwner, destinationItem, moveQty, function(status)
				if originOwner.type ~= destinationOwner.type or originOwner.owner ~= destinationOwner.owner then
					if originOwner.type == 2 then
						MySQL.Async.fetchScalar('SELECT COUNT(identifier) As DropInventory FROM `stored_items` WHERE `inventoryType` = @type AND `identifier` = @owner', { ['@type'] = originOwner.type, ['@owner'] = originOwner.owner}, function(count)
							if count < 1 then
								TriggerClientEvent('pw_inventory:client:CloseSecondary', -1, originOwner)
								TriggerEvent('pw_inventory:server:RemoveBag', originOwner)
							end
						end)
					else
						TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
					end
				else
					TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
				end
			end)
		end
	end)
end)

RegisterServerEvent('pw_inventory:server:CombineStack')
AddEventHandler('pw_inventory:server:CombineStack', function(originOwner, originItem, destinationOwner, destinationItem)
    local src = source
	local mPlayer = exports['pw_base']:Source(src)
	
	Citizen.CreateThread(function()
		mPlayer:Inventories():Move().Combine(originOwner, originItem, destinationOwner, destinationItem.slot, function(status)
			local isDropClosing = false
			if originOwner.type ~= destinationOwner.type or originOwner.owner ~= destinationOwner.owner then
				if originOwner.type == 2 then
					MySQL.Async.fetchScalar('SELECT COUNT(identifier) As DropInventory FROM `stored_items` WHERE `inventoryType` = @type AND `identifier` = @owner', { ['@type'] = originOwner.type, ['@owner'] = originOwner.owner }, function(count)
						if count < 1 then
							isDropClosing = true
							TriggerClientEvent('pw_inventory:client:CloseSecondary', -1, originOwner)
							TriggerEvent('pw_inventory:server:RemoveBag', originOwner)
						else
							TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
						end
					end)
				else
					TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
				end
			else
				TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
			end
		end)
	end)
end)

RegisterServerEvent('pw_inventory:server:TopoffStack')
AddEventHandler('pw_inventory:server:TopoffStack', function(originOwner, originItem, destinationOwner, destinationItem)
    local src = source
	local mPlayer = exports['pw_base']:Source(src)
	
	
	Citizen.CreateThread(function()
		mPlayer:Inventories():Move().Topoff(originOwner, originItem, destinationOwner, destinationItem, function()
			TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
		end)
	end)
end)

RegisterServerEvent('pw_inventory:server:SwapItems')
AddEventHandler('pw_inventory:server:SwapItems', function(originOwner, originItem, destinationOwner, destinationItem)
    local src = source
	local mPlayer = exports['pw_base']:Source(src)

	Citizen.CreateThread(function()
		mPlayer.Inventories():Move().Swap(originOwner, originItem, destinationOwner, destinationItem, function(status)
			if (originOwner.type ~= destinationOwner.type or originOwner.owner ~= destinationOwner.owner) and status then
				if originOwner.type == 1 then
					MySQL.Async.fetchScalar('SELECT user FROM characters WHERE cid = @charid LIMIT 1', { ['@charid'] = originOwner.owner }, function(res)
						if res ~= nil then
							local tPlayer = exports['mythic_base']:FetchComponent('Fetch'):UserId(res)
							if destinationItem.type == 1 then
								TriggerClientEvent("pw_inventory:client:RemoveWeapon", tPlayer:GetData('source'), destinationItem.itemId)
							end
							if originItem.type == 1 then
								TriggerClientEvent("pw_inventory:client:AddWeapon", tPlayer:GetData('source'), originItem.itemId)
								TriggerClientEvent('mythic_base:client:AddComponentFromItem', tPlayer:GetData('source'), originItem.itemId, originItem.metadata.components)
							end
						end
					end)
				end

				if destinationOwner.type == 1 then
					MySQL.Async.fetchScalar('SELECT user FROM characters WHERE cid = @charid LIMIT 1', { ['@charid'] = destinationOwner.owner }, function(res)
						if res ~= nil then
							local tPlayer = exports['mythic_base']:FetchComponent('Fetch'):UserId(res)
							if originItem.type == 1 then
								TriggerClientEvent("pw_inventory:client:RemoveWeapon", tPlayer:GetData('source'), originItem.itemId)
							end
							if destinationItem.type == 1 then
								TriggerClientEvent("pw_inventory:client:AddWeapon", tPlayer:GetData('source'), destinationItem.itemId)
								TriggerClientEvent('mythic_base:client:AddComponentFromItem', tPlayer:GetData('source'), destinationItem.itemId, destinationItem.metadata.components)
							end
						end
					end)
				end
			end
			TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
		end)
	end)
end)

RegisterServerEvent('pw_inventory:server:GiveItem')
AddEventHandler('pw_inventory:server:GiveItem', function(target, item, count)
	local src = source
	local mPlayer = exports['pw_base']:Source(src)
	local char = mPlayer:Character()
	local tPlayer = exports['pw_base']:Source(target)

	if tPlayer ~= nil then
		local tChar = tPlayer:Character()
		Citizen.CreateThread(function()
			mPlayer.Inventories():Remove().Give(tChar:getCID(), item, count, function()
				TriggerClientEvent('pw_inventory:client:RefreshInventory', char:getSource())
				TriggerClientEvent('pw_inventory:client:RefreshInventory', tChar:getSource())
			end)
		end)
	end
end)

RegisterServerEvent('pw_inventory:server:RemoveItem')
AddEventHandler('pw_inventory:server:RemoveItem', function(uId, qty, disableNotif)
    local src = source
    local mPlayer = exports['mythic_base']:FetchComponent('Fetch'):Source(src)
	local char = mPlayer:GetData('character')
	
	if qty < 1 then
		qty = 1
	end

	Citizen.CreateThread(function()
		char.Inventory.Remove.Personal:UID(uId, qty, function(status)
			TriggerClientEvent('pw_inventory:client:RefreshInventory', src)
		end, disableNotif)
	end)
end)

RegisterServerEvent('pw_inventory:server:GetPlayerInventory')
AddEventHandler('pw_inventory:server:GetPlayerInventory', function()
	GetPlayerInventory(source)
end)

PW.RegisterServerCallback('pw_inventory:doCraftingRequiredItemsCheck', function(source, cb, data)
	local _src = source
	local _char = exports['pw_base']:Source(_src)
	local requestedAmount = tonumber(data.requestedAmount)
	if data.itemRequested.crafting == nil then
		cb(false)
	else
		local validAmount = false
		local reqItems = json.decode(data.itemRequested.crafting)
		for k, v in pairs(reqItems) do
			local currentCount = _char:Inventories().getItemCount(k)
			if currentCount < (tonumber(v) * tonumber(requestedAmount)) then
				validAmount = true
			end
		end
		cb(validAmount)
	end
end)

RegisterServerEvent('pw_inventory:server:GetSecondaryInventory')
AddEventHandler('pw_inventory:server:GetSecondaryInventory', function(source2, owner)
	if Config.Blacklist[owner.type] then return end

	local src = source2
	local pwbase = exports['pw_base']:FetchComponent()

	if owner.type ~= 18 and owner.type ~= 21 then
		pwbase.Inventory(owner.type, owner.owner, function(items)
			local tier = 0

			if InvSlots[owner.type] ~= nil then
				tier = InvSlots[owner.type]
			else
				tier = InvSlots[0]
			end
		
			local data = {
				invId = owner,
				invTier = tier,
				inventory = items,
			}
		
			if owner.type == 2 and #items == 0 then
				TriggerEvent('pw_inventory:server:RemoveBag', owner)
			else
				TriggerClientEvent('pw_inventory:client:SetupSecondUI', src, data)
			end
		end)
	else
		local itemsSql
		if owner.type == 21 then
			itemsSql = MySQL.Sync.fetchScalar("SELECT `items` FROM `crafting_items` WHERE `itemset_id` = @id", {['@id'] = craftingStations[tonumber(owner.owner)].crafting_items})
		else
			itemsSql = MySQL.Sync.fetchScalar("SELECT `items` FROM `shop_items` WHERE `itemset_id` = @id", {['@id'] = shops[tonumber(owner.owner)].shop_items})
		end
		
		local items = json.decode(itemsSql)
		local itemsObject = {}
		for k, itemId in pairs(items) do
			local v = itemsDatabase[itemId]

			table.insert(itemsObject, {
				id = v['record_id'],
				itemId = v['item_name'],
				description = v["item_description"],
				qty = 1,
				slot = k,
				label = v['item_label'],
				type = v['item_type'],
				max = v['item_max'],
				image = v['item_image'],
				stackable = v['item_stackable'],
				unique = v['item_unique'],
				usable = false,
				metadata = nil,
				metaprivate = nil,
				itemMeta = nil,
				canRemove = true,
				price = v['item_price'],
				needs = v['item_needsboost'],
				closeUi = v['item_closeui'],
				detector = v['item_metalDetect'],
				crafting = v['item_crafting']
			})
		end

		local tier = 0
		if InvSlots[owner.type] ~= nil then
			tier = InvSlots[owner.type]
		else
			tier = InvSlots[0]
		end
	
		local data = {
			invId = owner,
			invTier = tier,
			inventory = itemsObject,
		}
	
		if owner.type == 2 and #itemsObject == 0 then
			TriggerEvent('pw_inventory:server:RemoveBag', owner)
		else
			TriggerClientEvent('pw_inventory:client:SetupSecondUI', src, data)
		end
	end
end)

RegisterServerEvent('pw_inventory:server:RobPlayer')
AddEventHandler('pw_inventory:server:RobPlayer', function(target)
	local src = source

	local myPed = GetPlayerPed(src)
	local myPos = GetEntityCoords(myPed)
	local tPed = GetPlayerPed(target)
	local tPos = GetEntityCoords(tPed)

	local dist = #(myPos - tPos)

	if dist < 2.51 then
		local char = exports['mythic_base']:FetchComponent('Fetch'):Source(src):GetData('character')
		local cData = char:GetData()
		local tPlayer = exports['mythic_base']:FetchComponent('Fetch'):Source(target)
		if tPlayer ~= nil then
			tChar = tPlayer:GetData('character'):GetData()
			TriggerEvent('pw_inventory:server:GetSecondaryInventory', target)
		end
	else
		exports['mythic_base']:FetchComponent('PownzorAction'):PermanentBanSource(src, 'Get Fucked', 'Pwnzor')
	end
end)

AddEventHandler('mythic_base:shared:ComponentRegisterReady', function()
    exports['mythic_base']:ExtendComponent('Inventory', PWInv.Inventory)
end)