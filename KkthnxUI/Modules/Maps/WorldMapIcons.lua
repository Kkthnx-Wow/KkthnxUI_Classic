local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("WorldMap")

local _G = _G

local table_insert = _G.table.insert

local C_Map_GetMapInfoAtPosition = _G.C_Map.GetMapInfoAtPosition
local ConvertRGBtoColorString = _G.ConvertRGBtoColorString
local CreateFromMixins = _G.CreateFromMixins
local CreateVector2D = _G.CreateVector2D
local FACTION_ALLIANCE = _G.FACTION_ALLIANCE
local FACTION_CONTROLLED_TERRITORY = _G.FACTION_CONTROLLED_TERRITORY
local FACTION_HORDE = _G.FACTION_HORDE
local FONT_COLOR_CODE_CLOSE = _G.FONT_COLOR_CODE_CLOSE
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local MapUtil_FindBestAreaNameAtMouse = _G.MapUtil.FindBestAreaNameAtMouse
local UnitFactionGroup = _G.UnitFactionGroup
local hooksecurefunc = _G.hooksecurefunc

function Module:CreateMapIcons()
		-- Flight points
		local tATex, tHTex = "TaxiNode_Alliance", "TaxiNode_Horde"
		local playerFaction = UnitFactionGroup("player")

		-- Add situational data
		if K.Class == "DRUID" then
			-- Moonglade flight points for druids only
			table_insert(K.WorldMapPlusPinData[1450], {"FlightA", 44.1, 45.2, "Nighthaven"..", ".."Moonglade", "Druid only flight point to Darnassus", tATex, nil, nil})
			table_insert(K.WorldMapPlusPinData[1450], {"FlightH", 44.3, 45.9, "Nighthaven"..", ".."Moonglade", "Druid only flight point to Thunder Bluff", tHTex, nil, nil})
		end

		local KkthnxUIMix = CreateFromMixins(MapCanvasDataProviderMixin)
		function KkthnxUIMix:RefreshAllData()
			-- Remove all pins
			self:GetMap():RemoveAllPinsByTemplate("KkthnxUIMapsGlobalPinTemplate")

			-- Make new pins
			local pMapID = _G.WorldMapFrame.mapID
			if K.WorldMapPlusPinData[pMapID] then
				local count = #K.WorldMapPlusPinData[pMapID]
				for i = 1, count do

					-- Do nothing if pinInfo has no entry for zone we are looking at
					local pinInfo = K.WorldMapPlusPinData[pMapID][i]
					if not pinInfo then return nil end

					-- Get POI if any quest requirements have been met
					if (pinInfo[1] == "Dungeon" or pinInfo[1] == "Raid" or pinInfo[1] == "Dunraid")
						or playerFaction == "Alliance" and (pinInfo[1] == "FlightA" or pinInfo[1] == "FlightN")
						or playerFaction == "Horde" and (pinInfo[1] == "FlightH" or pinInfo[1] == "FlightN")
						or playerFaction == "Alliance" and (pinInfo[1] == "TravelA" or pinInfo[1] == "TravelN")
						or playerFaction == "Horde" and (pinInfo[1] == "TravelH" or pinInfo[1] == "TravelN")
					then
						local myPOI = {}
						myPOI["position"] = CreateVector2D(pinInfo[2] / 100, pinInfo[3] / 100)
						if pinInfo[7] and pinInfo[8] then
							-- Set dungeon level in title
							local playerLevel = K.Level
							local color
							local name = ""
							local dungeonMinLevel, dungeonMaxLevel = pinInfo[7], pinInfo[8]
							if playerLevel < dungeonMinLevel then
								color = GetQuestDifficultyColor(dungeonMinLevel)
							elseif playerLevel > dungeonMaxLevel then
								-- Subtract 2 from the maxLevel so zones entirely below the player's level won't be yellow
								color = GetQuestDifficultyColor(dungeonMaxLevel - 2)
							else
								color = QuestDifficultyColors["difficult"]
							end
							color = ConvertRGBtoColorString(color)
							if dungeonMinLevel ~= dungeonMaxLevel then
								name = name..color.." ("..dungeonMinLevel.."-"..dungeonMaxLevel..")"..FONT_COLOR_CODE_CLOSE
							else
								name = name..color.." ("..dungeonMaxLevel..")"..FONT_COLOR_CODE_CLOSE
							end
							myPOI["name"] = pinInfo[4]..name
						else
							myPOI["name"] = pinInfo[4] -- Show zone levels is disabled or dungeon has no level range
						end
						myPOI["description"] = pinInfo[5]
						myPOI["atlasName"] = pinInfo[6]
						local pin = self:GetMap():AcquirePin("KkthnxUIMapsGlobalPinTemplate", myPOI)
						-- Override travel textures
						if pinInfo[1] == "TravelA" then
							pin.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Worldmap\\Leatrix_Maps.blp")
							pin.Texture:SetTexCoord(0, 0.125, 0.5, 1)
							pin.HighlightTexture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Worldmap\\Leatrix_Maps.blp")
							pin.HighlightTexture:SetTexCoord(0, 0.125, 0.5, 1)
						elseif pinInfo[1] == "TravelH" then
							pin.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Worldmap\\Leatrix_Maps.blp")
							pin.HighlightTexture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Worldmap\\Leatrix_Maps.blp")
							pin.Texture:SetTexCoord(0.125, 0.25, 0.5, 1)
							pin.HighlightTexture:SetTexCoord(0.125, 0.25, 0.5, 1)
						elseif pinInfo[1] == "TravelN" then
							pin.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Worldmap\\Leatrix_Maps.blp")
							pin.HighlightTexture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Worldmap\\Leatrix_Maps.blp")
							pin.Texture:SetTexCoord(0.25, 0.375, 0.5, 1)
							pin.HighlightTexture:SetTexCoord(0.25, 0.375, 0.5, 1)
						elseif pinInfo[1] == "Dunraid" then
							pin.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Worldmap\\Leatrix_Maps.blp")
							pin.HighlightTexture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Worldmap\\Leatrix_Maps.blp")
							pin.Texture:SetTexCoord(0.375, 0.5, 0.5, 1)
							pin.Texture:SetSize(32, 32)
							pin.HighlightTexture:SetTexCoord(0.375, 0.5, 0.5, 1)
							pin.HighlightTexture:SetSize(32, 32)
						end
					end
				end
			end
		end

		KkthnxUIMapsGlobalPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE")

		function KkthnxUIMapsGlobalPinMixin:OnAcquired(myInfo)
			BaseMapPoiPinMixin.OnAcquired(self, myInfo)
		end

		function KkthnxUIMapsGlobalPinMixin:OnMouseUp(btn)
			if btn == "RightButton" then
				WorldMapFrame:NavigateToParentMap()
			end
		end

		WorldMapFrame:AddDataProvider(KkthnxUIMix)
