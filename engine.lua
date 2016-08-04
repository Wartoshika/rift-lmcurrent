local player_id = nil
local speedBlur = {}
local blurynessAmount = 25

-- jedes dritte event wird ausgewertet, schont die cpu :)
local eventCounter, eventMax = 1, 3 

-- wird ausgeloesst wenn sich der spieler bewegt
function LmCurrent.Engine.coordChangeEvent(_, x, y, z)

    -- nicht alle events mitnehmen
    if eventCounter < eventMax then
        eventCounter = eventCounter + 1
        return
    else
        eventCounter = 1
    end
    
    -- wenn player_id null ist diese erstmal finden
    if not player_id then player_id = Inspect.Unit.Detail("player").id end

    -- gibt es den spieler im table?
    if not LmUtils.tableHasValue(LmUtils.getTableKeys(x), player_id) then return end

    local coords = {
        x = x[player_id],
        --y = y[player_id], -- wird aktuell nicht benoetigt da dies die hoehe ist
        z = z[player_id],
        time = Inspect.Time.Real() -- zeit mitspeichern um geschw. zu berechnen
    }

    -- speichern
    LmCurrent.Misc.previousLocation = LmCurrent.Misc.currentLocation
    LmCurrent.Misc.currentLocation = coords

    -- gui updaten
    LmCurrent.Ui.update()
end

-- berechnet die geschwindigkeit zwischen coordinaten
function LmCurrent.Engine.calculateSpeed(current, previous)

    -- geschw. kann erst berechnet werden wenn beide werte gesetzt sind
    if current == nil or previous == nil then return 0 end

    -- vergangene zeit in milisekunden fuer die zurueckgelegte strecke
    local seconds = current.time - previous.time

    -- im rift system (u.a. wegpunkte) wird ein meter in einem koordinaten punkt
    -- ausgegeben. also mit dieser formel die geschw. berechnen.
    -- ausserdem muss natuerlich die vorwaerts- und seitwaertsbewegung addiert werden
    local speedX, speedZ

    -- vorzeihen und richtiger startwert muss passen
    if math.abs(current.x) > math.abs(previous.x) then
        speedX = (math.abs(current.x) - math.abs(previous.x)) / seconds
    else
        speedX = (math.abs(previous.x) - math.abs(current.x)) / seconds
    end

    -- auch hier - vorzeihen und richtiger startwert muss passen
    if math.abs(current.z) > math.abs(previous.z) then
        speedZ = (math.abs(current.z) - math.abs(previous.z)) / seconds
    else
        speedZ = (math.abs(previous.z) - math.abs(current.z)) / seconds
    end

    -- nun x + z addieren
    local speed = speedX + speedZ
    
    -- nun verwischen
    table.insert(speedBlur, speed)

    -- evtl einen entfernen
    if LmUtils.tableLength(speedBlur) > blurynessAmount then

        -- aeltesten eintrag entfernen
        table.remove(speedBlur, 1)
    end

    -- alle werte zusammenzaehlen und teilen
    return math.floor(LmUtils.tableReduce(LmUtils.copyTable(speedBlur), function(a, b)
        return a + b
    end) / LmUtils.tableLength(speedBlur))

end

-- erkennt wenn der spieler den shard wechselt und updated die gui
function LmCurrent.Engine.detectShardChange(_, units)

    -- wenn player_id null ist diese erstmal finden
    if not player_id then player_id = Inspect.Unit.Detail("player").id end

    -- spieler im table? passiert wenn der shard gewechselt wird
    if LmUtils.tableHasValue(LmUtils.getTableKeys(units), player_id) then

        -- ja gefunden, nun den shard finden. dazu muss der chat zurate gezogen
        -- werden da dieser beim wechsel verschiedene channels verlaesst und betritt
        -- erstmal die hauptconsole finden wo diese infos stehen
        local consoles = Inspect.Console.List()

        -- aktuelle zone des spielers finden um shard zu bestimmen
        local zone = Inspect.Zone.Detail(Inspect.Unit.Detail("player").zone)

        -- alle durchgehen und parameter suchen
        for console, active in pairs(consoles) do 

            -- nur wenn aktiv
            if active then

                -- details holen
                local consoleDetails = Inspect.Console.Detail(console)

                -- nur wenn es channels gibt
                if not consoleDetails.channel then goto continueChannel end
                
                -- channels durchgehen
                local channels = LmUtils.getTableKeys(consoleDetails.channel)

                -- jetzt gucken, ob ein channel ein @ zeiten beinhaltet, dann ist dies
                -- der aktuelle shard. wenn nicht, dann kann vom homeshard ausgegangen werden
                for k, shard in pairs(channels) do

                    -- beginnt der channel mit der aktuellen zone?
                    if shard:match("^" .. zone.name) then

                        -- ja, gefunden! wenn @ vorhanden ist dann fremdshard!
                        local offset = shard:find("@")
                        if offset ~= nil then

                            -- shard info extrahieren
                            LmCurrent.Misc.currentShard = shard:sub(offset + 1)
                        else

                            -- es ist der homeshard
                            LmCurrent.Misc.currentShard = Inspect.Shard().name
                        end

                        -- gui updaten
                        return LmCurrent.Ui.update()
                    end
                end 
            end

            ::continueChannel::
        end
    end
end 