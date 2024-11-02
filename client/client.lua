ESX = exports['es_extended']:getSharedObject()

-- Fahrzeug Liste
local OWRVeh = {"openwheel1","openwheel2","formula","formula2"}

local exitVehicle = true
local plateText = "" 
-- DRS Locales
local atDRSEntry = false
local atDRSExit = false
local DRSEntered = false
-- Pit Locales
local PitEntered = false
local inPitPlace = false
local pitRequested = false
local atPitEntry = false
local atPitExit = false
local atFinishLane = false
-- Safety Locale
local safetyMode = false
-- Blip Locales
local blip1Visible = false
local blip2Visible = false
local blip3Visible = false
local blip4Visible = false
local blip5Visible = false
local blip6Visible = false
local blip7Visible = false
local blip8Visible = false
-- Spawner und Deleter Locales
local inSpawnerPlace = false
local inDeleterPlace = false
-- Timer Locales
local timerInSeconds = 0
local timerInMinutes = 0
local lapTimer = ""
local lapJustFinished = false

--Slow Down to Vehicle Speed 
function SlowDownToLimitSpeed(veh, wantedSpeed)
    local timeout = 4.0 -- limits the slowing down to 4 seconds at most

    while timeout > 0.0 do
        Wait(0)
        
        timeout = timeout - GetFrameTime()
        
        local speed = GetEntitySpeed(veh)
        if wantedSpeed > speed then
            return
        else
            SetControlNormal(0, 72, 1.0)
            SetControlNormal(0, 71, 0.0)
        end
    end
end

--Show Notification
function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

-- BoxZone Create 
local PitEntry = BoxZone:Create(vector3(3759.0107, -6450.9277, 2188.6829), 1.0, 5.5, {
    name="PitEntry",
    heading = 136.0000,
    useZ = true,
    debugPoly = false,
})

local PitExit = BoxZone:Create(vector3(3463.8962, -6745.5469, 2188.1611), 1.0, 13.0, {
    name="PitExit",
    heading = 136.0000,
    useZ = true,
    debugPoly = false,
})

local DRSEntry = BoxZone:Create(vector3(6277.0181, -4694.3535, 2126.4270), 1.0, 13.0, {
    name="DRSEntry",
    heading = 119.3637,
    useZ = true,
    debugPoly = true,
})

local DRSExit = BoxZone:Create(vector3(4648.4902, -5636.9375, 2158.2505), 1.0, 13.0, {
    name="DRSExit",
    heading =  117.9240,
    useZ = true,
    debugPoly = false,
})

local FinishLane = BoxZone:Create(vector3(3705.7615, -6522.9370, 2191.1753), 1.0, 17.0, {
    name="FinishLane",
    heading =  134.60,
    useZ = true,
    debugPoly = true,
})

-- Verschiedene Checks
local function isPlayerInsideArea(area)
    local plyPed = PlayerPedId()
    local coord = GetEntityCoords(plyPed)
    return area:isPointInside(coord)
end

-- Überprüfungen nur bei Bedarf ausführen
function checkIfPitIsEntered()
    return isPlayerInsideArea(PitEntry)
end

function checkIfPitIsLeft()
    return isPlayerInsideArea(PitExit)
end

function checkIfDRSZoneIsEntered()
    return isPlayerInsideArea(DRSEntry)
end

function checkIfDRSZoneIsLeft()
    return isPlayerInsideArea(DRSExit)
end

function checkIfFinishLaneIsCrossed()
    return isPlayerInsideArea(FinishLane)
end

-- Überprüfung, ob ein Boxenstopp angefordert wurde
function checkIfPitStopIsRequested()
    return pitRequested
end


-- Exports Anfang
exports("ifPitEntered", checkIfPitIsEntered)
exports("ifPitLeft", checkIfPitIsLeft)
exports("ifDRSEntered", checkIfDRSZoneIsEntered)
exports("ifDRSLeft", checkIfDRSZoneIsLeft)
exports("ifFinishLaneIsCrossed", checkIfFinishLaneIsCrossed)
exports("IfPitStopIsRequested", checkIfPitStopIsRequested)

