# Warcraft Logs Finder

A lightweight World of Warcraft (Retail) addon for Premade Groups (Group Finder):
right-click an applicant, or a group in the browse list, to copy a link straight to
the relevant character's Warcraft Logs page — so you can check parses before you
invite, or before you apply.

## Features

- **One right-click away** — adds a "Copy Warcraft Logs URL" option to the same
  context menu you already use to whisper, report, or ignore an applicant, and to the
  context menu on group listings in the browse list.
- **Works both directions** — right-click an applicant to check them before you
  invite, or right-click a listed group to check its leader before you apply.
- **Knows what you're recruiting for** — builds a link to the raid rankings or
  Mythic+ rankings depending on whether the listing in question is a raid or a
  dungeon/Mythic+ group.
- **Select-and-copy popup** — clicking the option opens a small window with the URL
  already selected, so Ctrl+C copies it immediately.
- **Works cross-realm** — resolves the correct region and realm for the link whether
  the character shares your realm or not.

## How it works

- Right-clicking an applicant's name, or a group in the browse list, reads the
  relevant character/realm from the game's own Premade Groups API and looks at the
  activity that listing is for (`C_LFGList`) to tell a raid group from a Mythic+ group.
- It builds the matching `warcraftlogs.com/character/<region>/<realm>/<name>` URL and,
  if a current-tier zone ID is configured (see Configuration below), links directly to
  that tier's rankings instead of the character's default page.
- The popup is a plain edit box with its text highlighted and focused on open — no
  network requests, no external dependencies.

## Installation

1. Download the latest release from the [GitHub Releases page](../../releases)
   (also published automatically to CurseForge).
2. Extract the `WarcraftLogsFinder` folder into your
   `World of Warcraft/_retail_/Interface/AddOns/` directory.
3. Restart or reload the game client.

## Usage

**Checking an applicant:**
1. Open Premade Groups and expand an application.
2. Right-click the name of the member you want to check.
3. Click **Copy Warcraft Logs URL**.

**Checking a group before you apply:**
1. Open Premade Groups and browse the list of groups.
2. Right-click a listing.
3. Click **Copy Leader's Warcraft Logs URL**.

Either way, a popup opens with the URL already selected — press Ctrl+C to copy it,
then Escape or Close to dismiss the window.

`/wlf` prints the content type and URL that were last built, for troubleshooting.

## Configuration

Warcraft Logs treats a raid tier and a Mythic+ season as the same kind of "zone", and
a character URL can jump straight to one with `#zone=<id>` — but that ID changes every
tier/season. `Data.lua` has two constants for this, `RAID_ZONE_ID`
and `MYTHIC_PLUS_ZONE_ID`, already set to the current tier/season.

When the next one opens, update whichever constant changed: open the new tier/season
on warcraftlogs.com and copy the number after `zone=` in the URL. Setting either back
to `nil` links the character's default rankings page instead (still the right
character, just not deep-linked to a specific tier).

## Contributing

Issues and pull requests are welcome.

- `Data.lua` is the single source of truth for anything that
  changes with the game rather than the addon: the two zone IDs above, and the realm
  slug table used for characters whose realm name doesn't survive Blizzard's
  cross-realm normalization cleanly (e.g. `Kel'Thuzad`). If a copied URL 404s because
  of the realm segment, that realm likely needs an entry there.

## License

Licensed under the [Apache License 2.0](LICENSE).
