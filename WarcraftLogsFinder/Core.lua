local ADDON_NAME, ns = ...

local VERSION = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or "0"

SLASH_WARCRAFTLOGSFINDER1 = "/wlf"
SlashCmdList["WARCRAFTLOGSFINDER"] = function()
	if ns.lastURL then
		print(("|cff40ff40[WLF]|r v%s content=%s url=%s"):format(VERSION, tostring(ns.lastContentType), ns.lastURL))
	else
		print(("|cff40ff40[WLF]|r v%s -- no Warcraft Logs URL built yet. Right-click an applicant or a group listing in Premade Groups first."):format(VERSION))
	end
end