end

local function AreaLabel_OnUpdate(self)
	self:ClearLabel(_G.MAP_AREA_LABEL_TYPE.AREA_NAME)
	local map = self.dataProvider:GetMap()
	if map:IsCanvasMouseFocus() then
		local name, description
		local mapID = map:GetMapID()
		local normalizedCursorX, normalizedCursorY = map:GetNormalizedCursorPosition()
		local positionMapInfo = C_Map_GetMapInfoAtPosition(mapID, normalizedCursorX, normalizedCursorY)
		if positionMapInfo and positionMapInfo.mapID ~= mapID then
			-- print(positionMapInfo.mapID)
			name = positionMapInfo.name
			-- Get level range from table
			local playerMinLevel, playerMaxLevel, playerFaction, PlayerFishLevel
			if K.WorldMapLevelZoneData[positionMapInfo.mapID] then
				playerMinLevel = K.WorldMapLevelZoneData[positionMapInfo.mapID]["minLevel"]
				playerMaxLevel = K.WorldMapLevelZoneData[positionMapInfo.mapID]["maxLevel"]
				playerFaction = K.WorldMapLevelZoneData[positionMapInfo.mapID].faction
				PlayerFishLevel = K.WorldMapLevelZoneData[positionMapInfo.mapID]["minFish"]
			end

			if (playerFaction) then
				local englishFaction = UnitFactionGroup("player")
				if (playerFaction == "Alliance") then
					description = string.format(FACTION_CONTROLLED_TERRITORY, FACTION_ALLIANCE)
				elseif (playerFaction == "Horde") then
					description = string.format(FACTION_CONTROLLED_TERRITORY, FACTION_HORDE)
				end

				if (englishFaction == playerFaction) then
					description = "|CFF40D326"..description.."|r"..FONT_COLOR_CODE_CLOSE
				else
					description = "|CFFF52E24"..description.."|r"..FONT_COLOR_CODE_CLOSE
				end
			end
			-- Show level range if map zone exists in table
			if name and playerMinLevel and playerMaxLevel and playerMinLevel > 0 and playerMaxLevel > 0 then
				local playerLevel = K.Level
				local color
				if playerLevel < playerMinLevel then
					color = GetQuestDifficultyColor(playerMinLevel)
				elseif playerLevel > playerMaxLevel then
					-- Subtract 2 from the maxLevel so zones entirely below the player's level won't be yellow
					color = GetQuestDifficultyColor(playerMaxLevel - 2)
				else
					color = QuestDifficultyColors["difficult"]
				end
				color = ConvertRGBtoColorString(color)
				if playerMinLevel ~= playerMaxLevel then
					name = name..color.." ("..playerMinLevel.."-"..playerMaxLevel..")"..FONT_COLOR_CODE_CLOSE
				else
					name = name..color.." ("..playerMaxLevel..")"..FONT_COLOR_CODE_CLOSE
				end
			end
			if PlayerFishLevel then
				description = "Fishing"..": "..PlayerFishLevel
			end
		else
			name = MapUtil_FindBestAreaNameAtMouse(mapID, normalizedCursorX, normalizedCursorY)
		end

		if name then
			self:SetLabel(_G.MAP_AREA_LABEL_TYPE.AREA_NAME, name, description)
		end
    end

	self:EvaluateLabels()
