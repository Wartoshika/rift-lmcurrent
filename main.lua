-- addon env holen
local addon = ...

-- main init funktion nach addon load
local function init()

    -- event registrieren wenn sich der spieler bewegt
    Command.Event.Attach(Event.Unit.Detail.Coord, LmCurrent.Engine.coordChangeEvent, "LmCurrent.Engine.coordChangeEvent")
    Command.Event.Attach(Event.Unit.Availability.Full, LmCurrent.Engine.detectShardChange, "LmCurrent.Engine.detectShardChange")

    -- addon daten speichern
    LmCurrent.Addon = addon

    -- gui erstellen
    LmCurrent.Ui.initialize()

    -- erfolgreichen start ausgeben
    print("erfolgreich geladen (v " .. addon.toc.Version .. ")")

end

-- wartet bis rift den spieler character geladen hat
local function waitForRiftCharacterSystem()

    -- kann initialisiert werden?
    if Inspect.Unit.Detail("player") ~= nil and Inspect.Unit.Detail("player").coordX ~= nil then

        -- ja, event entfernen
        Command.Event.Detach(Event.System.Update.End, waitForRiftCharacterSystem, "waitForRiftCharacterSystem")

        -- initialisieren
        init();        
    end
end

-- event registrieren
Command.Event.Attach(Event.System.Update.End, waitForRiftCharacterSystem, "waitForRiftCharacterSystem")