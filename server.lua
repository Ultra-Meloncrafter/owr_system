ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local F1Plate = "1"
local OldPlate = ""

RegisterServerEvent ('owr_systems:addTime')
AddEventHandler 
(
    'owr_systems:addTime', 
    function
    (
        vehPlate, lapTimerClient
    )
    local plate = vehPlate
    local lapTimer = lapTimerClient
    print(lapTimer)
    print(plate)

    MySQL.Async.execute('UPDATE owr_laptime SET time = @timer WHERE carplate = @plate', {['@plate'] = plate, ['@timer'] = lapTimer})
end
)

RegisterServerEvent('owr_systems:removePlate')
AddEventHandler('owr_systems:removePlate', function(plateText)
    local src = source
    local identifier = ESX.GetPlayerFromId(src).identifier
	local plate = plateText
    print(plate)
end)

ESX.RegisterServerCallback('owr_systems:checkPlate', function (src, cb, OldPlate)
    print("F1Plate:" .. tostring(F1Plate))
    OldPlate = tostring(F1Plate)
    print("OldPlate:" .. tostring(OldPlate))
    F1Plate = tonumber(F1Plate) + 1
    print("F1Plate:" .. tostring(F1Plate))
    cb(OldPlate)
end)
