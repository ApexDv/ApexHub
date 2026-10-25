local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // SISTEMA DE DONO //
local SEU_ID = 7362723389
local isOwner = (LocalPlayer.UserId == SEU_ID)

-- Variáveis de Controle
local Aimlock = false
local TP_Gun_Ativo = false
local MiraPausada = false
local PausarAoArrastar = false
local ESP_Murder = false
local ESP_Sheriff = false
local ESP_Player = false
local ESP_Gun = false

local ESP_Objects = {} 
local JanelaAimlock = nil 
local JanelaTPGun = nil
local GunESP_Gui = nil 

-- Cores
local ColorNormal = Color3.fromRGB(255, 255, 255)
local ColorSheriff = Color3.fromRGB(0, 150, 255) 
local ColorMurder = Color3.fromRGB(255, 0, 0)    
local ColorGun = Color3.fromRGB(255, 255, 0) 

-- // TAG DE DONO //
if isOwner then
    local ownerTag = Instance.new("TextLabel")
    ownerTag.Name = "OwnerTag"
    ownerTag.Parent = game.CoreGui
    ownerTag.Size = UDim2.new(0, 100, 0, 30)
    ownerTag.Position = UDim2.new(0, 10, 0, 10)
    ownerTag.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- Dourado
    ownerTag.Text = "👑 DONO"
    ownerTag.TextColor3 = Color3.fromRGB(0, 0, 0)
    ownerTag.Font = Enum.Font.GothamBold
    ownerTag.TextSize = 14
    ownerTag.BorderSizePixel = 0
    Instance.new("UICorner", ownerTag).CornerRadius = UDim.new(0, 6)
    print("Bem-vindo, Dono do ApexHub!")
end

-- // FUNÇÃO TP GUN //
local function FindGunDrop()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "GunDrop" then return obj end
    end
    return nil
end

local function ExecuteTPGun()
    local gunDrop = FindGunDrop()
    local char = LocalPlayer.Character
    if gunDrop and char and char:FindFirstChild("HumanoidRootPart") then
        local oldPos = char.HumanoidRootPart.CFrame
        char:PivotTo(CFrame.new(gunDrop.Position + Vector3.new(0, 3, 0)))
        task.wait(0.4) 
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:PivotTo(oldPos)
        end
        Rayfield:Notify({Title = "TP Arma", Content = "Arma coletada!", Duration = 3})
    else
        Rayfield:Notify({Title = "TP Arma", Content = "Nenhuma arma no chão.", Duration = 3})
    end
end

-- // JANELA FLUTUANTE: AIMLOCK (Com Animação) //
local function CreateAimlockWindow()
    if JanelaAimlock then return end
    JanelaAimlock = Instance.new("ScreenGui")
    JanelaAimlock.Name = "ApexAimlockWindow"
    JanelaAimlock.ResetOnSpawn = false
    JanelaAimlock.Parent = game.CoreGui

    local AimBtn = Instance.new("TextButton")
    AimBtn.Size = UDim2.new(0, 120, 0, 45) 
    AimBtn.Position = UDim2.new(0, 20, 0.5, -50) 
    AimBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20) 
    AimBtn.Text = "AIMLOCK ON"
    AimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimBtn.Font = Enum.Font.GothamBold
    AimBtn.TextSize = 14
    AimBtn.Parent = JanelaAimlock
    Instance.new("UICorner", AimBtn).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", AimBtn)
    stroke.Color = Color3.fromRGB(0, 150, 255)
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    task.spawn(function()
        while JanelaAimlock and JanelaAimlock.Parent do
            if not MiraPausada then
                local tween1 = TweenService:Create(stroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.5, Thickness = 3})
                tween1:Play()
                tween1.Completed:Wait()
                local tween2 = TweenService:Create(stroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0, Thickness = 2})
                tween2:Play()
                tween2.Completed:Wait()
            else
                stroke.Transparency = 0.8
                task.wait(0.5)
            end
        end
    end)

    local dragging, dragInput, dragStart, startPos
    local touchStartTime = 0

    AimBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            PausarAoArrastar = true 
            touchStartTime = os.clock()
            dragStart = input.Position
            startPos = AimBtn.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    PausarAoArrastar = false 
                    if os.clock() - touchStartTime < 0.2 then
                        MiraPausada = not MiraPausada
                        if MiraPausada then
                            AimBtn.Text = "AIMLOCK OFF"
                            AimBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
                            stroke.Color = Color3.fromRGB(100, 100, 100)
                        else
                            AimBtn.Text = "AIMLOCK ON"
                            AimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                            stroke.Color = Color3.fromRGB(0, 150, 255)
                        end
                    end
                end
            end)
        end
    end)

    AimBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then touchStartTime = 0 end
            AimBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- // JANELA FLUTUANTE: TP GUN (Com Animação) //