end

function Module:CreateClassIcons()
	local WorldMapUnitPin, WorldMapUnitPinSizes
	local partyTexture = "Interface\\OptionsFrame\\VoiceChat-Record"

	local function setPinTexture(self)
		self:SetPinTexture("raid", partyTexture)
		self:SetPinTexture("party", partyTexture)
	end

	-- Set group icon textures
	for pin in WorldMapFrame:EnumeratePinsByTemplate("GroupMembersPinTemplate") do
		WorldMapUnitPin = pin
		WorldMapUnitPinSizes = pin.dataProvider:GetUnitPinSizesTable()
		setPinTexture(WorldMapUnitPin)
		hooksecurefunc(WorldMapUnitPin, "UpdateAppearanceData", setPinTexture)
		break
	end

	-- Set party icon size and enable class colors
	WorldMapUnitPinSizes.player = C["WorldMap"].PlayerIconSize or 24
	WorldMapUnitPinSizes.party = C["WorldMap"].PartyIconSize or 14
	WorldMapUnitPin:SetAppearanceField("party", "useClassColor", true)
	WorldMapUnitPin:SetAppearanceField("raid", "useClassColor", true)
	WorldMapUnitPin:SynchronizePinSizes()
end

function Module:SetUpZoneLevels()
	for provider in next, WorldMapFrame.dataProviders do
		if provider.setAreaLabelCallback then
			provider.Label:SetScript("OnUpdate", AreaLabel_OnUpdate)
		end
	end
end

function Module:CreateWorldMapIcons()
	if C["WorldMap"].WorldMapIcons ~= true then
		return
	end

	self:CreateMapIcons()
	self:SetUpZoneLevels()
	self:CreateClassIcons()
end