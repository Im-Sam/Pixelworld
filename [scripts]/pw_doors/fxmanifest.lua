description 'PixelWorld Doors'
name 'PixelWorld pw_doors'
author 'PixelWorldRP [creaKtive] - https://pixelworldrp.com'
version 'v1.0.0'

client_scripts {
    'config/main.lua',
    'client/main.lua'
}

server_scripts {
    '@pw_mysql/lib/MySQL.lua',
    'config/main.lua',
    'server/main.lua'
}

dependencies {
    'pw_mysql',
    'pw_queue',
    'pw_notify',
    'pw_progbar',
    'pw_menu',
    'pw_base' 
}

fx_version 'adamant'
games {'gta5'}