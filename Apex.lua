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

-- // DESATIVAR NOME BRANCO DO ROBLOX //
local function DisableDefaultName(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end
end

for _, p in pairs(Players:GetPlayers()) do
    if p.Character then DisableDefaultName(p.Character) end
    p.CharacterAdded:Connect(DisableDefaultName)
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(DisableDefaultName)
end)

-- // TAG DONO //
if isOwner then
    task.spawn(function()
        while task.wait(0.5) do
            local char = LocalPlayer.Character
            local head = char and char:FindFirstChild("Head")
            if head and not head:FindFirstChild("OwnerTagGui") then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "OwnerTagGui"
                billboard.Adornee = head
                billboard.Size = UDim2.new(0, 150, 0, 30)
                billboard.StudsOffset = Vector3.new(0, 2.5, 0) 
                billboard.AlwaysOnTop = true
                billboard.Parent = head
                
                local tag = Instance.new("TextLabel")
                tag.Parent = billboard
                tag.BackgroundTransparency = 1
                tag.Size = UDim2.new(1, 0, 1, 0)
                tag.Font = Enum.Font.GothamBold
                tag.Text = "👑 DONO"
                tag.TextColor3 = Color3.fromRGB(255, 215, 0)
                tag.TextSize = 18
                tag.TextStrokeTransparency = 0
            end
        end
    end)
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
    end
end

-- // SISTEMA DE ESP POR DESENHO (DRAWING) //
local function CreateDrawingESP(player)
    if player == LocalPlayer or not player.Character then return end
    if ESP_Objects[player] then return end

    local text = Drawing.new("Text")
    text.Center = true
    text.Outline = true
    text.Size = 15       
    text.Font = 3        
    text.Visible = false
    
    ESP_Objects[player] = text
end

local function RemoveDrawingESP(player)
    if ESP_Objects[player] then
        ESP_Objects[player]:Remove()
        ESP_Objects[player] = nil
    end
end

-- // LÓGICA DO AIMLOCK //
RunService.RenderStepped:Connect(function()
    if not Aimlock or MiraPausada or PausarAoArrastar then UserInputService.MouseBehavior = Enum.MouseBehavior.Default return end
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
                    if dist < closestDist then closestDist = dist targetPart = head end
                end
            end
        end
    end
    if targetPart then UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position) else UserInputService.MouseBehavior = Enum.MouseBehavior.Default end
end)

-- // ATUALIZAÇÃO DO ESP //
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local head = char and char:FindFirstChild("Head")
            local esp = ESP_Objects[player]

            if head and esp then
                local vector, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 3, 0))
                
                if onScreen then
                    esp.Position = Vector2.new(vector.X, vector.Y)
                    esp.Text = player.Name
                    
                    local backpack = player:FindFirstChild("Backpack")
                    local gui = player:FindFirstChild("PlayerGui")
                    
                    local hasKnife = (backpack and backpack:FindFirstChild("Knife")) or char:FindFirstChild("Knife") or (gui and gui:FindFirstChild("Murderer", true))
                    local hasGun = (backpack and backpack:FindFirstChild("Gun")) or char:FindFirstChild("Gun") or (gui and gui:FindFirstChild("Sheriff", true))

                    if hasKnife and ESP_Murder then
                        esp.Color = Color3.fromRGB(255, 50, 50) 
                        esp.Visible = true
                    elseif hasGun and ESP_Sheriff then
                        esp.Color = Color3.fromRGB(50, 150, 255) 
                        esp.Visible = true
                    elseif not hasKnife and not hasGun and ESP_Player then
                        esp.Color = Color3.fromRGB(0, 255, 0) 
                        esp.Visible = true
                    else
                        esp.Visible = false
                    end
                else
                    esp.Visible = false
                end
            elseif esp then
                esp.Visible = false
            end
        end
    end
end)

-- // GERENCIADOR DE ENTRADA/SAÍDA //
task.spawn(function()
    while task.wait(0.5) do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                if not ESP_Objects[player] then
                    CreateDrawingESP(player)
                end
                DisableDefaultName(player.Character)
            end
        end
        
        for player, esp in pairs(ESP_Objects) do
            if not player.Parent or not player.Character then
                RemoveDrawingESP(player)
            end
        end
    end
end)

-- // JANELA DO AIMLOCK //
local function CreateAimlockWindow()
    if JanelaAimlock then return end
    JanelaAimlock = Instance.new("ScreenGui")
    JanelaAimlock.Name = "ApexAimlockWindow"
    JanelaAimlock.ResetOnSpawn = false
    JanelaAimlock.Parent = game.CoreGui

    local AimBtn = Instance.new("TextButton")
    AimBtn.Size = UDim2.new(0, 240, 0, 80) 
    AimBtn.Position = UDim2.new(0, 20, 0.5, -100) 
    AimBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) 
    AimBtn.BackgroundTransparency = 0.4
    AimBtn.Text = "Aimlock"
    AimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimBtn.Font = Enum.Font.Gotham
    AimBtn.TextSize = 20
    AimBtn.Parent = JanelaAimlock
    
    Instance.new("UICorner", AimBtn).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", AimBtn)
    stroke.Color = Color3.fromRGB(0, 255, 0) 
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    task.spawn(function()
        while JanelaAimlock and JanelaAimlock.Parent do
            if not MiraPausada then
                TweenService:Create(stroke, TweenInfo.new(0.8), {Transparency = 0.8}):Play()
                task.wait(0.8)
                TweenService:Create(stroke, TweenInfo.new(0.8), {Transparency = 0}):Play()
                task.wait(0.8)
            else
                stroke.Transparency = 1
                task.wait(0.5)
            end
        end
    end)

    local dragging, dragInput, dragStart, startPos
    local touchStartTime = 0

    AimBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; PausarAoArrastar = true; touchStartTime = os.clock()
            dragStart = input.Position; startPos = AimBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false; PausarAoArrastar = false 
                    if os.clock() - touchStartTime < 0.2 then
                        MiraPausada = not MiraPausada
                        if MiraPausada then AimBtn.Text = "Aimlock OFF" else AimBtn.Text = "Aimlock" end
                    end
                end
            end)
        end
    end)
    AimBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then touchStartTime = 0 end AimBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
