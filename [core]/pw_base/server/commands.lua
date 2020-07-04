RegisterServerEvent('pw_base:startMeText')
AddEventHandler('pw_base:startMeText', function(text)
    local _src = source
    if text ~= nil then
        TriggerClientEvent('pw_base:broadcastMeText', -1, text, _src)
    end
end)

exports['pw_chat']:AddChatCommand('me', function(source, args, rawCommand)
    local _src = source
    if args[1] ~= nil then
        TriggerClientEvent('pw_base:startMeText', _src, args)
    end
end, {
    help = "Send a Me Action Message"
}, -1)

exports['pw_chat']:AddAdminChatCommand('pfx', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_base:admin:testParticleFX', _src, args)
end, {
    help = "Test Out ParticleFX",
    params = {
    {
        name = "Dictionary",
        help = "The Disctionary the Particle FX is apart of"
    },
    {
        name = "Name",
        help = "The String name of the ParticleFX"
    },
    {
        name = "Loop FX",
        help = "Either True or False or (1 or 0)"
    },
}
}, -1)

exports['pw_chat']:AddChatCommand('givecash', function(source, args, rawCommand)
    local _src = source
    if args[1] ~= nil and args[2] ~= nil then
        local xTarget = tonumber(args[2])
        local myTarget = _src
        if Players[_src] and Players[xTarget] then
            if exports['pw_base']:Source(myTarget):Cash().getCash() >= args[2] then
                exports['pw_base']:Source(myTarget):Cash().Remove(tonumber(args[2]))
                exports['pw_base']:Source(xTarget):Cash().Add(tonumber(args[2]))
                local SrcName = exports['pw_base']:Source(myTarget):Character().getName()
                local TgtName = exports['pw_base']:Source(xTarget):Character().getName()
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You have given $"..args[2]..' to '..TgtName, length = 5000})
                TriggerClientEvent('pw:notification:SendAlert', xTarget, {type = "error", text = "You have received $"..args[2]..' from '..SrcName, length = 5000})
            else
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You do not have enough cash to hand over this amount", length = 5000})
            end
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "The requested PayPal ID is not avaliable.", length = 5000})
        end
    end
end, {
    help = "Send a Me Action Message"
}, -1)

exports['pw_chat']:AddAdminChatCommand('addcash', function(source, args, rawCommand)
    local _src = source
    if args[1] ~= nil and args[2] ~= nil then
        local xTarget = tonumber(args[1])
        if Players[xTarget] then
            local added = exports['pw_base']:Source(xTarget):Cash().Add(tonumber(args[2]))
            if added then
                local newTotal = exports['pw_base']:Source(xTarget):Cash().getCash()
                if _src ~= xTarget then
                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = "$"..tonumber(args[2]).." has been added to the players cash, New Cash Balance: $"..newTotal, length = 5000})
                end
                TriggerClientEvent('pw:notification:SendAlert', xTarget, {type = "success", text = "$"..tonumber(args[2]).." has been added to your cash, New Cash Balance: $"..newTotal, length = 5000})
                doAdminLog(_src, "Gave User "..xTarget.." $"..tonumber(args[2]).." directly into there pocket as cash.", xTarget)
            end
            
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "The requested Player ID is not online", length = 5000})
            doAdminLog(_src, "Attempted to give a user $"..tonumber(args[2]).." directly into there pocket as cash, however the user was not online")
        end
    end
end, {
    help = "Give Cash to a Player",
    params = {
    {
        name = "PlayerID",
        help = "The Server ID of the Player"
    },
    {
        name = "Amount of Cash",
        help = "The Amount of Cash to Give the Player"
    },
}
}, -1)

exports['pw_chat']:AddAdminChatCommand('addbank', function(source, args, rawCommand)
    local _src = source
    if args[1] ~= nil and args[2] ~= nil then
        local xTarget = tonumber(args[1])
        if Players[xTarget] then
            local added = exports['pw_base']:Source(xTarget):Bank().Add(tonumber(args[2]), "Money Given by Server Admin")
            if added then
                local newTotal = exports['pw_base']:Source(xTarget):Bank().getBalance()
                if _src ~= xTarget then
                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = "$"..tonumber(args[2]).." has been added to the players bank, New Bank Balance: $"..newTotal, length = 5000})
                end
                TriggerClientEvent('pw:notification:SendAlert', xTarget, {type = "success", text = "$"..tonumber(args[2]).." has been added to your bank, New Bank Balance: $"..newTotal, length = 5000})             
                doAdminLog(_src, "Gave User "..xTarget.." $"..tonumber(args[2]).." directly into there bank account.", xTarget)
            end
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "The requested Player ID is not online", length = 5000})
            doAdminLog(_src, "Attempted to give a user $"..tonumber(args[2]).." directly into there bank account, however the user was not online")
        end
    end
