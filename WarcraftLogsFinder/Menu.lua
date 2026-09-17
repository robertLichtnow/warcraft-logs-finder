local ADDON_NAME, ns = ...

-- owner is the LFGListApplicantMemberButton that was right-clicked. Its parent carries
-- applicantID, and the button itself carries which member of that application this is.
local function GetApplicantMemberIdentity(owner)
	local memberIdx = owner and owner.memberIdx
	if not memberIdx then
		return nil
	end

	local parent = owner:GetParent()
	local applicantID = parent and parent.applicantID
	if not applicantID then
		return nil
	end

	local fullName = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx)
	return ns.Data.SplitNameRealm(fullName)
end

-- owner is the LFGListSearchEntry that was right-clicked (a row in the browse list of
-- groups to join). It carries resultID, which C_LFGList.GetSearchResultInfo() turns
-- into the listing's details, including the party leader's name and the activity the
-- group is for.
local function GetSearchResultLeaderIdentity(owner)
	local resultID = owner and owner.resultID
	if not resultID then
		return nil
	end

	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
	if not searchResultInfo then
		return nil
	end

	local name, realm, isNormalizedRealm = ns.Data.SplitNameRealm(searchResultInfo.leaderName)
	local activityID = searchResultInfo.activityIDs and searchResultInfo.activityIDs[1]
	return name, realm, isNormalizedRealm, activityID
end

local function AddCopyURLButton(rootDescription, buttonLabel, name, realm, isNormalizedRealm, contentType)
	if not name then
		return
	end

	local url = ns.Data.BuildCharacterURL(name, realm, isNormalizedRealm, contentType)
	if not url then
		return
	end

	ns.lastURL = url
	ns.lastContentType = contentType

	rootDescription:CreateDivider()
	rootDescription:CreateTitle("Warcraft Logs")
	rootDescription:CreateButton(buttonLabel, function()
		ns.Popup.ShowURL(url)
	end)
end

Menu.ModifyMenu("MENU_LFG_FRAME_MEMBER_APPLY", function(owner, rootDescription)
	local name, realm, isNormalizedRealm = GetApplicantMemberIdentity(owner)
	AddCopyURLButton(rootDescription, "Copy Warcraft Logs URL", name, realm, isNormalizedRealm, ns.Data.GetContentType())
end)

Menu.ModifyMenu("MENU_LFG_FRAME_SEARCH_ENTRY", function(owner, rootDescription)
	local name, realm, isNormalizedRealm, activityID = GetSearchResultLeaderIdentity(owner)
	local contentType = ns.Data.GetContentTypeForActivity(activityID)
	AddCopyURLButton(rootDescription, "Copy Leader's Warcraft Logs URL", name, realm, isNormalizedRealm, contentType)
end)

-- Blizzard's unit-frame right-click menu is one system shared by every frame (party,
-- focus, target, raid, nameplates, ...). Which tag it opens under depends on the
-- targeted unit's relationship to the player, not on which frame was clicked -- e.g.
-- right-clicking the target frame while your target is a party member opens
-- MENU_UNIT_PARTY, the same tag a right-click on the party frame itself opens. So to
-- cover "right-click a party member" and "right-click whoever is targeted/focused" we
-- hook every tag a player-controlled character can open a menu under. contextData.unit
-- is the live unit token (e.g. "party1", "target", "focus") regardless of tag.
local UNIT_MENU_TAGS = {
	"MENU_UNIT_PARTY",
	"MENU_UNIT_RAID_PLAYER",
	"MENU_UNIT_SELF",
	"MENU_UNIT_PLAYER",
	"MENU_UNIT_ENEMY_PLAYER",
	"MENU_UNIT_FOCUS",
}

for _, tag in ipairs(UNIT_MENU_TAGS) do
	Menu.ModifyMenu(tag, function(owner, rootDescription, contextData)
		local unit = contextData and contextData.unit
		local name, realm, isNormalizedRealm = ns.Data.GetUnitIdentity(unit)
		AddCopyURLButton(rootDescription, "Copy Warcraft Logs URL", name, realm, isNormalizedRealm, nil)
	end)
end
