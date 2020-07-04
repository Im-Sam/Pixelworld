Config = {}

Config.Marker = {
    ['blipScale'] = 1.0,
    ['blipSprite'] = 227,
    ['blipColor'] = 15,
    ['markerSize'] = {['x'] = 1.0, ['y'] = 1.0, ['z'] = 1.0 },
    ['markerColor'] = { ['r'] = 180, ['g'] = 233, ['b'] = 123 },
    ['name'] = "Car Dealers"
}

Config.Locations = {
    {['x'] = -33.76, ['y'] = -1103.28, ['z'] = 26.42, ['type'] = "standard", ['spawner'] = { ['x'] = -30.36, ['y'] = -1089.5, ['z'] = 26.42, ['h'] = 335.17 }, ['public'] = true, ['blip'] = true},
    {['x'] = -31.44, ['y'] = -1114.02, ['z'] = 26.42, ['type'] = "bossmenu", ['public'] = false },
    {['x'] = -56.34, ['y'] = -1099.22, ['z'] = 26.42, ['type'] = "dealer", ['public'] = false },
    {['x'] = -31.42, ['y'] = -1107.04, ['z'] = 26.42, ['type'] = "duty", ['public'] = false },
    {['x'] = -45.59, ['y'] = -1082.67, ['z'] = 26.72, ['type'] = "testdrive", ['public'] = false }
}

Config.Showroom = {
    Cars = {
        { ['x'] = -45.73, ['y'] = -1096.46, ['z'] = 26.01, ['h'] = 186.99 },
        { ['x'] = -42.68, ['y'] = -1097.52, ['z'] = 26.01, ['h'] = 186.55 },
        { ['x'] = -39.75, ['y'] = -1098.58, ['z'] = 26.01, ['h'] = 184.66 }
    },
    Bikes = {
        { ['x'] = -44.85, ['y'] = -1102.75, ['z'] = 25.76, ['h'] = 187.89 },
        { ['x'] = -41.64, ['y'] = -1103.49, ['z'] = 26.31, ['h'] = 188.66 },
        { ['x'] = -38.98, ['y'] = -1104.83, ['z'] = 25.76, ['h'] = 190.14 },
    }
}

Config.AvailableColors = {
    { label = 'Black', index = {0, 0, 0}, buttonColor = 'dark' },
    { label = 'White', index = {255, 255, 255}, buttonColor = 'light' },
    { label = 'Silver', index = {192, 192, 192}, buttonColor = 'white-50' },
    { label = 'Red', index = {255, 0, 0}, buttonColor = 'danger' },
    { label = 'Green', index = {0, 255, 0}, buttonColor = 'success' },
    { label = 'Blue', index = {0, 0, 255}, buttonColor = 'primary' },
    { label = 'Yellow', index = {255, 255, 0}, buttonColor = 'warning' }
}

Config.DisplayVehicle = { ['x'] = -49.33, ['y'] = -1096.18, ['z'] = 26.29, ['h'] = 158.15 }

Config.VehicleSold = {
                    { ['x'] = -27.61, ['y'] = -1081.82, ['z'] = 26.13, ['h'] = 70.54 },
                    { ['x'] = -20.21, ['y'] = -1084.53, ['z'] = 26.22, ['h'] = 70.54 },
                    { ['x'] = -34.32, ['y'] = -1079.49, ['z'] = 26.25, ['h'] = 70.54 },
                    { ['x'] = -41.55, ['y'] = -1076.95, ['z'] = 26.25, ['h'] = 70.54 }
}

Config.VehicleSoldHeading = 70.54
Config.DelieverTestDrive = { ['x'] = -45.59, ['y'] = -1082.67, ['z'] = 26.72, ['h'] = 189.76 }

Config.MySQL = {}
Config.MySQL.DealershipBuyMargin = 70 -- | Percentage of the base price of a car that the dealership will spend
Config.MySQL.FinancingMargin = 15 -- | Added cost for choosing Financing Method (BasePrice * 1.15 default)
Config.MySQL.Margin = 10 -- | Set price margin relative to the base price of a car (default: BasePrice * 0.90 to BasePrice * 1.10 <0.10 below and 0.10 above>)

Config.MySQL.DealerMargin = 10 -- | Percentage of the profit made that'll go to the dealer
Config.MySQL.FinanceWeeks = {10, 20, 30} -- | Default period for financing
Config.MySQL.Downpayment = 20 -- | Downpayment calculated from BasePrice * (1+FinancingMargin) -- First payment
Config.MySQL.TestDriveTimer = 10