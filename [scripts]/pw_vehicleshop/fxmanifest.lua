description 'PixelWorld Vehicle Shop'
name 'PixelWorld [pw_vehicleshop]'
author 'PixelWorldRP [Chris Rogers] - https://pixelworldrp.com'
version 'v1.0.0'

-- These are the client side scripts the resource will load.
client_scripts {
    'config/main.lua',
    'config/vehiclemakes.lua',
    'client/main.lua',
    'client/nui.lua'
}

-- These are the server side scripts the resource will load
server_scripts {
    '@pw_mysql/lib/MySQL.lua',
    'config/main.lua',
    'config/vehiclemakes.lua',
    'server/wrappers/vehicles.lua',
    'server/main.lua'
}

ui_page 'nui/index.html'

files {
    -- NUI Images Here - These are images/files for all NUI Components and are required no matter the item type.
    'nui/style.css',
    'nui/index.html',
    'nui/pw_vehicleshop.js',
    'nui/scripting/jquery-ui.css',
    'nui/scripting/external/jquery/jquery.js',
    'nui/scripting/jquery-ui.js',
    'nui/images/logo.png',
    'nui/images/logo.gif',
    'nui/images/noimage.jpg',

}


-- We tend to have this to ensure the base is loaded before sub resources
dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_menu',
    'pw_base' 
}

fx_version 'adamant'
games {'gta5'}