-- Exports Ende

-- Pit Stop Menu Anfang
function OpenPitStopMenu()
    local elements = {
        {label = "Tanken", value = 'fuel_vehicle'},
        {label = "Reifen wechseln", value = 'change_tires'},
        {label = "Alles", value = 'everything'},
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pitstop_menu', {
        css = '',
        title = "Boxenstopp",
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        local playerPed = PlayerPedId()
        local playerVeh = GetVehiclePedIsIn(playerPed, false)

        local actions = {
            fuel_vehicle = function()
                local time = math.random(1600, 3000)
                local actuallTime = math.floor((time / 1000) * 100 + 0.5) / 100
                FreezeEntityPosition(playerVeh, true)
                ESX.ShowNotification("Noch ~g~" .. tostring(actuallTime) .. " ~w~Sekunden bis dein Wagen vollgetankt ist")
                exports["esx-sna-fuel-main"]:SetFuel(playerVeh, 100)
                exports['progbars']:StartProg(time, 'Fahrzeug tanken')
                Wait(time)
                FreezeEntityPosition(playerVeh, false)
                ESX.UI.Menu.CloseAll()
            end,

            change_tires = function()
                local time = math.random(1800, 3500)
                local actuallTime = math.floor((time / 1000) * 100 + 0.5) / 100
                FreezeEntityPosition(playerVeh, true)
                ESX.ShowNotification("Noch ~g~" .. tostring(actuallTime) .. " ~w~Sekunden bis deine Reifen gewechselt sind")
                SetVehicleFixed(playerVeh)
                SetVehicleDirtLevel(playerVeh, 0.0)
                exports['progbars']:StartProg(time, 'Reifen wechseln')
                Wait(time)
                FreezeEntityPosition(playerVeh, false)
                ESX.UI.Menu.CloseAll()
            end,

            everything = function()
                local time = math.random(1980, 4980)
                local actuallTime = math.floor((time / 1000) * 100 + 0.5) / 100
                FreezeEntityPosition(playerVeh, true)
                ESX.ShowNotification("Noch ~g~" .. tostring(actuallTime) .. " ~w~Sekunden bis deine Reifen gewechselt sind und dein Fahrzeug betankt ist")
                SetVehicleFixed(playerVeh)
                SetVehicleDirtLevel(playerVeh, 0.0)
                exports["esx-sna-fuel-main"]:SetFuel(playerVeh, 100)
                exports['progbars']:StartProg(5000, 'Fahrzeug tanken und Reifen wechseln')
                Wait(time)
                FreezeEntityPosition(playerVeh, false)
                ESX.UI.Menu.CloseAll()
            end
        }

        local action = actions[data.current.value]
        if action then
            action()
        end

    end, function(data, menu)
        menu.close()
    end)
end

-- Pit Stop Menu Ende

local inVeh = false

