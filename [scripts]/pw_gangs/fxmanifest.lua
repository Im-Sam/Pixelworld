description 'PixelWorld Gangs'
name 'PixelWorld: pw_gangs'
author 'PixelWorldRP [Dr Nick] - https://pixelworldrp.com'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua', 
    'config.lua',
    'server/main.lua',
}

client_scripts {
    'config.lua',
    'client/main.lua',
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_menu',
    'pw_base'
}

fx_version 'adamant'
games {'gta5'}
