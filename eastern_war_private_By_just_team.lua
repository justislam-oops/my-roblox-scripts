local P, R, U, Twn = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("TweenService")
local lp, esp, vesp, spd, nrec, jmp, cspd = P.LocalPlayer, false, false, false, false, false, 20
local cam = workspace.CurrentCamera

if game:GetService("CoreGui"):FindFirstChild("EWM") then game:GetService("CoreGui").EWM:Destroy() end
local G = Instance.new("ScreenGui", game:GetService("CoreGui")) G.Name = "EWM"

local tracers = {}

-- Главное Окно
local M = Instance.new("Frame", G) M.Size = UDim2.new(0, 240, 0, 310) M.Position = UDim2.new(0.4, 0, 0.3, 0) M.BackgroundColor3 = Color3.fromRGB(15, 15, 18) M.BorderSizePixel = 0 M.Active = true M.Draggable = true
Instance.new("UICorner", M).CornerRadius = UDim.new(0, 9)
local ms = Instance.new("UIStroke", M) ms.Color = Color3.fromRGB(45, 45, 55) ms.Thickness = 1 ms.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Заголовок меню
local T = Instance.new("TextLabel", M) T.Size = UDim2.new(1, 0, 0, 35) T.Text = "  EASTERN WAR // PRIVATE" T.TextColor3 = Color3.fromRGB(240, 240, 240) T.Font = Enum.Font.GothamBold T.TextSize = 13 T.TextXAlignment = Enum.TextXAlignment.Left T.BackgroundColor3 = Color3.fromRGB(22, 22, 26) T.BorderSizePixel = 0
Instance.new("UICorner", T).CornerRadius = UDim.new(0, 9)
local tg = Instance.new("UIGradient", T) tg.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 38)), ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 25))}

-- Кнопки интерфейса
local function btn(txt, pos, cb)
    local B = Instance.new("TextButton", M) B.Size = UDim2.new(0, 200, 0, 32) B.Position = UDim2.new(0, 20, 0, pos) B.BackgroundColor3 = Color3.fromRGB(26, 26, 32) B.Text = "  " .. txt B.TextColor3 = Color3.fromRGB(180, 180, 190) B.Font = Enum.Font.GothamSemibold B.TextSize = 11 B.TextXAlignment = Enum.TextXAlignment.Left B.BorderSizePixel = 0
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
    local bs = Instance.new("UIStroke", B) bs.Color = Color3.fromRGB(40, 40, 48) bs.Thickness = 1

    local active = false
    B.MouseButton1Click:Connect(function()
        active = not active
        cb(active)
        local targetColor = active and Color3.fromRGB(35, 115, 75) or Color3.fromRGB(26, 26, 32)
        local targetStroke = active and Color3.fromRGB(50, 180, 110) or Color3.fromRGB(40, 40, 48)
        local targetText = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
        Twn:Create(B, TweenInfo.new(0.2), {BackgroundColor3 = targetColor, TextColor3 = targetText}):Play()
        Twn:Create(bs, TweenInfo.new(0.2), {Color = targetStroke}):Play()
    end)
    return B
end

btn("ESP Players + Tracers", 45, function(v) esp = v end)
btn("ESP Vehicles", 82, function(v) vesp = v end)
btn("Speedhack Bypass", 119, function(v) spd = v end)

-- Слайдер Скорости
local SliderFrame = Instance.new("Frame", M) SliderFrame.Size = UDim2.new(0, 200, 0, 32) SliderFrame.Position = UDim2.new(0, 20, 0, 156) SliderFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28) SliderFrame.BorderSizePixel = 0
Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)

local Ind = Instance.new("TextLabel", SliderFrame) Ind.Size = UDim2.new(0, 120, 0, 32) Ind.Position = UDim2.new(0, 40, 0, 0) Ind.Text = "Speed: " .. cspd Ind.TextColor3 = Color3.fromRGB(150, 160, 175) Ind.Font = Enum.Font.GothamBold Ind.TextSize = 11 Ind.BackgroundTransparency = 1

local function createSliderBtn(txt, pos, offset)
    local b = Instance.new("TextButton", SliderFrame) b.Size = UDim2.new(0, 32, 0, 32) b.Position = pos b.BackgroundColor3 = Color3.fromRGB(32, 32, 40) b.Text = txt b.TextColor3 = Color3.fromRGB(255, 255, 255) b.Font = Enum.Font.GothamBold b.TextSize = 14 b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        cspd = math.clamp(cspd + offset, 5, 150)
        Ind.Text = "Speed: " .. cspd
    end)
end
createSliderBtn("-", UDim2.new(0, 0, 0, 0), -5)
createSliderBtn("+", UDim2.new(0, 168, 0, 0), 5)

btn("No Recoil / CamShake", 193, function(v) nrec = v end)
btn("Infinite Jump", 230, function(v) jmp = v end)

