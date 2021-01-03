console = LibStub("AceConsole-3.0")
HORDE = 0
ALLIANCE = 1

function JBG:BATTLEGROUND_OBJECTIVES_UPDATE(...)
    --
    -- uiMapID = C_Map.GetBestMapForUnit("player")
    -- poi_list = C_AreaPoiInfo.GetAreaPOIForMap(uiMapID)
    -- self.poi_info = {}
    -- for _, poi_id in pairs(poi_list) do
    --     self.poi_info[poi_id] = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, poi_id)
    -- end
end

function JBG:GetBattlegroundCapStatuses(uiMapID)
    --
    -- JBG:Print(self.poi_info)
end

function JBG:BATTLEGROUND_POINTS_UPDATE(ally_string, horde_string, ...)
    real_A, max_A = GetBattlegroundPoints(ALLIANCE)
    real_H, max_H = GetBattlegroundPoints(HORDE)

    -- https://wow.gamepedia.com/UiMapID
    uiMapID = C_Map.GetBestMapForUnit("player")

    -- Zones
    local AB, BFG, EOTS, DWG1, DWG2 = 1366, 275, 112, 519, 1576

    rates = {
        [EOTS] = {[0] = 0, [1] = 1, [2] = 2, [3] = 5, [4] = 10},
        [AB] = {[0] = 0, [1] = 2, [2] = 3, [3] = 4, [4] = 7, [5] = 60},
        [BFG] = {[0] = 0, [1] = 10 / 9, [2] = 10 / 3, [3] = 30},

        -- I can't find the tick rates for DWG so I'm assuming same as AB
        [DWG2] = {[0] = 0, [1] = 1, [2] = 1.5, [3] = 2, [4] = 3.5, [5] = 30}
    }
    nodes = {[AB] = 5, [BFG] = 3, [EOTS] = 4, [DWG1] = 3, [DWG2] = 5}

    if (uiMapID == AB) or (uiMapID == BFG) or (uiMapID == EOTS) or
        (uiMapID == DWG2) or (uiMapID == DWG1) then

        ally_string:SetAlpha(1)
        horde_string:SetAlpha(1)

        lowest_A = 100
        lowest_H = 100
        for bases_A = 0, nodes[uiMapID] do
            bases_H = nodes[uiMapID] - bases_A
            fake_A = real_A
            fake_H = real_H

            for tick = 0, max_A do
                fake_A = fake_A + rates[uiMapID][bases_A]
                fake_H = fake_H + rates[uiMapID][bases_H]

                if (fake_A >= max_A) and (fake_H >= max_H) then
                    break
                elseif fake_A >= max_A then
                    if bases_A < lowest_A then
                        lowest_A = bases_A
                    end
                    break
                elseif fake_H >= max_H then
                    if bases_H < lowest_H then
                        lowest_H = bases_H
                    end
                    break
                end
            end
        end

        if ally_string == 0 or ally_string == 100 then
            ally_string:SetAlpha(0)
            horde_string:SetAlpha(0)
        else
            ally_string:SetText(lowest_A)
            horde_string:SetText(lowest_H)
        end
    end
end

function JBG:ZONE_CHANGED_NEW_AREA(ally_string, horde_string, ...)
    if not C_PvP.IsBattleground() then
        ally_string:SetAlpha(0)
        horde_string:SetAlpha(0)
    end
end

local frame = CreateFrame("Frame");

frame:SetWidth(1)
frame:SetHeight(1)
frame:SetPoint("CENTER", 0, 0)

local ally_string = frame:CreateFontString(f, "OVERLAY", "GameTooltipText")
ally_string:SetPoint("CENTER", -90, 365)
ally_string:SetAlpha(0)
ally_string:SetText("")

local horde_string = frame:CreateFontString(f, "OVERLAY", "GameTooltipText")
horde_string:SetPoint("CENTER", 90, 365)
horde_string:SetAlpha(0)
horde_string:SetText("")

frame:SetScript("OnEvent", function(self, event, ...)
    JBG[event](self, ally_string, horde_string, ...); -- call one of the functions above
end);

frame:RegisterEvent("BATTLEGROUND_POINTS_UPDATE")
frame:RegisterEvent("BATTLEGROUND_OBJECTIVES_UPDATE")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
