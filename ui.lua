local context, frame, position, speed, shard

-- initialisiert die gui
function LmCurrent.Ui.initialize()

    -- haupt ui elemente erstellen
    context = UI.CreateContext(LmCurrent.Addon.identifier .. ".Context")
    frame = UI.CreateFrame("Texture", LmCurrent.Addon.identifier .. ".MainFrame", context)
    position = UI.CreateFrame("Text", LmCurrent.Addon.identifier .. ".PositionFrame", context)
    speed = UI.CreateFrame("Text", LmCurrent.Addon.identifier .. ".SpeedFrame", context)
    shard = UI.CreateFrame("Text", LmCurrent.Addon.identifier .. ".ShardFrame", context)

    -- frame params setzen
    frame:SetTexture("Rift", "square_progbar_bg.png.dds")
    frame:SetPoint("BOTTOMRIGHT", UI.Native.MapMini, "BOTTOMRIGHT", -12, -5)
    frame:SetWidth(215)
    frame:SetLayer(2)
    frame:SetAlpha(.5)

    -- position params
    position:SetText("0, 0")
    position:SetPoint("CENTER", frame, "CENTER")
    position:SetLayer(3)

    -- speed params
    speed:SetText("0 m/s")
    speed:SetPoint("CENTERRIGHT", frame, "CENTERRIGHT", -2, 0)
    speed:SetLayer(3)

    -- waypoint params
    shard:SetText(Inspect.Shard().name)
    shard:SetPoint("CENTERLEFT", frame, "CENTERLEFT", 2, 0)
    shard:SetLayer(3)

end

-- gui update durchfuehren
function LmCurrent.Ui.update()

    -- daten holen
    local prev = LmCurrent.Misc.previousLocation
    local curr =  LmCurrent.Misc.currentLocation

    -- nur wenn geschw. berechnet werden kann
    if curr ~= nil and prev ~= nil then

        -- daten berechnen
        local calculatedSpeed = LmCurrent.Engine.calculateSpeed(curr, prev)

        -- daten anzeigen
        position:SetText(string.format("%s, %s", math.floor(curr.x), math.floor(curr.z)))
        speed:SetText(calculatedSpeed .. " m/s")
    end

    -- aktuellen shard anzeigen
    if LmCurrent.Misc.currentShard then
        shard:SetText(LmCurrent.Misc.currentShard)
    end

end