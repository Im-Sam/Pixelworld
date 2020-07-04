description 'Coord Shower'

client_scripts {
	"coords.lua"
}

server_scripts {
	'@pw_mysql/lib/MySQL.lua',
	'server.lua'
}

ui_page 'nui/index.html'

files {
	'nui/app.js',
	'nui/index.html',
	'nui/image/logo.png',
	'nui/style.css',
}

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_menu'
}

fx_version 'adamant'
games { 'gta5' }