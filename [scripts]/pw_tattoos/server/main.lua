PW = nil

TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)

PW.RegisterServerCallback("pw_tattoos:server:requestPlayerTattoos", function(source, cb)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    if _char then
        MySQL.Async.fetchScalar("SELECT `tattoos` FROM `character_tattoos` WHERE `cid` = @cid", {['@cid'] = _char:Character().getCID()}, function(tats)
            if tats ~= nil then
                cb(json.decode(tats))
            else
                cb()
            end
        end)
    else
        cb()
    end 
end)

PW.RegisterServerCallback('pw_tattoos:server:checkCashAmount', function(source, cb, price)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    local _cash = _char:Cash().getCash()
    if _cash >= price then
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('pw_tattoos:server:purchaseTattoo')
AddEventHandler('pw_tattoos:server:purchaseTattoo', function(amount)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    _char:Cash().Remove(tonumber(amount))
end)

RegisterServerEvent('pw_tattoos:server:saveTattoos')
AddEventHandler('pw_tattoos:server:saveTattoos', function(tatts)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    MySQL.Async.fetchScalar("SELECT `tattoos` FROM `character_tattoos` WHERE `cid` = @cid", {['@cid'] = _char:Character().getCID()}, function(exist)
        local query = nil
        if exist == nil then
            query = "INSERT INTO `character_tattoos` (`cid`, `tattoos`) VALUES (@cid, @tats)"
        else
            query = "UPDATE `character_tattoos` SET `tattoos` = @tats WHERE `cid` = @cid"
        end
        if query ~= nil then
            MySQL.Async.execute(query, {['@cid'] = _char:Character().getCID(), ['@tats'] = json.encode(tatts)}, function(success)
                if success then
        
                end
            end)
        end
    end)
end)