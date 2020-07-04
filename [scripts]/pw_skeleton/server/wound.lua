function GetCharsInjuries(src)
    local _char = exports.pw_base:Source(src)
    return _char:Injuries():Load()
end

RegisterServerEvent('pw_skeleton:server:GetInjuries')
AddEventHandler('pw_skeleton:server:GetInjuries', function()
    local _src = source
    local sendInjuries = {}
    sendInjuries = GetCharsInjuries(_src)

    TriggerClientEvent('pw_skeleton:client:LoadInjuries', _src, sendInjuries)
end)

RegisterServerEvent('pw_skeleton:server:SyncInjuries')
AddEventHandler('pw_skeleton:server:SyncInjuries', function(data)
    local _src = source
    local _char = exports.pw_base:Source(_src)
    if _char then
        _char:Injuries().Save(data)
    end
end)