end, {
    help = "Give Cash to a Player",
    params = {
    {
        name = "PlayerID",
        help = "The Server ID of the Player"
    },
    {
        name = "Amount of Cash",
        help = "The Amount of Cash to Give the Player"
    },
}
}, -1)

exports['pw_chat']:AddAdminChatCommand('giveitem', function(source, args, rawCommand)
    local _src = source
    if args[1] ~= nil and args[2] ~= nil then
        local amount = tonumber(args[3]) or 1
        local xTarget = tonumber(args[1])
        if Players[xTarget] then
            if args[2] == "simcard" then
                TriggerClientEvent('pw:notification:SendAlert', source, {type = "inform", text = "Simcards can only be purchased from a shop, and not given to people by the Admin Command.", length = 5000})
            else
                exports['pw_base']:Source(xTarget):Inventories():AddItem():Player().Single(args[2], amount)
                doAdminLog(_src, "Gave User "..xTarget.." "..amount.."x of "..args[2]..".", xTarget)
            end
        else
            doAdminLog(_src, "Attempted to give a User "..amount.."x of "..args[2]..", however the user was not online.")
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "The requested Player ID is not online", length = 5000})
        end
    end

end, {
    help = "Give an Item to a Player",
    params = {
    {
        name = "PlayerID",
        help = "The Server ID of the Player"
    },
    {
        name = "Item Name",
        help = "The Item you wish to give the player"
    },
    {
        name = "Quantity (Optional)",
        help = "The Amount of the Item you wish to Give"
    },
}
}, -1)

exports['pw_chat']:AddAdminChatCommand('giveweapon', function(source, args, rawCommand)
    local _src = source
    if args[1] ~= nil and args[2] ~= nil and args[3] ~= nil then
        local amount = tonumber(args[3])
        local xTarget = tonumber(args[1])
        if Players[xTarget] then
            exports['pw_base']:Source(xTarget):Inventories():AddItem():Player().Weapon(args[2], amount, true)
            doAdminLog(_src, "Gave User "..xTarget.." a "..args[2].." with "..amount.."x ammo.", xTarget)
        else
            doAdminLog(_src, "Attempted to give a User a "..args[2].." with "..amount.."x ammo, however the user was not online.")
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "The requested Player ID is not online", length = 5000})
        end
    end

end, {
    help = "Give a Player a Weapon Item",
    params = {
    {
        name = "PlayerID",
        help = "The Server ID Of the Player to Give to"
    },
    {
        name = "Weapon Name",
        help = "The Weapon to Give (e.g WEAPON_PISTOL)"
    },
    {
        name = "Ammo",
        help = "The Amount of Ammo to give with the weapon"
    },
}
}, -1)

exports['pw_chat']:AddAdminChatCommand('sv', function(source, args, rawCommand)
    local _src = source
    local model = args[1] or "r820"
    TriggerClientEvent('pw_base:admin:spawnVehicle', _src, model)
    doAdminLog(_src, "Spawned a "..model.." vehicle on the server.")
end, {
    help = "Spawn a Vehicle",
    params = {
    {
        name = "MODEL",
        help = "Model Name or Blank for the 'Audi R820'"
    },
}
}, -1)

exports['pw_chat']:AddAdminChatCommand('dv', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_base:admin:deleteVehicle', _src)
end, {
    help = "Despawn a Vehicle"
}, -1)

exports['pw_chat']:AddAdminChatCommand('goto', function(source, args, rawCommand)
    local _src = source
    if _src then
        if args[1] and args[2] and args[3] then
            coords = { ['x'] = tonumber(args[1]), ['y'] = tonumber(args[2]), ['z'] = tonumber(args[3]) }
        else
            coords = { ['x'] = false, ['y'] = false, ['z'] = false }
        end
        TriggerClientEvent('pw:teleport', _src, coords)
    end
end, {
    help = "Goto a Location",
    params = {{ name = "X", help = "The X Position"}, { name = "Y", help = "The Y Position"}, {name = "Z", help = "The Z Position"} }
}, -1)

