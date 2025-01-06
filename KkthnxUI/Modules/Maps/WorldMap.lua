local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("WorldMap")

local select, tinsert = select, tinsert
local WorldMapFrame = WorldMapFrame
local CreateVector2D = CreateVector2D
local UnitPosition = UnitPosition
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Map_GetWorldPosFromMapPos = C_Map.GetWorldPosFromMapPos

local mapRects = {}
local tempVec2D = CreateVector2D(0, 0)
local currentMapID, playerCoords, cursorCoords

function Module:GetPlayerMapPos(mapID)
	if not mapID then
		return
	end
	tempVec2D.x, tempVec2D.y = UnitPosition("player")
	if not tempVec2D.x then
		return
	end

	local mapRect = mapRects[mapID]
	if not mapRect then
		mapRect = {}
		mapRect[1] = select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0)))
		mapRect[2] = select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1)))
		mapRect[2]:Subtract(mapRect[1])

		mapRects[mapID] = mapRect
	end
	tempVec2D:Subtract(mapRect[1])

	return tempVec2D.y / mapRect[2].y, tempVec2D.x / mapRect[2].x
end

function Module:GetCursorCoords()
	if not WorldMapFrame.ScrollContainer:IsMouseOver() then
		return
	end

	local cursorX, cursorY = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
	if cursorX < 0 or cursorX > 1 or cursorY < 0 or cursorY > 1 then
		return
	end
	return cursorX, cursorY
end

local function CoordsFormat(owner, none)
	local text = none and ": --, --" or ": %.1f, %.1f"
	return K.SystemColor .. owner .. K.MyClassColor .. text
end