local function CreateTPGunWindow()
    if JanelaTPGun then return end
    JanelaTPGun = Instance.new("ScreenGui")
    JanelaTPGun.Name = "ApexTPGunWindow"
    JanelaTPGun.ResetOnSpawn = false
    JanelaTPGun.Parent = game.CoreGui

    local TPBtn = Instance.new("TextButton")
    TPBtn.Size = UDim2.new(0, 120, 0, 45) 
    TPBtn.Position = UDim2.new(0, 20, 0.5, 10) 
    TPBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20) 
    TPBtn.Text = "PEGAR ARMA"
    TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TPBtn.Font = Enum.Font.GothamBold
    TPBtn.TextSize = 14
    TPBtn.Parent = JanelaTPGun
    Instance.new("UICorner", TPBtn).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", TPBtn)
    stroke.Color = Color3.fromRGB(255, 150, 0)
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    task.spawn(function()
        local rotation = 0
        while JanelaTPGun and JanelaTPGun.Parent do
            rotation = (rotation + 10) % 360
            local color = Color3.fromHSV(rotation / 360, 1, 1)
            stroke.Color = color
            task.wait(0.1)
        end
    end)

    TPBtn.MouseButton1Click:Connect(ExecuteTPGun)

    local dragging, dragInput, dragStart, startPos

    TPBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = TPBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    TPBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TPBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- // FUNÇÕES DO ESP (JOGADORES) //
local function RemoveESP(player)
    if ESP_Objects[player] then
        if ESP_Objects[player].Highlight then ESP_Objects[player].Highlight:Destroy() end
        if ESP_Objects[player].Billboard then ESP_Objects[player].Billboard:Destroy() end
        ESP_Objects[player] = nil
    end
end

local function CreateESP(player)
    if player == LocalPlayer or not player.Character then return end
    local char = player.Character
    local head = char:FindFirstChild("Head")
    if not head then return end
    RemoveESP(player)

    local highlight = Instance.new("Highlight")
    highlight.Name = "ApexESP"
    highlight.Adornee = char
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    highlight.Enabled = false 
    highlight.Parent = char

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ApexNameESP"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = char

    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboard
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 16
    textLabel.TextStrokeTransparency = 0
    textLabel.TextColor3 = ColorNormal
    textLabel.Text = ""

    ESP_Objects[player] = { Highlight = highlight, Billboard = billboard, Text = textLabel }
end

local function ForceESPCheck()
    if not ESP_Murder and not ESP_Sheriff and not ESP_Player then return end
    
    for player, data in pairs(ESP_Objects) do
        if not player.Parent or not player.Character or not player.Character:FindFirstChild("Head") then
            RemoveESP(player)
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if not ESP_Objects[player] then CreateESP(player) end
        end
    end

    for player, data in pairs(ESP_Objects) do
        if player.Character then
            local backpack = player.Backpack
            local character = player.Character
            local isSheriff = backpack:FindFirstChild("Gun") or character:FindFirstChild("Gun")
            local isMurder = backpack:FindFirstChild("Knife") or character:FindFirstChild("Knife")

            if isMurder and ESP_Murder then
                data.Highlight.Enabled = true
                data.Text.Text = "Assassino"
                data.Highlight.FillColor = ColorMurder
                data.Text.TextColor3 = ColorMurder
            elseif isSheriff and ESP_Sheriff then
                data.Highlight.Enabled = true
                data.Text.Text = "Xerife"
                data.Highlight.FillColor = ColorSheriff
                data.Text.TextColor3 = ColorSheriff
            elseif not isMurder and not isSheriff and ESP_Player then
                data.Highlight.Enabled = true
                data.Text.Text = "Inocente"
                data.Highlight.FillColor = ColorNormal
                data.Text.TextColor3 = ColorNormal
            else
                data.Highlight.Enabled = false
                data.Text.Text = ""
            end
        end
    end
end