end

-- // JANELA DO GRAB GUN //
local function CreateTPGunWindow()
    if JanelaTPGun then return end
    JanelaTPGun = Instance.new("ScreenGui")
    JanelaTPGun.Name = "ApexTPGunWindow"
    JanelaTPGun.ResetOnSpawn = false
    JanelaTPGun.Parent = game.CoreGui

    local TPBtn = Instance.new("TextButton")
    TPBtn.Size = UDim2.new(0, 60, 0, 60) 
    TPBtn.Position = UDim2.new(0, 20, 0.5, -10) 
    TPBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) 
    TPBtn.BackgroundTransparency = 0.4
    TPBtn.Text = "Grab\nGun" 
    TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TPBtn.Font = Enum.Font.Gotham
    TPBtn.TextSize = 10 
    TPBtn.TextWrapped = true
    TPBtn.Parent = JanelaTPGun
    
    Instance.new("UICorner", TPBtn).CornerRadius = UDim.new(1, 0) 
    
    local stroke = Instance.new("UIStroke", TPBtn)
    stroke.Color = Color3.fromRGB(0, 255, 0) 
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    task.spawn(function()
        while JanelaTPGun and JanelaTPGun.Parent do
            TweenService:Create(stroke, TweenInfo.new(0.8), {Transparency = 0.8}):Play()
            task.wait(0.8)
            TweenService:Create(stroke, TweenInfo.new(0.8), {Transparency = 0}):Play()
            task.wait(0.8)
        end
    end)

    TPBtn.MouseButton1Click:Connect(ExecuteTPGun)
    local dragging, dragInput, dragStart, startPos
    TPBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position startPos = TPBtn.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
    TPBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart TPBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
end

-- // INTERFACE RAYFIELD //
local Window = Rayfield:CreateWindow({
   Name = "Apex | MM2", 
   LoadingTitle = "",
   LoadingSubtitle = "by Apex", 
   ConfigurationSaving = {Enabled = false},
   KeySystem = false
})

local UpdateTab = Window:CreateTab("Atualizações",  "alert-triangle") 
local GameTab = Window:CreateTab("Game", "gamepad-2") 
local EspTab = Window:CreateTab("ESP", "eye") 

UpdateTab:CreateParagraph({Title = "📌 PATCH NOTES - v1.0", Content = "[ NOVIDADES ]\n• ESP 2D otimizado\n• Aimlock Mobile\n• Grab Gun\\n[ CORREÇÕES ]\n• Corrigido bug do ESP\n• Melhor desempenho em celulares fracos"})

GameTab:CreateToggle({ Name = "Aimlock", CurrentValue = false, Flag = "Aimlock", Callback = function(Value) Aimlock = Value if Aimlock then MiraPausada = false CreateAimlockWindow() else if JanelaAimlock then JanelaAimlock:Destroy() JanelaAimlock = nil end UserInputService.MouseBehavior = Enum.MouseBehavior.Default end end })
GameTab:CreateToggle({ Name = "Tp Gun", CurrentValue = false, Flag = "TPGun", Callback = function(Value) TP_Gun_Ativo = Value if TP_Gun_Ativo then CreateTPGunWindow() else if JanelaTPGun then JanelaTPGun:Destroy() JanelaTPGun = nil end end end })

EspTab:CreateToggle({ Name = "ESP Murder", CurrentValue = false, Flag = "ESPMurder", Callback = function(Value) ESP_Murder = Value end })
EspTab:CreateToggle({ Name = "ESP Xerife", CurrentValue = false, Flag = "ESPSheriff", Callback = function(Value) ESP_Sheriff = Value end })
EspTab:CreateToggle({ Name = "ESP Player", CurrentValue = false, Flag = "ESPPlayer", Callback = function(Value) ESP_Player = Value end })

EspTab:CreateToggle({ Name = "ESP Gun", CurrentValue = false, Flag = "ESPGun", Callback = function(Value) ESP_Gun = Value if not Value and GunESP_Gui then GunESP_Gui:Destroy() GunESP_Gui = nil end end })

-- LOOP DO ESP GUN //
task.spawn(function()
    while task.wait(0.1) do
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
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
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

Rayfield:Notify({Title = "Apex | MM2", Content = "Script carregado!", Duration = 4})
