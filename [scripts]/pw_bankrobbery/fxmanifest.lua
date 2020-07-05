fx_version 'adamant'
games {'gta5'}

description 'PixelWorld Banking'
name 'PixelWorld: pw_bankrobbery'
author 'PixelWorldRP'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua',
    'config/config.lua',
    'server/main.lua'
}

client_scripts {
    'config/config.lua',
    'client/main.lua'
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_menu',
    'pw_base'
}