local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil_Classic")
local RCVotingFrame = addon:GetModule("RCVotingFrame")
local RCVFP = addon:NewModule("RCVFP", "AceComm-3.0", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceSerializer-3.0")

local session = 1
local table = table

function RCVFP:OnInitialize()
	if not RCVotingFrame.scrollCols then
		return self:ScheduleTimer("OnInitialize", 0.5)
	end
    self:UpdateColumns()
	self.initialize = true
end

function RCVFP:GetScrollColIndexFromName(colName)
    for i, v in ipairs(RCVotingFrame.scrollCols) do
        if v.colName == colName then
            return i
        end
    end
end

function RCVFP:UpdateColumns()
    local plusonems =
    { name = "+MS", DoCellUpdate = self.SetCellPlusoneMS, colName = "MS", sortnext = self:GetScrollColIndexFromName("response"), width = 30, align = "CENTER", defaultsort = "asc" }
	table.insert(RCVotingFrame.scrollCols, plusonems)

    local plusoneos =
    { name = "+OS", DoCellUpdate = self.SetCellPlusoneOS, colName = "OS", sortnext = self:GetScrollColIndexFromName("MS"), width = 30, align = "CENTER", defaultsort = "asc" }
	table.insert(RCVotingFrame.scrollCols, plusoneos)

    -- Check if the columns "votes" and "vote" exist before trying to remove them
	local votesIdx = self:GetScrollColIndexFromName("votes")
	if votesIdx then
		table.remove(RCVotingFrame.scrollCols, votesIdx)
	end
	local voteIdx = self:GetScrollColIndexFromName("vote")
	if voteIdx then
		table.remove(RCVotingFrame.scrollCols, voteIdx)
	end

    self:ResponseSortNext()

    -- Verify that UpdateSt() is valid in Cataclysm; replace if necessary
    if RCVotingFrame:GetFrame() and RCVotingFrame:GetFrame().UpdateSt then
        RCVotingFrame:GetFrame().UpdateSt()
    end
end

function RCVFP:ResponseSortNext()
    local responseIdx = self:GetScrollColIndexFromName("response")
    local msIdx = self:GetScrollColIndexFromName("MS")
    if responseIdx then
        RCVotingFrame.scrollCols[responseIdx].sortnext = msIdx
    end
end

function RCVFP.SetCellPlusoneMS(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
	local lootTable = RCVotingFrame:GetLootTable()
	local countLoot = 0
	for nameLootReceiver, a in pairs(RCLootCouncil.lootDB.factionrealm) do
		if nameLootReceiver == name then
			for i, v in ipairs(a) do
				if v.date == date("%d/%m/%y") then
					for k, t in pairs(v) do
						if k == "response" and string.find(string.lower(t), "ms") then
							countLoot = countLoot + 1
						end
					end
				end
			end
		end
	end
	
	frame.text:SetText(countLoot)
	data[realrow].cols[column].value = lootTable[session].candidates[name].plusone or 0
end

function RCVFP.SetCellPlusoneOS(rowFrame, frame, data, cols, row, realrow, column, fShow, table, ...)
	local name = data[realrow].name
	local lootTable = RCVotingFrame:GetLootTable()
	local countLoot = 0
	for nameLootReceiver, a in pairs(RCLootCouncil.lootDB.factionrealm) do
		if nameLootReceiver == name then
			for i, v in ipairs(a) do
				if v.date == date("%d/%m/%y") then
					for k, t in pairs(v) do
						if k == "response" and string.find(string.lower(t), "os") then
							countLoot = countLoot + 1
						end
					end
				end
			end
		end
	end
	
	frame.text:SetText(countLoot)
	data[realrow].cols[column].value = lootTable[session].candidates[name].plusone or 0
end
