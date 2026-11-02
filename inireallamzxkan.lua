-- LAMZX SCRIPT STEAL AN EGG
-- Auto steal eggs to furthest point

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local CONFIG = {
    WalkSpeed   = 100,
    JumpPower   = 80,
    AutoSteal   = true,
    StealRadius = 60,
    Delay       = 0.05,
}

-- Noclip
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

-- Speed boost
hum.WalkSpeed = CONFIG.WalkSpeed
hum.JumpPower = CONFIG.JumpPower

-- Teleport to furthest egg
local function getFurthestEgg()
    local furthest = nil
    local maxDist  = 0

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

-- Steal loop
local function stealLoop()
    while CONFIG.AutoSteal do
        local egg = getFurthestEgg()
        if egg then
            noclip = true
            hrp.CFrame = egg.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.1)

            -- Simulate touch / interact
            local touchFn = egg.Touched
            if touchFn then
                pcall(function() touchFn:Fire(hrp) end)
            end

            -- Try RemoteEvent trigger
            for _, v in ipairs(game:GetDescendants()) do
                if v:IsA("RemoteEvent") and (
                    v.Name:lower():find("steal") or
                    v.Name:lower():find("egg") or
                    v.Name:lower():find("collect") or
                    v.Name:lower():find("grab")
                ) then
                    pcall(function() v:FireServer(egg) end)
                end
            end

            noclip = false
        end
        task.wait(CONFIG.Delay)
    end
end

-- GUI
local sg = Instance.new("ScreenGui", lp.PlayerGui)
sg.Name          = "LAMZX_GUI"
sg.ResetOnSpawn  = false

local frame = Instance.new("Frame", sg)
frame.Size            = UDim2.new(0, 220, 0, 130)
frame.Position        = UDim2.new(0.01, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
frame.BorderSizePixel = 0

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Text              = "LAMZX SCRIPT"
title.Size              = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3  = Color3.fromRGB(99, 102, 241)
title.TextColor3        = Color3.new(1,1,1)
title.Font              = Enum.Font.GothamBold
title.TextSize          = 13
title.BorderSizePixel   = 0

local sub = Instance.new("TextLabel", frame)
sub.Text             = "STEAL AN EGG — FURTHEST TARGET"
sub.Size             = UDim2.new(1, 0, 0, 20)
sub.Position         = UDim2.new(0, 0, 0, 30)
sub.BackgroundTransparency = 1
sub.TextColor3       = Color3.fromRGB(148, 163, 184)
sub.Font             = Enum.Font.Gotham
sub.TextSize         = 10

local statusLbl = Instance.new("TextLabel", frame)
statusLbl.Text             = "Status: RUNNING"
statusLbl.Size             = UDim2.new(1, 0, 0, 20)
statusLbl.Position         = UDim2.new(0, 0, 0, 55)
statusLbl.BackgroundTransparency = 1
statusLbl.TextColor3       = Color3.fromRGB(34, 197, 94)
statusLbl.Font             = Enum.Font.Gotham
statusLbl.TextSize         = 11

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Text              = "STOP"
toggleBtn.Size              = UDim2.new(0.9, 0, 0, 32)
toggleBtn.Position          = UDim2.new(0.05, 0, 0, 85)
toggleBtn.BackgroundColor3  = Color3.fromRGB(239, 68, 68)
toggleBtn.TextColor3        = Color3.new(1,1,1)
toggleBtn.Font              = Enum.Font.GothamBold
toggleBtn.TextSize          = 12
toggleBtn.BorderSizePixel   = 0

local btnCorner = Instance.new("UICorner", toggleBtn)
btnCorner.CornerRadius = UDim.new(0, 7)

toggleBtn.MouseButton1Click:Connect(function()
    CONFIG.AutoSteal = not CONFIG.AutoSteal
    if CONFIG.AutoSteal then
        toggleBtn.Text             = "STOP"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        statusLbl.Text             = "Status: RUNNING"
        statusLbl.TextColor3       = Color3.fromRGB(34, 197, 94)
        task.spawn(stealLoop)
    else
        toggleBtn.Text             = "START"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
        statusLbl.Text             = "Status: STOPPED"
        statusLbl.TextColor3       = Color3.fromRGB(239, 68, 68)
    end
end)

-- Respawn handler
lp.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp  = newChar:WaitForChild("HumanoidRootPart")
    hum  = newChar:WaitForChild("Humanoid")
    hum.WalkSpeed = CONFIG.WalkSpeed
    hum.JumpPower = CONFIG.JumpPower
    if CONFIG.AutoSteal then task.spawn(stealLoop) end
end)

task.spawn(stealLoop)
print("[LAMZX] Steal An Egg — Active | Target: Furthest Egg")
