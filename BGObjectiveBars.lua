--[[
	BGObjectiveBars
	Battleground objective "bars" (flag captures / team points shown as bars)
	Ported from the PandaWoW custom WorldStateFrame patch.
	Left bar = Alliance, Right bar = Horde.

	Works on any MoP 5.4.x client. Uses only the standard 5.4 API + the stock
	"objectivewidget" texture atlases (fallback to solid colors if absent).
]]

local ADDON = ...
local addon = CreateFrame("Frame", ADDON)

local MAX_FILL_WIDTH = 90
local NUM_POI = 5

-- Battleground map area IDs (MoP)
local BATTLEGROUND_WARSONG_GULCH     = 443
local BATTLEGROUND_ARATHI_BASIN      = 461
local BATTLEGROUND_EYE_OF_THE_STORM  = 482
local BATTLEGROUND_TWIN_PEAKS        = 626
local BATTLEGROUND_BATTLE_FOR_GILNEAS = 736
local BATTLEGROUND_TEMPLE_OF_KOTMOGU = 856
local BATTLEGROUND_SILVER_SHARD_MINES = 860
local BATTLEGROUND_DEEPWIND_GORGE    = 935
local BATTLEGROUND_ALTERAC_VALLEY    = 401
local BATTLEGROUND_ISLE_OF_CONQUEST  = 540
local BATTLEGROUND_SEETHING_SHORE    = 1010
local BATTLEGROUND_WINDVALE_MARKET   = 1012

-----------------------------------------------------------------
-----------------------------------------------------------------
-- Bundled texture atlas (coordinates dumped from PandaWoW 5.4.8)
-----------------------------------------------------------------
local TEXTURE_DIR = "Interface\\AddOns\\BGObjectiveBars\\textures\\"

