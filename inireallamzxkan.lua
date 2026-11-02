-- LAMZX SCRIPT STEAL AN EGG + BYPASS BAN
-- Full toggle: Auto Steal + Bypass via button

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local STATE = {
    AutoSteal   = false,
    BypassActive = false,
    AutoRejoin  = false,
}

local placeId = game.PlaceId

-- ============================================
-- BYPASS MODULE (toggled)
-- ============================================

local bypassConnections = {}

local function enableBypass()
    -- Spoof display name
    pcall(function()
        lp.DisplayName = "Player_" .. math.random(10000, 99999)
    end)

    -- Auto rejoin on kick
    local c = lp.AncestryChanged:Connect(function(_, parent)
        if not parent and STATE.AutoRejoin then
            task.wait(1.5)
            TeleportService:Teleport(placeId)
        end
    end)
    table.insert(bypassConnections, c)

    -- Intercept ban remotes via metatable
    pcall(function()
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" or method == "InvokeServer" then
                local args = {...}
                if args[1] and type(args[1]) == "string" then
                    local lower = args[1]:lower()
                    if lower:find("ban") or lower:find("kick") or lower:find("report") then
                        return nil
                    end
                end
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)

    -- Block ban RemoteEvents
    pcall(function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local n = v.Name:lower()
                if n:find("ban") or n:find("kick") or n:find("report") then
                    local mt2 = getrawmetatable(v)
                    setreadonly(mt2, false)
                    mt2.__namecall = newcclosure(function() return nil end)
                    setreadonly(mt2, true)
                end
            end
        end
    end)

    STATE.BypassActive = true
end

local function disableBypass()
    for _, c in ipairs(bypassConnections) do
        c:Disconnect()
    end
    bypassConnections = {}
    STATE.BypassActive = false
end

-- ============================================
-- STEAL MODULE (toggled)
-- ============================================

hum.WalkSpeed = 100
hum.JumpPower = 80

local noclip = false
RunService.Stepped:Connect(function()
    if noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local function getFurthestEgg()
    local furthest, maxDist = nil, 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("egg") and obj:IsA("BasePart") then
            local dist = (obj.Position - hrp.Position).Magnitude
            if dist > maxDist then
                maxDist  = dist
                furthest = obj
            end
        end
    end
    return furthest
end

local function stealLoop()
    while STATE.AutoSteal do
        local egg = getFurthestEgg()
        if egg then
            noclip = true
            local offset = Vector3.new(math.random(-2,2), 3, math.random(-2,2))
            hrp.CFrame = egg.CFrame + offset
            task.wait(0.1)
            pcall(function() egg.Touched:Fire(hrp) end)
            for _, v in ipairs(game:GetDescendants()) do
                if v:IsA("RemoteEvent") then
                    local n = v.Name:lower()
                    if n:find("steal") or n:find("egg") or n:find("collect") or n:find("grab") then
                        pcall(function() v:FireServer(egg) end)
                    end
                end
            end
            noclip = false
        end
        task.wait(0.05)
    end
end

lp.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp  = newChar:WaitForChild("HumanoidRootPart")
    hum  = newChar:WaitForChild("Humanoid")
    hum.WalkSpeed = 100
    hum.JumpPower = 80
    if STATE.AutoSteal then task.spawn(stealLoop) end
end)

-- ============================================
-- GUI
-- ============================================

local sg = Instance.new("ScreenGui", lp.PlayerGui)
sg.Name         = "LAMZX_GUI"
sg.ResetOnSpawn = false

local frame = Instance.new("Frame", sg)
frame.Size             = UDim2.new(0, 240, 0, 220)
frame.Position         = UDim2.new(0.01, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
frame.BorderSizePixel  = 0
frame.Active           = true
frame.Draggable        = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- Title bar
local titleBar = Instance.new("Frame", frame)
titleBar.Size             = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
titleBar.BorderSizePixel  = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleLbl = Instance.new("TextLabel", titleBar)
titleLbl.Text      = "LAMZX SCRIPT"
titleLbl.Size      = UDim2.new(1, 0, 1, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.TextColor3 = Color3.new(1,1,1)
titleLbl.Font      = Enum.Font.GothamBold
titleLbl.TextSize  = 13

-- Helper: buat toggle button
local function makeToggle(parent, yPos, labelOff, labelOn, colorOn, colorOff, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size             = UDim2.new(0.9, 0, 0, 36)
    btn.Position         = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = colorOff
    btn.TextColor3       = Color3.new(1,1,1)
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 12
    btn.Text             = labelOff
    btn.BorderSizePixel  = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.Text             = labelOn
            btn.BackgroundColor3 = colorOn
        else
            btn.Text             = labelOff
            btn.BackgroundColor3 = colorOff
        end
        callback(active)
    end)

    return btn
end

-- Auto Steal toggle
makeToggle(
    frame, 42,
    "AUTO STEAL  [ OFF ]",
    "AUTO STEAL  [ ON ]",
    Color3.fromRGB(34, 197, 94),
    Color3.fromRGB(55, 55, 75),
    function(on)
        STATE.AutoSteal = on
        if on then task.spawn(stealLoop) end
    end
)

-- Bypass Ban toggle
makeToggle(
    frame, 88,
    "BYPASS BAN  [ OFF ]",
    "BYPASS BAN  [ ON ]",
    Color3.fromRGB(168, 85, 247),
    Color3.fromRGB(55, 55, 75),
    function(on)
        if on then
            enableBypass()
        else
            disableBypass()
        end
    end
)

-- Auto Rejoin toggle
makeToggle(
    frame, 134,
    "AUTO REJOIN  [ OFF ]",
    "AUTO REJOIN  [ ON ]",
    Color3.fromRGB(251, 191, 36),
    Color3.fromRGB(55, 55, 75),
    function(on)
        STATE.AutoRejoin = on
    end
)

-- Manual Rejoin button
local rejoinBtn = Instance.new("TextButton", frame)
rejoinBtn.Text              = "MANUAL REJOIN"
rejoinBtn.Size              = UDim2.new(0.9, 0, 0, 28)
rejoinBtn.Position          = UDim2.new(0.05, 0, 0, 182)
rejoinBtn.BackgroundColor3  = Color3.fromRGB(30, 30, 50)
rejoinBtn.TextColor3        = Color3.fromRGB(148, 163, 184)
rejoinBtn.Font              = Enum.Font.Gotham
rejoinBtn.TextSize          = 11
rejoinBtn.BorderSizePixel   = 0
Instance.new("UICorner", rejoinBtn).CornerRadius = UDim.new(0, 7)

rejoinBtn.MouseButton1Click:Connect(function()
    TeleportService:Teleport(placeId)
end)

print("[LAMZX] Loaded — toggle via GUI")