AddEventHandler('esx:enteredVehicle', function(vehicle, plate, seat, displayName, netId)
    local playerPed = PlayerPedId() 
    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    local model = GetEntityModel(playerVeh)

    if GetHashKey(OWRVeh[i]) == model then
        inVeh = true
    end

    CreateThread(function()
        while inVeh do
            Wait(0)
            local actions = {}

            if not PitEntered and not DRSEntered and not safetyMode then
                actions.default = function()
                    local speed = 250 / 3.6
                    SetVehicleMaxSpeed(playerVeh, speed)
                end
            end

            if exports["ultra_owr_systems"]:ifDRSEntered() then
                actions.drs_entered = function()
                    ShowNotification("DRS ~g~aktiviert")
                    DRSEntered = true
                    local speed = 300 / 3.6
                    SetVehicleMaxSpeed(playerVeh, speed)
                    SetVehicleEnginePowerMultiplier(playerVeh, 50.0)
                end
            end

            if exports["ultra_owr_systems"]:ifDRSLeft() and DRSEntered then
                actions.drs_left = function()
                    ShowNotification("DRS ~r~deaktiviert")
                    local speed = 250 / 3.6
                    SlowDownToLimitSpeed(playerVeh, speed)
                    SetVehicleMaxSpeed(playerVeh, speed)
                    SetVehicleEnginePowerMultiplier(playerVeh, 1.0)
                    DRSEntered = false
                end
            end

            if exports["ultra_owr_systems"]:ifPitEntered() and not PitEntered and pitRequested then
                actions.pit_entered = function()
                    ShowNotification("Boxengassen Begrenzer ~g~aktiviert")
                    PitEntered = true
                    local speed = 80 / 3.6
                    SlowDownToLimitSpeed(playerVeh, speed)
                    SetVehicleMaxSpeed(playerVeh, speed)
                end
            end

            if exports["ultra_owr_systems"]:ifPitLeft() and PitEntered then
                actions.pit_left = function()
                    ShowNotification("Boxengassen Begrenzer ~r~deaktiviert")
                    inPitPlace = false
                    PitEntered = false
                    pitRequested = false
                    local speed = 250 / 3.6
                    SetVehicleMaxSpeed(playerVeh, speed)
                    RemovePitMarkers()
                end
            end

            if IsControlJustReleased(0, 29) then
                if not safetyMode then
                    actions.safety_mode_on = function()
                        ShowNotification("Safetycar Begrenzer ~g~aktiviert")
                        safetyMode = true
                        local speed = 150 / 3.6
                        SetVehicleMaxSpeed(playerVeh, speed)
                        SlowDownToLimitSpeed(playerVeh, speed)
                    end
                else
                    actions.safety_mode_off = function()
                        ShowNotification("Safetycar Begrenzer ~r~deaktiviert")
                        local speed = 250 / 3.6
                        SetVehicleMaxSpeed(playerVeh, speed)
                        safetyMode = false
                    end
                end
            end

            if IsControlJustReleased(0, 44) then
                if not pitRequested then
                    actions.pit_request = function()
                        pitRequested = true
                        ESX.ShowNotification("Du hast einen Boxenstopp angefragt")
                    end
                else
                    actions.pit_request_active = function()
                        ESX.ShowNotification("⚠ Du hast noch einen offenen Boxenstopp")
                    end
                end
            end

            for _, action in pairs(actions) do
                action()
            end
        end
    end)
end)


--Pit Marker entfernen
function RemovePitMarkers()
    for i = 1, 8 do
        RemoveBlip(_G["blip" .. i])
        _G["blip" .. i .. "Visible"] = false
    end
end