local ATLAS = {
	["bfg_capPts-leftIcon1-state1"] = { file = "pvpcapturewidgeticons", l = 0.150390625, r = 0.220703125, t = 0.658203125, b = 0.7265625, w = 18, h = 17, tilesH = false },
	["custombg-orb-blue-right"] = { file = "pvpcapturewidgeticons", l = 0.595703125, r = 0.666015625, t = 0.150390625, b = 0.220703125, w = 28, h = 28, tilesH = false },
	["objectivewidget-bar-background"] = { file = "objectivewidget", l = 0.00390625, r = 0.7890625, t = 0.41796875, b = 0.50390625, w = 201, h = 22, tilesH = false },
	["bfg_capPts-leftIcon2-state1"] = { file = "pvpcapturewidgeticons", l = 0.498046875, r = 0.568359375, t = 0.361328125, b = 0.416015625, w = 18, h = 14, tilesH = false },
	["bfg_capPts-leftIcon2-state2"] = { file = "pvpcapturewidgeticons", l = 0.572265625, r = 0.642578125, t = 0.361328125, b = 0.416015625, w = 18, h = 14, tilesH = false },
	["objectivewidget-bar-spark-left"] = { file = "objectivewidget", l = 0.14453125, r = 0.20703125, t = 0.51171875, b = 0.6640625, w = 16, h = 39, tilesH = false },
	["eots_capPts-rightIcon2-state2"] = { file = "pvpcapturewidgeticons", l = 0.076171875, r = 0.146484375, t = 0.818359375, b = 0.888671875, w = 18, h = 18, tilesH = false },
	["ab_capPts-leftIcon4-state2"] = { file = "pvpcapturewidgeticons", l = 0.892578125, r = 0.962890625, t = 0.150390625, b = 0.21875, w = 18, h = 17, tilesH = false },
	["bfg_capPts-rightIcon3-state1"] = { file = "pvpcapturewidgeticons", l = 0.150390625, r = 0.220703125, t = 0.802734375, b = 0.87109375, w = 18, h = 17, tilesH = false },
	["bfg_capPts-leftIcon1-state2"] = { file = "pvpcapturewidgeticons", l = 0.150390625, r = 0.220703125, t = 0.73046875, b = 0.798828125, w = 18, h = 17, tilesH = false },
	["eots_capPts-leftIcon1-state1"] = { file = "pvpcapturewidgeticons", l = 0.296875, r = 0.365234375, t = 0.296875, b = 0.3671875, w = 17, h = 18, tilesH = false },
	["ab_capPts-leftIcon3-state1"] = { file = "pvpcapturewidgeticons", l = 0.658203125, r = 0.728515625, t = 0.296875, b = 0.3515625, w = 18, h = 14, tilesH = false },
	["bfg_capPts-leftIcon3-state1"] = { file = "pvpcapturewidgeticons", l = 0.298828125, r = 0.369140625, t = 0.001953125, b = 0.072265625, w = 18, h = 18, tilesH = false },
	["objectivewidget-icon-left"] = { file = "objectivewidget", l = 0.00390625, r = 0.13671875, t = 0.51171875, b = 0.671875, w = 34, h = 41, tilesH = false },
	["ab_capPts-rightIcon4-state1"] = { file = "pvpcapturewidgeticons", l = 0.7421875, r = 0.8125, t = 0.224609375, b = 0.2890625, w = 18, h = 16, tilesH = false },
	["bfg_capPts-leftIcon3-state2"] = { file = "pvpcapturewidgeticons", l = 0.373046875, r = 0.443359375, t = 0.001953125, b = 0.072265625, w = 18, h = 18, tilesH = false },
	["dg_capPts-rightIcon2-state2"] = { file = "pvpcapturewidgeticons", l = 0.892578125, r = 0.962890625, t = 0.076171875, b = 0.146484375, w = 18, h = 18, tilesH = false },
	["bfg_capPts-rightIcon1-state2"] = { file = "pvpcapturewidgeticons", l = 0.521484375, r = 0.591796875, t = 0.001953125, b = 0.072265625, w = 18, h = 18, tilesH = false },
	["dg_capPts-rightIcon5-state2"] = { file = "pvpcapturewidgeticons", l = 0.51953125, r = 0.58984375, t = 0.224609375, b = 0.29296875, w = 18, h = 17, tilesH = false },
	["dg_capPts-leftIcon2-state2"] = { file = "pvpcapturewidgeticons", l = 0.521484375, r = 0.591796875, t = 0.076171875, b = 0.146484375, w = 18, h = 18, tilesH = false },
	["custombg-flag-blue"] = { file = "custombgicons", l = 0.015625, r = 0.140625, t = 0.328125, b = 0.453125, w = 32, h = 32, tilesH = false },
	["ab_capPts-leftIcon4-state1"] = { file = "pvpcapturewidgeticons", l = 0.818359375, r = 0.888671875, t = 0.150390625, b = 0.21875, w = 18, h = 17, tilesH = false },
	["ab_capPts-leftIcon2-state1"] = { file = "pvpcapturewidgeticons", l = 0.59375, r = 0.6640625, t = 0.224609375, b = 0.2890625, w = 18, h = 16, tilesH = false },
	["objectivewidget-bar-spark-right"] = { file = "objectivewidget", l = 0.14453125, r = 0.20703125, t = 0.83203125, b = 0.984375, w = 16, h = 39, tilesH = false },
	["dg_capPts-leftIcon1-state1"] = { file = "pvpcapturewidgeticons", l = 0.296875, r = 0.3671875, t = 0.224609375, b = 0.29296875, w = 18, h = 17, tilesH = false },
	["bfg_capPts-rightIcon2-state1"] = { file = "pvpcapturewidgeticons", l = 0.646484375, r = 0.716796875, t = 0.361328125, b = 0.416015625, w = 18, h = 14, tilesH = false },
	["objectivewidget-bar-border-middle"] = { file = "objectivewidget", l = 0.00390625, r = 0.7421875, t = 0.28515625, b = 0.41015625, w = 189, h = 32, tilesH = false },
	["dg_capPts-rightIcon4-state1"] = { file = "pvpcapturewidgeticons", l = 0.076171875, r = 0.146484375, t = 0.150390625, b = 0.220703125, w = 18, h = 18, tilesH = false },
	["ab_capPts-rightIcon2-state2"] = { file = "pvpcapturewidgeticons", l = 0.150390625, r = 0.220703125, t = 0.5859375, b = 0.654296875, w = 18, h = 17, tilesH = false },
	["eots_capPts-rightIcon3-state2"] = { file = "pvpcapturewidgeticons", l = 0.369140625, r = 0.431640625, t = 0.4453125, b = 0.515625, w = 16, h = 18, tilesH = false },
	["dg_capPts-rightIcon5-state1"] = { file = "pvpcapturewidgeticons", l = 0.4453125, r = 0.515625, t = 0.224609375, b = 0.29296875, w = 18, h = 17, tilesH = false },
	["custombg-orb-orange-left"] = { file = "pvpcapturewidgeticons", l = 0.447265625, r = 0.517578125, t = 0.150390625, b = 0.220703125, w = 28, h = 28, tilesH = false },
	["dg_capPts-leftIcon2-state1"] = { file = "pvpcapturewidgeticons", l = 0.447265625, r = 0.517578125, t = 0.076171875, b = 0.146484375, w = 18, h = 18, tilesH = false },
	["dg_capPts-leftIcon4-state1"] = { file = "pvpcapturewidgeticons", l = 0.595703125, r = 0.666015625, t = 0.076171875, b = 0.146484375, w = 18, h = 18, tilesH = false },
	["eots_capPts-leftIcon5-state2"] = { file = "pvpcapturewidgeticons", l = 0.076171875, r = 0.146484375, t = 0.521484375, b = 0.591796875, w = 18, h = 18, tilesH = false },
	["custombg-orb-purple-left"] = { file = "pvpcapturewidgeticons", l = 0.298828125, r = 0.369140625, t = 0.150390625, b = 0.220703125, w = 28, h = 28, tilesH = false },
	["eots_capPts-leftIcon2-state2"] = { file = "pvpcapturewidgeticons", l = 0.296875, r = 0.361328125, t = 0.51953125, b = 0.58984375, w = 16, h = 18, tilesH = false },
	["ab_capPts-leftIcon5-state2"] = { file = "pvpcapturewidgeticons", l = 0.150390625, r = 0.220703125, t = 0.296875, b = 0.365234375, w = 18, h = 17, tilesH = false },
	["ab_capPts-rightIcon2-state1"] = { file = "pvpcapturewidgeticons", l = 0.150390625, r = 0.220703125, t = 0.513671875, b = 0.58203125, w = 18, h = 17, tilesH = false },
	["ab_capPts-leftIcon1-state1"] = { file = "pvpcapturewidgeticons", l = 0.001953125, r = 0.072265625, t = 0.001953125, b = 0.072265625, w = 18, h = 18, tilesH = false },
	["custombg-orb-green-left"] = { file = "pvpcapturewidgeticons", l = 0.224609375, r = 0.294921875, t = 0.150390625, b = 0.220703125, w = 28, h = 28, tilesH = false },
	["dg_capPts-rightIcon1-state2"] = { file = "pvpcapturewidgeticons", l = 0.583984375, r = 0.654296875, t = 0.296875, b = 0.357421875, w = 18, h = 15, tilesH = false },
	["windvale-market-horde-assaulted"] = { file = "custombgicons", l = 0.1640625, r = 0.3046875, t = 0.1640625, b = 0.3046875, w = 18, h = 18, tilesH = false },
	["windvale-market-horde"] = { file = "custombgicons", l = 0.3203125, r = 0.4609375, t = 0.1640625, b = 0.3046875, w = 18, h = 18, tilesH = false },
	["windvale-market-alliance-assaulted"] = { file = "custombgicons", l = 0.7890625, r = 0.9296875, t = 0.0078125, b = 0.1484375, w = 18, h = 18, tilesH = false },
	["windvale-market-alliance"] = { file = "custombgicons", l = 0.0078125, r = 0.1484375, t = 0.1640625, b = 0.3046875, w = 18, h = 18, tilesH = false },
	["ab_capPts-leftIcon5-state1"] = { file = "pvpcapturewidgeticons", l = 0.150390625, r = 0.220703125, t = 0.224609375, b = 0.29296875, w = 18, h = 17, tilesH = false },
	["sm_carts-rightIcon3-state1"] = { file = "pvpcapturewidgeticons", l = 0.435546875, r = 0.494140625, t = 0.361328125, b = 0.431640625, w = 21, h = 25, tilesH = false },
	["dg_capPts-rightIcon1-state1"] = { file = "pvpcapturewidgeticons", l = 0.509765625, r = 0.580078125, t = 0.296875, b = 0.357421875, w = 18, h = 15, tilesH = false },
	["sm_carts-rightIcon2-state1"] = { file = "pvpcapturewidgeticons", l = 0.369140625, r = 0.427734375, t = 0.890625, b = 0.9609375, w = 21, h = 25, tilesH = false },
	["sm_carts-rightIcon1-state1"] = { file = "pvpcapturewidgeticons", l = 0.369140625, r = 0.427734375, t = 0.81640625, b = 0.88671875, w = 21, h = 25, tilesH = false },
	["sm_carts-leftIcon3-state1"] = { file = "pvpcapturewidgeticons", l = 0.369140625, r = 0.427734375, t = 0.7421875, b = 0.8125, w = 21, h = 25, tilesH = false },
	["ab_capPts-rightIcon3-state1"] = { file = "pvpcapturewidgeticons", l = 0.806640625, r = 0.876953125, t = 0.296875, b = 0.3515625, w = 18, h = 14, tilesH = false },
	["dg_capPts-rightIcon4-state2"] = { file = "pvpcapturewidgeticons", l = 0.076171875, r = 0.146484375, t = 0.224609375, b = 0.294921875, w = 18, h = 18, tilesH = false },
	["objectivewidget-bar-fill-left"] = { file = "objectivewidget", l = 0, r = 0.00390625, t = 0.00390625, b = 0.08984375, w = 1, h = 22, tilesH = true },
	["eots_capPts-leftIcon4-state2"] = { file = "pvpcapturewidgeticons", l = 0.296875, r = 0.359375, t = 0.890625, b = 0.9609375, w = 16, h = 18, tilesH = false },
	["sm_carts-leftIcon2-state1"] = { file = "pvpcapturewidgeticons", l = 0.369140625, r = 0.427734375, t = 0.66796875, b = 0.73828125, w = 21, h = 25, tilesH = false },
	["sm_carts-leftIcon1-state1"] = { file = "pvpcapturewidgeticons", l = 0.369140625, r = 0.427734375, t = 0.59375, b = 0.6640625, w = 21, h = 25, tilesH = false },
	["dg_capPts-rightIcon2-state1"] = { file = "pvpcapturewidgeticons", l = 0.818359375, r = 0.888671875, t = 0.076171875, b = 0.146484375, w = 18, h = 18, tilesH = false },
	["objectivewidget-bar-border-right"] = { file = "objectivewidget", l = 0.796875, r = 0.8359375, t = 0.28515625, b = 0.41015625, w = 10, h = 32, tilesH = false },
	["dg_capPts-leftIcon4-state2"] = { file = "pvpcapturewidgeticons", l = 0.669921875, r = 0.740234375, t = 0.076171875, b = 0.146484375, w = 18, h = 18, tilesH = false },
	["objectivewidget-bar-fill-right"] = { file = "objectivewidget", l = 0, r = 0.00390625, t = 0.19140625, b = 0.27734375, w = 1, h = 22, tilesH = true },
	["objectivewidget-icon-right"] = { file = "objectivewidget", l = 0.00390625, r = 0.13671875, t = 0.6796875, b = 0.83984375, w = 34, h = 41, tilesH = false },
	["custombg-orb-purple-right"] = { file = "pvpcapturewidgeticons", l = 0.669921875, r = 0.740234375, t = 0.150390625, b = 0.220703125, w = 28, h = 28, tilesH = false },
	["objectivewidget-bar-border-left"] = { file = "objectivewidget", l = 0.75, r = 0.7890625, t = 0.28515625, b = 0.41015625, w = 10, h = 32, tilesH = false },
	["eots_capPts-rightIcon4-state2"] = { file = "pvpcapturewidgeticons", l = 0.150390625, r = 0.220703125, t = 0.150390625, b = 0.220703125, w = 18, h = 18, tilesH = false },
	["custombg-orb-orange-right"] = { file = "pvpcapturewidgeticons", l = 0.521484375, r = 0.591796875, t = 0.150390625, b = 0.220703125, w = 28, h = 28, tilesH = false },
	["eots_capPts-rightIcon5-state2"] = { file = "pvpcapturewidgeticons", l = 0.296875, r = 0.361328125, t = 0.7421875, b = 0.8125, w = 16, h = 18, tilesH = false },
	["bfg_capPts-rightIcon2-state2"] = { file = "pvpcapturewidgeticons", l = 0.720703125, r = 0.791015625, t = 0.361328125, b = 0.416015625, w = 18, h = 14, tilesH = false },
	["dg_capPts-leftIcon1-state2"] = { file = "pvpcapturewidgeticons", l = 0.37109375, r = 0.44140625, t = 0.224609375, b = 0.29296875, w = 18, h = 17, tilesH = false },
	["ab_capPts-leftIcon3-state2"] = { file = "pvpcapturewidgeticons", l = 0.732421875, r = 0.802734375, t = 0.296875, b = 0.3515625, w = 18, h = 14, tilesH = false },
	["eots_capPts-rightIcon1-state1"] = { file = "pvpcapturewidgeticons", l = 0.296875, r = 0.365234375, t = 0.37109375, b = 0.44140625, w = 17, h = 18, tilesH = false },
	["eots_capPts-leftIcon3-state2"] = { file = "pvpcapturewidgeticons", l = 0.076171875, r = 0.146484375, t = 0.373046875, b = 0.443359375, w = 18, h = 18, tilesH = false },
	["ab_capPts-rightIcon4-state2"] = { file = "pvpcapturewidgeticons", l = 0.81640625, r = 0.88671875, t = 0.224609375, b = 0.2890625, w = 18, h = 16, tilesH = false },
	["ab_capPts-leftIcon1-state2"] = { file = "pvpcapturewidgeticons", l = 0.076171875, r = 0.146484375, t = 0.001953125, b = 0.072265625, w = 18, h = 18, tilesH = false },
	["custombg-flag-red"] = { file = "custombgicons", l = 0.796875, r = 0.921875, t = 0.171875, b = 0.296875, w = 32, h = 32, tilesH = false },
	["ab_capPts-rightIcon5-state2"] = { file = "pvpcapturewidgeticons", l = 0.224609375, r = 0.294921875, t = 0.001953125, b = 0.072265625, w = 18, h = 18, tilesH = false },
	["ab_capPts-leftIcon2-state2"] = { file = "pvpcapturewidgeticons", l = 0.66796875, r = 0.73828125, t = 0.224609375, b = 0.2890625, w = 18, h = 16, tilesH = false },
	["ab_capPts-rightIcon5-state1"] = { file = "pvpcapturewidgeticons", l = 0.150390625, r = 0.220703125, t = 0.001953125, b = 0.072265625, w = 18, h = 18, tilesH = false },
	["custombg-orb-blue-left"] = { file = "pvpcapturewidgeticons", l = 0.373046875, r = 0.443359375, t = 0.150390625, b = 0.220703125, w = 28, h = 28, tilesH = false },
	["bfg_capPts-rightIcon1-state1"] = { file = "pvpcapturewidgeticons", l = 0.447265625, r = 0.517578125, t = 0.001953125, b = 0.072265625, w = 18, h = 18, tilesH = false },
	["ab_capPts-rightIcon1-state2"] = { file = "pvpcapturewidgeticons", l = 0.150390625, r = 0.220703125, t = 0.44140625, b = 0.509765625, w = 18, h = 17, tilesH = false },
	["ab_capPts-rightIcon3-state2"] = { file = "pvpcapturewidgeticons", l = 0.880859375, r = 0.951171875, t = 0.296875, b = 0.3515625, w = 18, h = 14, tilesH = false },
	["bfg_capPts-rightIcon3-state2"] = { file = "pvpcapturewidgeticons", l = 0.150390625, r = 0.220703125, t = 0.875, b = 0.943359375, w = 18, h = 17, tilesH = false },
	["ab_capPts-rightIcon1-state1"] = { file = "pvpcapturewidgeticons", l = 0.150390625, r = 0.220703125, t = 0.369140625, b = 0.4375, w = 18, h = 17, tilesH = false },
	["dg_capPts-leftIcon5-state2"] = { file = "pvpcapturewidgeticons", l = 0.435546875, r = 0.505859375, t = 0.296875, b = 0.357421875, w = 18, h = 15, tilesH = false },
	["custombg-orb-green-right"] = { file = "pvpcapturewidgeticons", l = 0.744140625, r = 0.814453125, t = 0.150390625, b = 0.220703125, w = 28, h = 28, tilesH = false },
	["dg_capPts-leftIcon5-state1"] = { file = "pvpcapturewidgeticons", l = 0.890625, r = 0.9609375, t = 0.224609375, b = 0.28515625, w = 18, h = 15, tilesH = false },
}

