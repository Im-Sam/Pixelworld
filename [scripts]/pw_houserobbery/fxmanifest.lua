fx_version 'adamant'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'PixelWorld NPC House Robberys'
name 'PixelWorld: [pw_houserobbery]'
author 'PixelWorldRP'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua', -- Required for MySQL Support
    'config/main.lua',
    'server/main.lua',
}

client_scripts {
    'config/main.lua',
    'client/main.lua',
}

ui_page 'nui/index.html' -- Only Required if implementing a NUI

files { -- Any NUI Files also need to be loaded here.
    'nui/index.html',
    'nui/css/style.css',
    'nui/noise.js',
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_menu',
    'pw_base'
}