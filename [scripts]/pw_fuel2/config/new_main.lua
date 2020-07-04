Config = {}

Config.DecorsRequired = { 
	['pw_vehicles_fuelLevel'] = 1,
	['pw_vehicles_fuelType'] = 3,
}

Config.DecorValues = {
	['gas'] = 2,
	['electric'] = 3,
	['nofuel'] = 1
}

Config.Classes = {
	[0] = 1.0, -- Compacts
	[1] = 1.0, -- Sedans
	[2] = 1.0, -- SUVs
	[3] = 1.0, -- Coupes
	[4] = 1.0, -- Muscle
	[5] = 1.0, -- Sports Classics
	[6] = 1.0, -- Sports
	[7] = 1.0, -- Super
	[8] = 1.0, -- Motorcycles
	[9] = 1.0, -- Off-road
	[10] = 1.0, -- Industrial
	[11] = 1.0, -- Utility
	[12] = 1.0, -- Vans
	[13] = 0.0, -- Cycles
	[14] = 1.0, -- Boats
	[15] = 1.0, -- Helicopters
	[16] = 1.0, -- Planes
	[17] = 1.0, -- Service 
	[18] = 1.0, -- Emergency
	[19] = 1.0, -- Military
	[20] = 1.0, -- Commercial
	[21] = 1.0, -- Trains
}

-- The left part is at percentage RPM, and the right is how much fuel (divided by 10) you want to remove from the tank every second
Config.FuelUsage = {
	[1.0] = 1.2,
	[0.9] = 1.1,
	[0.8] = 1.0,
	[0.7] = 0.9,
	[0.6] = 0.8,
	[0.5] = 0.7,
	[0.4] = 0.5,
	[0.3] = 0.4,
	[0.2] = 0.3,
	[0.1] = 0.2,
	[0.0] = 0.1,
}

Config.PumpModels = {
	[-2007231801] = true,
	[1339433404] = true,
	[1694452750] = true,
	[1933174915] = true,
	[-462817101] = true,
	[-469694731] = true,
	[-164877493] = true
}

Config.DisableKeys = {0, 22, 23, 24, 29, 30, 31, 37, 44, 56, 82, 140, 166, 167, 168, 170, 288, 289, 311, 323}

Config.RefuelPerPercentCost = 2
Config.JerryCanCost = 200

Config.Strings = {
	ExitVehicle = "Exit the vehicle to refuel",
	EToRefuel = "Press ~g~E ~w~to refuel vehicle",
	JerryCanEmpty = "Jerry can is empty",
	FullTank = "Tank is full",
	PurchaseJerryCan = "Press ~g~E ~w~to purchase a jerry can for ~g~$" .. Config.JerryCanCost,
	CancelFuelingPump = "Press ~g~E ~w~to cancel the fueling",
	CancelFuelingJerryCan = "Press ~g~E ~w~to cancel the fueling",
	NotEnoughCash = "Not enough cash",
	RefillJerryCan = "Press ~g~E ~w~ to refill the jerry can for ",
	NotEnoughCashJerryCan = "Not enough cash to refill jerry can",
	JerryCanFull = "Jerry can is full",
	TotalCost = "Cost",
}

Config.GasStations = {
	vector3(49.4187, 2778.793, 58.043),
	vector3(263.894, 2606.463, 44.983),
	vector3(1039.958, 2671.134, 39.550),
	vector3(1207.260, 2660.175, 37.899),
	vector3(2539.685, 2594.192, 37.944),
	vector3(2679.858, 3263.946, 55.240),
	vector3(2005.055, 3773.887, 32.403),
	vector3(1687.156, 4929.392, 42.078),
	vector3(1701.314, 6416.028, 32.763),
	vector3(179.857, 6602.839, 31.868),
	vector3(-94.4619, 6419.594, 31.489),
	vector3(-2554.996, 2334.40, 33.078),
	vector3(-1800.375, 803.661, 138.651),
	vector3(-1441.14, -271.99, 46.21),
	vector3(-2096.243, -320.286, 13.168),
	vector3(-719.67, -932.71, 19.02),
	vector3(-526.019, -1211.003, 18.184),
	vector3(-70.2148, -1761.792, 29.534),
	vector3(265.648, -1261.309, 29.292),
	vector3(819.653, -1028.846, 26.403),
	vector3(1208.951, -1402.567,35.224),
	vector3(1181.381, -330.847, 69.316),
	vector3(620.843, 269.100, 103.089),
	vector3(2581.321, 362.039, 108.468),
	vector3(176.631, -1562.025, 29.263),
	vector3(176.631, -1562.025, 29.263),
	vector3(-319.292, -1471.715, 30.549),
	vector3(1784.324, 3330.55, 41.253)
}

