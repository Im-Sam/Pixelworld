function fetchDatabase(name)
    local processed = false
    local database
    if name == "items" then
        MySQL.Async.fetchAll("SELECT * FROM `items_database`", {}, function(result)
            database = {}
            for i = 1, #result do
                database[result[i].item_name] = result[i]
            end
            processed = true
        end)
    end

    repeat Wait(0) until processed == true
    return database
end

exports('FetchDatabase', function(name)
    return fetchDatabase(name)
end)

function fetchItemData(item, cb)
    local items = {}
    MySQL.Async.fetchAll("SELECT * FROM `items_database`", {}, function(result)
        database = {}
        for i = 1, #result do
            items[result[i].item_name] = result[i]
        end
        if items[item] then
            cb(items[item])
        else
            cb(nil)
        end
    end)
end

function FetchComponent()
    local component = {}
    component.Inventory = function(itype, owner, cb)
        MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `inventoryType` = @ty AND `identifier` = @owner", {['ty'] = itype, ['owner'] = owner}, function(inv)
            local items = {}
            local processed = false
                if inv[1] ~= nil then
                    for k, v in pairs(inv) do
                        MySQL.Async.fetchAll("SELECT * FROM `items_database` WHERE `item_name` = @item", { ['item'] = v.item}, function(detailss)
                            details = detailss[1]
                            processed = false
                            local meta = {}
                            local metapri = {}
                            local itemMeta = {}

                            if details.item_reqmeta ~= nil then
                                itemMeta = json.decode(details.item_reqmeta)
                            end

                            if v.metaprivate ~= nil then
                                metapri = json.decode(v.metaprivate)
                            end

                            if v.metapublic ~= nil then
                                meta = json.decode(v.metapublic)
                            end

                            table.insert(items, {
                                id = v["record_id"],
                                itemId = details.item_id,
                                description = details.item_description,
                                qty = v["count"],
                                slot = v["slot"],
                                item = v["item"],
                                label = details.item_label,
                                type = details.item_type,
                                max = details.item_max,
                                image = details.item_image,
                                stackable = details.item_stackable,
                                unique = details.item_unique,
                                usable = details.item_usable,
                                metadata = meta,
                                metaprivate = metapri,
                                itemMeta = itemMeta,
                                canRemove = true,
                                price = details.item_price or 0,
                                needs = details.item_needsboost,
                                closeUi = details.item_closeui,
                            })
                            processed = true
                        end)
                    end
                else
                    processed = true
                end
            repeat Wait(0) until processed == true
            repeat Wait(0) until #items == #inv
            cb(items)
        end)
    end
    return component
end

exports('FetchComponent', function()
    return FetchComponent()
end)