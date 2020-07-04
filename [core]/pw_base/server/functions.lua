PW = {}
PW.Players              = {}
PW.ServerCallbacks      = {}
PW.TimeoutCount         = -1
PW.CancelledTimeouts    = {}
PW.UsableItemsCallbacks = {}
Users = {}
Players = {}

PW.RegisterServerCallback = function(name, cb)
	PW.ServerCallbacks[name] = cb
end

PW.TriggerServerCallback = function(name, requestId, source, cb, ...)
	if PW.ServerCallbacks[name] ~= nil then
		PW.ServerCallbacks[name](source, cb, ...)
	else
		print('^1[PixelWorld]:^7 TriggerServerCallback => [^2' .. name .. '^7] does not exist')
	end
end

function doAdminLog(src, action, tgt)
	if Config.Logging.admin then
		if src ~= nil and action ~= nil then
			local _src = src
			local _user = exports['pw_base']:Source(_src)
			local time = os.date("%Y-%m-%d %H:%M:%S")
			if _user ~= nil then
				local targetName = ""
				if tgt ~= nil then
					local xTarget = exports['pw_base']:Source(tonumber(tgt)):Character()
					if xTarget ~= nil then
						targetName = "(Target Player: "..xTarget.getName()..")"
					end
				end
				MySQL.Async.insert("INSERT INTO `adminLogging` (`logged_user`, `logged_action`, `logged_datetime`) VALUES (@user, @action, @time)", {
					['@user'] = _user:Character().getName()..' ('..GetPlayerName(_src)..')',
					['@action'] = action..' '..targetName,
					['@time'] = time,
				}, function(ins) 
					
				end)
			end
		end
	end
end

exports('doAdminLog', function(src, action, tgt)
	doAdminLog(src, action, tgt)
end)

RegisterServerEvent('pw_base:server:triggerServerCallback')
AddEventHandler('pw_base:server:triggerServerCallback', function(name, requestId, ...)
	local _source = source

	PW.TriggerServerCallback(name, requestID, _source, function(...)
		TriggerClientEvent('pw_base:client:serverCallback', _source, requestId, ...)
	end, ...)
end)

