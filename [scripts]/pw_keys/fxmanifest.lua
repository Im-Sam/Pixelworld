description 'PixelWorld Keys System'
name 'PixelWorld pw_keys'
author 'PixelWorldRP'
version 'v1.0.0'

client_scripts {
	'client/main.lua'
}

server_scripts {
    '@pw_mysql/lib/MySQL.lua',
	'server/main.lua'
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_menu',
    'pw_base'
}

fx_version 'adamant'
games {'gta5'}