local function SetBundledTexture(tex, name, r, g, b)
	local info = ATLAS[name]
	if info then
		tex:SetTexture(TEXTURE_DIR .. info.file .. ".blp")
		tex:SetTexCoord(info.l, info.r, info.t, info.b)
		if info.tilesH then
			tex:SetHorizTile(true)
		end
		return true
	elseif r then
		tex:SetColorTexture(r, g, b)
	end
	return false
end

-- Reads a raw worldstate value. PandaWoW uses a custom C_PandaWoWAPI.GetWorldState;
-- on a standard client we fall back to GetWorldState / GetWorldStateInfo, else nil.
local function GetWorldStateValue(worldStateId)
	local ok, value = pcall(function()
		if C_PandaWoWAPI and C_PandaWoWAPI.GetWorldState then
			return C_PandaWoWAPI.GetWorldState(worldStateId)
		elseif GetWorldState then
			return GetWorldState(worldStateId)
		elseif GetWorldStateInfo then
			return (GetWorldStateInfo(worldStateId))
		end
	end)
	return ok and value or nil
end

-----------------------------------------------------------------
-- Bar widget (mirrors WorldStateTopCenterFrame_StatusBarTemplate)
-----------------------------------------------------------------
local function Bar_SetValue(self, value, formattedText)
	if formattedText then
		self.SubLayer.Label:SetText(formattedText)
	else
		self.SubLayer.Label:SetFormattedText("%d/%d", value, self.maxValue or 0)
	end

	self.BarFillTexture:SetShown(value > 0)
	self.SubLayer.Spark:SetShown(value > 0 and value < self.maxValue)

	self.value = value
	self:UpdateBarWidth()
