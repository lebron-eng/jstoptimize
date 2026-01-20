-- ============================================
-- JST Client - Master Toggle + Transparency
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

if _G.__JST_CLIENT_LOADED then return end
_G.__JST_CLIENT_LOADED = true

local Settings = {
    HitboxEnabled = false,
    LimbSize = 15,
    LimbTransparency = 0.5, -- Transparency variable
    TeamCheck = true,
    TargetLimb = "Head",
}

-- Memory for Master Toggle
local MasterState = true 
local SavedSettings = {
    Hitbox = false,
    ESP = false
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
    LoadingSubtitle = "jiggle soft titties",
    ConfigurationSaving = { Enabled = true, FolderName = "JST_Client" },
    KeybindSource = "RightShift"
})

local CombatTab = Window:CreateTab("Combat", "crosshair")
local VisualsTab = Window:CreateTab("Visuals", "eye")

-- Reference toggles for script control
local HitboxToggle = CombatTab:CreateToggle({
    Name = "Enable Hitboxes",
    CurrentValue = false,
    Flag = "JST_Hitbox", 
    Callback = function(v) 
        if MasterState then Settings.HitboxEnabled = v end 
    end
})

local ESPToggle = VisualsTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "JST_ESP",
    Callback = function(v) 
        if MasterState then Sense.teamSettings.enemy.enabled = v end 
    end
})

-- =========================
-- MASTER TOGGLE LOGIC
-- =========================
local function ToggleAll()
    MasterState = not MasterState
    
    local coreGui = game:GetService("CoreGui")
    local uiName = "Rayfield"
    local targetUI = coreGui:FindFirstChild(uiName) or LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild(uiName)

    if not MasterState then
        -- DISABLE & SAVE
        SavedSettings.Hitbox = Settings.HitboxEnabled
        SavedSettings.ESP = Sense.teamSettings.enemy.enabled
        
        Settings.HitboxEnabled = false
        Sense.teamSettings.enemy.enabled = false
        
        HitboxToggle:Set(false)
        ESPToggle:Set(false)
        
        if targetUI then targetUI.Enabled = false end
        
        Rayfield:Notify({Title = "Status", Content = "PANIC: All Off / UI Hidden", Duration = 2})
    else
        -- RESTORE
        Settings.HitboxEnabled = SavedSettings.Hitbox
        Sense.teamSettings.enemy.enabled = SavedSettings.ESP
        
        HitboxToggle:Set(SavedSettings.Hitbox)
        ESPToggle:Set(SavedSettings.ESP)
        
        if targetUI then targetUI.Enabled = true end
        
        Rayfield:Notify({Title = "Status", Content = "RESTORED: Settings Loaded", Duration = 2})
    end
end

-- =========================
-- UI ELEMENTS
-- =========================

CombatTab:CreateKeybind({
    Name = "MASTER TOGGLE (Panic/Restore)",
    CurrentKeybind = "RightControl",
    HoldToInteract = false,
    Callback = function() ToggleAll() end,
})

CombatTab:CreateKeybind({
    Name = "Hitbox Quick Key",
    CurrentKeybind = "Backquote",
    HoldToInteract = false,
    Callback = function() 
        if MasterState then HitboxToggle:Set(not Settings.HitboxEnabled) end 
    end,
})

CombatTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {2, 50},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(v) Settings.LimbSize = v end
})

-- RE-ADDED TRANSPARENCY SLIDER
CombatTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 0.5,
    Callback = function(v) Settings.LimbTransparency = v end
})

VisualsTab:CreateKeybind({
    Name = "ESP Quick Key",
    CurrentKeybind = "Comma",
    HoldToInteract = false,
    Callback = function() 
        if MasterState then ESPToggle:Set(not Sense.teamSettings.enemy.enabled) end 
    end,
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
                local face = limb:FindFirstChildOfClass("Decal")
                local isTeammate = Settings.TeamCheck and p.Team == myTeam and myTeam ~= nil
                
                if not Settings.HitboxEnabled or isTeammate then
                    if limb.Size ~= defaultV3 then
                        limb.Size = defaultV3
                        limb.Transparency = 0
                        limb.Massless = false
                        if face then face.Transparency = 0 end
                    end
                else
                    limb.Size = sizeV3
                    limb.Transparency = Settings.LimbTransparency -- Correctly applies from slider
                    limb.CanCollide = false
                    limb.Massless = true 
                    if face then face.Transparency = 1 end
                end
            end
        end
    end
end)

Sense.Load()

Rayfield:Notify({
    Title = "JST client",
    Content = "Loaded with Transparency & Master Toggle.",
    Duration = 5,
})