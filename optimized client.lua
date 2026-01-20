-- ============================================
-- JST Client - "mink monkey jew" Build
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

if _G.__JST_CLIENT_LOADED then return end
_G.__JST_CLIENT_LOADED = true

local Settings = {
    HitboxEnabled = false,
    LimbSize = 15,
    LimbTransparency = 0.5,
    TeamCheck = true,
    TargetLimb = "Head",
}

-- =========================
-- LIBRARIES
-- =========================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Sense = loadstring(game:HttpGet('https://sirius.menu/sense'))()

Sense.teamSettings.enemy.enabled = false
Sense.teamSettings.enemy.box = true

-- =========================
-- MAIN GUI SETUP
-- =========================
local Window = Rayfield:CreateWindow({
    Name = "JST Client",
    LoadingTitle = "mink monkey jew",
    LoadingSubtitle = "i love kids",
    ConfigurationSaving = { Enabled = true, FolderName = "JST_Client" },
    KeybindSource = "RightShift"
})

local CombatTab = Window:CreateTab("Combat", "crosshair")
local VisualsTab = Window:CreateTab("Visuals", "eye")

local HitboxToggle = CombatTab:CreateToggle({
    Name = "Enable Hitboxes",
    CurrentValue = false,
    Flag = "JST_Hitbox", 
    Callback = function(v) Settings.HitboxEnabled = v end
})

CombatTab:CreateKeybind({
    Name = "Hitbox Keybind",
    CurrentKeybind = "Backquote",
    HoldToInteract = false,
    Callback = function() HitboxToggle:Set(not Settings.HitboxEnabled) end,
})

CombatTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {2, 50},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(v) Settings.LimbSize = v end
})

CombatTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 0.5,
    Callback = function(v) Settings.LimbTransparency = v end
})

local ESPToggle = VisualsTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "JST_ESP",
    Callback = function(v) Sense.teamSettings.enemy.enabled = v end
})

VisualsTab:CreateKeybind({
    Name = "ESP Keybind",
    CurrentKeybind = "Comma",
    HoldToInteract = false,
    Callback = function() ESPToggle:Set(not Sense.teamSettings.enemy.enabled) end,
})

CombatTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(v) Settings.TeamCheck = v end
})

-- =========================
-- OPTIMIZED BATCH ENGINE
-- =========================
local currentIndex = 1
local BATCH_SIZE = 20 

RunService.Heartbeat:Connect(function()
    local allPlayers = Players:GetPlayers()
    local myTeam = LocalPlayer.Team
    local sizeV3 = Vector3.new(Settings.LimbSize, Settings.LimbSize, Settings.LimbSize)
    local defaultV3 = Vector3.new(2, 2, 1)

    for i = 1, BATCH_SIZE do
        if currentIndex > #allPlayers then
            currentIndex = 1
            break
        end

        local p = allPlayers[currentIndex]
        currentIndex = currentIndex + 1

        if p ~= LocalPlayer then
            local char = p.Character
            local limb = char and char:FindFirstChild(Settings.TargetLimb)
            
            if limb then
                local face = limb:FindFirstChildOfClass("Decal") -- Target the face
                local isTeammate = Settings.TeamCheck and p.Team == myTeam and myTeam ~= nil
                
                if not Settings.HitboxEnabled or isTeammate then
                    -- Reset to Normal
                    if limb.Size ~= defaultV3 then
                        limb.Size = defaultV3
                        limb.Transparency = 0
                        limb.Massless = false
                        if face then face.Transparency = 0 end -- Show face
                    end
                else
                    -- Expand and Hide Face
                    limb.Size = sizeV3
                    limb.Transparency = Settings.LimbTransparency
                    limb.CanCollide = false
                    limb.Massless = true 
                    if face then face.Transparency = 1 end -- Hide face
                end
            end
        end
    end
end)

Sense.Load()

Rayfield:Notify({
    Title = "JST client",
    Content = "mink nigga jew",
    Duration = 5,
})