--Pit Marker erstellen
CreateThread(function()
	while true do
		Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
        if IsPedInAnyVehicle(playerPed, false) then
			local playerVeh = GetVehiclePedIsIn(playerPed, false)
            local model = GetEntityModel(playerVeh)
            for i = 1, #OWRVeh do
                if GetHashKey(OWRVeh[i]) == model and PitEntered then
                    if PitEntered then
                        DrawMarker(1, 3482.8706, -6721.2778, 2187.8362, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 1.0, 0, 255, 0, 100, false, true, 2, true, nil, nil, false)
                        if not blip1Visible then
                            blip1 = AddBlipForCoord(3482.8706, -6721.2778, 2187.8362)
                            SetBlipSprite(blip1, 267)
                            SetBlipAsShortRange(blip1, true)
                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString("Box Nr.1")
                            EndTextCommandSetBlipName(blip1)
                            blip1Visible = true
                        end
                        DrawMarker(1, 3493.6082, -6710.8833, 2187.9531, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 1.0, 0, 255, 0, 100, false, true, 2, true, nil, nil, false)
                        if not blip2Visible then
                            blip2 = AddBlipForCoord(3493.6082, -6710.8833, 2187.9531)
                            SetBlipSprite(blip2, 267)
                            SetBlipAsShortRange(blip2, true)
                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString("Box Nr.2")
                            EndTextCommandSetBlipName(blip2)
                            blip2Visible = true
                        end
                        DrawMarker(1, 3513.9102, -6689.7056, 2188.2068, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 1.0, 0, 255, 0, 100, false, true, 2, true, nil, nil, false)
                        if not blip3Visible then
                            blip3 = AddBlipForCoord(3513.9102, -6689.7056, 2188.2068)
                            SetBlipSprite(blip3, 267)
                            SetBlipAsShortRange(blip3, true)
                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString("Box Nr.3")
                            EndTextCommandSetBlipName(blip3)
                            blip3Visible = true
                        end
                        DrawMarker(1, 3550.4514, -6652.8560, 2188.7454, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 1.0, 0, 255, 0, 100, false, true, 2, true, nil, nil, false)
                        if not blip4Visible then
                            blip4 = AddBlipForCoord(3550.4514, -6652.8560, 2188.7454)
                            SetBlipSprite(blip4, 267)
                            SetBlipAsShortRange(blip4, true)
                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString("Box Nr.4")
                            EndTextCommandSetBlipName(blip4)
                            blip4Visible = true
                        end
                        DrawMarker(1, 3565.5452, -6637.2407, 2188.9316, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 1.0, 0, 255, 0, 100, false, true, 2, true, nil, nil, false)
                        if not blip5Visible then
                            blip5 = AddBlipForCoord(3565.5452, -6637.2407, 2188.9316)
                            SetBlipSprite(blip5, 267)
                            SetBlipAsShortRange(blip5, true)
                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString("Box Nr.5")
                            EndTextCommandSetBlipName(blip5)
                            blip5Visible = true
                        end
                        DrawMarker(1, 3591.0752, -6611.1997, 2189.1545, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 1.0, 0, 255, 0, 100, false, true, 2, true, nil, nil, false)
                        if not blip6Visible then
                            blip6 = AddBlipForCoord(3591.0752, -6611.1997, 2189.1545)
                            SetBlipSprite(blip6, 267)
                            SetBlipAsShortRange(blip6, true)
                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString("Box Nr.6")
                            EndTextCommandSetBlipName(blip6)
                            blip6Visible = true
                        end
                        DrawMarker(1, 3617.6296, -6584.3223, 2189.4675, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 1.0, 0, 255, 0, 100, false, true, 2, true, nil, nil, false)
                        if not blip7Visible then
                            blip7 = AddBlipForCoord(3617.6296, -6584.3223, 2189.4675)
                            SetBlipSprite(blip7, 267)
                            SetBlipAsShortRange(blip7, true)
                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString("Box Nr.7")
                            EndTextCommandSetBlipName(blip7)
                            blip7Visible = true
                        end
                        DrawMarker(1, 3627.5750, -6575.1270, 2189.5598, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 1.0, 0, 255, 0, 100, false, true, 2, true, nil, nil, false)
                        if not blip8Visible then
                            blip8 = AddBlipForCoord(3627.5750, -6575.1270, 2189.5598)
                            SetBlipSprite(blip8, 267)
                            SetBlipAsShortRange(blip8, true)
                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString("Box Nr.8")
                            EndTextCommandSetBlipName(blip8)
                            blip8Visible = true
                        end
                    end
                    if GetDistanceBetweenCoords(coords, 3482.8706, -6721.2778, 2187.8362, true) < 2.0 or GetDistanceBetweenCoords(coords, 3493.6082, -6710.8833, 2187.9531, true) < 2.0 or GetDistanceBetweenCoords(coords, 3513.9102, -6689.7056, 2188.2068, true) < 2.0 or GetDistanceBetweenCoords(coords, 3550.4514, -6652.8560, 2188.7454, true) < 2.0 or GetDistanceBetweenCoords(coords, 3565.5452, -6637.2407, 2188.9316, true) < 2.0 or GetDistanceBetweenCoords(coords, 3591.0752, -6611.1997, 2189.1545, true) < 2.0 or GetDistanceBetweenCoords(coords, 3617.6296, -6584.3223, 2189.4675, true) < 2.0 or GetDistanceBetweenCoords(coords, 3627.5750, -6575.1270, 2189.5598, true) < 2.0 then
                        ESX.ShowHelpNotification('Drücke ~INPUT_CONTEXT~ um einen Boxenstopp durchzuführen!')
                        inPitPlace = true
                    else
                        ESX.UI.Menu.CloseAll()
                        inPitPlace = false
                    end
                    if IsControlJustReleased(0, 51) and inPitPlace then
                        OpenPitStopMenu()
                    end
                end
            end
        end
	end
end)