end

local function Bar_SetMinMaxValues(self, minValue, maxValue, formattedText)
	self.minValue = minValue
	self.maxValue = maxValue
	self:SetValue(minValue, formattedText)
end

local function Bar_GetMinMaxValues(self)
	return self.minValue, self.maxValue
end

local function Bar_UpdateBarWidth(self)
	if not self.maxValue or self.maxValue == 0 then
		self.BarFillTexture:SetWidth(0)
		return
	end
	local width = math.min((self.value / self.maxValue) * MAX_FILL_WIDTH, MAX_FILL_WIDTH)
	self.BarFillTexture:SetWidth(width)
end

local function Bar_Reset(self)
	self.minValue = nil
	self.maxValue = nil
	self.value = nil
	self.BarFillTexture:SetWidth(0)
	self.BarFillTexture:Hide()
	self.SubLayer.Spark:Hide()
	for i = 1, NUM_POI do
		self.POIButtons[i]:Hide()
	end
end

local function POIButton_OnEnter(self)
	if self.name and self.description then
		GameTooltip:SetOwner(self, (self:GetParent():GetParent().id == 1) and "ANCHOR_BOTTOMLEFT" or "ANCHOR_BOTTOMRIGHT")
		GameTooltip:SetText(self.name)
		GameTooltip:AddLine(self.description, 1, 1, 1, true)
		GameTooltip:Show()
	end
end

local function CreatePOIButton(bar, index)
	local button = CreateFrame("Button", nil, bar.Container)
	button:SetSize(24, 24)
	button:SetPoint("CENTER", 0, 0)

	button.Icon = button:CreateTexture(nil, "BORDER")
	button.Icon:SetAllPoints(button)

	button.name = nil
	button.description = nil
	button:SetScript("OnEnter", POIButton_OnEnter)
	button:SetScript("OnLeave", function() GameTooltip_Hide() end)
	button:Hide()

	return button
end

