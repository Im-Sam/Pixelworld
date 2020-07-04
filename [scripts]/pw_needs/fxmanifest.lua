description 'PixelWorld Basic Needs'
name 'PixelWorld: pw_needs'
author 'PixelWorldRP [Author] - https://pixelworldrp.com'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua',
    'config/main.lua',
    'common/functions.lua',
    'server/main.lua'
}

client_scripts {
    'config/main.lua',
    'common/functions.lua',
    'client/main.lua',
}

ui_page 'html/index.html'

files {
    'html/pw_needs.css',
    'html/index.html',
    'html/pw_needs.js'
}

dependencies {
    'pw_mysql',
    'pw_base'
}

fx_version 'adamant'
games {'gta5'}