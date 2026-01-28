local ADDON_NAME, EOG = ...

-- Create the main frame
EOG.frame = CreateFrame("Frame", "EvenOddGroupFrame", UIParent)
EOG.frame:SetSize(150, 40)
EOG.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
EOG.frame:SetMovable(true)
EOG.frame:SetClampedToScreen(true)

-- Make the frame draggable
EOG.frame:EnableMouse(true)
EOG.frame:RegisterForDrag("LeftButton")
EOG.frame:SetScript("OnDragStart", EOG.frame.StartMoving)
EOG.frame:SetScript("OnDragStop", EOG.frame.StopMovingOrSizing)

-- Create background
EOG.frame.bg = EOG.frame:CreateTexture(nil, "BACKGROUND")
EOG.frame.bg:SetAllPoints(EOG.frame)
EOG.frame.bg:SetColorTexture(0, 0, 0, 0.5)

-- Create the text display with custom font
EOG.frame.text = EOG.frame:CreateFontString(nil, "OVERLAY")
EOG.frame.text:SetPoint("CENTER", EOG.frame, "CENTER", 0, 0)

-- Set up custom font (using a WoW built-in font, or replace with your own font file)
local FONT = "Interface\\AddOns\\EvenOddGroup\\media\\fonts\\PTSansNarrow-Bold.ttf"

local fontObject = CreateFont("EvenOddGroupFont")
fontObject:SetFont(FONT, 24, "OUTLINE")
fontObject:SetTextColor(1, 1, 1, 1)
EOG.frame.text:SetFontObject(fontObject)


EOG.frame.text:SetText("Unknown")

-- Function to update the display
function EOG:UpdateGroupParity()
    local playerName = UnitName("player")
    local groupSize = GetNumGroupMembers()

    if groupSize == 0 then
        EOG.frame:Hide()
        EOG.frame.text:SetText("Not in group")
        return
    end

    -- Find our group number
    local myGroup = nil

    -- Check if in raid
    if IsInRaid() then
        for i = 1, groupSize do
            local name, _, subgroup = GetRaidRosterInfo(i)
            if name == playerName then
                myGroup = subgroup
                break
            end
        end
    else
        -- In party, Don't show
    end

    if myGroup then
        EOG.frame:Show()
        if myGroup % 2 == 0 then
            EOG.frame.text:SetText("even")
            EOG.frame.text:SetTextColor(0.5, 0.5, 1, 1) -- Blue for even
        else
            EOG.frame.text:SetText("odd")
            EOG.frame.text:SetTextColor(1, 0.5, 0.5, 1) -- Red for odd
        end
    else
        EOG.frame.text:SetText("Unknown")
    end
end

-- Initialize saved variables
function EOG:InitializeSavedVariables()
    if not EvenOddGroupDB then
        EvenOddGroupDB = {
            locked = false,
            showBackground = true
        }
    end

    EOG.db = EvenOddGroupDB

    -- Apply saved settings
    if EOG.db.locked then
        EOG.frame:EnableMouse(false)
    else
        EOG.frame:EnableMouse(true)
    end

    if EOG.db.showBackground then
        EOG.frame.bg:Show()
    else
        EOG.frame.bg:Hide()
    end
end

-- Register events
EOG.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
EOG.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
EOG.frame:RegisterEvent("ADDON_LOADED")


-- Event handler
EOG.frame:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" and addon == ADDON_NAME then
        EOG:InitializeSavedVariables()

        EOG:UpdateGroupParity()
    else
        EOG:UpdateGroupParity()
    end
end)

-- Slash command to toggle visibility and lock/unlock
SLASH_EVENODDGROUP1 = "/evenoddgroup"
SLASH_EVENODDGROUP2 = "/eog"
SlashCmdList["EVENODDGROUP"] = function(msg)
    msg = msg:lower():trim()

    if msg == "l" or msg == "lock" then
        EOG.db.locked = not EOG.db.locked
        EOG.frame:EnableMouse(not EOG.db.locked)
        print("Even Odd Group: Frame " .. (EOG.db.locked and "L" or "Unl") .. "ocked")
    elseif msg == "unlock" then
        EOG.db.locked = false
        EOG.frame:EnableMouse(true)
        print("Even Odd Group: Frame unlocked")
    elseif msg == "bg" or msg == "background" then
        EOG.db.showBackground = not EOG.db.showBackground
        if EOG.db.showBackground then
            EOG.frame.bg:Show()
            print("Even Odd Group: Background shown")
        else
            EOG.frame.bg:Hide()
            print("Even Odd Group: Background hidden")
        end
    elseif msg == "" then
        if EOG.frame:IsShown() then
            EOG.frame:Hide()
            print("Even Odd Group: Hidden")
        else
            EOG.frame:Show()
            print("Even Odd Group: Shown")
        end
    else
        print("Even Odd Group commands:")
        print("  /eog - Toggle visibility")
        print("  /eog lock | /eog l - Toggle frame lock")
        print("  /eog unlock - Unlock frame")
    end
end

print("Even Odd Group addon loaded. Use /eog for commands.")
