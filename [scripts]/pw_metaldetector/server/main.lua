PW = nil

TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)

PW.RegisterServerCallback('pw_metaldetector:server:checkMetalicItems', function(source, cb)
    local _src = source
    _char = exports['pw_base']:Source(_src)
    cb(_char:Inventories().getMetalicItems())
end)