
------
-- InteractSound by Scott
-- Verstion: v0.0.1
------
-- Client Scripts
client_script 'client/main.lua'

-- Server Scripts
server_script 'server/main.lua'

-- NUI Default Page
ui_page('client/html/index.html')

-- Files needed for NUI
-- DON'T FORGET TO ADD THE SOUND FILES TO THIS!
files({
    'client/html/index.html',
    -- Begin Sound Files Here...
    -- client/html/sounds/ ... .ogg
    'client/html/sounds/demo.ogg',
    'client/html/sounds/cell.ogg',
    'client/html/sounds/housedoor.ogg',
    'client/html/sounds/houseknock.ogg',
    'client/html/sounds/houselock.ogg',
    'client/html/sounds/stashopen.ogg',
    'client/html/sounds/metaldetect.ogg',
    'client/html/sounds/alarm.ogg',
    'client/html/sounds/success.ogg',
    'client/html/sounds/error.ogg',
    'client/html/sounds/pickaxe.ogg',
})

fx_version 'adamant'
games { 'gta5' }