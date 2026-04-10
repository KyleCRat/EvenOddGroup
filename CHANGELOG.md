# Changelog

## [12.0.5-1] - 2026-04-10

### Features
- Display even/odd raid group number with color-coded text (blue for even, red for odd)
- Draggable, lockable frame with toggleable background
- Slash commands (`/eog`) for visibility, lock, and background toggles

### Fixes
- Fix ADDON_LOADED event triggering unnecessary updates for every addon
- Move load message inside ADDON_LOADED handler so it prints after initialization
- Hide frame when in a party (non-raid group)
