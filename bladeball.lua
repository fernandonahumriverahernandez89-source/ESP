--// ============================================
--// BLADE BALL - SCRIPT COMPLETO
--// Auto Parry + Auto Spam + Ball ESP
--// ============================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Mi Script Blade Ball",
    LoadingTitle = "Cargando...",
    LoadingSubtitle = "Auto Parry & ESP",
    ConfigurationSaving = { Enabled = false },
})

local MainTab = Window:CreateTab("Principal", 4483362458)
local VisualTab = Window:CreateTab("Visuales", 4483362458)

--// ⚙️ CONFIGURACIÓN
local Config = {
    AutoParry = false,
    AutoSpam = false,
    BallESP = false,
    ParryDistance = 10,
    BallColor = Color3.fromRGB(255, 50, 50),
}

--// 🎯 SERVICIOS
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local Balls = workspace:WaitForChild("Balls", 10)

--// 🧩 CONTENEDOR SEGURO
local SAFE_PARENT = CoreGui
if gethui then
    local ok, hui = pcall(gethui)
    if ok and hui then SAFE_PARENT = hui end
end

--// ============================================
--// FUNCIONES DE PARRY
--// ============================================
local function VerifyBall(Ball)
    if typeof(Ball) == "Instance" and Ball:IsA("BasePart") and Ball:IsDescendantOf(Balls) and Ball:GetAttribute("realBall") == true then
        return true
    end
    return false
end

local function IsTarget()
    return (Player.Character and Player.Character:FindFirstChild("Highlight"))
end

local function Parry()
    if Remotes:FindFirstChild("ParryButtonPress") then
        Remotes.ParryButtonPress:Fire()
    end
end

--// 🔁 AUTO PARRY
task.spawn(function()
    while task.wait(0.1) do
        if not Config.AutoParry then continue end

        for _, Ball in ipairs(Balls:GetChildren()) do
            if VerifyBall(Ball) and IsTarget() then
                local Distance = (Ball.Position - workspace.CurrentCamera.Focus.Position).Magnitude
                if Distance <= Config.ParryDistance then
                    Parry()
                end
            end
        end
    end
end)

--// 🔁 AUTO SPAM
task.spawn(function()
    while task.wait(0.5) do
        if Config.AutoSpam then
            Parry()
        end
    end
end)

--// ============================================
--// ESP DEL BALÓN
--// ============================================
local ballHighlight = nil

local function setupBallESP()
    task.spawn(function()
        while task.wait(0.2) do
            if not Config.BallESP then
                if ballHighlight then
                    ballHighlight:Destroy()
                    ballHighlight = nil
                end
                continue
            end

            for _, Ball in ipairs(Balls:GetChildren()) do
                if VerifyBall(Ball) then
                    if not ballHighlight or ballHighlight.Adornee ~= Ball then
                        if ballHighlight then ballHighlight:Destroy() end

                        ballHighlight = Instance.new("Highlight")
                        ballHighlight.FillColor = Config.BallColor
                        ballHighlight.OutlineColor = Config.BallColor
                        ballHighlight.FillTransparency = 0.2
                        ballHighlight.OutlineTransparency = 0
                        ballHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        ballHighlight.Adornee = Ball
                        ballHighlight.Parent = SAFE_PARENT
                    end
                    break
                end
            end
        end
    end)
end

setupBallESP()

--// ============================================
--// 🎮 INTERFAZ
--// ============================================

-- Pestaña Principal
MainTab:CreateToggle({
    Name = "Auto Parry",
    CurrentValue = false,
    Flag = "AutoParryFlag",
    Callback = function(Value)
        Config.AutoParry = Value
    end,
})

MainTab:CreateToggle({
    Name = "Auto Spam (Parry constante)",
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
    CurrentValue = 10,
    Flag = "DistanceSlider",
    Callback = function(Value)
        Config.ParryDistance = Value
    end,
})

-- Pestaña Visuales
VisualTab:CreateToggle({
    Name = "ESP del Balón",
    CurrentValue = false,
    Flag = "BallESPFlag",
    Callback = function(Value)
        Config.BallESP = Value
    end,
})

VisualTab:CreateColorPicker({
    Name = "Color del Balón",
    Color = Color3.fromRGB(255, 50, 50),
    Flag = "BallColorFlag",
    Callback = function(Value)
        Config.BallColor = Value
        if ballHighlight then
            ballHighlight.FillColor = Value
            ballHighlight.OutlineColor = Value
        end
    end,
})

print("✅ Script Blade Ball cargado correctamente")
