local ADDON_NAME, ns = ...

ns.Data = {}

-- Warcraft Logs treats a raid tier and a Mythic+ season as the same kind of thing
-- internally (a "zone"), and a character URL can jump straight to one by appending
-- "#zone=<id>". These IDs change every tier/season, so bump them here when a new one
-- opens: open the character's Rankings page on warcraftlogs.com, pick the tier/season
-- you want from the zone dropdown, and copy the number after "zone=" out of the URL.
-- Leaving one nil just means the popup links the character's default rankings page
-- instead of a specific tier -- still the right character, just not deep-linked.
-- Current raid tier's zone id (confirmed on warcraftlogs.com). Re-check this once the
-- next raid tier opens.
ns.Data.RAID_ZONE_ID = 53

-- Current Mythic+ season's zone id (Season 2, confirmed on warcraftlogs.com). Re-check
-- this once the next M+ season opens.
ns.Data.MYTHIC_PLUS_ZONE_ID = 55

local REGION_NAMES = {
	[1] = "us",
	[2] = "kr",
	[3] = "eu",
	[4] = "tw",
	[5] = "cn",
}

-- Realms whose name joins two words without an original space (almost always an
-- apostrophe, e.g. "Kel'Thuzad"): Blizzard's cross-realm "Name-Realm" string has
-- already dropped that punctuation by the time we see it, so it looks identical to a
-- realm that really is two separate words (e.g. "Silver Hand"). The two need different
-- slugs ("kelthuzad" vs "silver-hand"), so the ambiguous ones are hand-listed here.
-- If a copied URL 404s because of a realm slug, that realm probably belongs in this
-- table -- add it as NormalizedRealmName = "correct-slug".
local REALM_SLUG_OVERRIDES = {
	AhnQiraj = "ahnqiraj",
	AlAkir = "alakir",
	AmanThul = "amanthul",
	CThun = "cthun",
	DathRemar = "dathremar",
	DrakTharon = "draktharon",
	DrekThar = "drekthar",
	EldreThalas = "eldrethalas",
	JubeiThos = "jubeithos",
	KelThuzad = "kelthuzad",
	MalGanis = "malganis",
	MokNathal = "moknathal",
	QuelThalas = "quelthalas",
	ThrokFeroth = "throkferoth",
	UnGoro = "ungoro",
}

function ns.Data.GetRegion()
	local regionID = GetCurrentRegion and GetCurrentRegion()
	return REGION_NAMES[regionID] or "us"
end

-- realmName: either a display name with real spaces/apostrophes (e.g. from
-- GetRealmName()), or a Blizzard-normalized name with those stripped (e.g. the realm
-- half of a "Name-Realm" identity string). isNormalized picks which rule applies.
function ns.Data.RealmToSlug(realmName, isNormalized)
	if not realmName or realmName == "" then
		return nil
	end

	if isNormalized then
		local override = REALM_SLUG_OVERRIDES[realmName]
		if override then
			return override
		end

		-- Insert a hyphen at each lower-to-upper transition, e.g. "SilverHand" ->
		-- "silver-hand". Wrong for realms in REALM_SLUG_OVERRIDES above.
		local slug = realmName:gsub("(%l)(%u)", "%1-%2")
		return slug:lower()
	end

	local slug = realmName:gsub("'", "")
	slug = slug:gsub("%s+", "-")
	return slug:lower()
end

-- Returns "mythicplus", "raid", or nil (open world / quest / custom / unknown) for a
-- given LFG List activity id.
function ns.Data.GetContentTypeForActivity(activityID)
	if not activityID then
		return nil
	end

	local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
	if not activityInfo then
		return nil
	end

	if activityInfo.isMythicPlusActivity then
		return "mythicplus"
	elseif activityInfo.categoryID == 3 then
		return "raid"
	end

	return nil
end

-- Same as above, for the Premade Groups listing the player is currently managing
-- applicants for.
function ns.Data.GetContentType()
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
	local activityID = activeEntryInfo and activeEntryInfo.activityIDs and activeEntryInfo.activityIDs[1]
	return ns.Data.GetContentTypeForActivity(activityID)
end

-- Splits a Blizzard "Name" or "Name-Realm" identity string. Cross-realm characters
-- come back as "Name-Realm" (already normalized, no spaces/apostrophes); same-realm
-- characters come back as just "Name", in which case we fall back to the player's own
-- realm (which still has real spaces/apostrophes).
function ns.Data.SplitNameRealm(fullName)
	if not fullName or fullName == "" then
		return nil
	end

	local name, realm = strsplit("-", fullName)
	local isNormalizedRealm = true
	if not realm then
		realm = GetRealmName()
		isNormalizedRealm = false
	end

	return name, realm, isNormalizedRealm
end

-- Reads a live unit token (e.g. "party1", "target", "focus", "player") off the game
-- world, as opposed to SplitNameRealm which parses a name string handed to us by an API
-- like C_LFGList. UnitFullName's realm is already normalized (no spaces/apostrophes)
-- when the unit is cross-realm, and empty when it's on the player's own realm -- same
-- shape as the realm half of a "Name-Realm" identity string, so it's handled the same way.
function ns.Data.GetUnitIdentity(unit)
	if not unit or not UnitExists(unit) or not UnitIsPlayer(unit) then
		return nil
	end

	local name, realm = UnitFullName(unit)
	if not name or name == "" then
		return nil
	end

	local isNormalizedRealm = true
	if not realm or realm == "" then
		realm = GetRealmName()
		isNormalizedRealm = false
	end

	return name, realm, isNormalizedRealm
end

function ns.Data.BuildCharacterURL(characterName, realmName, isNormalizedRealm, contentType)
	if not characterName or characterName == "" then
		return nil
	end

	local realmSlug = ns.Data.RealmToSlug(realmName, isNormalizedRealm)
	if not realmSlug then
		return nil
	end

	local url = ("https://www.warcraftlogs.com/character/%s/%s/%s"):format(
		ns.Data.GetRegion(), realmSlug, characterName)

	local zoneID
	if contentType == "mythicplus" then
		zoneID = ns.Data.MYTHIC_PLUS_ZONE_ID
	elseif contentType == "raid" then
		zoneID = ns.Data.RAID_ZONE_ID
	end

	if zoneID then
		url = url .. "#zone=" .. zoneID
	end

	return url
end
