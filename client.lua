local RSGCore = exports['rsg-core']:GetCoreObject()

local prisonWagon = nil
local wagonModel = GetHashKey("WAGONPRISON01X")

-- ==== SPAWN-BEFEHL ====
RegisterCommand("spawnprison", function()
    RequestModel(wagonModel)
    while not HasModelLoaded(wagonModel) do Wait(100) end

    local player = PlayerPedId()
    local coords = GetEntityCoords(player)

    -- Kutsche spawnen und an den Koordinaten platzieren
    prisonWagon = CreateVehicle(wagonModel, coords.x + 2.0, coords.y, coords.z, 0.0, true, true)
    
    -- Türen beim Spawn für alle Spieler verschließen
    SetVehicleDoorsLocked(prisonWagon, 2)  -- Verriegelt das Fahrzeug
    for door = 0, 5 do  -- Alle Türen verschließen
        Citizen.InvokeNative(0x6A3C24B91FD0EA09, prisonWagon, door, false)  -- Schließt die Tür
        print("✅ Tür-ID " .. door .. " geschlossen.")
    end

    local netId = NetworkGetNetworkIdFromEntity(prisonWagon)
    if netId and netId ~= 0 then
        -- Sende die NetID des Wagens an den Server
        TriggerServerEvent("prisonwagon:setWagonNetId", netId)
        -- Synchronisiere die Türzustände für alle Spieler
        TriggerServerEvent("prisonwagon:closeAndLockDoors", netId)
    else
        print("^1Fehler: Keine gültige NetID!^7")
        return
    end

    -- === Gefangenen-NPC ===
    local prisonerModel = GetHashKey("a_m_m_fivefingerfilletplayers_01")
    RequestModel(prisonerModel)
    while not HasModelLoaded(prisonerModel) do Wait(100) end

    local prisoner = CreatePed(prisonerModel, coords.x + 1.0, coords.y + 1.0, coords.z, 0.0, true, false, false, false)
    TaskWarpPedIntoVehicle(prisoner, prisonWagon, 3)
end)

-- ==== /wagontuer ====
RegisterCommand("wagontuer", function()
    if prisonWagon and DoesEntityExist(prisonWagon) then
        local netId = NetworkGetNetworkIdFromEntity(prisonWagon)
        TriggerServerEvent("prisonwagon:openDoors", netId)

        -- Alle Türen öffnen
        for door = 0, 5 do  -- Teste 6 Türen (ID 0 bis 5)
            SetVehicleDoorOpen(prisonWagon, door, false, false)
            print("✅ Tür-ID " .. door .. " wurde geöffnet.")
            TriggerEvent("chat:addMessage", {
                color = {0, 255, 0},
                args = {"System", "Tür-ID " .. door .. " wurde geöffnet!"}
            })
            Wait(500)
        end
    end
end)

-- ==== /wagontuerclose ====
RegisterCommand("wagontuerclose", function()
    if prisonWagon and DoesEntityExist(prisonWagon) then
        local netId = NetworkGetNetworkIdFromEntity(prisonWagon)
        -- Sende das Event zum Schließen und Verriegeln der Türen an den Server
        TriggerServerEvent("prisonwagon:closeAndLockDoors", netId)

        -- Alle Türen schließen und verriegeln
        for door = 0, 5 do  -- Teste 6 Türen (ID 0 bis 5)
            Citizen.InvokeNative(0x6A3C24B91FD0EA09, prisonWagon, door, false)  -- Schließt die Tür
            print("✅ Tür-ID " .. door .. " wurde geschlossen.")
            TriggerEvent("chat:addMessage", {
                color = {0, 255, 0},
                args = {"System", "Tür-ID " .. door .. " wurde geschlossen!"}
            })
            Wait(500)
        end
        -- Verriegelt das Fahrzeug
        SetVehicleDoorsLocked(prisonWagon, 2)
        print("✅ Fahrzeug wurde verriegelt.")
    end
end)

-- ==== CLIENT-EVENT: Türen öffnen ====
RegisterNetEvent("prisonwagon:openDoorsClient", function(netId)
    local wagon = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(wagon) then
        SetVehicleDoorsLocked(wagon, 1)  -- Entsperren

        -- Alle Türen öffnen
        for door = 0, 5 do  -- Teste 6 Türen (ID 0 bis 5)
            SetVehicleDoorOpen(wagon, door, false, false)
            print("✅ Tür-ID " .. door .. " geöffnet.")
        end
    end
end)

-- ==== CLIENT-EVENT: Türen schließen + verriegeln ====
RegisterNetEvent("prisonwagon:closeAndLockDoorsClient", function(netId)
    local wagon = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(wagon) then
        -- Alle Türen schließen und verriegeln
        for door = 0, 5 do  -- Teste 6 Türen (ID 0 bis 5)
            Citizen.InvokeNative(0x6A3C24B91FD0EA09, wagon, door, false)  -- Schließt die Tür
            print("✅ Tür-ID " .. door .. " geschlossen.")
        end
        SetVehicleDoorsLocked(wagon, 2)  -- Verriegelt das Fahrzeug
        print("✅ Fahrzeug verriegelt.")
    else
        print("^1Fehler: Wagen nicht gefunden!^7")
    end
end)