local function CreateBar(parent, id)
	local bar = CreateFrame("Frame", nil, parent)
	bar:SetSize(92, 22)
	bar.id = id

	local barSide = (id == 1) and "left" or "right"

	-- background
	bar.BG = bar:CreateTexture(nil, "BACKGROUND")
	bar.BG:SetAllPoints(bar)
	SetBundledTexture(bar.BG, "objectivewidget-bar-background", 0, 0, 0)

	-- fill
	bar.BarFillTexture = bar:CreateTexture(nil, "BORDER")
	bar.BarFillTexture:SetSize(1, 22)
	SetBundledTexture(bar.BarFillTexture, "objectivewidget-bar-fill-" .. barSide, (id == 1) and 0.90 or 0.95, 0.15, 0.15)
	bar.BarFillTexture:SetPoint("CENTER", 0, 0)
	bar.BarFillTexture:Hide()

	-- borders
	bar.BorderLeft = bar:CreateTexture(nil, "OVERLAY")
	bar.BorderLeft:SetSize(10, 32)
	bar.BorderLeft:SetPoint("LEFT", bar, "LEFT", -4, 0)
	SetBundledTexture(bar.BorderLeft, "objectivewidget-bar-border-left")

	bar.BorderRight = bar:CreateTexture(nil, "OVERLAY")
	bar.BorderRight:SetSize(10, 32)
	bar.BorderRight:SetPoint("RIGHT", bar, "RIGHT", 4, 0)
	SetBundledTexture(bar.BorderRight, "objectivewidget-bar-border-right")

	bar.BorderCenter = bar:CreateTexture(nil, "OVERLAY")
	bar.BorderCenter:SetPoint("TOPLEFT", bar.BorderLeft, "TOPRIGHT", 0, 0)
	bar.BorderCenter:SetPoint("BOTTOMRIGHT", bar.BorderRight, "BOTTOMLEFT", 0, 0)
	SetBundledTexture(bar.BorderCenter, "objectivewidget-bar-border-middle")

	-- sub layer (spark / icon / label)
	bar.SubLayer = CreateFrame("Frame", nil, bar)
	bar.SubLayer:SetAllPoints(bar)

	bar.SubLayer.Spark = bar.SubLayer:CreateTexture(nil, "BACKGROUND")
	bar.SubLayer.Spark:SetSize(16, 39)
	bar.SubLayer.Spark:SetBlendMode("ADD")
	SetBundledTexture(bar.SubLayer.Spark, "objectivewidget-bar-spark-" .. barSide)
	bar.SubLayer.Spark:Hide()

	bar.SubLayer.Icon = bar.SubLayer:CreateTexture(nil, "BORDER")
	bar.SubLayer.Icon:SetSize(34, 41)
	SetBundledTexture(bar.SubLayer.Icon, "objectivewidget-icon-" .. barSide)

	bar.SubLayer.Label = bar.SubLayer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	bar.SubLayer.Label:SetPoint("CENTER", 0, 0)

	if id == 1 then
		bar.SubLayer.Icon:ClearAllPoints()
		bar.BarFillTexture:ClearAllPoints()
		bar.SubLayer.Spark:ClearAllPoints()
		bar.SubLayer.Icon:SetPoint("RIGHT", bar, "LEFT", 4, 0)
		bar.BarFillTexture:SetPoint("LEFT", bar, "LEFT", 1, 0)
		bar.SubLayer.Spark:SetPoint("LEFT", bar.BarFillTexture, "RIGHT", -7, 0)
	else
		bar.SubLayer.Icon:ClearAllPoints()
		bar.BarFillTexture:ClearAllPoints()
		bar.SubLayer.Icon:SetPoint("LEFT", bar, "RIGHT", -8, 0)
		bar.BarFillTexture:SetPoint("RIGHT", bar, "RIGHT", -1, 0)
		bar.SubLayer.Spark:SetPoint("RIGHT", bar.BarFillTexture, "LEFT", 7, 0)
	end

	-- POI button container
	bar.Container = CreateFrame("Frame", nil, bar)
	bar.Container:SetSize(90, 18)
	bar.Container:SetPoint("TOP", bar, "BOTTOM", 0, -8)

	bar.POIButtons = {}
	for i = 1, NUM_POI do
		local button = CreatePOIButton(bar, i)
		if id == 1 then
			if i == 1 then
				button:SetPoint("RIGHT", bar.Container, "RIGHT", 0, 0)
			else
				button:SetPoint("RIGHT", bar.POIButtons[i - 1], "LEFT", -2, 0)
			end
		else
			if i == 1 then
				button:SetPoint("LEFT", bar.Container, "LEFT", 0, 0)
			else
				button:SetPoint("LEFT", bar.POIButtons[i - 1], "RIGHT", 2, 0)
			end
		end
		bar.POIButtons[i] = button
	end

	bar.SetValue = Bar_SetValue
	bar.SetMinMaxValues = Bar_SetMinMaxValues
	bar.GetMinMaxValues = Bar_GetMinMaxValues
	bar.UpdateBarWidth = Bar_UpdateBarWidth
	bar.Reset = Bar_Reset

	return bar
end

-----------------------------------------------------------------
-- Main frame
-----------------------------------------------------------------
local bars = {}

local UpdateState -- forward declaration (defined after CreateMainFrame)

local function FixWorldStateHeight()
	local timerShown = bars.TimeLeft and bars.TimeLeft:IsShown()
	bars.frame:SetPoint("TOP", UIParent, "TOP", 0, timerShown and -30 or -15)
end

local function CreateMainFrame()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(232, 55)
	frame:SetPoint("TOP", UIParent, "TOP", 0, -15)
	frame:Hide()
	frame.BattlegroundPOIData = {}

	bars.frame = frame

	-- Left bar = Alliance (id 1), Right bar = Horde (id 2)
	bars.left = CreateBar(frame, 1)
	bars.right = CreateBar(frame, 2)

	bars.left:SetPoint("TOPRIGHT", frame, "TOP", -7, -5)
	bars.right:SetPoint("TOPLEFT", frame, "TOP", 7, -5)

	-- timer label (CTF)
	bars.TimeLeft = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	bars.TimeLeft:SetPoint("BOTTOM", frame, "TOP", 0, 6)
	bars.TimeLeft:Hide()

	frame:SetScript("OnShow", function()
		UpdateState()
	end)
	frame:SetScript("OnHide", function()
		bars.left:Reset()
		bars.right:Reset()
		bars.TimeLeft:SetText("")
		bars.TimeLeft:Hide()
	end)

	return frame
end

-----------------------------------------------------------------
-- Flag / resource -> bar logic (mirrors the PandaWoW patch inside
-- WorldStateAlwaysUpFrame_Update)
-----------------------------------------------------------------
local function UpdateBarInfo(statusBar, currentValue, maxValue, formattedText)
	local _, max = statusBar:GetMinMaxValues()
	currentValue = tonumber(currentValue)
	maxValue = tonumber(maxValue)

	if not max then
		statusBar:SetMinMaxValues(0, maxValue)
	elseif currentValue > max then
		statusBar:SetMinMaxValues(currentValue, currentValue, formattedText)
	end

	statusBar:SetValue(currentValue, formattedText)