PW.RandomString = function(length)
    local charset = {}
    for i = 48,  57 do table.insert(charset, string.char(i)) end
    for i = 65,  90 do table.insert(charset, string.char(i)) end
    for i = 97, 122 do table.insert(charset, string.char(i)) end

    local function randomstr(length)
        math.randomseed(os.time())
        if length > 0 then
            return randomstr(length - 1) .. charset[math.random(1, #charset)]
        else
            return ""
        end
    end

    return randomstr(length)
end

PW.SetTimeout = function(msec, cb)
	local id = PW.TimeoutCount + 1

	SetTimeout(msec, function()
		if PW.CancelledTimeouts[id] then
			PW.CancelledTimeouts[id] = nil
		else
			cb()
		end
	end)

	PW.TimeoutCount = id

	return id
end

PW.ClearTimeout = function(id)
	PW.CancelledTimeouts[id] = true
end

PW.CheckOnlineDuty = function(job)
	local online = {}
	for k, v in pairs(Players) do
		if Users[v] then
			if Users[v]:Job().getJob().job == job and Users[v]:Job().getDuty() then
				table.insert(online, {['cid'] = Users[v]:Character().getCID(), ['job'] = Users[v]:Job().getJob(), ['source'] = Users[v]:Character().getSource() })
			end
		end
	end
	return online
end

PW.TablePrint = function(t, s)
    for k, v in pairs(t) do
        local kfmt = '["' .. tostring(k) ..'"]'
        if type(k) ~= 'string' then
            kfmt = '[' .. k .. ']'
        end
        local vfmt = '"'.. tostring(v) ..'"'
        if type(v) == 'table' then
            PW.TablePrint(v, (s or '')..kfmt)
        else
            if type(v) ~= 'string' then
                vfmt = tostring(v)
            end
            print(type(t)..(s or '')..kfmt..' = '..vfmt)
        end
    end
end

function multiInsert(times)
    local initialQuery = "(@id, @item, @count, @metapub, @metapri, @type, @slot)"
    local newQuery
    for i = 1, times do
        if i == 1 then
            newQuery = initialQuery
        else
            initialQuery = "(@id, @item, @count, @metapub, @metapri, @type, @slot)"
            newQuery = newQuery .. ',' .. initialQuery
        end
    end
    Citizen.Wait(50)
    return newQuery
end

function split(s, sep)
    local fields = {}

    local sep = sep or " "
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)

    return fields
end

AddEventHandler('pw:getSharedObject', function(cb)
	cb(PW)
end)

function getSharedObject()
	return PW
end

exports('getSharedObject', function()
    return getSharedObject()
end)

PW.RegisterServerCallback('pw_base:server:checkItemCount', function(source, cb, item)
	local _src = source
	local _char = exports['pw_base']:Source(_src)
	cb(_char:Inventories().getItemCount(item))
end)

function checkOnline(cid)
	for k, v in pairs(Users) do
		if tonumber(Users[k].loadedChar) == tonumber(cid) then
			return Users[k]:Character():getSource()

		end
	end
	return false
end

function getOnlineCharacters()
	local onlineChars = {}
	for k, v in pairs(Users) do
		if v.loadedChar ~= 0 then
			table.insert(onlineChars, {['cid'] = v.Character():getCID(), ['source'] = v.Character():getSource() } )
		end
	end
	return onlineChars
end

exports('getOnlineCharacters', function()
    return getOnlineCharacters()
end)

exports('checkOnline', function(cid)
    return checkOnline(tonumber(cid))
end)

function selectOfflineByCID(cid)
	if tonumber(cid) ~= nil then
		local processed = false
		local uid
		local character = MySQL.Async.fetchScalar("SELECT `uid` FROM `characters` WHERE `cid` = @cid", {['@cid'] = tonumber(cid)}, function(userid)
			uid = userid
			processed = true
		end)
		repeat Wait(0) until processed == true
		if tonumber(uid) ~= nil then
			if Users[tonumber(uid)] then
				return Users[tonumber(uid)]
			else
				return nil
			end
        end
    end
end

exports('selectOfflineByCID', function(cid)
    return selectOfflineByCID(tonumber(cid))
end)

PW.RegisterServerCallback('pw_base:functions:getAvailiableGrades', function(source, cb, job)
	MySQL.Async.fetchAll("SELECT * FROM `job_grades` WHERE `job` = @job", { ['@job'] = job }, function(grades)
		cb(grades)
	end)
end)

PW.RegisterServerCallback('pw_base:functions:getAvaliableJobs', function(source, cb)
	MySQL.Async.fetchAll("SELECT * FROM `avaliable_jobs`", {}, function(jobs)
		cb(jobs)
	end)
end)

PW.RegisterServerCallback('pw_base:functions:getTotalPlayers', function(source, cb)
	local total = 0
	for k, v in pairs(Players) do
		total = total + 1
	end
	cb(total)
end)

PW.RegisterServerCallback('pw_base:functions:getGradeSalery', function(source, cb, job, grade)
	MySQL.Async.fetchScalar("SELECT `salery` FROM `job_grades` WHERE `job` = @job AND `grade` = @grade", {['@job'] = job, ['@grade'] = grade}, function(sal)
		cb(sal)
	end)
end)

PW.RegisterServerCallback('pw:base:server:getPlayerNamesNearby', function(source, cb, players)
    local tbl = {}
    for k, v in pairs(players) do
        if Users[Players[tonumber(v.id)]] then
            table.insert(tbl, {['name'] = Users[Players[tonumber(v.id)]]:Character():getName(), ['id'] = v.id, ['cid'] = Users[Players[tonumber(v.id)]]:Character():getCID(), ['uid'] = Users[Players[tonumber(v.id)]]:User():getUID()})
        end
    end
    cb(tbl)
end)