Config.VehicleTypes = {
	['electric'] = { "cyclone", "khamelion", "models", "neon", "raiden", "surge", "teslax", "tmodel", "twizy", "voltic" },
	['gas'] = { "t20", "model2", "model3", "v242", "124spider", "2011mazda2", "2f2fgts", "2f2fmle7", "718boxster", "ardent", "asterope", "bfinjection", "bifta", "blista", "blista2", "brioso", "brzbn", "camper", "cheburek", "cobra", "comet2", "comet3", "comet5", "cu2", "deluxo", "dilettante", "dune", "Dynasty", "eclipse", "elegy", "evo10", "fcr", "ff4wrx", "flashgt", "fnf4r34", "fnflan", "fq2", "fuluxt2", "futo", "golfgti", "gt86", "habanero", "hondacivictr", "ingot", "intruder", "jetta", "kalahari", "kuruma", "michelli", "na6", "omnis", "oracle", "panamera17turbo", "panto", "penumbra", "pigalle", "prairie", "premier", "primo", "punto", "rabbit", "raptor", "rav4", "regina", "retinue", "rhapsody", "rx3", "rx3b", "s15rb", "savestra", "sentinel", "sentinel2", "sentinel3", "Sti", "stratum", "Subaruwagon2002", "subwrx", "sultan", "sultanrs", "surfer", "Surfer2", "tailgater", "tropos", "turismo2", "v242", "vindicator", "warrener", "xa21", "yPG205t16A", "z190", "16CHALLENGER", "18Velar", "2008f150", "2f2fmk4", "3000gt", "3000gta", "370z", "69charger", "80silverado", "a8audi", "alpha", "baller", "baller2", "baller3", "bestiagts", "bgnx", "bison", "BjXL", "blade", "brawler", "brutus3", "buffalo", "buffalo2", "buffalo3", "bullet", "burrito3", "camry55", "cara", "casco", "cats", "cavalcade", "cavalcade2", "cherokee1", "cnty", "cog55", "cogcabrio", "cooperworks", "coquette2", "drafter", "dubsta", "dubsta2", "dubsta3", "elegy2", "Emperor2", "exemplar", "f620", "f82", "f824slw", "f82duke", "f82hs", "f82lw", "f82st", "felon", "felon2", "fiero85", "fnfmk4", "fordh", "freecrawler", "furoregt", "FX4", "gauntlet3", "gburrito", "gburrito2", "gresley", "impalass", "issi3", "issi4", "issi5", "issi6", "jeep2012", "jeepreneg", "jester3", "journey", "jp12", "kiagt", "landseries3", "landstalker", "lc500", "lex570", "lrii109a", "lrii109a2", "lynx", "m5e34", "m8gte", "mamba", "massacro", "massacro2", "mb300sl", "mesa", "mesa3", "minivan", "minivan2", "monroe", "moonbeam", "moonbeam2", "mustang19", "nebula", "nightshade", "nismo20", "Novak", "ody18", "oracle2", "paradise", "paragon", "paragon2", "pariah", "passatr", "pgto", "phoenix", "picador", "primo2", "qashqai16", "qx56", "radi", "rapidgt", "rapidgt2", "rapidgt3", "RC350", "rdmstr96", "rebel", "rebel2", "revolter", "rocoto", "rs318", "rs4avant", "rs5", "ruiner2", "rumpo", "rumpo3", "ruston", "rx7tunable", "s5", "s60pole", "s90", "sc1", "schafter2", "schafter3", "schafter4", "schlagen", "schwarzer", "scout", "seminole", "serrano", "seven70", "sheava", "slamvan", "slamvan2", "slamvan3", "specter", "specter2", "speedo", "sq72016", "srt8", "srt8b", "streiter", "stromberg", "subn", "supra2", "surano", "tornado ", "tornado2", "tornado3", "tornado5", "toros", "trophytruck", "trophytruck2", "v250", "vacca", "vamos", "virgo2", "virgo3", "volvo850r", "voodoo", "voodoo2", "wagoneer", "washington", "xls", "youga", "youga2", "z4bmw", "zion", "zion2", "zion3", "19gt500", "19ram", "2017chiron", "2018transam", "2019chiron", "720s", "adder", "amggt", "baller4", "banshee", "banshee2", "bbentayga", "ben17", "bobcatxl", "bodhi2", "broncoc", "btype2", "buccaneer", "buccaneer2", "C7", "caracara2", "carbonizzare", "catalina", "cayenne", "cd69", "chall70", "cheetah", "cheetah2", "chino", "chino2", "cla45sb", "cla45sb2", "clique", "cls500w219", "cm69", "cn69", "cognoscenti", "contender", "coquette", "coquette3", "cougar70", "COUNTACH", "crawler", "ctsv16", "def90", "demonhawk", "deviant", "dloader", "dloader2", "dloader3", "dloader4", "dloader5", "dodgesrt2", "domc", "dominator", "dominator2", "dominator3", "dukes", "e63amg", "eleanor", "ellie", "entity2", "f15078", "f288gto", "f430s", "faction", "faction2", "faction3", "fct", "g65", "gauntlet", "gauntlet2", "gauntlet4", "gmt900escalade", "granger", "gsxb", "gt17", "gt500", "gto06", "guardian", "gx460", "hotknife", "impaler", "impaler3", "impaler4", "imperator", "imperator2", "imperator3", "infernus", "infernus2 ", "jester", "jester2", "kamacho", "kitt", "lamboMurcielago", "limoxts", "locust", "lp670", "Lurcher", "lwlp670", "manana", "marshall", "monster", "mudsl", "neo", "ninef", "ninef2", "nissantitan17", "onebeast", "osiris", "ottov53", "p7", "peyote", "peyote2", "r820", "r8ppi", "rancherxl", "rancherxlextreme", "ratloader", "ratloader2", "reaper", "riata", "rmaster", "romero", "rrocket", "rt70", "ruiner", "sabregt", "sabregt2", "Sadler", "sandking", "sandking2", "sandkinghd", "sandkinghdxl", "sixtyone41", "spyker", "stalion", "stalion2", "stanier", "stinger", "stingergt", "stretch", "superd", "t20", "tampa", "tampa2", "tempesta", "thrax", "torero", "trailcat", "trhawk", "tulip", "turismor", "tyrant", "tyrus", "vagner", "verlierer2", "vigero", "virgo", "viseris", "visione", "vulcan", "windsor", "windsor2", "x5e53", "yosemite", "z2879", "zentorno", "zil130", "zl12017", "zorrusso", "18performante", "99viper", "autarch", "deveste", "gp1", "gtr2020", "italigtb", "italigtb2", "italigto", "krieger", "le7b", "lp700r", "lp770", "moss", "nero2", "p1", "pfister811", "prototipo", "s80", "sian", "sian2", "taipan", "tezeract", "84rx7k", "fnfrx7", "911r", "AKUMA", "avarus", "bati", "bati2", "bf400", "blazer", "blazer4", "blazer5", "carbonrs", "cb500x", "chimera", "cliffhanger", "daemon", "daemon2", "defiler", "diablous", "double", "emperor", "enduro", "executioner", "fagaloa", "faggio", "faggio2", "faggio3", "fair500", "feltzer2", "feltzer3", "fmj", "fugitive", "fusilade", "gargoyle", "glendale", "goldwing", "hakuchou", "hakuchou2", "hcbr17", "hdbobber", "hellion", "hermes", "hexer", "huntley", "hustler", "innovation", "issi2", "issi7", "jackal", "kaneda", "lectro", "manchez", "nemesis", "nightblade", "oppressor", "patriot", "patriot2", "pcj", "ruffian", "sanchez", "sanchez2", "sanctus", "shotaro", "sovereign", "thrust", "vader", "vortex", "wolfsbane", "zombiea", "zombieb", "amazon", "asea", "beetle74", "btype", "btype3", "COOPERS", "gb200", "l37", "miata3", "Skyline", "stafford", "ztype", "bagger", "voltic2" },
	['nofuel'] = { "bycycle1", "bycycle2", "bycycle3", "bmx", "cruiser", "fixter", "scorcher", "tribike3" }
}