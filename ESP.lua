--// ⚙️ Servicios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

--// 🎨 Configuración
local HIGHLIGHT_COLOR = Color3.fromRGB(57, 255, 20)
local IGNORE_LOCAL = true

--// 🕵️ Nombre aleatorio
local function randomName()
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local name = ""
    for i = 1, 12 do
        local r = math.random(1, #chars)
        name = name .. chars:sub(r, r)
    end
    return name
end

--// 🧩 Contenedor seguro
local function getSafeParent()
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    return CoreGui
end

local SAFE_PARENT = getSafeParent()
local highlights = {}

--// ✅ Crear highlight
local function createHighlight(player)
    if IGNORE_LOCAL and player == LocalPlayer then return end
    if highlights[player] then return end

    local hl = Instance.new("Highlight")
    hl.Name = randomName()
    hl.FillColor = HIGHLIGHT_COLOR
    hl.OutlineColor = HIGHLIGHT_COLOR
    hl.FillTransparency = 0.35
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = player.Character
    hl.Parent = SAFE_PARENT

    highlights[player] = hl

    -- 🔑 CLAVE: reasignar SIEMPRE que cambie el personaje
    player.CharacterAdded:Connect(function(char)
        -- Esperar a que el HumanoidRootPart cargue
        char:WaitForChild("HumanoidRootPart", 10)
        if hl and hl.Parent then
            hl.Adornee = char
        end
    end)
end

--// ❌ Eliminar highlight
local function removeHighlight(player)
    local hl = highlights[player]
    if hl then
        pcall(function() hl:Destroy() end)
        highlights[player] = nil
    end
end

--// 🔄 Aplicar a TODOS los jugadores del server
for _, player in ipairs(Players:GetPlayers()) do
    createHighlight(player)
end

Players.PlayerAdded:Connect(createHighlight)
Players.PlayerRemoving:Connect(removeHighlight)

--// 🔁 LOOP que revisa constantemente todos los jugadores
-- Esto arregla el problema de personajes que cargan tarde o lejos
task.spawn(function()
    while task.wait(0.5) do
        for _, player in ipairs(Players:GetPlayers()) do
            if IGNORE_LOCAL and player == LocalPlayer then continue end

            local hl = highlights[player]
            local char = player.Character

            -- Si no tiene highlight, crearlo
            if not hl then
                createHighlight(player)
                hl = highlights[player]
            end

            -- Si tiene personaje pero el Adornee está mal o nil, reasignarlo
            if hl and hl.Parent then
                if char and hl.Adornee ~= char then
                    hl.Adornee = char
                elseif not char and hl.Adornee then
                    hl.Adornee = nil
                end
            end
        end
    end
end)
