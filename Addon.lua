--[[--------------------------------------------------------------------
	SpellAlertFilter
	Hides annoying spell alert graphics.
	Copyright (c) 2014-2016 Phanx <addons@phanx.net>
	All rights reserved.
	You MAY reuse code from this addon in any way and for any purpose,
	as long you DO NOT use the names of this addon and/or its author
	anywhere in your project other than an OPTIONAL credits notation.
----------------------------------------------------------------------]]

local L = setmetatable({}, { __index = function(L, k)
	local v = tostring(k)
	L[k] = v
	return v
end })

if GetLocale() == "deDE" then
	L["%d (%s) will no longer be hidden."] = "%d (%s) wird nicht mehr versteckt."
	L["%d (%s) will now be hidden."] = "%d (%s) wird jetzt versteckt."
	L["%d spell alerts are being hidden."] = "Momentan sind %d Zauberwarnmeldungen versteckt."
	L["All spell alerts have been removed from the filter list."] = "Alle Zauberwarnmeldungen wurden aus der Verstecksliste entfernt."
	L["disabled"] = "deaktiviert"
	L["enabled"] = "aktiviert"
	L["Spell alert reporting now %s."] = "Berichten über Zauberwarnmeldungen wird jetzt %s."
elseif GetLocale():match("^es") then
	L["%d (%s) will no longer be hidden."] = "%d (%s) ya no se oculta."
	L["%d (%s) will now be hidden."] = "%d (%s) ahora se oculta."
	L["%d spell alerts are being hidden."] = "%d alertas de hechizos se ocultan actualmente."
	L["All spell alerts have been removed from the filter list."] = "Todos hechizos se han eliminados por la lista para ocultar."
	L["disabled"] = "desactivados"
	L["enabled"] = "activados"
	L["Spell alert reporting now %s."] = "Informes sobre alertas de hechizos se han %s."
end

L["enabled"] = "|cff7fff7f" .. L["enabled"] .. "|r"
L["disabled"] = "|cffff7f7f" .. L["disabled"] .. "|r"

------------------------------------------------------------------------

local setupMode

SpellAlertFilterDB = {
	[124275] = true, -- Light Stagger
}

SpellActivationOverlayFrame:SetScript("OnEvent", function(self, event, spellID, ...)
	if event == "SPELL_ACTIVATION_OVERLAY_SHOW" and SpellAlertFilterDB[spellID] then
		return
	end
	if setupMode then
		DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fSpellAlertFilter:|r " .. format("%d (%s)", spellID, GetSpellInfo(spellID or UNKNOWN)))
	end
	SpellActivationOverlay_OnEvent(self, event, spellID, ...)
end)

------------------------------------------------------------------------

local options = {
	list = function()
		local t = {}
		for id in pairs(SpellAlertFilter) do
			tinsert(id)
		end
		sort(t)
		DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fSpellAlertFilter:|r " .. format(L["%d spell alerts are being hidden."], #t))
		for i = 1, #t do
			local spellID = t[i]
			DEFAULT_CHAT_FRAME:AddMessage("   " .. format(L["%d (%s)"], spellID, GetSpellInfo(spellID) or UNKNOWN))
		end
	end,
	setup = function()
		setupMode = not setupMode
		DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fSpellAlertFilter:|r " .. format(L["Spell alert reporting now %s."], setupMode and L["enabled"] or L["disabled"]))
	end,
	reset = function()
		for id in pairs(SpellAlertFilter) do
			SpellAlertFilter[id] = nil
		end
		DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fSpellAlertFilter:|r " .. L["All spell alerts have been removed from the filter list."])
	end,
}

SLASH_SPELLALERTFILTER1 = "/saf"

SlashCmdList.SPELLALERTFILTER = function(cmd)
	cmd = strtrim(strlower(cmd or ""))
	if options[cmd] then
		options[cmd]()
	elseif strmatch(cmd, "^%d+") then
		local spellID = tonumber(cmd)
		if SpellAlertFilter[spellID] then
			SpellAlertFilter[spellID] = nil
			DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fSpellAlertFilter:|r " .. format(L["%d (%s) will no longer be hidden."], spellID, GetSpellInfo(spellID) or UNKNOWN))
		else
			SpellAlertFilter[spellID] = true
			DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fSpellAlertFilter:|r " .. format(L["%d (%s) will now be hidden."], spellID, GetSpellInfo(spellID) or UNKNOWN))
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fSpellAlertFilter:|r " .. L["Use /saf with the following commands:"])
		DEFAULT_CHAT_FRAME:AddMessage("   123456 - Add/remove spell ID 123456 to/from the filter list.")
		DEFAULT_CHAT_FRAME:AddMessage("   list - List the spell alerts currently on the filter list.")
		DEFAULT_CHAT_FRAME:AddMessage("   setup - Show a message in the chat frame with the related spell ID whenever a spell alert is displayed.")
		DEFAULT_CHAT_FRAME:AddMessage("   reset - Remove all spell alerts from the filter list.")
	end
end
