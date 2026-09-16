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
