local K, C = unpack(select(2, ...))
local Module = K:NewModule("WorldMap")

local _G = _G
local table_insert = _G.table.insert
local select = _G.select

local C_Map_GetBestMapForUnit = _G.C_Map.GetBestMapForUnit
local C_Map_GetWorldPosFromMapPos = _G.C_Map.GetWorldPosFromMapPos
local CreateFrame = _G.CreateFrame
local CreateVector2D = _G.CreateVector2D
local IsAddOnLoaded = _G.IsAddOnLoaded
local PLAYER = _G.PLAYER
local UnitPosition = _G.UnitPosition
local WorldMapFrame = _G.WorldMapFrame
local hooksecurefunc = _G.hooksecurefunc

local mapRects = {}
local tempVec2D = CreateVector2D(0, 0)
local currentMapID, playerCoords, cursorCoords

function Module:GetPlayerMapPos(mapID)
	tempVec2D.x, tempVec2D.y = UnitPosition("player")
	if not tempVec2D.x then return end

	local mapRect = mapRects[mapID]
	if not mapRect then
		mapRect = {}
		mapRect[1] = select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0)))
		mapRect[2] = select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1)))
		mapRect[2]:Subtract(mapRect[1])

		mapRects[mapID] = mapRect
	end
	tempVec2D:Subtract(mapRect[1])

	return tempVec2D.y/mapRect[2].y, tempVec2D.x/mapRect[2].x
end

function Module:GetCursorCoords()
	if not WorldMapFrame.ScrollContainer:IsMouseOver() then return end

	local cursorX, cursorY = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
	if cursorX < 0 or cursorX > 1 or cursorY < 0 or cursorY > 1 then return end
	return cursorX, cursorY
end

local function CoordsFormat(owner, none)
	local text = none and ": --, --" or ": %.1f, %.1f"
	return owner..K.MyClassColor..text
end

function Module:UpdateCoords(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > .1 then
		local cursorX, cursorY = Module:GetCursorCoords()
		if cursorX and cursorY then
			cursorCoords:SetFormattedText(CoordsFormat("Mouse"), 100 * cursorX, 100 * cursorY)
		else
			cursorCoords:SetText(CoordsFormat("Mouse", true))
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

	playerCoords = K.CreateFontString(WorldMapFrame, 12, nil, "", "system", "TOPLEFT", 20, -7)
	cursorCoords = K.CreateFontString(WorldMapFrame, 12, nil, "", "system", "TOPLEFT", 170, -7)

	hooksecurefunc(WorldMapFrame, "OnFrameSizeChanged", Module.UpdateMapID)
	hooksecurefunc(WorldMapFrame, "OnMapChanged", Module.UpdateMapID)

	local CoordsUpdater = CreateFrame("Frame", nil, WorldMapFrame)
	CoordsUpdater:SetScript("OnUpdate", Module.UpdateCoords)
end

function Module:UpdateMapScale()
	if self.isMaximized and self:GetScale() ~= 1 then
		self:SetScale(1)
	elseif not self.isMaximized and self:GetScale() ~= C["WorldMap"].MapScale then
		self:SetScale(C["WorldMap"].MapScale)
	end
end

function Module:UpdateMapAnchor()
	Module.UpdateMapScale(self)
	if not self.isMaximized then K.RestoreMoverFrame(self) end
end

function Module:SetupWorldMap()
	if IsAddOnLoaded("Leatrix_Maps") then return end

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
	hooksecurefunc(WorldMapFrame, "HandleUserActionToggleSelf", self.UpdateMapAnchor)

	-- Default elements
	WorldMapFrame.BlackoutFrame:Hide()
	WorldMapFrame:SetFrameStrata("MEDIUM")
	WorldMapFrame.BorderFrame:SetFrameStrata("MEDIUM")
	WorldMapFrame.BorderFrame:SetFrameLevel(1)
	WorldMapFrame:SetAttribute("UIPanelLayout-area", "center")
	WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)
	WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
	WorldMapFrame.HandleUserActionToggleSelf = function()
		if WorldMapFrame:IsShown() then WorldMapFrame:Hide() else WorldMapFrame:Show() end
	end

	table_insert(UISpecialFrames, "WorldMapFrame")
end

local function isMouseOverMap()
	return not WorldMapFrame:IsMouseOver()
end

function Module:MapFader()
	if C["WorldMap"].MapFader then
		PlayerMovementFrameFader.AddDeferredFrame(WorldMapFrame, .5, 1, .5, isMouseOverMap)
	else
		PlayerMovementFrameFader.RemoveFrame(WorldMapFrame)
	end
end

function Module:OnEnable()
	self:SetupWorldMap()
	self:SetupCoords()
	self:MapFader()

	self:CreateWorldMapReveal()
	self:CreateWorldMapIcons()
end