function Module:UpdateCoords(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		local cursorX, cursorY = Module:GetCursorCoords()
		if cursorX and cursorY then
			cursorCoords:SetFormattedText(CoordsFormat(MOUSE_LABEL), 100 * cursorX, 100 * cursorY)
		else
			cursorCoords:SetText(CoordsFormat(MOUSE_LABEL, true))
		end

		if not currentMapID then
			playerCoords:SetText(CoordsFormat(PLAYER, true))
		else
			local x, y = Module:GetPlayerMapPos(currentMapID)
			if not x or (x == 0 and y == 0) then
				playerCoords:SetText(CoordsFormat(PLAYER, true))
			else
				playerCoords:SetFormattedText(CoordsFormat(PLAYER), 100 * x, 100 * y)
			end
		end

		self.elapsed = 0
	end
end

function Module:UpdateMapID()
	if self:GetMapID() == C_Map_GetBestMapForUnit("player") then
		currentMapID = self:GetMapID()
	else
		currentMapID = nil
	end
end

function Module:SetupCoords()
	if not C["WorldMap"].Coordinates then
		return
	end

	-- Create the coordinates frame
	local textParent = CreateFrame("Frame", nil, WorldMapFrame.ScrollContainer)
	textParent:SetFrameLevel(5)
	textParent:SetSize(WorldMapFrame:GetWidth(), 17)
	textParent:SetPoint("BOTTOMLEFT", 17)
	textParent:SetPoint("BOTTOMRIGHT", 0)

	-- Background texture for the coordinates frame
	textParent.Texture = textParent:CreateTexture(nil, "BACKGROUND")
	textParent.Texture:SetAllPoints()
	textParent.Texture:SetTexture(C["Media"].Textures.White8x8Texture)
	textParent.Texture:SetVertexColor(0.04, 0.04, 0.04, 0.5)

	playerCoords = K.CreateFontString(textParent, 13, "", "OUTLINE", false, "BOTTOMLEFT", 80, 2)
	playerCoords:SetAlpha(0.8)
	playerCoords:SetJustifyH("LEFT")
	cursorCoords = K.CreateFontString(textParent, 13, "", "OUTLINE", false, "BOTTOMRIGHT", -80, 2)
	cursorCoords:SetAlpha(0.8)
	cursorCoords:SetJustifyH("RIGHT")

	hooksecurefunc(WorldMapFrame, "OnFrameSizeChanged", Module.UpdateMapID)
	hooksecurefunc(WorldMapFrame, "OnMapChanged", Module.UpdateMapID)

	local CoordsUpdater = CreateFrame("Frame", nil, WorldMapFrame)
	CoordsUpdater:SetScript("OnUpdate", Module.UpdateCoords)
end

function Module:UpdateMapScale()
	if self.isMaximized and self:GetScale() ~= 0.8 then
		self:SetScale(0.8)
	elseif not self.isMaximized and self:GetScale() ~= 0.7 then
		self:SetScale(0.7)
	end
end

function Module:UpdateMapAnchor()
	Module.UpdateMapScale(self)
	if not self.isMaximized then
		K.RestoreMoverFrame(self)
	end
end

local function isMouseOverMap()
	return not WorldMapFrame:IsMouseOver()
end

function Module:MapFader()
	if C["WorldMap"].FadeWhenMoving then
		PlayerMovementFrameFader.AddDeferredFrame(WorldMapFrame, 0.5, 1, 0.5, isMouseOverMap)
	else
		PlayerMovementFrameFader.RemoveFrame(WorldMapFrame)
	end
end

function Module:MapPartyDots()
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
	WorldMapUnitPinSizes.player = 22
	WorldMapUnitPinSizes.party = 12
	WorldMapUnitPin:SetAppearanceField("party", "useClassColor", true)
	WorldMapUnitPin:SetAppearanceField("raid", "useClassColor", true)
	WorldMapUnitPin:SynchronizePinSizes()
end

function Module:OnEnable()
	if not C["WorldMap"].Enable then
		return
	end

	-- Exit if conflicting addons are loaded
	if IsAddOnLoaded("Leatrix_Maps") or IsAddOnLoaded("Mapster") then
		return
	end

	-- Fix worldmap cursor when scaling
	WorldMapFrame.ScrollContainer.GetCursorPosition = function(f)
		local x, y = MapCanvasScrollControllerMixin.GetCursorPosition(f)
		local scale = WorldMapFrame:GetScale()
		return x / scale, y / scale
	end

	-- Fix scroll zooming in classic
	WorldMapFrame.ScrollContainer:HookScript("OnMouseWheel", function(self, delta)
		local x, y = self:GetNormalizedCursorPosition()
		local nextZoomOutScale, nextZoomInScale = self:GetCurrentZoomRange()
		if delta == 1 then
			if nextZoomInScale > self:GetCanvasScale() then
				self:InstantPanAndZoom(nextZoomInScale, x, y)
			end
		else
			if nextZoomOutScale < self:GetCanvasScale() then
				self:InstantPanAndZoom(nextZoomOutScale, x, y)
			end
		end
	end)

	K.CreateMoverFrame(WorldMapFrame, nil, true)
	self.UpdateMapScale(WorldMapFrame)
	WorldMapFrame:HookScript("OnShow", self.UpdateMapAnchor)
	hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", self.UpdateMapAnchor)

	-- Default elements
	WorldMapFrame.BlackoutFrame:SetAlpha(0)
	WorldMapFrame.BlackoutFrame:EnableMouse(false)
	WorldMapFrame:SetFrameStrata("MEDIUM")
	WorldMapFrame.BorderFrame:SetFrameStrata("MEDIUM")
	WorldMapFrame.BorderFrame:SetFrameLevel(1)
	WorldMapTitleButton:SetFrameLevel(1)
	WorldMapFrame:SetAttribute("UIPanelLayout-area", "center")
	WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)
	WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
	WorldMapFrame.HandleUserActionToggleSelf = function()
		if WorldMapFrame:IsShown() then
			WorldMapFrame:Hide()
		else
			WorldMapFrame:Show()
		end
	end
	tinsert(UISpecialFrames, "WorldMapFrame")

	self:MapPartyDots()
	self:SetupCoords()
	self:MapFader()

	local loadWorldMapModules = {
		"CreateWorldMapReveal",
		"CreateWowHeadLinks",
		"CreateWorldMapPins",
	}

	for _, funcName in ipairs(loadWorldMapModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end