RegisterCommand('consoleadduser', function(source, args)
    if source == 0 then
        local addtype, id, whitelisted, prio, level = args[1], args[2], tonumber(args[3]), tonumber(args[4]), args[5]
        if addtype ~= nil and id ~= nil and whitelisted ~= nil and prio ~= nil then
            if level == nil then
                level = "User"
            end

            local function generateIdent(genId)
                local processed = false
                local res
                MySQL.Async.fetchScalar("SELECT `unique_id` FROM `users` WHERE `unique_id` = @uid", {['@uid'] = genId}, function(id)
                    res = id
                    processed = true
                end)
                repeat Wait(0) until processed == true
                return res
            end

            local randomIdent
            repeat
                math.randomseed(os.time())
                randomIdent = math.random(111111111,999999999)
                local check = generateIdent(randomIdent)
            until check == nil

            if level:upper() == "OWNER" then
                level = "Owner"
            elseif level:upper() == "ADMIN" then
                level = "Admin"
            elseif level:upper() == "DEVELOPER" then
                level = "Developer"
            else
                level = "User"
            end 
            local query

            if addtype:upper() == "STEAM" then
                id = "steam:"..id
                query = "INSERT INTO `users` (`unique_id`, `steam`, `prio`, `whitelisted`, `permission`) VALUES (@uid, @id, @prio, @wl, @perm)"
            else
                id = "license:"..id
                query = "INSERT INTO `users` (`unique_id`, `license`, `prio`, `whitelisted`, `permission`) VALUES (@uid, @id, @prio, @wl, @perm)"
            end

            if randomIdent ~= nil and randomIdent > 0 then
                MySQL.Async.insert(query, {['@uid'] = randomIdent, ['@id'] = id, ['@prio'] = prio, ['@wl'] = whitelisted, ['perm'] = level}, function(inserted)
                    if inserted > 0 then
                        Users[tonumber(randomIdent)] = User(tonumber(randomIdent))
                        if whitelisted then
                            local pw_queue = exports.pw_queue:GetQueueExports()
                            pw_queue.AddPriority(id, prio)
                            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = "The New User has been added to the system, and has also been whitelisted.", length = 5000})
                        else
                            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = "The New User has been added to the system", length = 5000})
                        end
                    end
                end)
            end
        else
            print('Error In Syntaxing - Format "/consoleadduser [steam/license] [steam/license id] [whitelisted 1 or 0] [prio 1-100] [permission admin/developer/owner/user]"')
        end
    else
        local _src = source
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You can not execute this command in-game, please use the '/adduser' command for adding a user within the game.", length = 5000})
    end
end, true)

exports['pw_chat']:AddAdminChatCommand('adduser', function(source, args, rawCommand)  
    local addtype, id, whitelisted, prio, level = args[1], args[2], tonumber(args[3]), tonumber(args[4]), args[5]

    if addtype ~= nil and id ~= nil and whitelisted ~= nil and prio ~= nil then
        if level == nil then
            level = "User"
        end

        local function generateIdent(genId)
            local processed = false
            local res
            MySQL.Async.fetchScalar("SELECT `unique_id` FROM `users` WHERE `unique_id` = @uid", {['uid'] = genId}, function(id)
                res = id
                processed = true
            end)
            repeat Wait(0) until processed == true
            return res
        end

        local randomIdent
        repeat
            math.randomseed(os.time())
            randomIdent = math.random(111111111,999999999)
            local check = generateIdent(randomIdent)
        until check == nil

        if level:upper() == "OWNER" then
            level = "Owner"
        elseif level:upper() == "ADMIN" then
            level = "Admin"
        elseif level:upper() == "DEVELOPER" then
            level = "Developer"
        else
            level = "User"
        end 
        local query

        if addtype:upper() == "STEAM" then
            id = "steam:"..id
            query = "INSERT INTO `users` (`unique_id`, `steam`, `prio`, `whitelisted`, `permission`) VALUES (@uid, @id, @prio, @wl, @perm)"
        else
            id = "license:"..id
            query = "INSERT INTO `users` (`unique_id`, `license`, `prio`, `whitelisted`, `permission`) VALUES (@uid, @id, @prio, @wl, @perm)"
        end

        if randomIdent ~= nil and randomIdent > 0 then
            MySQL.Async.insert(query, {['@uid'] = randomIdent, ['@id'] = id, ['@prio'] = prio, ['@wl'] = whitelisted, ['perm'] = level}, function(inserted)
                if inserted > 0 then
                    Users[tonumber(randomIdent)] = User(tonumber(randomIdent))
                    if whitelisted then
                        local pw_queue = exports.pw_queue:GetQueueExports()
                        pw_queue.AddPriority(id, prio)
                        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = "The New User has been added to the system, and has also been whitelisted.", length = 5000})
                    else
                        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = "The New User has been added to the system", length = 5000})
                    end
                end
            end)
        end
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "The command has been entered incorrectly.", length = 5000})
    end
