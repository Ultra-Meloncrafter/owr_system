fx_version 'cerulean'
game 'gta5'
author 'Ultra-Meloncrafter火の神'
description 'OWR System'
version '1.0'
lua54 'yes'

-- Client Script
client_scripts {
	"@es_extended/locale.lua",
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'client/client.lua',
}

server_scripts {
	'@es_extended/locale.lua',
	'@mysql-async/lib/MySQL.lua',
	'server/server.lua',
}