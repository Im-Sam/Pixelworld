PW = nil

TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)

RegisterServerEvent('pw_notes:server:createNote')
AddEventHandler('pw_notes:server:createNote', function(message)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    MySQL.Async.insert("INSERT INTO `notes` (`message`) VALUES (@message)", {['@message'] = message}, function(noteid)
        if noteid > 0 then
            _char:Inventories():AddItem():Player().Single('note', 1, {['public'] = { ['note'] = noteid }})
        end
    end)
end)

RegisterServerEvent('pw_notes:server:updateNote')
AddEventHandler('pw_notes:server:updateNote', function(noteid, message)
    MySQL.Async.execute("UPDATE `notes` SET `message` = @message WHERE `note_id` = @id", {['@message'] = message, ['@id'] = noteid}, function()
    end)
end)

RegisterServerEvent('pw_base:itemUsed')
AddEventHandler('pw_base:itemUsed', function(_src, data)
    if data.item == "note" then
        noteId = json.decode(data.metapublic)
        MySQL.Async.fetchScalar("SELECT `message` FROM `notes` WHERE `note_id` = @id", {['@id'] = noteId.note}, function(message)
            print(message, noteId.note)
            TriggerClientEvent('pw_notes:client:openNote', _src, noteId.note, message)
        end)
    end
end)



exports['pw_chat']:AddChatCommand('note', function(source, args, rawCommand)
    local _src = source
    if _src > 0 then
        TriggerClientEvent('pw_notes:client:newNote', _src)
    end
end, {
    help = "Create a New Note"
}, -1)