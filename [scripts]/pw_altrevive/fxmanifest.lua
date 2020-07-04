description 'PixelWorld Alternate Revive (Grandma House)'
name 'PixelWorld: pw_altrevive'
author 'PixelWorldRP [Dr Nick] - https://pixelworldrp.com'
version 'v1.0.0'

server_scripts {
    'config.lua',
    'server/main.lua',
}

client_scripts {
    'config.lua',
    'client/main.lua',
}

dependencies {
    'pw_notify',
    'pw_progbar',
    'pw_base',
    'pw_interact',
    'pw_ems'
}

fx_version 'adamant'
games {'gta5'} 