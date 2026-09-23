-- =================================================================
-- BLADE BALL SCRIPT (OPTIMIZADO PARA DELTA EXECUTOR)
-- =================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Actualizar referencia del personaje al respawnear
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
end)

-- Variables de Control
local Config = {
    AutoParry = false,
    AutoSpam = false,
    BallESP = false,
    ParryDistance = 15, -- Distancia de detección para Auto Parry
    SpamDelay = 0.05    -- Intervalo de tiempo para Auto Spam
}

-- Referencia al Remoto de Parry
local ParryRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ParryButtonPress")

-- Obtener el contenedor seguro para la UI/ESP
local getHui = gethui or function() return CoreGui end

-- =================================================================
-- FUNCIONES AUXILIARES
-- =================================================================

-- Función para enviar la señal de Parry de forma segura
local function triggerParry()
    pcall(function()
        ParryRemote:FireServer()
    end)
end

-- Función para verificar y obtener la bola real del juego
local function getRealBall()
    local ballsFolder = Workspace:FindFirstChild("Balls")
    if not ballsFolder then return nil end

    for _, ball in ipairs(ballsFolder:GetChildren()) do
        if ball:GetAttribute("realBall") == true then
            return ball
        end
    end
    return nil
end

-- =================================================================
-- 1. SISTEMA AUTO PARRY
-- =================================================================
task.spawn(function()
    RunService.PreRender:Connect(function()
        if not Config.AutoParry then return end

        pcall(function()
            local ball = getRealBall()
            if not ball or not Character or not Character:FindFirstChild("HumanoidRootPart") then return end

            local hrp = Character.HumanoidRootPart
            local distance = (ball.Position - hrp.Position).Magnitude

            -- Detectar si la bola está en dirección al jugador y a la distancia configurada
            if distance <= Config.ParryDistance then
                triggerParry()
            end
        end)
    end)
end)

-- =================================================================
-- 2. SISTEMA AUTO SPAM
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
-- 3. SISTEMA ESP PARA LA BOLA
-- =================================================================
local ballHighlight = nil

local function updateHighlight()
    pcall(function()
        local ball = getRealBall()

        if Config.BallESP and ball then
            if not ballHighlight or ballHighlight.Parent ~= getHui() then
                if ballHighlight then ballHighlight:Destroy() end
                
                ballHighlight = Instance.new("Highlight")
                ballHighlight.Name = "BladeBallESP"
                ballHighlight.FillColor = Color3.fromRGB(255, 0, 0)
                ballHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
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
        task.wait(0.5)
    end
end)

-- =================================================================
-- 4. INTERFAZ GRÁFICA (RAYFIELD UI CON FALLBACK)
-- =================================================================
local uiLoaded, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if uiLoaded and Rayfield then
    pcall(function()
        local Window = Rayfield:CreateWindow({
            Name = "Blade Ball - Delta Script",
            LoadingTitle = "Cargando Script...",
            LoadingSubtitle = "Por Delta Executor",
            ConfigurationSaving = { Enabled = false }
        })

        local MainTab = Window:CreateTab("Principal", 4483362458)

        MainTab:CreateToggle({
            Name = "Auto Parry",
            CurrentValue = Config.AutoParry,
            Flag = "AutoParryFlag",
            Callback = function(Value)
                Config.AutoParry = Value
            end,
        })

        MainTab:CreateToggle({
            Name = "Auto Spam",
            CurrentValue = Config.AutoSpam,
            Flag = "AutoSpamFlag",
            Callback = function(Value)
                Config.AutoSpam = Value
            end,
        })

        MainTab:CreateToggle({
            Name = "ESP de la Bola",
            CurrentValue = Config.BallESP,
            Flag = "BallESPFlag",
            Callback = function(Value)
                Config.BallESP = Value
            end,
        })
    end)
else
    -- Fallback: Si la UI no carga por red o compatibilidad, activa Auto Parry y ESP por defecto
    warn("Rayfield UI no se pudo cargar. Activando Auto Parry y ESP en modo seguro...")
    Config.AutoParry = true
    Config.BallESP = true
end
