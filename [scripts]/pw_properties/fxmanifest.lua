description 'PixelWorld Properties'
name 'PixelWorld pw_properties'
author 'PixelWorldRP'
version 'v1.0.0'

client_scripts {
    'config/main.lua',
    'config/furniture.lua',
    'client/main.lua'
}

server_scripts {
    '@pw_mysql/lib/MySQL.lua',
    '@pw_async/async.lua',
    'config/main.lua',
    'config/furniture.lua',
    'server/wrappers/properties.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/style.css',
    'html/index.html',
    'html/pw_properties.js',
    'html/scripting/jquery-ui.css',
    'html/scripting/external/jquery/jquery.js',
    'html/scripting/jquery-ui.js',
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_async',
    'pw_progbar',
    'pw_menu',
    'pw_interact',
    'pw_base'
}

fx_version 'adamant'
games {'gta5'}