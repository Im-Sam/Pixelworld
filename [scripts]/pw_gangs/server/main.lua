PW = nil
GangPoints = {}


TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)

MySQL.ready(function()
    MySQL.Async.fetchAll("SELECT * FROM `gangs` WHERE `gang_locations` IS NOT NULL", {}, function(gangpoints)
        if gangpoints and gangpoints[1] ~= nil then
            GangPoints = gangpoints
            for k,v in pairs(GangPoints) do
                GangPoints[k].gang_id = v.gang_id
                GangPoints[k].gang_name = v.gang_name
                GangPoints[k].gang_coords = json.decode(v.gang_locations)
            end
        end
        PW.TablePrint(GangPoints)
    end)
end)

PW.RegisterServerCallback('pw_gangs:server:getGangPoints', function(source, cb)
    cb(GangPoints)
end)

RegisterServerEvent('pw_gangs:server:changeCoord')
AddEventHandler('pw_gangs:server:changeCoord', function(data)
    local _src = source
    local type = data.type
    local gang = data.gang
    local newcoords = json.encode(data.newcoords)
    GangPoints[gang].gang_coords[type].coords.x = data.newcoords.x
    GangPoints[gang].gang_coords[type].coords.y = data.newcoords.y
    GangPoints[gang].gang_coords[type].coords.z = data.newcoords.z
    local newcoords = json.encode(GangPoints[gang].gang_coords)

    MySQL.Async.execute('UPDATE `gangs` SET `gang_hq` = @gang_hq WHERE `gang_id` = @gang_id', {['@gang_hq'] = newcoords, ['@gang_id'] = gang }, function()
        RefreshGangPoints()
    end)
    TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = "Location Changed", length = 5000})
end)

function RefreshGangPoints()
    MySQL.Async.fetchAll("SELECT * FROM `gangs` WHERE `gang_locations` IS NOT NULL", {}, function(gangpoints)
        if gangpoints and gangpoints[1] ~= nil then
            GangPoints = gangpoints
            for k,v in pairs(GangPoints) do
                GangPoints[k].gang_id = v.gang_id
                GangPoints[k].gang_name = v.gang_name
                GangPoints[k].gang_coords = json.decode(v.gang_locations)
            end
        end
        PW.TablePrint(GangPoints)
    end)
    TriggerClientEvent('pw_gangs:client:refreshGangPoints', -1)
end  

PW.RegisterServerCallback('pw_gangs:server:getGangMembers', function(source, cb, gang)
    local gangList = exports.pw_base:getGangMembers(gang)
    cb(gangList)
end)

PW.RegisterServerCallback('pw_gangs:server:getNearbyName', function(source, cb, id)
    local _char = exports.pw_base:Source(id)
    if _char == nil then cb(false); end
    local name = _char:Character().getName()
    if name ~= nil then
        cb(name)
    else
        cb(false)
    end
end)

RegisterServerEvent('pw_gangs:server:sendContractForm')
AddEventHandler('pw_gangs:server:sendContractForm', function(res)
    local target = tonumber(res.target.value)
    local gang = tonumber(res.gang_id.value)
    local gangname = res.gang_name.value
    local level = tonumber(res.gang_level.value)
    local bossSrc = tonumber(res.bossSrc.value)
    TriggerClientEvent('pw_gangs:client:sendContractForm', target, gang, gangname, level, bossSrc)
end)

RegisterServerEvent('pw_gangs:server:contractSigned')
AddEventHandler('pw_gangs:server:contractSigned', function(res)
    local _src = source
    local _char = exports.pw_base:Source(_src)
    _char:Gang().setGang(tonumber(res.gang.value), tonumber(res.level.value))
    TriggerClientEvent('pw:notification:SendAlert', tonumber(res.bossSrc.value), {type = 'inform', text = _char:Character().getName() .. " signed the contract and is now part of your gang!"})
end)

RegisterServerEvent('pw_gangs:server:fireStaff')
AddEventHandler('pw_gangs:server:fireStaff', function(data)
    local _src = source
    local pSrc = exports.pw_base:checkOnline(data.data.data.cid)
    local _char
    if pSrc > 0 then
        _char = exports.pw_base:Source(pSrc)
    else
        _char = exports.pw_base:getOfflineCharacter(data.data.data.cid)
    end
    if data.fire.value then
        --_char:Gang().setGang(0, 0) NO REMOVE GANG FUNCTION YET
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You have kicked '..data.data.data.name})
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You have to sign the contract'})
    end
end)

RegisterServerEvent('pw_gangs:server:setNewGrade')
AddEventHandler('pw_gangs:server:setNewGrade', function(data)
    local _src = source
    local _bosschar = exports.pw_base:Source(_src)
    local bosscid = _bosschar:Character().getCID()
    if bosscid == data.data.data.cid then
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You can\'t change your own level!'})
    else
        if statusEmployee then
            _char = exports.pw_base:Source(statusEmployee)
        else
            _char = exports.pw_base:Offline(data.data.data.cid)
        end
        _char:Gang().setGang(tonumber(data.gang.data), tonumber(data.grades.value))
        if statusEmployee then
            TriggerClientEvent('pw:notification:SendAlert', statusEmployee, {type = 'inform', text = 'You were changed to level '.. data.grades.value .. ' in your gang'})
        end
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You changed '.. data.data.data.name ..' to level '..data.grades.value})  
    end     
end)


exports.pw_chat:AddChatCommand('gangbossmenu', function(source, args, rawCommand)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    if _char:Gang().getGang().level == 4 then
        TriggerClientEvent('pw_gangs:bossMenu', _src)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You're Are Not the Gang Boss!", length = 5000}) 
    end       
end, {
    help = "Open the Gang Settings Menu",
    params = {}
}, -1)





