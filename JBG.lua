JBG = LibStub("AceAddon-3.0"):NewAddon("JBG", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local ScrollingTable = LibStub("ScrollingTable");

JBG:RegisterChatCommand("jbg", "ChatCommand")

widths = {Name = 200, Kills = 40, Deaths = 40, Damage = 40, Healing = 40}
widths_order = {"Name", "Kills", "Deaths", "Damage", "Healing"}
widths["Total"] = 0
for k, v in pairs(widths) do
    if k ~= "Total" then widths["Total"] = widths["Total"] + v end
end
widths["Total"] = widths["Total"] * 2

function JBG:CreateParentFrame()
    -- if not C_PvP.IsBattleground() then return end
    if _G["JBG_Frame"] ~= nil then return end

    local parentFrame = AceGUI:Create("Frame")
    parentFrame:SetLayout("Flow")

    -- Free resources on close
    parentFrame:SetCallback("OnClose", function(widget)
        _G["JBG_Frame"] = nil

        AceGUI:Release(widget)
    end)
    -- Set BG name to window title
    parentFrame:SetTitle(GetZoneText())
    -- Make escape close the window
    -- Register the global variable `JBG_Frame` as a "special frame"
    -- so that it is closed when the escape key is pressed.
    _G["JBG_Frame"] = parentFrame.frame
    tinsert(UISpecialFrames, "JBG_Frame")

    parentFrame:SetWidth(625)
    parentFrame:SetHeight(800)

    -- Add header row
    -- parentFrame:AddChild(self:CreateHeaderRow())

    -- Add table
    -- parentFrame:AddChild(self:BuildBGDataTable())
    if self.scrTbl == nil then
        self.scrTbl = self:BuildBGDataTable(parentFrame)
        self.scrTbl:SetHeight(700)
    end

    -- Add data to scroll table
    self.scrTbl:SetData(self:ConvertDataTableToFrames(), false)
    self.parentFrame = parentFrame
end

function JBG:CreateScrollableFrame() end

function JBG:CreateHeaderRow()
    local row = AceGUI:Create("SimpleGroup")
    row:SetLayout("Flow")

    for colName, colWidth in pairs(widths) do
        local label = AceGUI:Create("InteractiveLabel")
        label:SetWidth(colWidth)
        label:SetText(colName)
        row:AddChild(label)
    end

    return row
end

function JBG:BuildBGDataTable(parent)
    local cols = {}
    -- for colName, colWidth in pairs(widths) do
    for indx, colName in pairs(widths_order) do
        local colWidth = widths[colName]
        if colName ~= "Total" then
            cols[#cols + 1] = {
                ["name"] = colName,
                ["width"] = colWidth * 1.5,
                ["align"] = "LEFT",
                ["color"] = {["r"] = 1.0, ["g"] = 1.0, ["b"] = 1.0, ["a"] = 1.0},
                ["defaultsort"] = "asc"
            }
        end
    end

    local scrollingTable = ScrollingTable:CreateST(cols, 20, 20, nil,
                                                   parent.frame)

    return scrollingTable
end

function JBG:ConvertDataTableToFrames()
    local rows = {}
    for i = 1, GetNumBattlefieldScores() do
        name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec =
            GetBattlefieldScore(i)

        local row = {}
        row["cols"] = {
            {["value"] = name}, {["value"] = killingBlows},
            {["value"] = deaths}, {["value"] = damageDone},
            {["value"] = healingDone}
        }

        rows[#rows + 1] = row
    end

    return rows
end

function JBG:ConvertDataRowToFrame() end

function JBG:RegisterForDataUpdateEvent() end

function JBG:DataUpdateEventHandler() end

function JBG:ChatCommand()
    if _G["JBG_Frame"] then
        self.parentFrame:Hide()
    else
        self:CreateParentFrame()
    end
end
