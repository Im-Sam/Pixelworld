function User(uid)

    local charSelf = {}
    charSelf.uid = uid
    charSelf.loadedChar = 0
    charSelf.motelRoom = nil
    charSelf.duty = false

    charSelf.User = function()
        local userInfo = {}
        local queryDone = false
        MySQL.Async.fetchAll("SELECT * FROM `users` WHERE `unique_id` = @uid", {['@uid'] = charSelf.uid}, function(usr)
            if usr[1] ~= nil then
                userInfo.getSteam = function()
                    return usr[1].steam
                end

                userInfo.getFiveM = function()
                    return usr[1].license
                end

                userInfo.getPermission = function()
                    return usr[1].permission
                end

                userInfo.getPrioLevel = function()
                    return usr[1].prio
                end

                userInfo.getUID = function()
                    return usr[1].unique_id
                end
            end
            queryDone = true
        end)
        repeat Wait(0) until queryDone == true
        return userInfo
    end

    charSelf.avaCharacters = function()
        local processed = false
        local characters = {}
        MySQL.Async.fetchAll("SELECT * FROM `characters` WHERE `uid` = @uid", {['@uid'] = charSelf.uid}, function(cs)
            for k, v in pairs(cs) do
                table.insert(characters, { ['cid'] = v.cid, ['uid'] = v.uid })
            end
            processed = true
        end)
        repeat Wait(0) until processed == true
        return characters
    end

    charSelf.loadCharacter = function(src, cid)
        charSelf.loadedChar = cid
        charSelf.source = src
        TriggerClientEvent('pw_chat:refreshChat', charSelf.source)
        exports.pw_banking:current(tonumber(charSelf.loadedChar)).updateSource(src)
        charSelf.duty = false
        return true
    end

    charSelf.unloadCharacter = function()
        print(' ^1[PixelWorld Framework] ^5-^4 Unloading Character^7')
        if charSelf.motelRoom ~= nil then
            TriggerEvent('pw_motels:server:unassignRoom', charSelf.source, charSelf.loadedChar, charSelf.motelRoom)
            charSelf.motelRoom = nil
        end
        exports.pw_banking:current(tonumber(charSelf.loadedChar)).updateSource()
        charSelf.loadedChar = 0
        charSelf.source = 0
        charSelf.duty = false
        return true
    end 

    charSelf.Phone = function()
        local phone = {}
        phone.getActiveNumber = function()
            return math.random(11111111,99999999)
        end
        return phone
    end

    charSelf.Cash = function()
        local cash = {}

        cash.getCash = function()
            local processed = false
            local currentCash
            MySQL.Async.fetchScalar("SELECT `cash` FROM `characters` WHERE `cid` = @cid AND `uid` = @uid", {['@cid'] = charSelf.loadedChar, ['@uid'] = charSelf.uid}, function(playerCash)
                currentCash = playerCash
                processed = true
            end)
            repeat Wait(0) until processed == true
            return math.floor(currentCash)
        end

        cash.Add = function(amount)
            local processed = false
            local success
            if type(amount) == "number" then
                MySQL.Async.execute("UPDATE `characters` SET `cash` = `cash` + @amt WHERE `cid` = @cid AND `uid` = @uid", {['@amt'] = amount, ['@cid'] = charSelf.loadedChar, ['uid'] = charSelf.uid}, function(done)
                    if done == 1 then
                        success = true
                    else
                        success = false
                    end
                    processed = true
                end)
            else
                success = false
                processed = true
            end
            repeat Wait(0) until processed == true
            if charSelf.source ~= nil and charSelf.source > 0 then
                local newCash = cash.getCash()
                TriggerClientEvent('pw_banking:updateCash', charSelf.source, newCash)
            end
            return success
        end

        cash.Remove = function(amount)
            local processed = false
            local success = false
            if type(amount) == "number" then
                MySQL.Async.fetchScalar("SELECT `cash` FROM `characters` WHERE `cid` = @cid AND `uid` = @uid", {['@cid'] = charSelf.loadedChar, ['@uid'] = charSelf.uid}, function(playerCash)
                    if playerCash >= amount then
                        MySQL.Async.execute("UPDATE `characters` SET `cash` = `cash` - @amt WHERE `cid` = @cid AND `uid` = @uid", {['@amt'] = amount, ['@cid'] = charSelf.loadedChar, ['@uid'] = charSelf.uid}, function(done)
                            if done == 1 then
                                success = true
                            else
                                success = false
                            end
                            processed = true
                        end)
                    else
                        success = false
                        processed = true
                    end
                end)
            else
                success = false
                processed = true
            end
            repeat Wait(0) until processed == true
            if charSelf.source ~= nil and charSelf.source > 0 then
                local newCash = cash.getCash()
                TriggerClientEvent('pw_banking:updateCash', charSelf.source, newCash)
            end
            return success
        end

        return cash
    end

    charSelf.Bank = function()
        local bank = {}

        bank.Add = function(amount, statement)
            return exports.pw_banking:current(tonumber(charSelf.loadedChar)).AddMoney(amount, statement)
        end

        bank.Remove = function(amount, statement)
            return exports.pw_banking:current(tonumber(charSelf.loadedChar)).RemoveMoney(amount, statement)
        end

        bank.getBalance = function()
            return exports.pw_banking:current(tonumber(charSelf.loadedChar)).GetBalance()
        end

        bank.GetBankAccount = function()
            return { ['account_number'] = exports.pw_banking:current(tonumber(charSelf.loadedChar)).GetAccountNo(), ['sort_code'] = exports.pw_banking:current(tonumber(charSelf.loadedChar)).GetSortCode(), ['amount'] = exports.pw_banking:current(tonumber(charSelf.loadedChar)).GetBalance() }
        end

        bank.GetStatement = function()
            return exports.pw_banking:current(tonumber(charSelf.loadedChar)).GetStatement()
        end

        bank.GetCardDetails = function()
            if exports.pw_banking:current(tonumber(charSelf.loadedChar)).GetCardStatus() then
                return exports.pw_banking:current(tonumber(charSelf.loadedChar)).GetCardDetails()
            else
                return nil
            end
        end

        bank.ToggleDebitCard = function(toggle)
            return exports.pw_banking:current(tonumber(charSelf.loadedChar)).ToggleDebitCard(toggle)
        end

        bank.UpdateDebitCardPin = function(pin)
            return exports.pw_banking:current(tonumber(charSelf.loadedChar)).UpdateDebitCardPin(pin)
        end

        bank.CreateDebitCard = function(pin)
            if not exports.pw_banking:current(tonumber(charSelf.loadedChar)).GetCardStatus() then
                local success, cardNumber = exports.pw_banking:current(tonumber(charSelf.loadedChar)).CreateDebitCard(pin)
                return success, cardNumber
            end
        end

        return bank
    end

    charSelf.Job = function()
        local job = {}

        job.getJob = function()
            local currentJob = MySQL.Sync.fetchScalar("SELECT `job` FROM `characters` WHERE `cid` = @cid", {['@cid'] = charSelf.loadedChar})
            local returnTable = json.decode(currentJob)
            returnTable.duty = charSelf.duty
            return returnTable
        end

        job.removeJob = function()
            MySQL.Async.fetchAll("SELECT * FROM `job_grades` WHERE `job` = 'unemployed' AND `grade` = 'unemployed'", {}, function(job)
                if job[1] ~= nil then
                    local generateJobTable = {
                        ['job'] = "unemployed",
                        ['label'] = "Unemployed",
                        ['workplace'] = 0,
                        ['grade'] = "unemployed",
                        ['grade_label'] = "Unemployed",
                        ['salery'] = tonumber(job[1].salery),
                        ['grade_level'] = tonumber(job[1].level)
                    }
                    MySQL.Async.execute("UPDATE `characters` SET `job` = @job WHERE `cid` = @cid", {['@job'] = json.encode(generateJobTable), ['@cid'] = charSelf.loadedChar}, function(success)
                        if success > 0 then
                            charSelf.duty = false
                            if charSelf.source > 0 then
                                generateJobTable.duty = charSelf.duty
                                TriggerClientEvent('pw:setJob', charSelf.source, generateJobTable)
                                TriggerClientEvent('pw_chat:refreshChat', charSelf.source)
                                TriggerClientEvent('pw:notification:SendAlert', charSelf.source, {type = "success", text = "We have successfully removed your job.", length = 5000})
                            end
                        end
                    end)
                else
                    if charSelf.source > 0 then
                        TriggerClientEvent('pw_chat:refreshChat', charSelf.source)
                        TriggerClientEvent('pw:notification:SendAlert', charSelf.source, {type = "error", text = "There was an error removing your current job.", length = 5000})
                    end
                end
            end)
        end

        job.setJob = function(jobname, jobgrade, workplace)
            MySQL.Async.fetchAll("SELECT * FROM `avaliable_jobs` WHERE `name` = @job", {['@job'] = jobname}, function(foundJob)
                if foundJob[1] ~= nil then
                    MySQL.Async.fetchAll("SELECT * FROM `job_grades` WHERE `job` = @job AND `grade` = @grade", {['@job'] = jobname, ['@grade'] = jobgrade}, function(foundGrade)
                        if foundGrade[1] ~= nil then
                            local generateJobTable = {
                                ['job'] = foundJob[1].name,
                                ['label'] = foundJob[1].label,
                                ['workplace'] = tonumber(workplace) or 0,
                                ['grade'] = foundGrade[1].grade,
                                ['grade_label'] = foundGrade[1].label,
                                ['salery'] = tonumber(foundGrade[1].salery),
                                ['grade_level'] = tonumber(foundGrade[1].level)
                            }
                            MySQL.Async.execute("UPDATE `characters` SET `job` = @job WHERE `cid` = @cid", {['@job'] = json.encode(generateJobTable), ['@cid'] = charSelf.loadedChar}, function(success)
                                if success > 0 then
                                    charSelf.duty = false
                                    if charSelf.source > 0 then
                                        generateJobTable.duty = charSelf.duty
                                        TriggerClientEvent('pw:setJob', charSelf.source, generateJobTable)
                                        TriggerClientEvent('pw_chat:refreshChat', charSelf.source)
                                        TriggerClientEvent('pw:notification:SendAlert', charSelf.source, {type = "success", text = "We have successfully set your job as: <strong>"..foundJob[1].label.."</strong> with the grade of: <strong>"..foundGrade[1].label.."</strong> working at workplace: <strong>"..(tonumber(workplace) or 0).."</strong> ", length = 5000})
                                    end
                                end
                            end)
                        else
                            -- Error setting job, grade not found
                            if charSelf.source > 0 then
                                TriggerClientEvent('pw_chat:refreshChat', charSelf.source)
                                TriggerClientEvent('pw:notification:SendAlert', charSelf.source, {type = "error", text = "We could not locate the job grade you requested: '"..jobgrade.."'.", length = 5000})
                            end
                        end
                    end)
                else
                    -- Error Setting Job, Job Name not found
                    if charSelf.source > 0 then
                        TriggerClientEvent('pw_chat:refreshChat', charSelf.source)
                        TriggerClientEvent('pw:notification:SendAlert', charSelf.source, {type = "error", text = "We could not locate the job you requested: '"..jobname.."'.", length = 5000})
                    end
                end
            end)
        end

        job.getDuty = function()
            return charSelf.duty
        end

        job.toggleDuty = function()
            charSelf.duty = not charSelf.duty
            if charSelf.source ~= nil and  charSelf.source > 0 then 
                if charSelf.duty then
                    TriggerClientEvent('pw:notification:SendAlert', charSelf.source, {type = "success", text = "You have gone On-Duty.", length = 5000})
                    if job.getJob().job == "police" or job.getJob().job == "ems" or job.getJob().job == "fire" or job.getJob().job == "doctor" then
                        TriggerClientEvent('pw_base:joinRadio', charSelf.source, "add", job.getJob().job)
                    end
                else
                    TriggerClientEvent('pw:notification:SendAlert', charSelf.source, {type = "success", text = "You have gone Off-Duty.", length = 5000})
                    if job.getJob().job == "police" or job.getJob().job == "ems" or job.getJob().job == "fire" or job.getJob().job == "doctor" then
                        TriggerClientEvent('pw_base:joinRadio', charSelf.source, "remove", job.getJob().job)
                    end
                end
            end
            TriggerClientEvent('pw_chat:refreshChat', charSelf.source)
            TriggerClientEvent('pw:toggleDuty', charSelf.source, charSelf.duty)
        end

        return job
    end

    charSelf.Gang = function()
        local gang = {}

        gang.setGang = function(gangid, level)
            if gangid ~= nil and type(gangid) == "number" then
                MySQL.Async.fetchAll("SELECT * FROM `gangs` WHERE `gang_id` = @gang", {['@gang'] = gangid}, function(gangsql)
                    if gangsql[1] ~= nil then
                        local ranks = json.decode(gangsql[1].gang_ranks)
                        if level == nil then
                            level = 0
                        end

                        for k, v in pairs(ranks) do
                            if v == level then
                                local gangTable = { ['gang'] = gangid, ['name'] = gangsql[1].gang_name, ['level'] = level}
                                local gangEncrypted = json.encode(gangTable)
                                MySQL.Async.execute("UPDATE `characters` SET `gang` = @gang WHERE `cid` = @cid AND `uid` = @uid", {['@gang'] = gangEncrypted, ['@cid'] = charSelf.loadedChar, ['@uid'] = charSelf.uid}, function(updated)
                                    if updated == 1 then
                                        if charSelf.source ~= nil and charSelf.source > 0 then
                                            TriggerClientEvent('pw:setGang', charSelf.source, gangTable)
                                            TriggerClientEvent('pw:notification:SendAlert', charSelf.source, {type = "success", text = "Your gang has changed to "..gangsql[1].gang_name, length = 5000})
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end)
            end
        end

        gang.getGang = function()
            local processed = false
            local gangInformation
            MySQL.Async.fetchScalar("SELECT `gang` FROM `characters` WHERE `cid` = @cid AND `uid` = @uid", {['@cid'] = charSelf.loadedChar, ['@uid'] = charSelf.uid}, function(gang)
                if gang ~= nil then
                    gangInformation = json.decode(gang)
                else
                    local gangTable = { ['gang'] = 0, ['name'] = 'None', ['level'] = 0}
                    gangInformation = gangTable
                end
                processed = true
            end)
            repeat Wait(0) until processed == true
            return gangInformation
        end

        return gang
    end

    charSelf.Inventories = function()
        local inventories = {}

        inventories.getMetalicItems = function()
            local items = 0
            local getInventory = MySQL.Sync.fetchAll("SELECT * FROM `stored_items` WHERE `inventoryType` = 1 AND `identifier` = @id", {['@id'] = charSelf.loadedChar})
            for k, v in pairs(getInventory) do
                local metallic = MySQL.Sync.fetchScalar("SELECT `item_metalDetect` FROM `items_database` WHERE `item_name` = @item", {['@item'] = v.item})
                if metallic then
                    items = items + 1
                end
            end
            return items
        end

        inventories.getItemCount = function(item)
            local count = 0
            local query = MySQL.Sync.fetchScalar("SELECT SUM(count) FROM `stored_items` WHERE `inventoryType` = 1 AND `identifier` = @id AND item = @item", {['@id'] = charSelf.loadedChar, ['@item'] = item})
            if query ~= nil and query > 0 then
                count = query
            end

            return count
        end

        inventories.getInventory = function(cb)
            MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `identifier` = @cid AND `inventoryType` = @it", {['@cid'] = charSelf.loadedChar, ['@it'] = 1 }, function(inv)
                local items = {}
                local processed = false
                if inv[1] ~= nil then
                    for k, v in pairs(inv) do
                        processed = false
                        MySQL.Async.fetchAll("SELECT * FROM `items_database` WHERE `item_name` = @item", { ['@item'] = v.item}, function(detailss)
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
                                detector = details.item_metalDetect,
                                crafting = details.item_crafting
                            })
                        end)
                    end
                    repeat Wait(0) until #inv == #items
                    processed = true
                else
                    processed = true
                end
                repeat Wait(0) until processed == true
                cb(items)
            end)
        end

        inventories.getHotBar = function(cb)
            MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `slot` < 6 AND `identifier` = @cid AND `inventoryType` = @it ORDER BY `slot` ASC", { ['@cid'] = charSelf.loadedChar, ['@it'] = 1 }, function(items)
                local returnedItems = {}
                local processed = false
                if items[1] ~= nil then
                    for k, v in pairs(items) do
                        MySQL.Async.fetchAll("SELECT * FROM `items_database` WHERE `item_name` = @item", { ['@item'] = v.item}, function(detailss)
                            details = detailss[1]
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

                            v.id = v.record_id
                            v.itemId = details.item_id
                            v.description = details.item_description
                            v.qty = v.count
                            v.label = details.item_label
                            v.type = details.item_type
                            v.max = details.item_max
                            v.image = details.item_image
                            v.stackable = details.item_stackable
                            v.unique = details.item_unique
                            v.usable = details.item_usable
                            v.metadata = meta
                            v.metaprivate = metapri
                            v.itemMeta = itemMeta
                            v.canRemove = true
                            v.price = details.item_price or 0
                            v.needs = details.item_needsboost
                            v.closeUi = details.item_closeui
                            v.detector = details.item_metalDetect
                            v.crafting = details.item_crafting
                            table.insert(returnedItems, v)
                        end)
                    end
                    repeat Wait(0) until #returnedItems == #items
                    processed = true
                else
                    processed = true
                end
                repeat Wait(0) until processed == true
                cb(items)
            end)
        end

        inventories.getSlot = function(slot, cb)
            MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `slot` = @slot AND `identifier` = @cid AND `inventoryType` = @it", {['@slot'] = slot, ['@cid'] = charSelf.loadedChar, ['@it'] = 1 }, function(item)
                local items = {}
                local processed = false
                if item[1] ~= nil then
                    for k, v in pairs(item) do
                        processed = false
                        MySQL.Async.fetchAll("SELECT * FROM `items_database` WHERE `item_name` = @item", { ['@item'] = v.item}, function(detailss)
                            details = detailss[1]
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

                            items = {
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
                                detector = details.item_metalDetect,
                                crafting = details.item_crafting
                            }
                            processed = true
                        end)
                    end
                else
                    processed = true
                end
                repeat Wait(0) until processed == true
                cb(items)
            end)
        end

        inventories.Move = function()
            local action = {}     
            action.Empty = function(originOwner, originItem, destinationOwner, destinationItem, cb)
                MySQL.Async.execute("UPDATE `stored_items` SET `slot` = @newSlot, `identifier` = @owner, `inventoryType` = @itype WHERE `record_id` = @record", { ['@newSlot'] = destinationItem.slot, ['@record'] = originItem.id, ['@owner'] = destinationOwner.owner, ['@itype'] = destinationOwner.type }, function(changed)
                    if changed == 1 then
                        if originItem.type == "Simcard" and destinationOwner.type == 1 and originOwner.type ~= 18 then
                            if exports['pw_phone']:simCard(tonumber(originItem.metaprivate.number)).getOwner() ~= charSelf.loadedChar then
                                exports['pw_phone']:simCard(tonumber(originItem.metaprivate.number)).updateOwner(tonumber(charSelf.loadedChar))
                            end                            
                        end
                        if cb then
                            cb(true)
                        end
                    else
                        if cb then
                            cb(false)
                        end
                    end
                end)
            end

            action.Split = function(originOwner, originItem, destinationOwner, destinationItem, moveQty, cb)
                MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `slot` = @slot AND `identifier` = @owner AND `inventoryType` = @it", {['@slot'] = destinationItem.slot, ['@owner'] = destinationOwner.owner, ['@it'] = destinationOwner.type}, function(existing)
                    if existing[1] ~= nil then
                        if existing[1].item == originItem.item then
                            MySQL.Async.execute("UPDATE `stored_items` SET `count` = `count` + @moveQty WHERE `record_id` = @record", {['@moveQty'] = moveQty, ['@record'] = existing[1].record_id }, function(changed)
                                    if changed == 1 then
                                        MySQL.Async.execute("UPDATE `stored_items` SET `count` = `count` - @moveQty WHERE `identifier` = @owner AND `inventoryType` = @it AND `slot` = @slot", { ['@moveQty'] = moveQty, ['@owner'] = originOwner.owner, ['@slot'] = originItem.slot, ['@it'] = originOwner.type }, function(changedAgain)
                                            if changedAgain == 1 then
                                                if originItem.type == "Simcard" and destinationOwner.type == 1 and originOwner.type ~= 18 then
                                                    if exports['pw_phone']:simCard(tonumber(originItem.metaprivate.number)).getOwner() ~= charSelf.loadedChar then
                                                        exports['pw_phone']:simCard(tonumber(originItem.metaprivate.number)).updateOwner(tonumber(charSelf.loadedChar))
                                                    end                            
                                                end
                                                if cb then
                                                    cb(true)
                                                end
                                            else
                                                MySQL.Async.execute("UPDATE `stored_items` SET `count` = `count` - @moveQty WHERE `record_id` = @record", {['@moveQty'] = moveQty, ['@record'] = existing[1].record_id }, function(changed)
                                                    if cb then
                                                        cb(false)
                                                    end
                                                end)                
                                            end
                                        end)
                                    else
                                        if cb then
                                            cb(false)
                                        end
                                    end
                                end)
                        else
                            if cb then
                                cb(false)
                            end
                        end
                    else
                        local itemMetaPub = {}
                        local itemMetaPri = {}
                        if originItem.metadata ~= nil then
                            itemMetaPub = originItem.metadata
                        end

                        if originItem.metaprivate ~= nil then
                            itemMetaPri = originItem.metaprivate 
                        end
                        MySQL.Async.insert("INSERT INTO `stored_items` (`identifier`, `inventoryType`, `item`, `count`, `metapublic`, `metaprivate`, `type`, `slot`) VALUES (@cid, @it, @item, @count, @mp, @mpr, @type, @slot)", {['@cid'] = destinationOwner.owner, ['@it'] = destinationOwner.type, ['@item'] = originItem.item, ['@count'] = moveQty, ['@type'] = originItem.type, ['@mp'] = json.encode(itemMetaPub), ['@mpr'] = json.encode(itemMetaPri), ['@slot'] = destinationItem.slot }, function(inserted)
                            if inserted > 0 then
                                MySQL.Async.execute("UPDATE `stored_items` SET `count` = `count` - @moveQty WHERE `record_id` = @record", { ['@moveQty'] = moveQty, ['@record'] = originItem.id }, function(changed)
                                    if changed == 1 then
                                        if originItem.type == "Simcard" and destinationOwner.type == 1 and originOwner.type ~= 18 then
                                            if exports['pw_phone']:simCard(tonumber(originItem.metaprivate.number)).getOwner() ~= charSelf.loadedChar then
                                                exports['pw_phone']:simCard(tonumber(originItem.metaprivate.number)).updateOwner(tonumber(charSelf.loadedChar))
                                            end                            
                                        end
                                        if cb then
                                            cb(true)
                                        end
                                    else
                                        MySQL.Async.execute("DELETE FROM `stored_items` WHERE `record_id` = @itemid", { ['@itemid'] = inserted }, function()
                                            if cb then
                                                cb(false)
                                            end
                                        end)
                                    end
                                end)
                            else
                                if cb then
                                    cb(false)
                                end
                            end
                        end)
                    end
                end)
            end

            action.Combine = function(originOwner, originItem, destinationOwner, destinationItem, cb)
                MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `identifier` = @cid AND `inventoryType` = @it AND `slot` = @slot", {['@cid'] = originOwner.owner, ['@it'] = originOwner.type, ['@slot'] = originItem }, function(originalItem)
                    if originalItem[1] ~= nil then
                        MySQL.Async.execute("UPDATE `stored_items` SET `count` = `count` + @newCount WHERE `identifier` = @cid AND `inventoryType` = @it AND `slot` = @slot", {['@cid'] = destinationOwner.owner, ['@it'] = destinationOwner.type, ['@slot'] = destinationItem, ['@newCount'] = originalItem[1].count }, function(changed)
                            if changed == 1 then
                                if originalItem[1].type == "Simcard" and destinationOwner.type == 1 and originOwner.type ~= 18 then
                                    if exports['pw_phone']:simCard(tonumber(originItem.metaprivate.number)).getOwner() ~= charSelf.loadedChar then
                                        exports['pw_phone']:simCard(tonumber(originItem.metaprivate.number)).updateOwner(tonumber(charSelf.loadedChar))
                                    end                            
                                end
                                MySQL.Async.execute("DELETE FROM `stored_items` WHERE `record_id` = @id", {['@id'] = originalItem[1].record_id}, function(changed)
                                    if changed == 1 then
                                        if cb then
                                            cb(true)
                                        end
                                    else
                                        MySQL.Async.execute("UPDATE `stored_items` SET `count` = `count` - @newCount WHERE `identifier` = @cid AND `inventoryType` = @it AND `slot` = @slot", { ['@cid'] = destinationOwner.owner, ['@it'] = destinationOwner.type, ['@slot'] = destinationItem, ['@newCount'] = originalItem[1].count }, function(changed)
                                            if cb then
                                                cb(false)
                                            end
                                        end)
                                    end
                                end)
                            else
                                if cb then
                                    cb(false)
                                end
                            end
                        end)
                    else
                        if cb then
                            cb(false)
                        end
                    end
                end)
            end

            action.Topoff = function(originOwner, originItem, destinationOwner, destinationItem, cb)
                MySQL.Async.execute("UPDATE `stored_items` SET `count` = @newCount WHERE `identifier` = @cid AND `inventoryType` = @it AND `slot` = @slot", {['@newCount'] = originItem.qty, ['@cid'] = originOwner.owner, ['@it'] = originOwner.type, ['@slot'] = originItem.slot}, function(changed1)
                    if changed1 == 1 then
                        if originItem.type == "Simcard" and destinationOwner.type == 1 and originOwner.type ~= 18 then
                            if exports['pw_phone']:simCard(tonumber(originItem.metaprivate.number)).getOwner() ~= charSelf.loadedChar then
                                exports['pw_phone']:simCard(tonumber(originItem.metaprivate.number)).updateOwner(tonumber(charSelf.loadedChar))
                            end                            
                        end
                        MySQL.Async.execute("UPDATE `stored_items` SET `count` = @newCount WHERE `identifier` = @cid AND `inventoryType` = @it AND `slot` = @slot", {['@newCount'] = destinationItem.qty, ['@cid'] = destinationOwner.owner, ['@it'] = destinationOwner.type, ['@slot'] = destinationItem.slot }, function(changed2)
                            if changed2 == 1 then
                                if cb then
                                    cb(true)
                                end
                            end
                        end)
                    else
                        if cb then
                            cb(false)
                        end
                    end
                end)
            end

            action.Swap = function(originOwner, originItem, destinationOwner, destinationItem, cb)
                MySQL.Async.execute("UPDATE `stored_items` SET `slot` = @slot, `identifier` = @owner, `inventoryType` = @it WHERE `record_id` = @record", {
                    ['@slot'] = destinationItem.slot,
                    ['@owner'] = destinationOwner.owner,
                    ['@it'] = destinationOwner.type,
                    ['@record'] = destinationItem.id
                }, function(moved)
                    if moved == 1 then
                        MySQL.Async.execute("UPDATE `stored_items` SET `slot` = @slot, `identifier` = @owner, `inventoryType` = @it WHERE `record_id` = @record", {
                            ['@slot'] = originItem.slot,
                            ['@owner'] = originOwner.owner,
                            ['@it'] = originOwner.type,
                            ['@record'] = originItem.id
                        }, function(moved2)
                            if moved2 == 1 then
                                if originItem.type == "Simcard" and destinationOwner.type == 1 and originOwner.type ~= 18 then
                                    if exports['pw_phone']:simCard(tonumber(originItem.metaprivate.number)).getOwner() ~= charSelf.loadedChar then
                                        exports['pw_phone']:simCard(tonumber(originItem.metaprivate.number)).updateOwner(tonumber(charSelf.loadedChar))
                                    end                            
                                end
                                if cb then
                                    cb(true)
                                end
                            else
                                MySQL.Async.execute("UPDATE `stored_items` SET `slot` = @slot, `identifier` = @owner, `inventoryType` = @it WHERE `record_id` = @record", {
                                    ['@slot'] = originItem.slot,
                                    ['@owner'] = originOwner.owner,
                                    ['@it'] = originOwner.type,
                                    ['@record'] = destinationItem.id
                                }, function(moved)
                                    if cb then
                                        cb(false)
                                    end
                                end)
                            end
                        end)
                    else
                        if cb then
                            cb(false)
                        end
                    end
                end)
            end

            return action           
        end

        inventories.AddItem = function()
            local action = {}
                local function getAvaliableSlot(owner, type, maxSlots)
                    local startSlot = 1
                    local processed = false
                    local slotFree
                    repeat
                        processed = false
                        MySQL.Async.fetchScalar("SELECT `slot` FROM `stored_items` WHERE `identifier` = @owner AND `inventoryType` = @type AND `slot` = @slot", {['@slot'] = startSlot, ['@owner'] = owner, ['@type'] = type}, function(slotFreeSql)
                            slotFree = slotFreeSql
                            processed = true
                        end)
                        repeat Wait(0) until processed == true
                        if slotFree ~= nil then
                            startSlot = startSlot + 1
                        end
                    until slotFree == nil or startSlot > maxSlots
                    return startSlot
                end

                local function getAvaliableSlots(owner, type)
                    local slotsUsed = {}
                    local processed = false
                    MySQL.Async.fetchAll("SELECT `slot` FROM `stored_items` WHERE `identifier` = @owner AND `inventoryType` = @type", {['@owner'] = owner, ['@type'] = type}, function(slots)
                        for k,v in pairs(slots) do
                            if v.slot then
                                slotsUsed[tonumber(v.slot)] = true
                            end
                        end
                        processed = true
                    end)        
                    repeat Wait(0) until processed == true
                    return slotsUsed
                end

                action.Player = function()
                    local player = {}

                    player.Weapon = function(weapon, ammo, notify, slot)
                        fetchItemData(weapon, function(details)
                            local notification = {}
                            math.randomseed(os.time())
                            local generatedSerial = math.random(11111111,99999999)
                            local requestedSlot = getAvaliableSlot(charSelf.loadedChar, 1, 40)
                            local meta = {}
                            meta.private  = { ['serial'] = generatedSerial, ['owner'] = Users[charSelf.uid]:Character().getName(), ['cid'] = Users[charSelf.uid]:Character().getCID(), ['uid'] = charSelf.uid }
                            meta.public   = { ['registeredkeeper'] = Users[charSelf.uid]:Character().getName(), }
                            TriggerEvent('pw_weapons:server:registerFirearm', {name = weapon, qty = ammo}, generatedSerial, Users[charSelf.uid], false)
                            MySQL.Async.insert("INSERT INTO `stored_items` (`identifier`, `inventoryType`, `item`, `count`, `metapublic`, `metaprivate`,`type`,`slot`) VALUES (@ident, 1, @item, @qty, @pub, @pri, @type, @slot)", {
                                ['@ident'] = charSelf.loadedChar,
                                ['@item'] = details.item_name,
                                ['@pub'] = json.encode(meta.public),
                                ['@pri'] = json.encode(meta.private),
                                ['@type'] = details.item_type,
                                ['@slot'] = (slot or requestedSlot),
                                ['@qty'] = 1                                
                            }, function(inserted)
                                if inserted > 0 then
                                    if notify then
                                        table.insert(notification, { item = {label = details.item_label, image = details.item_image}, qty = 1, message = 'Weapon Received' })
                                        TriggerClientEvent('pw_inventory:client:useItemNotif', charSelf.source, notification)
                                    end
                                    success = true
                                else
                                    success = false
                                end
                                processed = true
                            end)
                        end)
                    end

                    player.Slot = function(name, qty, slot, meta)
                        local processed = false
                        local success = false
                        if meta == nil then
                            meta = {}
                        end

                        meta.public = meta.public or {}
                        meta.private = meta.private or {}

                        fetchItemData(name, function(details)
                            if details.item_type ~= "Weapon" then
                                if details.item_type == "Simcard" then
                                    local simCard = exports['pw_phone']:registerSim(charSelf.loadedChar)
                                    repeat Wait(0) until simCard ~= nil
                                    meta.public['number'] = simCard
                                    meta.private['number'] = simCard
                                end
                                MySQL.Async.insert("INSERT INTO `stored_items` (`identifier`, `inventoryType`, `item`, `count`, `metapublic`, `metaprivate`,`type`,`slot`) VALUES (@ident, 1, @item, @count, @pub, @pri, @type, @slot)", {
                                    ['@ident'] = charSelf.loadedChar,
                                    ['@item'] = details.item_name,
                                    ['@pub'] = json.encode(meta.public),
                                    ['@pri'] = json.encode(meta.private),
                                    ['@type'] = details.item_type,
                                    ['@count'] = qty,
                                    ['@slot'] = slot
                                }, function(inserted)
                                    if inserted > 0 then
                                        success = true
                                    else
                                        success = false
                                    end
                                    processed = true
                                end)
                            end
                        end)

                    end

                    player.Single = function(name, qty, meta)
                        local processed = false
                        local success = false
                        local notification = {}
                        if meta == nil then
                            meta = {}
                        end

                        if qty == nil then
                            qty = 1
                        end

                        meta.public = meta.public or {}
                        meta.private = meta.private or {}

                        fetchItemData(name, function(details)
                            if details.item_type ~= "Weapon" then
                                if details.item_stackable then
                                    if qty > details.item_max then
                                        local amountOfStacks = math.floor(qty/details.item_max)
                                        local qtyLeft = qty - (amountOfStacks * details.item_max)
                                        local slotsUsed = getAvaliableSlots(charSelf.loadedChar, 1)
                                        local multiQuery
                                        if amountOfStacks > 1 then
                                            for i = 1, amountOfStacks do
                                                for j = 1, 40 do
                                                    if slotsUsed[j] == nil then
                                                        slotsUsed[j] = true
                                                        if multiQuery == nil then
                                                            multiQuery = "(@ident, 1, @item, " .. details.item_max .. ", @pub, @pri, @type, " .. j ..")"
                                                        else
                                                            multiQuery = multiQuery .. ",(@ident, 1, @item, " .. details.item_max .. ", @pub, @pri, @type, " .. j ..")"
                                                        end
                                                        break
                                                    end
                                                end
                                            end
                                            if qtyLeft > 0 then
                                                for k = 1, 40 do
                                                    if slotsUsed[k] == nil then
                                                        slotsUsed[k] = true
                                                        multiQuery = multiQuery .. ",(@ident, 1, @item, " .. qtyLeft .. ", @pub, @pri, @type, " .. k ..")"        
                                                        break
                                                    end
                                                end
                                            end
                                        elseif amountOfStacks == 1 then
                                            local useSlot = getAvaliableSlot(charSelf.loadedChar, 1, 40)
                                            slotsUsed[useSlot] = true
                                            multiQuery = "(@ident, 1, @item, " .. details.item_max .. ", @pub, @pri, @type, " .. useSlot ..")"
                                            for k = 1, 40 do
                                                if slotsUsed[k] == nil then
                                                    slotsUsed[k] = true    
                                                    multiQuery = multiQuery .. ",(@ident, 1, @item, " .. qtyLeft .. ", @pub, @pri, @type, " .. k ..")"
                                                    break
                                                end
                                            end
                                        end
                            
                                        MySQL.Async.insert("INSERT INTO `stored_items` (`identifier`, `inventoryType`, `item`, `count`, `metapublic`, `metaprivate`,`type`,`slot`) VALUES "..multiQuery, {
                                            ['@ident'] = charSelf.loadedChar,
                                            ['@item'] = details.item_name,
                                            ['@pub'] = json.encode(meta.public),
                                            ['@pri'] = json.encode(meta.private),
                                            ['@type'] = details.item_type,                                        
                                        }, function(inserted)
                                            if inserted > 0 then
                                                table.insert(notification, { item = {label = details.item_label, image = details.item_image}, qty = qty, message = 'Item Received' })
                                                success = true
                                            else
                                                success = false
                                            end
                                            processed = true
                                        end)
                                    else
                                        local requestedSlot = getAvaliableSlot(charSelf.loadedChar, 1, 40)
                                        MySQL.Async.insert("INSERT INTO `stored_items` (`identifier`, `inventoryType`, `item`, `count`, `metapublic`, `metaprivate`,`type`,`slot`) VALUES (@ident, 1, @item, @count, @pub, @pri, @type, @slot)", {
                                            ['@ident'] = charSelf.loadedChar,
                                            ['@item'] = details.item_name,
                                            ['@pub'] = json.encode(meta.public),
                                            ['@pri'] = json.encode(meta.private),
                                            ['@type'] = details.item_type,
                                            ['@count'] = qty,
                                            ['@slot'] = requestedSlot
                                        }, function(inserted)
                                            if inserted > 0 then
                                                table.insert(notification, { item = {label = details.item_label, image = details.item_image}, qty = qty, message = 'Item Received' })
                                                success = true
                                            else
                                                success = false
                                            end
                                            processed = true
                                        end)
                                    end
                                else
                                    local multiQuery
                                    local slotsUsed = getAvaliableSlots(charSelf.loadedChar, 1)
                                    for i = 1, qty do
                                        if i == 1 then
                                            for j = 1, 40 do
                                                if slotsUsed[j] == nil then
                                                    slotsUsed[j] = true
                                                    multiQuery = "(@ident, 1, @item, 1, @pub, @pri, @type, " .. j ..")"
                                                    break
                                                end
                                            end
                                        else
                                            for j = 1, 40 do
                                                if slotsUsed[j] == nil then
                                                    slotsUsed[j] = true
                                                    multiQuery = multiQuery..", (@ident, 1, @item, 1, @pub, @pri, @type, " .. j ..")"
                                                    break
                                                end
                                            end
                                        end
                                    end

                                    MySQL.Async.insert("INSERT INTO `stored_items` (`identifier`, `inventoryType`, `item`, `count`, `metapublic`, `metaprivate`,`type`,`slot`) VALUES "..multiQuery, {
                                        ['@ident'] = charSelf.loadedChar,
                                        ['@item'] = details.item_name,
                                        ['@pub'] = json.encode(meta.public),
                                        ['@pri'] = json.encode(meta.private),
                                        ['@type'] = details.item_type,
                                        ['@slot'] = getAvaliableSlot(charSelf.loadedChar, 1, 40)
                                    }, function(insert)
                                        if insert > 0 then
                                            table.insert(notification, { item = {label = details.item_label, image = details.item_image}, qty = qty, message = 'Item Received' })
                                            success = true
                                            processed = true
                                        end
                                    end)
                                end
                            end
                        end)
                        repeat Wait(0) until processed == true
                        if notification[1] ~= nil then
                            TriggerClientEvent('pw_inventory:client:useItemNotif', charSelf.source, notification)
                        end
                        return success
                    end

                    return player
                end

                action.Drop = function(owner, item, count, cb)
                    local processed = false
                    local success = false
                    local assignedSlot = getAvaliableSlot(owner, 2, 100)
                    MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `record_id` = @id", {['@id'] = item.id}, function(playerItem)
                        if playerItem[1] ~= nil then
                            if playerItem[1].count - count == 0 then
                                MySQL.Async.execute("DELETE FROM `stored_items` WHERE `record_id` = @id", {['@id'] = item.id}, function(deleted)
                                    if deleted == 1 then
                                        local itemPub = {}
                                        local itemPri = {}
                                        if item.metadata ~= nil then
                                            itemPub = item.metadata
                                        end
                
                                        if item.metaprivate ~= nil then
                                            itemPri = item.metaprivate 
                                        end

                                        MySQL.Async.insert("INSERT INTO `stored_items` (`identifier`, `inventoryType`, `item`, `count`, `metapublic`, `metaprivate`, `type`, `slot`) VALUES (@owner, @it, @item, @count, @pub, @pri, @type, @slot)", {
                                            ['@owner'] = owner,
                                            ['@it'] = 2,
                                            ['@item'] = item.item,
                                            ['@count'] = count,
                                            ['@pub'] = json.encode(itemPub),
                                            ['@pri'] = json.encode(itemPri),
                                            ['@type'] = item.type,
                                            ['@slot'] = assignedSlot
                                        }, function(insert)
                                            if insert > 0 then
                                                if cb then
                                                    cb(true)
                                                end
                                            else
                                                if cb then
                                                    cb(false)
                                                end
                                            end
                                        end)
                                    else
                                        if cb then
                                            cb(false)
                                        end
                                    end
                                end)
                            else
                                MySQL.Async.execute("UPDATE `stored_items` SET `count` = `count` - @count WHERE `record_id` = @id", { ['@count'] = count, ['@id'] = item.id }, function(adjusted)
                                    if adjusted == 1 then
                                        local itemPub = {}
                                        local itemPri = {}
                                        if item.metadata ~= nil then
                                            itemPub = item.metadata
                                        end
                
                                        if item.metaprivate ~= nil then
                                            itemPri = item.metaprivate 
                                        end

                                        MySQL.Async.insert("INSERT INTO `stored_items` (`identifier`, `inventoryType`, `item`, `count`, `metapublic`, `metaprivate`, `type`, `slot`) VALUES (@owner, @it, @item, @count, @pub, @pri, @type, @slot)", {
                                            ['@owner'] = owner,
                                            ['@it'] = 2,
                                            ['@item'] = item.item,
                                            ['@count'] = count,
                                            ['@pub'] = json.encode(itemPub),
                                            ['@pri'] = json.encode(itemPri),
                                            ['@type'] = item.type,
                                            ['@slot'] = assignedSlot
                                        }, function(insert)
                                            if insert > 0 then
                                                if cb then
                                                    cb(true)
                                                end
                                            else
                                                if cb then
                                                    cb(false)
                                                end
                                            end
                                        end)
                                    else
                                        if cb then
                                            cb(false)
                                        end
                                    end
                                end)
                            end
                        else
                            if cb then
                                cb(false)
                            end
                        end
                    end)
                end
            return action
        end

        inventories.useItem = function()
            local useItem = {}

            useItem.equipWeapon = function(serial, cb)
                TriggerClientEvent('pw_weapons:client:loadWeapon', charSelf.source, serial)
                cb(true)
            end

            useItem.bySlot = function(slot, removeItem, cb)
                MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `inventoryType` = 1 AND `identifier` = @owner AND `slot` = @slot", {['@owner'] = charSelf.loadedChar, ['@slot'] = slot}, function(item)
                    if item[1] ~= nil then
                        fetchItemData(item[1].item, function(details)
                            item[1].details = details
                            if cb then
                                cb(item[1])
                            end
                        end)
                    else
                        if cb then
                            cb(false)
                        end
                    end
                end)
            end

            useItem.byName = function(item, removeItem, cb)
                MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `identifier` = @owner AND `inventoryType` = 1 AND `item` = @name AND `count` > 0", {['@owner'] = charSelf.loadedChar, ['@name'] = item}, function(item)
                    if item[1] ~= nil then 
                        fetchItemData(item[1].item, function(details)
                            item[1].details = details
                            if cb then
                                cb(item[1])
                            end
                        end)
                    else
                        if cb then
                            cb(false)
                        end
                    end
                end)
            end

            useItem.byId = function(itemid, removeItem, cb)
                local processed = false
                local success = false
                local notification = {}
                MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `identifier` = @owner AND `inventoryType` = 1 AND `record_id` = @id AND `count` > 0", {['@owner'] = charSelf.loadedChar, ['@id'] = itemid}, function(item)
                    if item[1] ~= nil then
                        fetchItemData(item[1].item, function(details)
                            item[1].details = details
                            if cb then
                                cb(item[1])
                            end
                        end)
                    else
                        if cb then
                            cb(false)
                        end
                    end
                end)
            end

            return useItem
        end
        
        inventories.Remove = function()
            local function getAvaliableSlot(owner, type, maxSlots)
                local startSlot = 1
                local processed = false
                local slotFree
                repeat
                    processed = false
                    MySQL.Async.fetchScalar("SELECT `slot` FROM `stored_items` WHERE `identifier` = @owner AND `inventoryType` = @type AND `slot` = @slot", {['@slot'] = startSlot, ['@owner'] = owner, ['@type'] = type}, function(slotFreeSql)
                        slotFree = slotFreeSql
                        processed = true
                    end)
                    repeat Wait(0) until processed == true
                    if slotFree ~= nil then
                        startSlot = startSlot + 1
                    end
                until slotFree == nil or startSlot > maxSlots
                return startSlot
            end

            local remove = {}

            remove.All = function()
                local processed = false
                local success = false
                MySQL.Async.execute("DELETE FROM `stored_items` WHERE `inventoryType` = 1 AND `identifier` = @cid", {['@cid'] = charSelf.loadedChar }, function(done)
                    if done > 0 then
                        success = true
                    else
                        success = false
                    end
                    processed = true
                end)
                repeat Wait(0) until processed == true
                return success                
            end

            remove.byName = function(name, qty)
                MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `item` = @item AND `count` >= @qty AND `identifier` = @ident AND `inventoryType` = @itype", {['@item'] = name, ['@qty'] = qty, ['@ident'] = charSelf.loadedChar, ['@itype'] = 1}, function(itemRes)
                    if itemRes[1] ~= nil then
                        local query
                        if ((itemRes[1].count - qty) == 0) then
                            query = "DELETE FROM `stored_items` WHERE `record_id` = @record LIMIT 1"
                        else
                            query = "UPDATE `stored_items` SET `count` = `count` - @qty WHERE `record_id` = @record"
                        end
                        MySQL.Sync.execute(query, {['@record'] = itemRes[1].record_id, ['@qty'] = qty})
                    end
                end)
            end

            remove.Item = function(item, qty, cb)
                MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `record_id` = @id", {['@id'] = item.record_id}, function(storedItem)
                    local itemInfo = MySQL.Sync.fetchAll("SELECT * FROM `items_database` WHERE `item_name` = @item", { ['@item'] = item.item })
                    if itemInfo[1] ~= nil then
                        item.details = itemInfo[1]
                    end
                    if storedItem[1] ~= nil then
                        if storedItem[1].count >= qty then
                            local newQty = (storedItem[1].count - qty)
                            local query
                            if newQty < 1 then
                                query = "DELETE FROM `stored_items` WHERE `record_id` = @id AND `identifier` = @ident AND `inventoryType` = 1"
                            else
                                query = "UPDATE `stored_items` SET `count` = @qty WHERE `record_id` = @id AND `identifier` = @ident AND `inventoryType` = 1"
                            end
                            MySQL.Async.execute(query, {['@id'] = item.record_id, ['@qty'] = newQty, ['@ident'] = charSelf.loadedChar}, function(done)
                                if done == 1 then
                                    if item.details ~= nil then
                                        TriggerClientEvent('pw_inventory:client:useItemNotif', charSelf.source, {{ item = {label = item.details.item_label, image = item.details.item_image, slot = storedItem[1].slot}, qty = qty, message = 'Item Removed' }})
                                    end
                                    if cb then
                                        cb(true)
                                    end
                                else
                                    if cb then
                                        cb(false)
                                    end
                                end
                            end)
                        else
                            if cb then
                                cb(false)
                            end
                        end
                    end
                end)
            end

            remove.Give = function(target, item, count, cb)
                local processed = false
                local success = false
                if target ~= nil and item ~= nil and count ~= nil and type(count) == "number" then
                    MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `record_id` = @id", { ['@id'] = item.id }, function(playerItem)
                        if playerItem[1] ~= nil and playerItem[1].count >= count then
                            local newCount = playerItem[1].count - count
                            if newCount == 0 then
                                MySQL.Async.execute("UPDATE `stored_items` SET `identifier` = @owner WHERE `record_id` = @id", {['@owner'] = target, ['@id'] = item.id}, function(adjusted)
                                    if adjusted == 1 then
                                        if cb then
                                            cb(true)
                                        end
                                    else
                                        if cb then
                                            cb(false)
                                        end
                                    end
                                end)
                            else
                                MySQL.Async.execute("UPDATE `stored_items` SET `count` = `count` - @count WHERE `record_id` = @id", {['@count'] = count, ['@id'] = item.id}, function(updated)
                                    if updated == 1 then
                                        local requestedSlot = getAvaliableSlot(target, 1, 40)
                                        MySQL.Async.insert("INSERT INTO `stored_items` (`identifier`, `inventoryType`, `item`, `count`, `metapublic`, `metaprivate`, `type`, `slot`) VALUES (@ident, 1, @item, @count, @pub, @pri, @type, @slot)", {
                                            ['@ident'] = target,
                                            ['@type'] = 1,
                                            ['@item'] = playerItem[1].item,
                                            ['@count'] = count,
                                            ['@pub'] = playerItem[1].metapublic,
                                            ['@pri'] = playerItem[1].metaprivate,
                                            ['@type'] = playerItem[1].type,
                                            ['@slot'] = requestedSlot,
                                        }, function(inserted)
                                            if inserted > 0 then
                                                if cb then
                                                    cb(true)
                                                end
                                            else
                                                MySQL.Async.execute("UPDATE `stored_items` SET `count` = `count` + @count WHERE `record_id` = @id", {['@count'] = count, ['@id'] = item.id}, function(updated)
                                                    if cb then
                                                        cb(false)
                                                    end
                                                end)
                                            end
                                        end)
                                    else
                                        if cb then
                                            cb(false)
                                        end
                                    end
                                end)
                            end
                        else
                            if cb then
                                cb(false)
                            end
                        end
                    end)
                end
            end

            return remove

        end

        return inventories
    end

    charSelf.retreiveCharacters = function()
        if charSelf.loadedChar ~= nil and tonumber(charSelf.loadedChar) > 0 then
            charSelf.unloadCharacter()
        end
        local chars = {}
        local loaded = false
        MySQL.Async.fetchAll("SELECT * FROM `characters` WHERE `uid` = @uid", {['@uid'] = charSelf.uid }, function(charssql)
            local processed = 0
            for k, v in pairs(charssql) do
                MySQL.Async.fetchAll("SELECT * FROM `bank_accounts` WHERE `account_type` = 'Current' AND `character_id` = @ci", {['@ci'] = v.cid}, function(lol)
                    v.bank = lol[1].amount
                    processed = processed + 1
                end)
            end
            repeat Wait(0) until processed == #charssql
            chars = charssql
            loaded = true
        end)
        repeat Wait(0) until loaded == true
        return chars
    end

    charSelf.generateCID = function(gid)
        local complete = false
        local res
        MySQL.Async.fetchScalar("SELECT `cid` FROM `characters` WHERE `cid` = @gid", { ['@gid'] = gid }, function(newRes)
            res = newRes
            complete = true
        end)
        repeat Wait(0) until complete == true
        return res
    end

    charSelf.createCharacter = function(data)
        local function checkEmail(genemail)
            local processed = false
            local res
            MySQL.Async.fetchScalar("SELECT `email` FROM `characters` WHERE `email` = @eml", {['@eml'] = genemail}, function(eml)
                res = eml
                processed = true
            end)
            repeat Wait(0) until processed == true
            return res
        end

        local function checkTwitter(twitterHandle)
            local processed = false
            local res
            MySQL.Async.fetchScalar("SELECT `twitter` FROM `characters` WHERE `twitter` = @twt", {['@twt'] = twitterHandle}, function(twt)
                res = twt
                processed = true
            end)
            repeat Wait(0) until processed == true
            return res
        end

        local loaded = false
        local created = false
        if data ~= nil then
            local generatedIdent
            repeat
                math.randomseed(os.time())
                generatedIdent = math.random(111111111,999999999)
                local guid = charSelf.generateCID(generatedIdent)
            until guid == nil

            local generatedEmail = data.firstname..'.'..data.lastname..'@pixelworldrp.com'
            local emailCheck = checkEmail(generatedEmail)
            local generatedTwitter = '@'..data.firstname..'_'..data.lastname
            local twitterCheck = checkTwitter(generatedTwitter)

            if twitterCheck ~= nil then
                repeat
                    math.randomseed(os.time())
                    generatedTwitter = '@'..data.firstname..'_'..data.lastname..''..math.random(0,99)
                    local twitter = checkTwitter(generatedTwitter)
                until twitter == nil
            end

            if emailCheck ~= nil then
                repeat
                    math.randomseed(os.time())
                    generatedEmail = data.firstname..'.'..data.lastname..''..math.random(1,99)..'@pixelworldrp.com'
                    local email = checkEmail(generatedEmail)
                until email == nil
            end

            local jobData = { ['job'] = "unemployed", ['label'] = "Unemployed", ['duty'] = false, ['grade'] = "unemployed" }
            
            MySQL.Async.insert("INSERT INTO `characters` (`cid`, `uid`,`slot`,`firstname`,`lastname`,`dateofbirth`,`biography`,`sex`,`email`,`twitter`,`cash`,`height`, `job`) VALUES (@cid, @uid, @slot, @first, @last, @dob, @bio, @sex, @email, @twitter, @cash, @height, @job)", {
                ['@uid'] = charSelf.uid,
                ['@cid'] = generatedIdent,
                ['@slot'] = data.slot, 
                ['@first'] = data.firstname,
                ['@last'] = data.lastname,
                ['@dob'] = data.dob,
                ['@bio'] = data.bio,
                ['@sex'] = data.gender,
                ['@email'] = generatedEmail,
                ['@twitter'] = generatedTwitter,
                ['@job'] = json.encode(jobData),
                ['@cash'] = Config.StartingFunds['cash'],
                ['@height'] = data.height 
            }, function(cre)
                if cre > 0 then
                    local sortCode = math.random(100000,999999)
                    local accountNumber = math.random(10000000,99999999)
                    MySQL.Async.insert("INSERT INTO `bank_accounts` (`character_id`, `account_number`, `sort_code`, `amount`, `cardActive`, `cardNumber`, `cardPin`, `account_type`, `cardLocked`) VALUES (@char, @account, @sort, @amount, @cardActive, @cardNumber, @cardPin, @accountType, 1)", {
                        ['@char'] = generatedIdent,
                        ['@account'] = accountNumber,
                        ['@sort'] = sortCode,
                        ['@amount'] = Config.StartingFunds['bank'],
                        ['@cardActive'] = 0,
                        ['@cardNumber'] = 0,
                        ['@cardPin'] = 0,
                        ['@accountType'] = 'Current'    
                    }, function(insertBank)
                        if insertBank > 0 then
                            exports['pw_banking']:registerAccount(tonumber(generatedIdent))
                            created = true
                            loaded = true
                        end
                    end)
                end
            end)
        else
            loaded = true
        end
        repeat Wait(0) until loaded == true
        return created
    end

    charSelf.spawnPositions = function(completeRefresh)
        local processed = false
        local spawns = {}
        local loadDefault = true
        if completeRefresh then
            TriggerEvent('pw_motels:server:requestRoom', charSelf.loadedChar, function(motelRoom)
                local motelProcessed = false
                if motelRoom ~= nil then
                    charSelf.motelRoom = motelRoom
                    table.insert(spawns, {['name'] = motelRoom.name, ['coords'] = motelRoom.coords, ['type'] = "Motel", ['pid'] = motelRoom.id})
                    loadDefault = false
                    motelProcessed = true
                else
                    charSelf.motelRoom = nil
                    motelProcessed = true
                end

                repeat Wait(0) until motelProcessed == true

                MySQL.Async.fetchAll("SELECT * FROM `properties` WHERE `metainformation` LIKE '%\"owner\":"..charSelf.loadedChar.."%' AND `metainformation` LIKE '%\"propertyRented\":false%' OR `metainformation` LIKE '%\"rentor\":"..charSelf.loadedChar.."%' AND `metainformation` LIKE '%\"propertyRented\":true%'", { ['@cid'] = charSelf.loadedChar }, function(properties)
                    if properties[1] ~= nil then
                        for k, v in pairs(properties) do
                            table.insert(spawns, {['name'] = v.name, ['coords'] = json.decode(v.charSpawn), ['type'] = "Property", ['pid'] = v.property_id})
                        end
                        loadDefault = false
                    end

                    if (loadDefault) or (charSelf.User():getPermission() == "Admin" or charSelf.User():getPermission() == "Developer" or charSelf.User():getPermission() == "Owner") then
                        processed = false
                        MySQL.Async.fetchAll("SELECT * FROM `default_spawns`", {}, function(default)
                            for k, v in pairs(default) do
                                table.insert(spawns, {['name'] = v.spawn_name, ['coords'] = {['x'] = v.x, ['y'] = v.y, ['z'] = v.z, ['h'] = v.h}, ['type'] = "Default"})
                            end
                            processed = true
                        end)
                    else
                        processed = true
                    end
                    
                end)
            end)
        else
            TriggerEvent('pw_motels:server:assignRoom', charSelf.source, charSelf.loadedChar, function(motelRoom)
                local motelProcessed = false
                if motelRoom ~= nil then
                    charSelf.motelRoom = motelRoom
                    table.insert(spawns, {['name'] = motelRoom.name, ['coords'] = motelRoom.coords, ['type'] = "Motel", ['pid'] = motelRoom.id})
                    loadDefault = false
                    motelProcessed = true
                else
                    motelProcessed = true
                end

                repeat Wait(0) until motelProcessed == true

                MySQL.Async.fetchAll("SELECT * FROM `properties` WHERE `metainformation` LIKE '%\"owner\":"..charSelf.loadedChar.."%' AND `metainformation` LIKE '%\"propertyRented\":false%' OR `metainformation` LIKE '%\"rentor\":"..charSelf.loadedChar.."%' AND `metainformation` LIKE '%\"propertyRented\":true%'", { ['@cid'] = charSelf.loadedChar }, function(properties)
                    if properties[1] ~= nil then
                        for k, v in pairs(properties) do
                            table.insert(spawns, {['name'] = v.name, ['coords'] = json.decode(v.charSpawn), ['type'] = "Property", ['pid'] = v.property_id})
                        end
                        loadDefault = false
                    end

                    if (loadDefault) or (charSelf.User():getPermission() == "Admin" or charSelf.User():getPermission() == "Developer" or charSelf.User():getPermission() == "Owner") then
                        processed = false
                        MySQL.Async.fetchAll("SELECT * FROM `default_spawns`", {}, function(default)
                            for k, v in pairs(default) do
                                table.insert(spawns, {['name'] = v.spawn_name, ['coords'] = {['x'] = v.x, ['y'] = v.y, ['z'] = v.z, ['h'] = v.h}, ['type'] = "Default"})
                            end
                            processed = true
                        end)
                    else
                        processed = true
                    end
                    
                end)
            end)
        end
        repeat Wait(0) until processed == true

        return spawns
    end

    charSelf.deleteCharacter = function(cid)
        local processed = false
        MySQL.Async.execute("DELETE FROM `characters` WHERE `cid` = @cid AND `uid` = @uid", { ['@cid'] = cid, ['@uid'] = charSelf.uid }, function()
            processed = true
        end)
        repeat Wait(0) until processed == true
        return true
    end

    charSelf.Offline = function(self, cid)
        if cid ~= nil then
            local container = {}
            local ident = tonumber(cid)
            container.cid = tonumber(ident)
            container.uid = tonumber(charSelf.uid)

            container.Bank = function()
                local bank = {}
                bank.Add = function(amount, statement)
                    return exports.pw_banking:current(container.cid).AddMoney(amount, statement)
                end
    
                bank.Remove = function(amount, statement)
                    return exports.pw_banking:current(container.cid).RemoveMoney(amount, statement)
                end
    
                bank.getBalance = function()
                    return exports.pw_banking:current(container.cid).GetBalance()
                end
    
                bank.GetBankAccount = function()
                    return { ['account_number'] = exports.pw_banking:current(container.cid).GetAccountNo(), ['sort_code'] = exports.pw_banking:current(container.cid).GetSortCode(), ['amount'] = exports.pw_banking:current(container.cid).GetBalance() }
                end
    
                bank.GetStatement = function()
                    return exports.pw_banking:current(container.cid).GetStatement()
                end
    
                bank.GetCardDetails = function()
                    if exports.pw_banking:current(container.cid).GetCardStatus() then
                        return exports.pw_banking:current(container.cid).GetCardDetails()
                    else
                        return nil
                    end
                end
    
                bank.ToggleDebitCard = function(toggle)
                    return exports.pw_banking:current(container.cid).ToggleDebitCard(toggle)
                end
    
                bank.UpdateDebitCardPin = function(pin)
                    return exports.pw_banking:current(container.cid).UpdateDebitCardPin(pin)
                end
    
                bank.CreateDebitCard = function(pin)
                    if not exports.pw_banking:current(container.cid).GetCardStatus() then
                        local success, cardNumber = exports.pw_banking:current(container.cid).CreateDebitCard(pin)
                        return success, cardNumber
                    end
                end
                return bank
            end

            container.Cash = function()
                local cash = {}
                cash.getCash = function()
                    local processed = false
                    local currentCash
                    MySQL.Async.fetchScalar("SELECT `cash` FROM `characters` WHERE `cid` = @cid AND `uid` = @uid", {['@cid'] = container.cid, ['@uid'] = charSelf.uid}, function(playerCash)
                        currentCash = playerCash
                        processed = true
                    end)
                    repeat Wait(0) until processed == true
                    return math.floor(currentCash)
                end

                cash.Add = function(amount)
                    local processed = false
                    local success
                    if type(amount) == "number" then
                        MySQL.Async.execute("UPDATE `characters` SET `cash` = `cash` + @amt WHERE `cid` = @cid AND `uid` = @uid", {['@amt'] = amount, ['@cid'] = container.cid, ['@uid'] = charSelf.uid}, function(done)
                            if done == 1 then
                                success = true
                            else
                                success = false
                            end
                            processed = true
                        end)
                    else
                        success = false
                        processed = true
                    end
                    repeat Wait(0) until processed == true
                    return success
                end

                cash.Remove = function(amount)
                    local processed = false
                    local success = false
                    if type(amount) == "number" then
                        MySQL.Async.fetchScalar("SELECT `cash` FROM `characters` WHERE `cid` = @cid AND `uid` = @uid", {['@cid'] = container.cid, ['@uid'] = charSelf.uid}, function(playerCash)
                            if playerCash >= amount then
                                MySQL.Async.execute("UPDATE `characters` SET `cash` = `cash` - @amt WHERE `cid` = @cid AND `uid` = @uid", {['@amt'] = amount, ['@cid'] = container.cid, ['@uid'] = charSelf.uid}, function(done)
                                    if done == 1 then
                                        success = true
                                    else
                                        success = false
                                    end
                                    processed = true
                                end)
                            else
                                success = false
                                processed = true
                            end
                        end)
                    else
                        success = false
                        processed = true
                    end
                    repeat Wait(0) until processed == true
                    return success
                end
                return cash
            end

            container.Gang = function()
                local gang = {}
                gang.setGang = function(gangid, level)
                    if gangid ~= nil and type(gangid) == "number" then
                        MySQL.Async.fetchAll("SELECT * FROM `gangs` WHERE `gang_id` = @gang", {['@gang'] = gangid}, function(gangsql)
                            if gangsql[1] ~= nil then
                                local ranks = json.decode(gangsql[1].gang_ranks)
                                if level == nil then
                                    level = 0
                                end
        
                                for k, v in pairs(ranks) do
                                    if v == level then
                                        local gangTable = { ['gang'] = gangid, ['name'] = gangsql[1].gang_name, ['level'] = level}
                                        local gangEncrypted = json.encode(gangTable)
                                        MySQL.Async.execute("UPDATE `characters` SET `gang` = @gang WHERE `cid` = @cid AND `uid` = @uid", {['@gang'] = gangEncrypted, ['@cid'] = container.cid, ['@uid'] = charSelf.uid}, function(updated)
                                        end)
                                    end
                                end
                            end
                        end)
                    end
                end
        
                gang.getGang = function()
                    local processed = false
                    local gangInformation
                    MySQL.Async.fetchScalar("SELECT `gang` FROM `characters` WHERE `cid` = @cid AND `uid` = @uid", {['@cid'] = container.cid, ['@uid'] = charSelf.uid}, function(gang)
                        if gang ~= nil then
                            gangInformation = json.decode(gang)
                        else
                            local gangTable = { ['gang'] = 0, ['name'] = 'None', ['level'] = 0}
                            gangInformation = gangTable
                        end
                        processed = true
                    end)
                    repeat Wait(0) until processed == true
                    return gangInformation
                end
        
                return gang
            end

            container.Job = function()
                local job = {}

                job.getJob = function()
                    local processed = false
                    local jobData
                    MySQL.Async.fetchScalar("SELECT `job` FROM `characters` WHERE `cid` = @cid AND `uid` = @uid", {['@cid'] = container.cid, ['@uid'] = charSelf.uid}, function(jobInfo)
                        if jobInfo ~= nil then
                            jobData = json.decode(jobInfo)
                            MySQL.Async.fetchAll("SELECT * FROM `job_grades` WHERE `job` = @job AND `grade` = @grade", {['@job'] = jobData.job, ['@grade'] = jobData.grade}, function(grade)
                                if grade[1] ~= nil then
                                    jobData['salery'] = grade[1].salery
                                    jobData['grade_label'] = grade[1].label
                                    jobData['grade_level'] = grade[1].level
                                else
                                    jobData['salery'] = 0
                                    jobData['grade_label'] = ""
                                end
                                processed = true
                            end)
                        else
                            jobData = { ['job'] = "unemployed", ['label'] = "Unemployed", ['duty'] = false, ['grade'] = "unemployed" }
                            MySQL.Async.fetchAll("SELECT * FROM `job_grades` WHERE `job` = @job AND `grade` = @grade", {['@job'] = jobData.job, ['@grade'] = jobData.grade}, function(grade)
                                if grade[1] ~= nil then
                                    jobData['salery'] = grade[1].salery
                                    jobData['grade_label'] = grade[1].label
                                    jobData['grade_level'] = grade[1].level
                                else
                                    jobData['salery'] = 0
                                    jobData['grade_label'] = ""
                                    jobData['grade_level'] = 0
                                end
                                processed = true
                            end)
                        end
                    end)
                    repeat Wait(0) until processed == true
                    return jobData
                end

                job.setJob = function(jobname, jobgrade, workplace)
                    local processed = false
                    local tableBlocks = {}
                    MySQL.Async.fetchAll("SELECT * FROM `avaliable_jobs` WHERE `name` = @job", {['@job'] = jobname}, function(jobsql)
                        if jobsql[1] ~= nil then
                            tableBlocks['job'] = jobsql[1].name
                            tableBlocks['label'] = jobsql[1].label
                            if workplace ~= nil then
                                tableBlocks['workplace'] = tonumber(workplace)
                            else
                                tableBlocks['workplace'] = 0
                            end
                            MySQL.Async.fetchAll("SELECT * FROM `job_grades` WHERE `job` = @job AND `grade` = @grade", {['@job'] = jobname, ['@grade'] = jobgrade}, function(gradesql)
                                if gradesql[1] ~= nil then
                                    tableBlocks['grade'] = jobgrade
                                    tableBlocks['grade_label'] = gradesql[1].label
                                    tableBlocks['grade_level'] = gradesql[1].level
                                    tableBlocks['salery'] = gradesql[1].salery
                                    MySQL.Async.execute("UPDATE `characters` SET `job` = @job WHERE `cid` = @cid AND `uid` = @uid", {['@job'] = json.encode(tableBlocks), ['@cid'] = container.cid, ['@uid'] = charSelf.uid}, function(updated)
                                        success = true
                                        successMsg = "Your job has been set to "..tableBlocks['label']
                                        processed = true
                                    end)
                                else
                                    tableBlocks = { ['job'] = "unemployed", ['label'] = "Unemployed", ['grade'] = "unemployed" }
                                    MySQL.Async.fetchAll("SELECT * FROM `job_grades` WHERE `job` = @job AND `grade` = @grade", {['@job'] = jobData.job, ['@grade'] = jobData.grade}, function(grade)
                                        if grade[1] ~= nil then
                                            tableBlocks['salery'] = grade[1].salery
                                            tableBlocks['grade_label'] = grade[1].label
                                            tableBlocks['grade_level'] = grade[1].level
                                        else
                                            tableBlocks['salery'] = 0
                                            tableBlocks['grade_label'] = ""
                                            tableBlocks['grade_level'] = 0
                                        end
                                        MySQL.Async.execute("UPDATE `characters` SET `job` = @job WHERE `cid` = @cid AND `uid` = @uid", {['@job'] = json.encode(tableBlocks), ['@cid'] = container.cid, ['@uid'] = charSelf.uid}, function(updated)
                                            success = false
                                            successMsg = "The job grade you have specified, could not be located."
                                            processed = true
                                        end)
                                    end)
                                end
                            end)
                        else
                            tableBlocks = { ['job'] = "unemployed", ['label'] = "Unemployed", ['grade'] = "unemployed" }
                            MySQL.Async.fetchAll("SELECT * FROM `job_grades` WHERE `job` = @job AND `grade` = @grade", {['@job'] = tableBlocks.job, ['@grade'] = tableBlocks.grade}, function(grade)
                                if grade[1] ~= nil then
                                    tableBlocks['salery'] = grade[1].salery
                                    tableBlocks['grade_label'] = grade[1].label
                                    tableBlocks['grade_level'] = grade[1].level
                                else
                                    tableBlocks['salery'] = 0
                                    tableBlocks['grade_label'] = ""
                                    tableBlocks['grade_level'] = 0
                                end
                                MySQL.Async.execute("UPDATE `characters` SET `job` = @job WHERE `cid` = @cid AND `uid` = @uid", {['@job'] = json.encode(tableBlocks), ['@cid'] = container.cid, ['@uid'] = charSelf.uid}, function(updated)
                                    success = false
                                    successMsg = "The job you have specified, could not be located."
                                    processed = true
                                end)
                            end)
                        end
                    end)
                    repeat Wait(0) until processed == true
                    if success then
                        -- do green notif
                    else
                        -- do red notif
                    end
                end

                return job
            end

            local loaded = false
            
            container.Character = function()
                local charFunc = {}
                
                charFunc.getSource = function()
                    return false
                end
                MySQL.Async.fetchAll("SELECT * FROM `characters` WHERE `cid` = @cid AND `uid` = @uid", {['@cid'] = container.cid, ['@uid'] = container.uid}, function(char)
                    charFunc.getName = function()
                        return char[1].firstname..' '..char[1].lastname
                    end
        
                    charFunc.getCID = function()
                        return tonumber(char[1].cid)
                    end
        
                    charFunc.getEmail = function()
                        return char[1].email
                    end
        
                    charFunc.getTwitter = function()
                        return char[1].twitter
                    end
        
                    charFunc.myProperties = function()
                        local processed = false
                        local properties = {}
                        MySQL.Async.fetchAll("SELECT * FROM `properties` WHERE `metainformation` LIKE '%\"owner\":"..container.cid.."%' OR `metainformation` LIKE '%\"rentor\":"..container.cid.."%'", {}, function(props)
                            properties = props
                            processed = true
                        end)
                        repeat Wait(0) until processed == true
                        return properties
                    end
        
                    charFunc.getGender = function()
                        return char[1].sex
                    end
        
                    charFunc.getSkinId = function()
                        return char[1].skin
                    end

                    charFunc.getOutfits = function()
                        local sql = MySQL.Sync.fetchAll("SELECT * FROM `character_outfits` WHERE `cid` = @cid", { ['@cid'] = charSelf.loadedChar})
                        return sql
                    end
        
                    charFunc.saveOutfit = function(self, skind)
                        local processed = false
                        local success = false
                        local skinData = json.encode(skind.skin)
                        MySQL.Async.insert("INSERT INTO `character_outfits` (`cid`,`uid`,`skindata`,`skin_name`) VALUES (@cid, @uid, @skin, @name)", {
                            ['@cid'] = container.cid,
                            ['@uid'] = char[1].uid,
                            ['@skin'] = skinData,
                            ['@name'] = skind.name
                        }, function(outfitCreated)
                            if outfitCreated > 0 then
                                MySQL.Async.execute("UPDATE `characters` SET `skin` = @skin WHERE `cid` = @cid AND `uid` = @uid", {['@skin'] = outfitCreated, ['@cid'] = container.cid, ['@uid'] = char[1].uid }, function(done)
                                    char[1].skin = outfitCreated
                                    success = true
                                    processed = true
                                end)
                            else
                                success = false
                                processed = true
                            end
                        end)
                        repeat Wait(0) until processed == true
                        return success
                    end
        
                    charFunc.getSkin = function()
                        local processed = false
                        local skin
                        MySQL.Async.fetchScalar("SELECT `skindata` FROM `character_outfits` WHERE `outfit_id` = @skinid AND `cid` = @cid AND `uid` = @uid", { ['@skinid'] = char[1].skin, ['@uid'] = char[1].uid, ['@cid'] = container.cid }, function(savedSkin)
                            if savedSkin ~= nil then
                                skin = json.decode(savedSkin)
                            else
                                skin = nil
                            end
                            processed = true
                        end)
                        repeat Wait(0) until processed == true
                        return skin
                    end
        
                    charFunc.getBio = function()
                        return char[1].biography
                    end
        
                    charFunc.getDob = function()
                        return char[1].dateofbirth
                    end
        
                    charFunc.getHealth = function()
                        return char[1].health
                    end
        
                    charFunc.getHeight = function()
                        return char[1].height
                    end
        
                    charFunc.getCash = function()
                        return char[1].cash 
                    end
        
                    charFunc.newCharacter = function()
                        return char[1].newCharacter
                    end
        
                    charFunc.toggleNewCharacter = function()
                        local processed = false
                        MySQL.Async.execute("UPDATE `characters` SET `newCharacter` = '0' WHERE `cid` = @cid AND `uid` = @uid", {['@cid'] = container.cid, ['@uid'] = container.uid }, function(success)
                            processed = true
                        end)
                        repeat Wait(0) until processed == true
                        return true 
                    end
        
                    loaded = true
                end)
                repeat Wait(0) until loaded == true

                return charFunc
            end

            return container
        end
    end

    charSelf.Character = function()
        local charFunc = {}
        local loaded = false

        charFunc.getSource = function()
            return charSelf.source
        end

        MySQL.Async.fetchAll("SELECT * FROM `characters` WHERE `cid` = @cid AND `uid` = @uid", {['@cid'] = charSelf.loadedChar, ['@uid'] = charSelf.uid}, function(char)
            charFunc.getName = function()
                return char[1].firstname..' '..char[1].lastname
            end

            charFunc.updatePlaytime = function()
                if charSelf.loadedChar ~= nil and charSelf.loadedChar ~= 0 then
                    MySQL.Async.execute("UPDATE `characters` SET `playtime` = `playtime` + 1 WHERE `cid` = @cid AND `uid` = @uid", {['@cid'] = charSelf.loadedChar, ['@uid'] = charSelf.uid}, function() end)
                end
            end

            charFunc.getNeeds = function()
                local processed = false
                local needsReturn 
                MySQL.Async.fetchScalar("SELECT `needs` FROM `characters` WHERE `cid` = @cid AND `uid` = @uid", {['@cid'] = charSelf.loadedChar, ['@uid'] = charSelf.uid }, function(needs)
                    if needs ~= nil then
                        needsReturn = json.decode(needs)
                        processed = true
                    else
                        needsReturn = { ['stress'] = 0, ['hunger'] = 1000000, ['thirst'] = 1000000, ['drugs'] = 0}
                        MySQL.Async.execute("UPDATE `characters` SET `needs` = @needs WHERE `cid` = @cid AND `uid` = @uid", {['@needs'] = json.encode(needsReturn), ['@cid'] = charSelf.loadedChar, ['uid'] = charSelf.uid}, function(done)
                            if done == 1 then
                                processed = true
                            end
                        end)
                    end
                end)
                repeat Wait(0) until processed == true
                return needsReturn
            end

            charFunc.getOutfits = function()
                local sql = MySQL.Sync.fetchAll("SELECT * FROM `character_outfits` WHERE `cid` = @cid", { ['@cid'] = charSelf.loadedChar})
                return sql
            end

            charFunc.getPrisonState = function()
                if char[1].jailed == nil then
                    theTable = { ['inPrison'] = false, ['time'] = 0 }
                else
                    theTable = json.decode(char[1].jailed)
                end
                return theTable
            end

            charFunc.updatePrisonState = function(toggle, time)
                local theTable = { ['inPrison'] = toggle, ['time'] = time }
                local processed = false
                local success
                MySQL.Async.execute("UPDATE `characters` SET `jailed` = @jail WHERE `cid` = @cid AND `uid` = @uid", {['@jail'] = json.encode(theTable), ['@cid'] = charSelf.loadedChar, ['@uid'] = charSelf.uid}, function(updated)
                    if updated == 1 then
                        success = true
                        processed = true
                    else
                        success = false
                        processed = true
                    end
                end)
                repeat Wait(0) until processed == true
                return success
            end

            charFunc.updateNeeds = function(needs)
                local processed = false
                local success = false
                if needs ~= nil then
                    MySQL.Async.execute("UPDATE `characters` SET `needs` = @needs WHERE `cid` = @cid AND `uid` = @uid", {['@needs'] = json.encode(needs), ['@cid'] = charSelf.loadedChar, ['@uid'] = charSelf.uid}, function(done)
                        if done == 1 then
                            success = true
                            processed = true
                        else
                            success = false
                            processed = true
                        end
                    end)
                else
                    success = false 
                    processed = true
                end
                repeat Wait(0) until processed == true
                return success
            end

            charFunc.getCID = function()
                return tonumber(char[1].cid)
            end

            charFunc.getEmail = function()
                return char[1].email
            end

            charFunc.getTwitter = function()
                return char[1].twitter
            end

            charFunc.getHealth = function()
                if char[1].health == nil then
                    return 200
                else
                    return char[1].health
                end
            end

            charFunc.updateHealth = function(n)
                if type(n) == "number" then
                    local done = false
                    MySQL.Async.execute("UPDATE `characters` SET `health` = @health WHERE `cid` = @cid AND `uid` = @uid", {['@cid'] = charSelf.loadedChar, ['@uid'] = charSelf.uid}, function()
                        done = true
                    end)
                    repeat Wait(0) until done == true
                end
            end

            charFunc.myProperties = function()
                local processed = false
                local properties = {}
                MySQL.Async.fetchAll("SELECT * FROM `properties` WHERE `metainformation` LIKE '%\"owner\":"..charSelf.loadedChar.."%' OR `metainformation` LIKE '%\"rentor\":"..charSelf.loadedChar.."%'", {}, function(props)
                    properties = props
                    processed = true
                end)
                repeat Wait(0) until processed == true
                return properties
            end

            charFunc.getGender = function()
                return char[1].sex
            end

            charFunc.getSkinId = function()
                return char[1].skin
            end

            charFunc.saveOutfit = function(skind, label)
                local processed = false
                local success = false
                local skinData = json.encode(skind)
                MySQL.Async.insert("INSERT INTO `character_outfits` (`cid`,`uid`,`skindata`,`skin_name`) VALUES (@cid, @uid, @skin, @name)", {
                    ['@cid'] = char[1].cid,
                    ['@uid'] = char[1].uid,
                    ['@skin'] = skinData,
                    ['@name'] = label
                }, function(outfitCreated)
                    if outfitCreated > 0 then
                        MySQL.Async.execute("UPDATE `characters` SET `skin` = @skin WHERE `cid` = @cid AND `uid` = @uid", {['@skin'] = outfitCreated, ['@cid'] = char[1].cid, ['@uid'] = char[1].uid }, function(done)
                            char[1].skin = outfitCreated
                            success = true
                            processed = true
                        end)
                    else
                        success = false
                        processed = true
                    end
                end)
                repeat Wait(0) until processed == true
                return success
            end

            charFunc.getSkin = function()
                local processed = false
                local skin
                MySQL.Async.fetchScalar("SELECT `skindata` FROM `character_outfits` WHERE `outfit_id` = @skinid AND `cid` = @cid AND `uid` = @uid", { ['@skinid'] = char[1].skin, ['@uid'] = char[1].uid, ['@cid'] = char[1].cid }, function(savedSkin)
                    if savedSkin ~= nil then
                        skin = json.decode(savedSkin)
                    else
                        skin = nil
                    end
                    processed = true
                end)
                repeat Wait(0) until processed == true
                return skin
            end

            charFunc.setSkin = function(skinId)
                local waiter
                MySQL.Async.execute("UPDATE `characters` SET `skin` = @skin WHERE `cid` = @cid AND `uid` = @uid", {['@skin'] = skinId, ['@cid'] = charSelf.loadedChar }, function(done)
                    waiter = MySQL.Sync.fetchScalar("SELECT `skindata` FROM `character_outfits` WHERE `outfit_id` = @id AND `cid` = @cid", {['@cid'] = charSelf.loadedChar, ['@id'] = skinId})    
                end)
                repeat Wait(0) until waiter ~= nil
                return waiter
            end

            charFunc.deleteOutfit = function(skinId)
                local success = nil
                MySQL.Async.fetchScalar("SELECT COUNT(*) FROM `character_outfits` WHERE `cid` = @cid", {['@cid'] = charSelf.loadedChar}, function(tot)
                    if tot > 1 then
                        MySQL.Async.execute("DELETE FROM `character_outfits` WHERE `cid` = @cid AND `outfit_id` = @oid", {['@cid'] = charSelf.loadedChar, ['@oid'] = skinId}, function()
                            success = true
                        end)
                    else
                        success = false
                    end
                end)

                repeat Wait(0) until success == true or false
                return success
            end

            charFunc.getBio = function()
                return char[1].biography
            end

            charFunc.getDob = function()
                return char[1].dateofbirth
            end

            charFunc.getHealth = function()
                return char[1].health
            end

            charFunc.getHeight = function()
                return char[1].height
            end

            charFunc.newCharacter = function()
                return char[1].newCharacter
            end

            charFunc.toggleNewCharacter = function()
                local processed = false
                MySQL.Async.execute("UPDATE `characters` SET `newCharacter` = '0' WHERE `cid` = @cid AND `uid` = @uid", {['@cid'] = charSelf.loadedChar, ['@uid'] = charSelf.uid }, function(success)
                    processed = true
                end)
                repeat Wait(0) until processed == true
                return true 
            end

            loaded = true
        end)
        repeat Wait(0) until loaded == true
        return charFunc
    end

    charSelf.Injuries = function()
        local injuries = {}
        injuries.Load = function()
            local processed = false
            local info = {}
            MySQL.Async.fetchScalar("SELECT `injuries` FROM `characters` WHERE `cid` = @cid AND `uid` = @uid", {['@cid'] = charSelf.loadedChar, ['@uid'] = charSelf.uid}, function(inj)
                if inj ~= nil then
                    info = json.decode(inj)
                    processed = true
                end
            end)
            repeat Wait(0) until processed == true
            return info
        end

        injuries.Save = function(injuriesrec)
            local processed = false
            MySQL.Async.execute("UPDATE `characters` SET `injuries` = @inj WHERE `cid` = @cid AND `uid` = @uid", {['@inj'] = json.encode(injuriesrec), ['@cid'] = charSelf.loadedChar, ['@uid'] = charSelf.uid}, function(done)
                processed = true
            end)
            repeat Wait(0) until processed == true
            return processed
        end
        return injuries
    end

    return charSelf
end