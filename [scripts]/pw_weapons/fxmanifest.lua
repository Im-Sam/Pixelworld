description 'PixelWorld Weapons System'
name 'PixelWorld pw_weapons'
author 'PixelWorldRP [Chris Rogers] - https://pixelworldrp.com'
version 'v1.0.1'

client_scripts {
    'config/main.lua',
    'config/weapons.lua',
	'client/main.lua'
}

server_scripts {
    '@pw_mysql/lib/MySQL.lua',
    'config/main.lua',
    'config/weapons.lua',
    'server/wrapper/weapons.lua',
	'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/style.css',
    'html/index.html',
    'html/pw_weapons.js',
    'html/scripting/jquery-ui.css',
    'html/scripting/external/jquery/jquery.js',
    'html/scripting/jquery-ui.js',
    'html/images/*.png'
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_menu',
    'pw_base',
    'pw_inventory'
}

fx_version 'adamant'
games {'gta5'}