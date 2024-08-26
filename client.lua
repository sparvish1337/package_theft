local packageModel = `prop_cs_package_01`
local angryPedModel = `a_m_m_hillbilly_02`

local function spawnAngryPed(playerPos)
    RequestModel(angryPedModel)
    while not HasModelLoaded(angryPedModel) do
        Citizen.Wait(100)
    end

    local spawnPos = playerPos + vector3(math.random(-40, 40), math.random(-40, 40), 0)
    local groundZ = GetGroundZFor_3dCoord(spawnPos.x, spawnPos.y, spawnPos.z, false)
    local ped = CreatePed(4, angryPedModel, spawnPos.x, spawnPos.y, groundZ, 0.0, true, true)

    local playerPed = PlayerPedId()

    SetPedRelationshipGroupHash(ped, GetHashKey("HATES_PLAYER"))

    SetPedCombatAttributes(ped, 46, true)
    SetPedCombatAbility(ped, 2)
    SetPedCombatMovement(ped, 3)
    SetPedCombatRange(ped, 2)

    GiveWeaponToPed(ped, GetHashKey("WEAPON_BAT"), 250, false, true)

    TaskCombatPed(ped, playerPed, 0, 16)

    SetEntityAsMissionEntity(ped, true, true)

    SetModelAsNoLongerNeeded(angryPedModel)
end

local function triggerCarAlarm(vehicle)
    SetVehicleAlarm(vehicle, true)
    StartVehicleAlarm(vehicle)
end

local function smashWindow(vehicle)
    local playerPed = PlayerPedId()

    local rearRightDoorBone = GetEntityBoneIndexByName(vehicle, "door_pside_r")
    local rearLeftDoorBone = GetEntityBoneIndexByName(vehicle, "door_dside_r")

    local rightDoorPos = GetWorldPositionOfEntityBone(vehicle, rearRightDoorBone)
    local leftDoorPos = GetWorldPositionOfEntityBone(vehicle, rearLeftDoorBone)

    local playerPos = GetEntityCoords(playerPed)

    local distToRightDoor = #(playerPos - rightDoorPos)
    local distToLeftDoor = #(playerPos - leftDoorPos)

    local targetDoorPos
    local doorIndex

    if distToLeftDoor < distToRightDoor then
        targetDoorPos = leftDoorPos
        doorIndex = 2
    else
        targetDoorPos = rightDoorPos
        doorIndex = 3
    end

    SetVehicleDoorsLocked(vehicle, 7)
    TaskEnterVehicle(playerPed, vehicle, 2000, doorIndex, 1.0, 1, 0)
    Citizen.Wait(2000)
    ClearPedTasksImmediately(playerPed)

    triggerCarAlarm(vehicle)

    local pos = GetEntityCoords(vehicle)
    local boneIndex = GetEntityBoneIndexByName(vehicle, "seat_dside_r")
    --local package = CreateObject(packageModel, pos.x, pos.y, pos.z, true, true, true)
    --AttachEntityToEntity(package, vehicle, boneIndex, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, false, false, true, false, 2, true)

    if math.random(1, 2) == 1 or 2 then
        local vehicleCoords = GetEntityCoords(vehicle)
        exports['bub-mdt']:CustomAlert({
            coords = vec3(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z),
            info = {},
            code = '10-90',
            offense = 'Vehicle Break-in',
            blip = 465,
        })
    end


    if math.random(1, 2) == 1 or 2 then
        spawnAngryPed(playerPos)
    end

    TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
    Citizen.Wait(5000)
    ClearPedTasksImmediately(playerPed)
    --DeleteEntity(package)
    TriggerServerEvent('package_theft:givePackage')
end

local function playBreakInMinigame(vehicle)
    local success = false
    success = lib.skillCheck({'easy', 'easy', 'easy'}, {'w', 'a', 's', 'd'})

    if success then
        smashWindow(vehicle)
    else
        TriggerEvent('QBCore:Notify', "Failed to break in!", 'error')
    end
end

RegisterNetEvent('package_theft:playSmashAnimation')
AddEventHandler('package_theft:playSmashAnimation', function(vehicleNetId)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    playBreakInMinigame(vehicle)
end)

exports.ox_target:addGlobalVehicle({
    {
        name = 'smash_window',
        icon = 'fa-solid fa-hand-fist',
        label = 'Sno paket',
        bones = { 'door_dside_r', 'door_pside_r' },
        onSelect = function(data)
            local vehicle = data.entity
            local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
            TriggerServerEvent('package_theft:smashWindow', vehicleNetId)
        end
    }
}, {
    distance = 1.5
})
