description 'PixelWorld Mining'
name 'PixelWorld pw_mining'
author 'PixelWorldRP [Dr Nick] - https://pixelworldrp.com'
version 'v1.0.0'


server_scripts {
    'config.lua',
    'server/main.lua'
}

client_scripts {
    'config.lua',
    'client/main.lua'
}

dependencies {
    'pw_base',
    'pw_sound',
    'pw_notify',
    'pw_progbar',
    'pw_drawtext'
}

fx_version 'adamant'
games {'gta5'}