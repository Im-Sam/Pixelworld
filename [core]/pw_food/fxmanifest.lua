fx_version 'adamant'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'PixelWorld Food / Drinks'
name 'PixelWorld: [pw_food]'
author 'PixelWorldRP [Chris Rogers] - https://pixelworldrp.com'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua', -- Required for MySQL Support
    'server/server.lua',
}

server_only 'yes'

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_menu',
    'pw_base'
}

