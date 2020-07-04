description 'PixelWorld Self-Blips'
name 'PixelWorld: pw_blips'
author 'PixelWorldRP [creaKtive] - https://pixelworldrp.com'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua',
    'config/config.lua',
    'server/main.lua'
}

client_scripts {
    'config/config.lua',
    'client/main.lua',
}

dependencies {
    'pw_mysql',
    'pw_base'
}

fx_version 'adamant'
games {'gta5'}