end

local function UpdateObjective()
	local frame = bars.frame
	local mapID = GetCurrentMapAreaID()
	local numUI = GetNumWorldStateUI()

	local isShownWidgetWorldState = false

	-- keep the CTF flag POI entries (stored under negative ids), wipe the rest
	for i in pairs(frame.BattlegroundPOIData) do
		if i > 0 then
			frame.BattlegroundPOIData[i] = nil
		end
	end

	for i = 1, numUI do
		local uiType, state, hidden, text, icon, dynamicIcon, tooltip, dynamicTooltip, extendedUI =
			GetWorldStateUIInfo(i)

		if not hidden and state > 0 and extendedUI == "" then
			local statusBar
			if icon and string.find(icon, "Alliance") then
				statusBar = bars.left
			elseif icon and string.find(icon, "Horde") then
				statusBar = bars.right
			end

			if statusBar then
				if mapID == BATTLEGROUND_WARSONG_GULCH or mapID == BATTLEGROUND_TWIN_PEAKS then
					local flagCountCurrent, flagCountMax = string.match(text, "(%d+)/(%d+)")

					if flagCountCurrent and flagCountMax then
						local barID = -statusBar.id

						if state == 2 then
							if dynamicIcon == "Interface\\WorldStateFrame\\AllianceFlag" then
								frame.BattlegroundPOIData[barID] = { "Horde", "custombg-flag-blue", dynamicTooltip, "" }
							else
								frame.BattlegroundPOIData[barID] = { "Alliance", "custombg-flag-red", dynamicTooltip, "" }
							end
						else
							frame.BattlegroundPOIData[barID] = nil
						end

						UpdateBarInfo(statusBar, flagCountCurrent, flagCountMax)
						isShownWidgetWorldState = true
					end
				elseif mapID == BATTLEGROUND_ARATHI_BASIN or
					mapID == BATTLEGROUND_BATTLE_FOR_GILNEAS or
					mapID == BATTLEGROUND_EYE_OF_THE_STORM or
					mapID == BATTLEGROUND_DEEPWIND_GORGE or
					mapID == BATTLEGROUND_WINDVALE_MARKET then

					local resourceCurrent, resourceMax = string.match(text, ".-%: %d .-%: (%d+)/(%d+)")

					if resourceCurrent and resourceMax then
						UpdateBarInfo(statusBar, resourceCurrent, resourceMax)
						isShownWidgetWorldState = true
					end
				elseif mapID == BATTLEGROUND_ALTERAC_VALLEY then
					local resourceCurrent = string.match(text, "(%d+)$")
					if resourceCurrent then
						UpdateBarInfo(statusBar, resourceCurrent, 500, resourceCurrent)
						isShownWidgetWorldState = true
					end
				elseif mapID == BATTLEGROUND_ISLE_OF_CONQUEST then
					local resourceCurrent = string.match(text, "(%d+)$")
					if resourceCurrent then
						UpdateBarInfo(statusBar, resourceCurrent, 300, resourceCurrent)
						isShownWidgetWorldState = true
					end
				elseif mapID == BATTLEGROUND_TEMPLE_OF_KOTMOGU or
					mapID == BATTLEGROUND_SILVER_SHARD_MINES or
					mapID == BATTLEGROUND_SEETHING_SHORE then

					local resourceCurrent, resourceMax = string.match(text, ".-%:? (%d+)/(%d+)")
					if resourceCurrent and resourceMax then
						UpdateBarInfo(statusBar, resourceCurrent, resourceMax)
						isShownWidgetWorldState = true
					end
				end
			end
		end
	end

	-- timer text for CTF (first worldstate UI entry when icon is empty)
	if (mapID == BATTLEGROUND_WARSONG_GULCH or mapID == BATTLEGROUND_TWIN_PEAKS) and numUI > 0 then
		local _, state, _, text, icon = GetWorldStateUIInfo(1)
		if icon == "" and state == 1 and text ~= "" then
			bars.TimeLeft:SetText(text)
			bars.TimeLeft:Show()
		else
			bars.TimeLeft:SetText("")
			bars.TimeLeft:Hide()
		end
	else
		bars.TimeLeft:SetText("")
		bars.TimeLeft:Hide()
	end

	FixWorldStateHeight()

	frame:SetShown(isShownWidgetWorldState)
end