-- // LÓGICA DO AIMLOCK //
RunService.RenderStepped:Connect(function()
    if not Aimlock or MiraPausada or PausarAoArrastar then 
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        return 
    end

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("Head") then return end

    local closestDist = math.huge
    local targetPart = nil
    local viewportCenter = Camera.ViewportSize / 2

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife") then
                local head = player.Character.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        targetPart = head
                    end
                end
            end
        end
    end

    if targetPart then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

-- // INTERFACE RAYFIELD //
local Window = Rayfield:CreateWindow({
   Name = isOwner and "👑 Painel do Dono" or "", 
   LoadingTitle = "",
   LoadingSubtitle = "",
   ConfigurationSaving = {Enabled = false},
   KeySystem = false
})

local UpdateTab = Window:CreateTab("Atualizações",  "alert-triangle") 
local GameTab = Window:CreateTab("Game", "gamepad-2") 
local EspTab = Window:CreateTab("ESP", "eye") 

UpdateTab:CreateParagraph({Title = "Atualizações", Content = isOwner and "Bem-vindo, Dono! Acesso total liberado." or "Adicionado animações neon nas janelas flutuantes."})

-- ABA GAME
GameTab:CreateToggle({
   Name = "Aimlock",
   CurrentValue = false,
   Flag = "Aimlock",
   Callback = function(Value) 
       Aimlock = Value 
       if Aimlock then 
           MiraPausada = false 
           CreateAimlockWindow() 
       else 
           if JanelaAimlock then JanelaAimlock:Destroy() JanelaAimlock = nil end 
           UserInputService.MouseBehavior = Enum.MouseBehavior.Default
       end
   end,
})

GameTab:CreateToggle({
   Name = "Tp Gun",
   CurrentValue = false,
   Flag = "TPGun",
   Callback = function(Value) 
       TP_Gun_Ativo = Value 
       if TP_Gun_Ativo then 
           CreateTPGunWindow() 
       else 
           if JanelaTPGun then JanelaTPGun:Destroy() JanelaTPGun = nil end 
       end
   end,
})

-- ABA ESP
EspTab:CreateToggle({
   Name = "ESP Murder",
   CurrentValue = false,
   Flag = "ESPMurder",
   Callback = function(Value) 
       ESP_Murder = Value 
       ForceESPCheck() 
   end,
})

EspTab:CreateToggle({
   Name = "ESP Xerife",
   CurrentValue = false,
   Flag = "ESPSheriff",
   Callback = function(Value) 
       ESP_Sheriff = Value 
       ForceESPCheck()
   end,
})

EspTab:CreateToggle({
   Name = "ESP Player",
   CurrentValue = false,
   Flag = "ESPPlayer",
   Callback = function(Value) 
       ESP_Player = Value 
       ForceESPCheck()
   end,
})

EspTab:CreateToggle({
   Name = "ESP Gun",
   CurrentValue = false,
   Flag = "ESPGun",
   Callback = function(Value)
       ESP_Gun = Value
       if not Value and GunESP_Gui then
           GunESP_Gui:Destroy()
           GunESP_Gui = nil
       end
   end,
})

-- // LOOPS E EVENTOS DE CORREÇÃO //
task.spawn(function()
    while task.wait(0.5) do ForceESPCheck() end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        ForceESPCheck() 
    end)
end)

Workspace.ChildRemoved:Connect(function(child)
    if child:IsA("Model") and child:FindFirstChild("Humanoid") then
        task.wait(1)
        ForceESPCheck() 
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    ForceESPCheck()
end)

task.spawn(function()
    while task.wait(0.2) do
        if ESP_Gun then
            local gunDrop = FindGunDrop()
            local myChar = LocalPlayer.Character
            
            if gunDrop and myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local distance = (myChar.HumanoidRootPart.Position - gunDrop.Position).Magnitude
                if distance <= 150 then
                    if not GunESP_Gui then
                        GunESP_Gui = Instance.new("BillboardGui")
                        GunESP_Gui.Name = "ApexGunTextESP"
                        GunESP_Gui.Size = UDim2.new(0, 100, 0, 50)
                        GunESP_Gui.StudsOffset = Vector3.new(0, 2, 0)
                        GunESP_Gui.AlwaysOnTop = true
                        GunESP_Gui.Parent = gunDrop
                        
                        local textLabel = Instance.new("TextLabel")
                        textLabel.Parent = GunESP_Gui
                        textLabel.BackgroundTransparency = 1
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.Font = Enum.Font.GothamBold
                        textLabel.TextSize = 16
                        textLabel.TextStrokeTransparency = 0
                        textLabel.TextColor3 = ColorGun
                        textLabel.Text = "Gun"
                    end
                    if GunESP_Gui.Parent ~= gunDrop then GunESP_Gui.Parent = gunDrop end
                else
                    if GunESP_Gui then GunESP_Gui:Destroy() GunESP_Gui = nil end
                end
            else
                if GunESP_Gui then GunESP_Gui:Destroy() GunESP_Gui = nil end
            end
        end
    end
end)