-- Стабильный Raycast
local function checkVisible(targetPart)
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return false end
    
    local origin = cam.CFrame.Position
    local dest = targetPart.Position
    local direction = dest - origin
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    
    -- Игнорируем себя, цель и все декоративные аксессуары (исключаем ложные преграды)
    local ignoreList = {lp.Character, targetPart.Parent}
    for _, item in pairs(targetPart.Parent:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Tool") then table.insert(ignoreList, item) end
    end
    params.FilterDescendantsInstances = ignoreList
    
    local res = workspace:Raycast(origin, direction, params)
    return res == nil
end

local function getTracer(player)
    if not tracers[player] then
        local line = Drawing.new("Line")
        line.Thickness = 2.0 -- Чуть увеличил жирность для видимости
        line.Transparency = 1.0
        tracers[player] = line
    end
    return tracers[player]
end

local function removeTracer(player)
    if tracers[player] then tracers[player]:Remove() tracers[player] = nil end
end

-- Физика перемещения
R.Heartbeat:Connect(function()
    if spd and lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character.Humanoid.MoveDirection.Magnitude > 0 then
        lp.Character:TranslateBy(lp.Character.Humanoid.MoveDirection * (cspd / 150))
    end
end)

U.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Space and jmp and lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
        lp.Character:FindFirstChildOfClass("Humanoid"):ChangeState(3)
    end
    if i.KeyCode == Enum.KeyCode.Insert then M.Visible = not M.Visible end
end)

-- Рендер-Линк с приоритетом камеры (Убирает микро-тряску линий)
R:BindToRenderStep("ExTracers", Enum.RenderPriority.Camera.Value + 1, function()
    -- Кадровая блокировка отдачи и жесткой тряски камеры
    if nrec and lp.Character then
        if lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.CameraOffset = Vector3.new(0, 0, 0) -- Обнуление тряски тела
        end
        -- Жесткий сброс угловой тряски камеры
        cam.CFrame = CFrame.new(cam.CFrame.Position) * cam.CFrame.Rotation 
        
        -- Сброс конфигураций оружия
        for _, t in pairs(lp.Character:GetChildren()) do
            if t:IsA("Tool") then
                for _, v in pairs(t:GetDescendants()) do
                    if v:IsA("NumberValue") or v:IsA("IntValue") then
                        if v.Name:find("Recoil") or v.Name:find("Spread") or v.Name:find("Shake") or v.Name:find("CamShake") then v.Value = 0 end
                    elseif v:IsA("BoolValue") and (v.Name == "Shake" or v.Name == "RecoilEnabled") then v.Value = false end
                end
            end
        end
    end

    if esp then
        for _, p in pairs(P:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                local line = getTracer(p)
                
                local b = p.Character:FindFirstChild("tESP")
                if not b then
                    b = Instance.new("BoxHandleAdornment", p.Character) b.Name = "tESP" b.Size = Vector3.new(4, 6, 4) b.AlwaysOnTop = true b.ZIndex = 5 b.Transparency = 0.7 b.Adornee = hrp
                end
                
                local calculatedColor
                if p.Team == lp.Team then
                    calculatedColor = Color3.fromRGB(40, 200, 100)
                else
                    if checkVisible(hrp) then
                        calculatedColor = Color3.fromRGB(230, 50, 230) -- Виден (Фиолетовый)
                    else
                        calculatedColor = Color3.fromRGB(240, 50, 50)  -- Спрятан (Красный)
                    end
                end
                
                b.Color3 = calculatedColor
                
                if onScreen and p.Team ~= lp.Team then
                    line.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                    line.To = Vector2.new(screenPos.X, screenPos.Y)
                    line.Color = calculatedColor
                    line.Visible = true
                else
                    line.Visible = false
                end
            else
                removeTracer(p)
            end
        end
    else
        for _, p in pairs(P:GetPlayers()) do 
            if p.Character and p.Character:FindFirstChild("tESP") then p.Character.tESP:Destroy() end 
            removeTracer(p)
        end
    end
end)

workspace.DescendantAdded:Connect(function(o)
    if vesp and (o:IsA("VehicleSeat") or (o:IsA("Model") and (o.Name:lower():find("drone") or o.Name:lower():find("car")))) then
        local p = o:IsA("VehicleSeat") and o or o:FindFirstChildOfClass("Part")
        if p and not p:FindFirstChild("vESP") then
            local b = Instance.new("BoxHandleAdornment", p) b.Name = "vESP" b.Size = Vector3.new(10, 8, 14) b.AlwaysOnTop = true b.ZIndex = 4 b.Color3 = Color3.fromRGB(240, 180, 30) b.Transparency = 0.7 b.Adornee = p
        end
    end
end)

P.PlayerRemoving:Connect(removeTracer)