-----------------------------------------------------------------
-- POI button update (flags / orbs / carts / landmarks)
-----------------------------------------------------------------
local BattlegroundPOITextureIdxToAtlas = {
	[BATTLEGROUND_ARATHI_BASIN] = {
		Alliance = {
			[1632] = "ab_capPts-leftIcon1-state1", [1630] = "ab_capPts-leftIcon1-state2",
			[1622] = "ab_capPts-leftIcon2-state1", [1620] = "ab_capPts-leftIcon2-state2",
			[1617] = "ab_capPts-leftIcon3-state1", [1615] = "ab_capPts-leftIcon3-state2",
			[1627] = "ab_capPts-leftIcon4-state1", [1625] = "ab_capPts-leftIcon4-state2",
			[1612] = "ab_capPts-leftIcon5-state1", [1610] = "ab_capPts-leftIcon5-state2",
		},
		Horde = {
			[1613] = "ab_capPts-rightIcon1-state1", [1611] = "ab_capPts-rightIcon1-state2",
			[1628] = "ab_capPts-rightIcon2-state1", [1626] = "ab_capPts-rightIcon2-state2",
			[1618] = "ab_capPts-rightIcon3-state1", [1616] = "ab_capPts-rightIcon3-state2",
			[1623] = "ab_capPts-rightIcon4-state1", [1621] = "ab_capPts-rightIcon4-state2",
			[1633] = "ab_capPts-rightIcon5-state1", [1631] = "ab_capPts-rightIcon5-state2",
		},
	},
	[BATTLEGROUND_BATTLE_FOR_GILNEAS] = {
		Alliance = {
			[2403] = "bfg_capPts-leftIcon1-state1", [2401] = "bfg_capPts-leftIcon1-state2",
			[2407] = "bfg_capPts-leftIcon2-state1", [2408] = "bfg_capPts-leftIcon2-state2",
			[2410] = "bfg_capPts-leftIcon3-state1", [2414] = "bfg_capPts-leftIcon3-state2",
		},
		Horde = {
			[2411] = "bfg_capPts-rightIcon1-state1", [2413] = "bfg_capPts-rightIcon1-state2",
			[2406] = "bfg_capPts-rightIcon2-state1", [2409] = "bfg_capPts-rightIcon2-state2",
			[2400] = "bfg_capPts-rightIcon3-state1", [2402] = "bfg_capPts-rightIcon3-state2",
		},
	},
	[BATTLEGROUND_EYE_OF_THE_STORM] = {
		Alliance = {
			[1948] = "eots_capPts-leftIcon5-state2", [1945] = "eots_capPts-leftIcon3-state2",
			[1942] = "eots_capPts-leftIcon2-state2", [1951] = "eots_capPts-leftIcon4-state2",
		},
		Horde = {
			[1949] = "eots_capPts-rightIcon2-state2", [1946] = "eots_capPts-rightIcon4-state2",
			[1943] = "eots_capPts-rightIcon5-state2", [1952] = "eots_capPts-rightIcon3-state2",
		},
	},
	[BATTLEGROUND_DEEPWIND_GORGE] = {
		Alliance = {
			[2973] = "bfg_capPts-leftIcon1-state1", [2975] = "bfg_capPts-leftIcon1-state2",
			[2969] = "bfg_capPts-leftIcon1-state1", [2971] = "bfg_capPts-leftIcon1-state2",
			[2960] = "bfg_capPts-leftIcon1-state1", [2962] = "bfg_capPts-leftIcon1-state2",
		},
		Horde = {
			[2972] = "bfg_capPts-rightIcon3-state1", [2974] = "bfg_capPts-rightIcon3-state2",
			[2967] = "bfg_capPts-rightIcon3-state1", [2970] = "bfg_capPts-rightIcon3-state2",
			[2961] = "bfg_capPts-rightIcon3-state1", [2963] = "bfg_capPts-rightIcon3-state2",
		},
	},
	[BATTLEGROUND_WINDVALE_MARKET] = {
		Alliance = {
			[9007] = "dg_capPts-leftIcon1-state1", [9009] = "dg_capPts-leftIcon1-state2",
			[9012] = "dg_capPts-leftIcon2-state1", [9014] = "dg_capPts-leftIcon2-state2",
			[9002] = "windvale-market-alliance-assaulted", [9004] = "windvale-market-alliance",
			[9017] = "dg_capPts-leftIcon4-state1", [9019] = "dg_capPts-leftIcon4-state2",
			[9022] = "dg_capPts-leftIcon5-state1", [9024] = "dg_capPts-leftIcon5-state2",
		},
		Horde = {
			[9021] = "dg_capPts-rightIcon1-state1", [9023] = "dg_capPts-rightIcon1-state2",
			[9016] = "dg_capPts-rightIcon2-state1", [9018] = "dg_capPts-rightIcon2-state2",
			[9001] = "windvale-market-horde-assaulted", [9003] = "windvale-market-horde",
			[9011] = "dg_capPts-rightIcon4-state1", [9013] = "dg_capPts-rightIcon4-state2",
			[9006] = "dg_capPts-rightIcon5-state1", [9008] = "dg_capPts-rightIcon5-state2",
		},
	},
}

local BattlegroundCarriedObjectTooltip = {
	[BATTLEGROUND_TEMPLE_OF_KOTMOGU] = {
		Alliance = BATTLEGROUND_ORB_TAKEN_ALLIANCE,
		Horde = BATTLEGROUND_ORB_TAKEN_HORDE,
	},
	[BATTLEGROUND_EYE_OF_THE_STORM] = {
		Alliance = BATTLEGROUND_FLAG_TAKEN_ALLIANCE,
		Horde = BATTLEGROUND_FLAG_TAKEN_HORDE,
	},
	[BATTLEGROUND_SILVER_SHARD_MINES] = {
		Alliance = BATTLEGROUND_MINE_CART_TAKEN_ALLIANCE,
		Horde = BATTLEGROUND_MINE_CART_TAKEN_HORDE,
	},
}
if not BATTLEGROUND_ORB_TAKEN_ALLIANCE then
	BattlegroundCarriedObjectTooltip[BATTLEGROUND_TEMPLE_OF_KOTMOGU] = { Alliance = "Orbe tomado", Horde = "Orbe tomado" }
end
if not BATTLEGROUND_FLAG_TAKEN_ALLIANCE then
	BattlegroundCarriedObjectTooltip[BATTLEGROUND_EYE_OF_THE_STORM] = { Alliance = "Bandera tomada", Horde = "Bandera tomada" }
end
if not BATTLEGROUND_MINE_CART_TAKEN_ALLIANCE then
	BattlegroundCarriedObjectTooltip[BATTLEGROUND_SILVER_SHARD_MINES] = { Alliance = "Vagoneta tomada", Horde = "Vagoneta tomada" }
end

local BattlegroundWorldStateToAtlas = {
	[BATTLEGROUND_TEMPLE_OF_KOTMOGU] = {
		Alliance = {
			[6966] = { atlas = "custombg-orb-green-left",   requiredValue = 1 },
			[6968] = { atlas = "custombg-orb-purple-left",  requiredValue = 1 },
			[6970] = { atlas = "custombg-orb-blue-left",    requiredValue = 1 },
			[6964] = { atlas = "custombg-orb-orange-left",  requiredValue = 1 },
		},
		Horde = {
			[6963] = { atlas = "custombg-orb-orange-right", requiredValue = 1 },
			[6969] = { atlas = "custombg-orb-blue-right",   requiredValue = 1 },
			[6967] = { atlas = "custombg-orb-purple-right", requiredValue = 1 },
			[6965] = { atlas = "custombg-orb-green-right",  requiredValue = 1 },
		},
	},
	[BATTLEGROUND_EYE_OF_THE_STORM] = {
		Alliance = { [2769] = { atlas = "eots_capPts-leftIcon1-state1",  requiredValue = 2 } },
		Horde    = { [2770] = { atlas = "eots_capPts-rightIcon1-state1", requiredValue = 2 } },
	},
	[BATTLEGROUND_SILVER_SHARD_MINES] = {
		Alliance = {
			[6881] = { atlas = "sm_carts-leftIcon1-state1", requiredValue = 1 },
			[6880] = { atlas = "sm_carts-leftIcon2-state1", requiredValue = 1 },
			[6439] = { atlas = "sm_carts-leftIcon3-state1", requiredValue = 1 },
		},
		Horde = {
			[6882] = { atlas = "sm_carts-rightIcon1-state1", requiredValue = 1 },
			[6879] = { atlas = "sm_carts-rightIcon2-state1", requiredValue = 1 },
			[6440] = { atlas = "sm_carts-rightIcon3-state1", requiredValue = 1 },
		},
	},
}

