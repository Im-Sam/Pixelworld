PW = nil

TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)

PW.RegisterServerCallback('pw_lockpick:server:getBobbyPins', function(source, cb)
    local _src = source
    local _character = exports['pw_base']:Source(_src)
    local _bobbyPins = _character:Inventories().getItemCount('bobbypin')
    local _screwdriver = _character:Inventories().getItemCount('screwdriver')
        if _bobbyPins == nil and _screwdriver == nil then
            cb(0, 0)
        else
            cb(_bobbyPins, _screwdriver)
        end
end)

RegisterServerEvent('pw_lockpick:server:removePin')
AddEventHandler('pw_lockpick:server:removePin', function()
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    _char:Inventories():Remove().byName('bobbypin', 1)
end)