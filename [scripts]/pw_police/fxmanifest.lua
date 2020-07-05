description 'PixelWorld Police'
name 'PixelWorld pw_police'
author 'PixelWorldRP'
version 'v1.0.0'

client_scripts {
    'config/main.lua',
    'client/cad.lua',
    'client/functions.lua',
    'client/main.lua'
}

server_scripts {
    '@pw_mysql/lib/MySQL.lua',
    'config/main.lua',
    'server/main.lua'
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_interact',
    'pw_base'
}

ui_page "nui/ui.html"

files {
    "nui/*"
}

fx_version 'adamant'
games {'gta5'}