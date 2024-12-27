local K, C = KkthnxUI[1], KkthnxUI[2]
local table_insert = table.insert

local HOME_TEXTURE = "Interface\\Buttons\\UI-HomeButton"

-- Skinning Functions
local function SkinChatButton(button, size)
	button:SkinButton()
	button:SetSize(size, size)
	if button.Flash then
		button.Flash:Hide()
	end
end

local function SkinCloseButton(button, size)
	button:SkinCloseButton()
	button:SetSize(size, size)
end

-- Theme Application
table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	-- BNToastFrame
	BNToastFrame:SetClampedToScreen(true)
	BNToastFrame:SetBackdrop(nil)
	BNToastFrame:CreateBorder()
	BNToastFrame.TooltipFrame:HideBackdrop()
	BNToastFrame.TooltipFrame:CreateBorder()
	SkinCloseButton(BNToastFrame.CloseButton, 18)

	-- ChatFrame Buttons
	SkinChatButton(ChatFrameChannelButton, 16)
	-- SkinChatButton(ChatFrameToggleVoiceDeafenButton, 16)
	-- SkinChatButton(ChatFrameToggleVoiceMuteButton, 16)
	SkinChatButton(ChatFrameMenuButton, 16)
	ChatFrameMenuButton:SetNormalTexture(HOME_TEXTURE)
	ChatFrameMenuButton:SetPushedTexture(HOME_TEXTURE)

	-- VoiceChatChannelActivatedNotification
	VoiceChatChannelActivatedNotification:SetBackdrop(nil)
	VoiceChatChannelActivatedNotification:CreateBorder()
	SkinCloseButton(VoiceChatChannelActivatedNotification.CloseButton, 32)
	VoiceChatChannelActivatedNotification.CloseButton:SetPoint("TOPRIGHT", 4, 4)
end)
