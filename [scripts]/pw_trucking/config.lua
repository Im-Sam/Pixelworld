Config              = {}

Config.HaulagePoints = {
	['duty'] = {
		['coords'] = { ['x'] = 152.92, ['y'] = -3210.24, ['z'] = 5.9, ['h'] = 289 },
		['dutyNeeded'] = false,
		['drawDistance'] = 2.0,
		['public'] = false,
		['blip'] = true
	},
	['haulageMenu'] = {
		['coords'] = { ['x'] = 143.7, ['y'] = -3210.73, ['z'] = 5.86, ['h'] = 272.23 },
		['truckSpawnCoords'] = { ['x'] = 134.65, ['y'] = -3204.09, ['z'] = 5.92, ['h'] = 271.39 },
		['trailerSpawnCoords'] = { ['x'] = 123.63, ['y'] = -3204.24, ['z'] = 5.94, ['h'] = 265.71 },
		['dutyNeeded'] = true,
		['drawDistance'] = 2.0,
		['public'] = false
	},
	['vehicleReturn'] = {
		['coords'] = { ['x'] = 162.69, ['y'] = -3190.37, ['z'] = 5.95, ['h'] = 1.22 },
		['dutyNeeded'] = true,
		['drawDistance'] = 2.0,
		['public'] = false
	},
}

Config.Marker = {
	['markerType'] = 2,
	['markerSize']  = { ['x'] = 0.6, ['y'] = 0.6, ['z'] = 0.6 },
	['markerColor'] = { ['r'] = 51, ['g'] = 153, ['b'] = 255 }	
}


Config.DeliveryMarker = {
	['markerType'] = 2,
	['markerSize']  = { ['x'] = 1.0, ['y'] = 1.0, ['z'] = 1.0 },
	['markerColor'] = { ['r'] = 51, ['g'] = 153, ['b'] = 255 }	
}

Config.Blips = {
    ['type'] = 477,
    ['name'] = "Trucker Depot",
    ['scale'] = 0.8,
    ['color'] = 57
}

Config.Trucks = {
	['regular'] = {
		'phantom',
		'packer',
	},
	['special'] = {
		'packer',
	},
	['fuel'] = {
		'packer',
		'phantom',
	}
}

Config.Trailers = {
	['regular'] = {
		'trailers',
		'trailers2',
		'trailers4',
	},
	['special'] = {
		'tvtrailer',
	},
	['fuel'] = {
		'tanker',
	}	
}

-- Payment Config --
Config.RegularDeliveryPay = { -- random between these values for a base pay 
	['min'] = 200,
	['max'] = 305
}

Config.SpecialDeliveryPay = { -- random between these values for a base pay 
	['min'] = 300,
	['max'] = 400
}

Config.SpecialDeliveryChance = 5

Config.FuelDeliveryPay = { -- random between these values for a base pay 
	['min'] = 500,
	['max'] = 700
}

Config.RegularDeliveryPoints = {
	{ ['x'] = -371.02, ['y'] = -1857.89, ['z'] = 20.86, ['h'] = 19.08 }, -- Maze Arena
	{ ['x'] = -41.65, ['y'] = -757.68, ['z'] = 32.81, ['h'] = 276.27 }, -- Under Pbox Bridge
	{ ['x'] = -43.65, ['y'] = -722.22, ['z'] = 33.12, ['h'] = 159.89 },
	{ ['x'] = -16.85, ['y'] = -626.83, ['z'] = 35.8, ['h'] = 252.82 }, -- Union Dep
	{ ['x'] = -0.78, ['y'] = -563.73, ['z'] = 37.81, ['h'] = 333.85 },
	{ ['x'] = -1806.16, ['y'] = -333.28, ['z'] = 43.63, ['h'] = 238.61 }, -- Del Perro
	{ ['x'] = -1534.14, ['y'] = -576.4, ['z'] = 33.72, ['h'] = 317.23 },
	{ ['x'] = -258.78, ['y'] = -232.69, ['z'] = 35.89, ['h'] = 83.55 }, -- Rockford Mall
	{ ['x'] = 964.82, ['y'] = -8.8, ['z'] = 80.72, ['h'] = 148.5 }, -- Casino
	{ ['x'] = 928.1, ['y'] = -10.86, ['z'] = 78.85, ['h'] = 148.61 },
	{ ['x'] = 1859.66, ['y'] = 2692.64, ['z'] = 45.98, ['h'] = 150.27 }, -- Prison
	{ ['x'] = 2665.0, ['y'] = 3516.3, ['z'] = 52.92, ['h'] = 64.19 },
	{ ['x'] = -126.79, ['y'] = 6221.42, ['z'] = 31.28, ['h'] = 46.18 }, -- Paleto
	{ ['x'] = 148.45, ['y'] = 6350.02, ['z'] = 31.48, ['h'] = 116.61 },
	{ ['x'] = 6.19, ['y'] = 6431.19, ['z'] = 31.5, ['h'] = 242.04 },
	{ ['x'] = -14.61, ['y'] = 6450.75, ['z'] = 31.49, ['h'] = 226.12 },
	{ ['x'] = 11.67, ['y'] = 6431.33, ['z'] = 31.5, ['h'] = 220.12 }, 
	{ ['x'] = -2356.54, ['y'] = 277.89, ['z'] = 167.16, ['h'] = 22.29 } -- Museum Thing on Hill
}
Config.SpecialDeliveryPoints = {
	{ ['x'] = -371.02, ['y'] = -1857.89, ['z'] = 20.86, ['h'] = 19.08 }, -- Maze Arena
	{ ['x'] = 641.48, ['y'] = 596.24, ['z'] = 128.98, ['h'] = 157.29 }, -- Theatre Thing
	{ ['x'] = 1193.59, ['y'] = 324.92, ['z'] = 82.06, ['h'] = 328.65 }, -- Dog Run Thing
	{ ['x'] = 146.36, ['y'] = 6396.92, ['z'] = 31.24, ['h'] = 299.89 },
	{ ['x'] = -1392.36, ['y'] = 94.91, ['z'] = 54.39, ['h'] = 7.06 }, -- Golf 
	{ ['x'] = -1676.02, ['y'] = 78.84, ['z'] = 64.07, ['h'] = 50.24 },
	{ ['x'] = -409.03, ['y'] = 1239.02, ['z'] = 325.71, ['h'] = 73.19 }, -- Observ
}
Config.FuelDeliveryPoints = {
	[1] = { ['x'] = 502.86, ['y'] = -2246.75, ['z'] = 6.01, ['h'] = 37.35 }, -- Pick Up Fuel
	[2] = { ['x'] = 1213.44, ['y'] = -1398.61, ['z'] = 35.28, ['h'] = 316.21 }, --ALL RON Fuel Stations
	[3] = { ['x'] = 173.12, ['y'] = -1553.91, ['z'] = 29.27, ['h'] = 312.48 },
	[4] = { ['x'] = 824.05, ['y'] = -1030.39, ['z'] = 26.42, ['h'] = 181.34 },
	[5] = { ['x'] = -1441.8, ['y'] = -258.59, ['z'] = 46.27, ['h'] = 133.56 },
	[6] = { ['x'] = -2547.92, ['y'] = 2330.97, ['z'] = 33.12, ['h'] = 272.96 },
	[7] = { ['x'] = 189.52, ['y'] = 6612.49, ['z'] = 31.87, ['h'] = 14.51 },
	[8] = { ['x'] = 2576.53, ['y'] = 355.61, ['z'] = 108.51, ['h'] = 178.57 },
}