CreateThread(function()
    local startTime = GetGameTimer()  -- Start the timer at the beginning
    local timerInSeconds = 0
    local timerInMinutes = 0
    local playerPed, playerVeh, model
    local resetControl = 38
    while true do
        Wait(0)
        playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            playerVeh = GetVehiclePedIsIn(playerPed, false)
            model = GetEntityModel(playerVeh)
            for i = 1, #OWRVeh do
                if GetHashKey(OWRVeh[i]) == model and not exitVehicle then
                    if exports["ultra_owr_systems"]:ifFinishLaneIsCrossed() or exports["ultra_owr_systems"]:ifPitLeft() and not lapJustFinished then
                        lapJustFinished = true
                        plateText = GetVehicleNumberPlateText(playerVeh)
                        TriggerServerEvent('owr_systems:addTime', plateText, lapTimer)
                        ESX.ShowNotification("Letzte Runden Zeit: " .. tostring(lapTimer))
                        startTime = GetGameTimer()
                        timerInSeconds = 0
                        timerInMinutes = 0
                        elapsedTime = 0
                        Citizen.Wait(1000)
                        lapJustFinished = false
                    end
                    local elapsedTime = GetGameTimer() - startTime
                    timerInSeconds = math.floor(elapsedTime / 1000 % 60)
                    timerInMinutes = math.floor(elapsedTime / 1000 / 60)
                    lapTimer = string.format("%d.%02d", timerInMinutes, timerInSeconds)
                end
            end
        else
            startTime = GetGameTimer()
            timerInSeconds = 0
            timerInMinutes = 0
            elapsedTime = 0
        end
    end
end)


CreateThread(function()
	while true do
		Wait(0)
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local playerVeh = GetVehiclePedIsIn(playerPed, false)
            local model = GetEntityModel(playerVeh)
            for i = 1, #OWRVeh do
                if GetHashKey(OWRVeh[i]) == model then
                    SetTextColour(255, 255, 255, 255)

                    SetTextFont(1)
                    SetTextScale(1.0, 1.0)
                    SetTextWrap(0.0, 1.0)
                    SetTextCentre(false)
                    SetTextDropshadow(2, 2, 0, 0, 0)
                    SetTextEdge(1, 0, 0, 0, 205)
                    SetTextEntry("STRING")
                    AddTextComponentString(lapTimer)
                    DrawText(0.02, 0.5)
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
			local playerVeh = GetVehiclePedIsIn(playerPed, false)
            local model = GetEntityModel(playerVeh)
            for i = 1, #OWRVeh do
                if GetHashKey(OWRVeh[i]) == model or not IsPedInAnyVehicle(playerPed, false) then
                    if IsControlJustPressed(0, 75) then
                        plateText = GetVehicleNumberPlateText(playerVeh)
                        TriggerServerEvent('owr_systems:addTime', plateText, lapTimer)
                        exitVehicle = true
                        timerInSeconds = 0
                        timerInMinutes = 0
                        lapTimer = ""
                    end
                end
            end
        end
    end
end)
--Lap Timer Ende

