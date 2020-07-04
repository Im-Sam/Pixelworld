RegisterServerEvent('chat:init')
RegisterServerEvent('chat:addTemplate')
RegisterServerEvent('chat:addMessage')
RegisterServerEvent('chat:addSuggestion')
RegisterServerEvent('chat:removeSuggestion')
RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('pw:chat:server:ClearChat')
RegisterServerEvent('__cfx_internal:commandFallback')

AddEventHandler('_chat:messageEntered', function(author, color, message)
    if not message or not author then
        return
    end

    TriggerEvent('chatMessage', source, author, message)

    if not WasEventCanceled() then
        --TriggerClientEvent('chatMessage', -1, author,  { 255, 255, 255 }, message)
    end
end)

AddEventHandler('__cfx_internal:commandFallback', function(command)
    local name = GetPlayerName(source)

    TriggerEvent('chatMessage', source, name, '/' .. command)

    if not WasEventCanceled() then
        --TriggerClientEvent('chatMessage', -1, name, { 255, 255, 255 }, '/' .. command) 
    end

    CancelEvent()
end)

-- command suggestions for clients
local function refreshCommands(player)
    local mPlayer = exports.pw_base:Source(player)
    if mPlayer ~= nil then
        local mData = mPlayer
        for k, command in pairs(commandSuggestions) do
            if IsPlayerAceAllowed(player, ('command.%s'):format(k)) then
                if commands[k] ~= nil then
                    if commands[k].admin then
                        if mData.User():getPermission() == 'Owner' or mData.User():getPermission() == 'Admin' or mData.User():getPermission() == 'Developer' then 
                            TriggerClientEvent('chat:addSuggestion', player, '/' .. k, command.help, command.params)
                        else
                            TriggerClientEvent('chat:removeSuggestion', player, '/' .. k)
                        end
                    elseif commands[k].job ~= nil then
                        for k2, v2 in pairs(commands[k].job) do
                            if v2 == mData:Job():getJob().job and mData:Job().getDuty() then
                                TriggerClientEvent('chat:addSuggestion', player, '/' .. k, command.help, command.params)
                                break
                            else
                                TriggerClientEvent('chat:removeSuggestion', player, '/' .. k)
                            end
                        end
                        
                    else
                        TriggerClientEvent('chat:addSuggestion', player, '/' .. k, command.help, command.params)
                    end
                else
                    TriggerClientEvent('chat:addSuggestion', player, '/' .. k, '')
                end
            end
        end
    end
end

AddEventHandler('chat:init', function()
    --refreshCommands(source)
end)

RegisterServerEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    TriggerClientEvent('chat:resetSuggestions', source)
    refreshCommands(source)
end)
 
RegisterServerEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(source)
    Wait(500)
    TriggerClientEvent('chat:resetSuggestions', source)
    refreshCommands(source)
end)

RegisterServerEvent('pw_chat:refreshChat')
AddEventHandler('pw_chat:refreshChat', function(src)
    local _src
    if src ~= nil then
        _src = src
    else
        _src = source
    end
    TriggerClientEvent('chat:resetSuggestions', _src)
    refreshCommands(_src)
end)

AddEventHandler('onServerResourceStart', function(resName)
    Wait(500)
    for _, player in ipairs(exports.pw_base:getOnlineCharacters()) do
        refreshCommands(player)
    end
end)