UpdateState = function()
	local frame = bars.frame
	local mapID = GetCurrentMapAreaID()

	for i in pairs(frame.BattlegroundPOIData) do
		if i > 0 then
			frame.BattlegroundPOIData[i] = nil
		end
	end

	-- landmark icons (bases)
	if BattlegroundPOITextureIdxToAtlas[mapID] then
		local textureData = BattlegroundPOITextureIdxToAtlas[mapID]
		for i = 1, 5 do
			local name, description, textureIndex, _, _, _, _, _, _, poiID = GetMapLandmarkInfo(i)
			local allianceAtlas = textureData.Alliance[poiID] or (textureIndex ~= 0 and textureData.Alliance[textureIndex])
			local hordeAtlas = textureData.Horde[poiID] or (textureIndex ~= 0 and textureData.Horde[textureIndex])

			if allianceAtlas then
				table.insert(frame.BattlegroundPOIData, { "Alliance", allianceAtlas, name, description })
			elseif hordeAtlas then
				table.insert(frame.BattlegroundPOIData, { "Horde", hordeAtlas, name, description })
			end
		end
	end

	-- carried objects (orbs / flags / carts)
	if BattlegroundWorldStateToAtlas[mapID] then
		local bgData = BattlegroundWorldStateToAtlas[mapID]
		local tooltips = BattlegroundCarriedObjectTooltip[mapID]

		for faction, entries in pairs(bgData) do
			for worldStateId, entry in pairs(entries) do
				if (GetWorldStateValue(worldStateId) == entry.requiredValue) then
					table.insert(frame.BattlegroundPOIData,
						{ faction, entry.atlas, tooltips and tooltips[faction] or "", "" })
				end
			end
		end
	end

	local list = {}
	for _, data in pairs(frame.BattlegroundPOIData) do
		table.insert(list, data)
	end

	table.sort(list, function(a, b) return a[2] < b[2] end)

	local allianceIndex, hordeIndex = 1, 1

	for _, POIData in ipairs(list) do
		local button

		if POIData[1] == "Alliance" then
			button = bars.left.POIButtons[allianceIndex]
			allianceIndex = allianceIndex + 1
		else
			button = bars.right.POIButtons[hordeIndex]
			hordeIndex = hordeIndex + 1
		end

		if button then
			local atlas = POIData[2]
			local info = atlas and atlas ~= "" and ATLAS[atlas] or nil
			if info then
				button:SetSize(info.w, info.h)
				button.Icon:SetTexture(TEXTURE_DIR .. info.file .. ".blp")
				button.Icon:SetTexCoord(info.l, info.r, info.t, info.b)
			end

			button.name = POIData[3]
			button.description = POIData[4] or ""
			button:Show()
		end
	end

	for _, data in ipairs({ { bars.left, allianceIndex }, { bars.right, hordeIndex } }) do
		for i = data[2], NUM_POI do
			data[1].POIButtons[i]:Hide()
		end
	end
end

-----------------------------------------------------------------
-- Events
-----------------------------------------------------------------
CreateMainFrame()

addon:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		local _, instanceType = IsInInstance()
		if instanceType == "none" then
			table.wipe(bars.frame.BattlegroundPOIData)
			bars.frame:Hide()
		end
	end
	UpdateObjective()
end)

addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("UPDATE_WORLD_STATES")
addon:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
addon:RegisterEvent("WORLD_STATE_UI_TIMER_UPDATE")
addon:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
addon:RegisterEvent("ZONE_CHANGED_NEW_AREA")
addon:RegisterEvent("WORLD_STATE_TIMER_START")
addon:RegisterEvent("WORLD_STATE_TIMER_STOP")

-- Hide the stock numeric flag/points indicators (AlwaysUpFrame1..N) in any supported battleground
local SUPPORTED_MAPS = {
	[BATTLEGROUND_WARSONG_GULCH] = true, [BATTLEGROUND_ARATHI_BASIN] = true,
	[BATTLEGROUND_EYE_OF_THE_STORM] = true, [BATTLEGROUND_TWIN_PEAKS] = true,
	[BATTLEGROUND_BATTLE_FOR_GILNEAS] = true, [BATTLEGROUND_TEMPLE_OF_KOTMOGU] = true,
	[BATTLEGROUND_SILVER_SHARD_MINES] = true, [BATTLEGROUND_DEEPWIND_GORGE] = true,
	[BATTLEGROUND_ALTERAC_VALLEY] = true, [BATTLEGROUND_ISLE_OF_CONQUEST] = true,
	[BATTLEGROUND_SEETHING_SHORE] = true, [BATTLEGROUND_WINDVALE_MARKET] = true,
}

hooksecurefunc("WorldStateAlwaysUpFrame_Update", function()
	if not SUPPORTED_MAPS[GetCurrentMapAreaID()] then return end
	local max = NUM_ALWAYS_UP_UI_FRAMES or 20
	for i = 1, max do
		local f = _G["AlwaysUpFrame"..i]
		if f then
			f:Hide()
		end
	end
end)

-- 1-second ticker to refresh POI icons while the bars are shown
-- (C_Timer does not exist in 5.4.7/18273; use a plain OnUpdate throttle)
local tickerElapsed = 0
local ticker = CreateFrame("Frame")
ticker:SetScript("OnUpdate", function(self, elapsed)
	tickerElapsed = tickerElapsed + elapsed
	if tickerElapsed >= 1 then
		tickerElapsed = 0
		if bars.frame:IsShown() then
			UpdateState()
		end
	end
end)

-----------------------------------------------------------------
-- Slash command
-----------------------------------------------------------------
SLASH_BGOBJECTIVEBARS1 = "/bgbars"
SlashCmdList.BGOBJECTIVEBARS = function(msg)
	if bars.frame:IsShown() then
		bars.frame:Hide()
		print("|cff33ff99BGObjectiveBars|r: oculto.")
	else
		UpdateObjective()
		bars.frame:Show()
		print("|cff33ff99BGObjectiveBars|r: visible (solo en campo de batalla).")
	end
end
