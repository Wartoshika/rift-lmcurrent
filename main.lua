-- addon env holen
local addon = ...

-- main init funktion nach addon load
local function init()

    -- event listener entfernen
    Command.Event.Detach(Event.Addon.Load.End, init, "init")

    -- variablen laden
    if LmCurrentGlobal then

        -- variablen laden wenn definiert
        for k,v in pairs(LmCurrentGlobal) do

            -- einzelnd updaten
            LmCurrent.Options[k] = v;
        end
    end

    -- erfolgreichen start ausgeben
    print("erfolgreich geladen (v " .. addon.toc.Version .. ")")

end

-- speichert die gesetzten optionen
local function saveOptionVariables()

    -- ueberschreiben
    LmCurrentGlobal = LmCurrent.Options
end

-- event registrieren
Command.Event.Attach(Event.Addon.Load.End, init, "init")
Command.Event.Attach(Event.Addon.Shutdown.Begin, saveOptionVariables, "saveOptionVariables")

