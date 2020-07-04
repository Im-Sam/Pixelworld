PW = nil

TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)


PW.RegisterServerCallback('pw_barbers:checkCashAmount', function(source, cb)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    local cash = _char:Cash().getCash()
    if cash >= Config.HairCutCost then
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('pw_barber:server:purchaseHair')
AddEventHandler('pw_barber:server:purchaseHair', function(data)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    local cash = _char:Cash().getCash()
    if cash >= Config.HairCutCost then
        _char:Cash().Remove(tonumber(Config.HairCutCost))
        MySQL.Async.fetchAll("SELECT * FROM `character_outfits` WHERE `cid` = @cid", {['@cid'] = _char:Character().getCID()}, function(skins)
            for i = 1, #skins do
                local currentSkin = json.decode(skins[i].skindata)
                if data.hair.style ~= nil then
                    currentSkin.facial.hair.style = data.hair.style
                end
                if data.hair.color1 ~= nil then
                    currentSkin.facial.hair.color1 = data.hair.color1
                end
                if data.hair.color2 ~= nil then
                    currentSkin.facial.hair.color2 = data.hair.color2
                end
                if data.eyebrow.style ~= nil then
                    currentSkin.facial.eyebrow.style = data.eyebrow.style
                end
                if data.eyebrow.opacity ~= nil then
                    currentSkin.facial.eyebrow.opacity = data.eyebrow.opacity
                end
                if data.eyebrow.color1 ~= nil then
                    currentSkin.facial.eyebrow.color1 = data.eyebrow.color1
                end
                if data.eyebrow.color2 ~= nil then
                    currentSkin.facial.eyebrow.color2 = data.eyebrow.color2
                end
                if data.beard.opacity ~= nil then
                    currentSkin.facial.beard.opacity = data.beard.opacity
                end
                if data.beard.style ~= nil then
                    currentSkin.facial.beard.style = data.beard.style
                end
                if data.beard.color1 ~= nil then
                    currentSkin.facial.beard.color1 = data.beard.color1
                end
                if data.beard.color2 ~= nil then
                    currentSkin.facial.beard.color2 = data.beard.color2
                end

                local recode = json.encode(currentSkin)
                MySQL.Sync.execute("UPDATE `character_outfits` SET `skindata` = @update WHERE `outfit_id` = @id", {['@update'] = recode, ['@id'] = skins[i].outfit_id})
            end
        end)
    else

    end
end)