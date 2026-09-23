-- =================================================================
-- BLADE BALL SCRIPT - VERSIÓN COMPLETA
-- Auto Parry + Auto Spam + Ball ESP + UI Rayfield
-- =================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Actualizar personaje al respawnear
LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    Character = newChar
end)

-- =================================================================
-- CONFIGURACIÓN
-- =================================================================
local Config = {
    AutoParry = false,
    AutoSpam = false,
    BallESP = false,
    ParryDistance = 15,
    SpamDelay = 0.05,
    BallColor = Color3.fromRGB(255, 0, 0),
    OutlineColor = Color3.fromRGB(255, 255, 255),
}

-- Contenedor seguro
local getHui = gethui or function() return CoreGui end

-- =================================================================
-- BUSCAR REMOTO DE PARRY (FLEXIBLE)
-- =================================================================
local ParryRemote = nil

local function findParryRemote()
    -- Buscar en ReplicatedStorage completo
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and string.find(string.lower(obj.Name), "parry") then
            ParryRemote = obj
            return obj
        end
    end
    -- Buscar en ReplicatedStorage.Remotes específicamente
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        for _, obj in ipairs(remotes:GetDescendants()) do
            if obj:IsA("RemoteEvent") and string.find(string.lower(obj.Name), "parry") then
                ParryRemote = obj
                return obj
            end
        end
    end
    return nil
end

findParryRemote()

-- =================================================================
-- BUSCAR LA BOLA REAL (FLEXIBLE)
-- =================================================================
local function getRealBall()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj:GetAttribute("realBall") == true then
            return obj
        end
    end
    return nil
end

-- =================================================================
-- TRIGGER PARRY
-- =================================================================
local function triggerParry()
    if not ParryRemote then
        findParryRemote()
    end
    if not ParryRemote then return end
    pcall(function()
        ParryRemote:FireServer()
    end)
end

-- =================================================================
-- AUTO PARRY
-- =================================================================
task.spawn(function()
    RunService.PreRender:Connect(function()
        if not Config.AutoParry then return end
        pcall(function()
            local ball = getRealBall()
            if not ball then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local distance = (ball.Position - hrp.Position).Magnitude
            if distance <= Config.ParryDistance then
                triggerParry()
            end
        end)
    end)
end)

-- =================================================================
-- AUTO SPAM
-- =================================================================
task.spawn(function()
    while true do
        if Config.AutoSpam then
            triggerParry()
        end
        task.wait(Config.SpamDelay)
    end
end)

-- =================================================================
-- ESP DEL BALÓN
-- =================================================================
local ballHighlight = nil

local function updateHighlight()
    pcall(function()
        local ball = getRealBall()
        
        if Config.BallESP and ball then
            if not ballHighlight or ballHighlight.Parent ~= getHui() then
                if ballHighlight then ballHighlight:Destroy() end
                
                ballHighlight = Instance.new("Highlight")
                ballHighlight.Name = "BallESP"
                ballHighlight.FillColor = Config.BallColor
                ballHighlight.OutlineColor = Config.OutlineColor
                ballHighlight.FillTransparency = 0.3
                ballHighlight.OutlineTransparency = 0
                ballHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                ballHighlight.Parent = getHui()
            end
            
            ballHighlight.Adornee = ball
            ballHighlight.Enabled = true
        else
            if ballHighlight then
                ballHighlight.Enabled = false
            end
        end
    end)
end

task.spawn(function()
    while true do
        updateHighlight()
        task.wait(0.2)
    end
end)

-- =================================================================
-- UI (RAYFIELD CON FALLBACK)
-- =================================================================
local uiLoaded, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if uiLoaded and Rayfield then
    pcall(function()
        local Window = Rayfield:CreateWindow({
            Name = "Blade Ball - Mi Script",
            LoadingTitle = "Cargando...",
            LoadingSubtitle = "Auto Parry + ESP",
            ConfigurationSaving = { Enabled = false }
        })

        local MainTab = Window:CreateTab("Principal", 4483362458)
        local VisualTab = Window:CreateTab("Visuales", 4483362458)

        -- Principal
        MainTab:CreateToggle({
            Name = "Auto Parry",
            CurrentValue = false,
            Flag = "AutoParryFlag",
            Callback = function(Value)
                Config.AutoParry = Value
            end,
        })

        MainTab:CreateToggle({
            Name = "Auto Spam",
            CurrentValue = false,
            Flag = "AutoSpamFlag",
            Callback = function(Value)
                Config.AutoSpam = Value
            end,
        })

        MainTab:CreateSlider({
            Name = "Distancia de Parry",
            Range = [0, 50],
            Increment = 1,
            Suffix = " studs",
            CurrentValue = 15,
            Flag = "DistanceSlider",
            Callback = function(Value)
                Config.ParryDistance = Value
            end,
        })

        -- Visuales
        VisualTab:CreateToggle({
            Name = "ESP de la Bola",
            CurrentValue = false,
            Flag = "BallESPFlag",
            Callback = function(Value)
                Config.BallESP = Value
            end,
        })

        VisualTab:CreateColorPicker({
            Name = "Color del ESP",
            Color = Color3.fromRGB(255, 0, 0),
            Flag = "BallColorFlag",
            Callback = function(Value)
                Config.BallColor = Value
                if ballHighlight then
                    ballHighlight.FillColor = Value
                end
            end,
        })
    end)
else
    warn("Rayfield UI no cargó. Activando Auto Parry y ESP en modo seguro...")
    Config.AutoParry = true
    Config.BallESP = true
end
