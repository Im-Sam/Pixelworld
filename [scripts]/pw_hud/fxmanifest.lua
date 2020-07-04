
description 'PixelWorld Hud Display'
name 'PixelWorld pw_hud'
author 'PixelWorldRP [Chris Rogers] - https://pixelworldrp.com'

client_scripts {
    'config/main.lua',
    'client/main.lua',
}

server_scripts {
    'config/main.lua',
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/style.css',
    'html/index.html',
    'html/pw_hud.js',
    'html/scripting/jquery-ui.css',
    'html/scripting/external/jquery/jquery.js',
    'html/scripting/jquery-ui.js',
}

fx_version 'adamant'
games {'gta5'}