end, {
    help = "Add a New User to the Server",
    params = {
    {
        name = "Addition Type",
        help = "Can either be 'steam' or 'license'"
    },
    {
        name = "ID",
        help = "This is the Users Steam or License ID Number (Do Not Include steam: or license:)"
    },
    {
        name = "Whitelisted",
        help = "1 for Yes, 0 for No"
    },
    {
        name = "Prioirty",
        help = "1-100 (1-70 Standard User, 71-80 Staff, 81-90 Developer, 91 - 100 Owners) (Higher the More Prio)"
    },
    {
        name = "Access Level (Optional)",
        help = "Either user/admin/developer or owner"
    },
}
}, -1)

exports['pw_chat']:AddAdminChatCommand('setgang', function(source, args, rawCommand)
    local _src = source
    if args[1] ~= nil and args[2] ~= nil then
        local xTarget = tonumber(args[1])
        if Players[xTarget] then
            local workplace
            if args[3] ~= nil then
                level = args[3]
            else
                level = 0
            end
            exports['pw_base']:Source(xTarget):Gang().setGang(tonumber(args[2]), tonumber(level))
            doAdminLog(_src, "Set the Gang of "..xTarget.." to "..args[2].." at the level of "..level..".", xTarget)
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "The requested Player ID is not online", length = 5000})
            doAdminLog(_src, "Attempted to set the Gang of a user to "..args[2].." at the level of "..level..", however the user was not online.")
        end
    end

end, {
    help = "Set the Gang of the requested Player",
    params = {
    {
        name = "PlayerID",
        help = "The Server ID of the player."
    },
    {
        name = "GangID",
        help = "The Unique Identifier for the Gang"
    },
    {
        name = "Level",
        help = "Optional will default to 0 if not set."
    }
}
}, -1)

exports['pw_chat']:AddAdminChatCommand('setjob', function(source, args, rawCommand)
    local _src = source
    if args[1] ~= nil and args[2] ~= nil and args[3] ~= nil then
        local xTarget = tonumber(args[1])
        local workplace
        if args[4] ~= nil then
            workplace = args[4]
        else
            workplace = 0
        end
        if Players[xTarget] then
            exports['pw_base']:Source(xTarget):Job().setJob(args[2], args[3], workplace)
            doAdminLog(_src, "Set the Job of "..xTarget.." to "..args[2].." at the grade of "..args[3].." for workplace "..workplace..".", xTarget)
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "The requested Player ID is not online", length = 5000})
            doAdminLog(_src, "Attempted to Set the Job for a user to "..args[2].." at the grade of "..args[3].." for workplace "..workplace..", however the user was not online")
        end
    end

end, {
    help = "Set the Job of the requested Player",
    params = {
    {
        name = "PlayerID",
        help = "The Server ID of the player."
    },
    {
        name = "Job Name",
        help = "The name of the Job in lowercase."
    },
    {
        name = "Grade Name",
        help = "The Job Grade/Rank"
    },
    {
        name = "WorkplaceID",
        help = "The Specific Workplace Buisness"
    },
}
}, -1)

exports['pw_chat']:AddAdminChatCommand('removejob', function(source, args, rawCommand)
    local _src = source
    local xTarget = tonumber(args[1]) or _src
    if Players[xTarget] then
        exports['pw_base']:Source(xTarget):Job().removeJob()
        doAdminLog(_src, "Removed the job for "..xTarget..".", xTarget)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "The requested Player ID is not online", length = 5000})
        doAdminLog(_src, "Attempted to Set the Job for a user to "..args[2].." at the grade of "..args[3].." for workplace "..workplace..", however the user was not online")
    end
end, {
    help = "Set the Job of the requested Player",
    params = {
    {
        name = "PlayerID",
        help = "The Server ID of the player. or blank for yourself"
    },
}
}, -1)