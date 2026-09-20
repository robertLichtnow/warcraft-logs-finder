local ADDON_NAME, ns = ...

ns.Popup = {}

StaticPopupDialogs["WARCRAFTLOGSFINDER_COPY_URL"] = {
	text = "Warcraft Logs URL",
	button1 = CLOSE,
	hasEditBox = true,
	editBoxWidth = 350,
	OnShow = function(self, url)
		self.EditBox:SetText(url)
		self.EditBox:HighlightText()
		self.EditBox:SetFocus()
		self.EditBox:SetScript("OnKeyDown", function(_, key)
			if key == "C" and (IsControlKeyDown() or IsMetaKeyDown()) then
				self:Hide()
			end
		end)
	end,
	OnHide = function(self)
		self.EditBox:SetScript("OnKeyDown", nil)
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = STATICPOPUP_NUMDIALOGS,
}

function ns.Popup.ShowURL(url)
	StaticPopup_Show("WARCRAFTLOGSFINDER_COPY_URL", nil, nil, url)
end