-- Fahrzeug Spawner
CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local Coords = vector3(3647.4951, -6547.1377, 2189.7495)

        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'public_transport' then
            DrawMarker(1, Coords.x, Coords.y, Coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, true, nil, nil, false)

            if #(coords - Coords) < 1.5 then
                ESX.ShowHelpNotification('Drück ~INPUT_CONTEXT~ um ein Wagen auszuparken!')
                inSpawnerPlace = true
            else
                inSpawnerPlace = false
            end

            if IsControlJustReleased(0, 51) and inSpawnerPlace then
                OpenVehicleSpawnerMenu()
            end
        end
    end
end)


-- Fahrzeug Spawner Menü
function OpenVehicleSpawnerMenu()
	local elements = {
		{label = 'BR8', value = 'spawn_openwheel1'},
	}

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'f1_spawner', {
		css =  '',
		title    = 'OWR Garage',
		align    = 'top-left',
		elements = elements
	}, function(data, menu)

		if data.current.value == 'spawn_openwheel1' then
            ESX.TriggerServerCallback('owr_systems:carCount', function(carCount)
                if tonumber(carCount) < 8 then
                    ESX.TriggerServerCallback('owr_systems:checkPlate', function (F1Plate)
                        plateText = F1Plate -- is equal to plate
                        local ModelHash = GetHashKey("openwheel1")
                        WaitModelLoad(ModelHash)
                        CurrentVehicle = CreateVehicle(ModelHash, 3651.6365, -6549.2417, 2190.7163, 140.2945, true, true)
                        SetVehicleNumberPlateText(CurrentVehicle, plateText)
                        TaskWarpPedIntoVehicle(PlayerPedId(), CurrentVehicle, -1)
                    end)
                else 
                    ESX.ShowNotification("Es sind genug Fahrzeuge unterwegs")
                end
            end)
            menu.close()
		end

	end, function(data, menu)
		menu.close()

		CurrentAction     = 'open_f1_spawner'
		CurrentActionMsg  = 'open_f1_spawner'
	end)
end

function WaitModelLoad(name)
	RequestModel(name)
	while not HasModelLoaded(name) do
		Wait(0)
	end
end

CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local cord = vector3(3660.1135, -6540.6270, 2189.8477)
        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        local model = GetEntityModel(playerVeh)

        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'public_transport' and IsPedInAnyVehicle(playerPed, false) then
            DrawMarker(1, cord.x, cord.y, cord.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 1.0, 0, 255, 0, 100, false, true, 2, true, nil, nil, false)

            if #(coords - cord) < 1.5 then
                ESX.ShowHelpNotification('Drücke ~INPUT_CONTEXT~ um den Wagen einzuparken!')
                inDeleterPlace = true
            else
                inDeleterPlace = false
            end

            if IsControlJustReleased(0, 51) and inDeleterPlace then
                if GetHashKey(OWRVeh[i]) == model then
                    ReturnVehicle()
                else
                    ESX.ShowNotification('Du kannst das Fahrzeug hier nicht einparken!')
                end
            end
        end
    end
end)


function ReturnVehicle()
	CurrentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    plateText = GetVehicleNumberPlateText(CurrentVehicle)
    --TriggerServerEvent('owr_systems:addTime', lapTimer)
    TriggerServerEvent('owr_systems:removePlate', plateText)
	SetVehicleAsNoLongerNeeded(CurrentVehicle)
	DeleteEntity(CurrentVehicle)
	ESX.ShowNotification("Fahrzeug eingeparkt")
    exitVehicle = true
    timerInSeconds = 0
    timerInMinutes = 0
    lapTimer = ""
end

RegisterCommand("owr-debug", function()
    if laptime < 0.5 then 
        print("YES")
    else
        print("NO")
    end
end)
