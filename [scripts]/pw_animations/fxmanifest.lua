description 'PixelWorld Animations'
name 'PixelWorld: pw_animations'
author 'PixelWorldRP [Chris Rogers] - https://pixelworldrp.com'
version 'v1.0.0'

server_scripts {
    'config/main.lua',
    'server/main.lua'
}

client_scripts {
    'config/main.lua',
    'client/main.lua',
}


dependencies {
    'pw_base'
}

fx_version 'adamant'
games {'gta5'}