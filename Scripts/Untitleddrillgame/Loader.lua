local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Untitled drill game By Strixzy",
    LoadingTitle = "Untitled drill game",
    LoadingSubtitle = "Made by Strixzy",
    Theme = selectedTheme,

    DisableBuildWarnings = false,
    DisableRayfieldPrompts = false,

    ConfigurationSaving = {
        Enabled = true,
        FolderName = "StrixzyConfig",
        FileName = "Untitleddrillgame"
    },

    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },

    KeySystem = false,
    KeySettings = {
        Title = "Strixzy Hub",
        Subtitle = "Key System",
        Note = "No method of obtaining the key is provided",
        FileName = "StrixzyHubKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"PEEM"}
    }
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = Packages:WaitForChild("Knit")
local Services = Knit:WaitForChild("Services")
local OreService = Services:WaitForChild("OreService")
local PlotService = Services:WaitForChild("PlotService")

local SellAll = OreService:WaitForChild("RE"):WaitForChild("SellAll")
local RequestRandomOre = OreService:WaitForChild("RE"):WaitForChild("RequestRandomOre")
local CollectDrill = PlotService:WaitForChild("RE"):WaitForChild("CollectDrill")

local MainTab = Window:CreateTab("Auto", "swords")
local Selection = MainTab:CreateSection("Auto Play")

local ToggleOreFarm = false

MainTab:CreateToggle({
    Name = "Auto Drill",
    CurrentValue = false,
    Flag = "AutoDrillToggle",
    Callback = function(Value)
        ToggleOreFarm = Value
        if Value then
            local player = game.Players.LocalPlayer
            local backpack = player:WaitForChild("Backpack")
            local handDrillsFolder = ReplicatedStorage:WaitForChild("HandDrills")

            local drillNames = {}
            for _, tool in ipairs(handDrillsFolder:GetChildren()) do
                table.insert(drillNames, tool.Name)
            end

            local function equipDrill()
                for _, tool in ipairs(backpack:GetChildren()) do
                    if table.find(drillNames, tool.Name) then
                        local char = player.Character or player.CharacterAdded:Wait()
                        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
                        if humanoid then
                            humanoid:EquipTool(tool)
                            break
                        end
                    end
                end
            end

            equipDrill()

            task.spawn(function()
                while ToggleOreFarm do
                    pcall(function()
                        local char = player.Character or player.CharacterAdded:Wait()
                        if not char:FindFirstChild("Humanoid") or not char.Humanoid:FindFirstChildOfClass("Tool") then
                            equipDrill()
                        end
                    end)
                    task.wait(1)
                end
            end)

            task.spawn(function()
                while ToggleOreFarm do
                    pcall(function()
                        RequestRandomOre:FireServer()
                    end)
                    task.wait()
                end
            end)
        end
    end,
})

local SellSelection = MainTab:CreateSection("Auto Sell")

local ToggleSellAll = false

MainTab:CreateToggle({
    Name = "Auto Sell All",
    CurrentValue = false,
    Callback = function(Value)
        ToggleSellAll = Value
        if Value then
            task.spawn(function()
                while ToggleSellAll do
                    pcall(function()
                        local player = game.Players.LocalPlayer
                        local character = player.Character or player.CharacterAdded:Wait()
                        local hrp = character:FindFirstChild("HumanoidRootPart")

                        if hrp then
                            local originalCFrame = hrp.CFrame

                            hrp.CFrame = CFrame.new(Vector3.new(-395.50, 92.04, 269.37))

                            task.wait(1)

                            for i = 1, 10 do
                                SellAll:FireServer()
                                task.wait()
                            end

                            hrp.CFrame = originalCFrame
                        end 
                    end)
                    task.wait(30)
                end
            end)
        end
    end,
})

local CollectSelection = MainTab:CreateSection("Auto Collect Drill/Storage")

local ToggleCollectDrill = false

MainTab:CreateToggle({
    Name = "Auto Collect Drill",
    CurrentValue = false,
    Flag = "AutoCollectDrillToggle",
    Callback = function(Value)
        ToggleCollectDrill = Value
        if Value then
            task.spawn(function()
                while ToggleCollectDrill do
                    pcall(function()
                        local player = game.Players.LocalPlayer
                        for _, plot in pairs(workspace.Plots:GetChildren()) do
                            local owner = plot:FindFirstChild("Owner")
                            if owner and owner.Value == player then
                                for _, folderName in ipairs({"Drills", "Storage"}) do
                                    local folder = plot:FindFirstChild(folderName)
                                    if folder then
                                        for _, drillModel in ipairs(folder:GetChildren()) do
                                            CollectDrill:FireServer(drillModel)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(30)
                end
            end)
        end
    end,
})

local ShopTab = Window:CreateTab("Shop", "shopping-basket")
local ShopSection = ShopTab:CreateSection("Shop Hand Drill")

local BuyHandDrill = OreService:WaitForChild("RE"):WaitForChild("BuyHandDrill")
local HandDrillsFolder = ReplicatedStorage:WaitForChild("HandDrills")

local drillsWithCost = {}

for _, tool in ipairs(HandDrillsFolder:GetChildren()) do
    local cost = tool:GetAttribute("Cost") or 0
    table.insert(drillsWithCost, {Name = tool.Name, Cost = cost})
end

table.sort(drillsWithCost, function(a, b)
    return a.Cost < b.Cost
end)

local dropdownOptions = {}
for _, drill in ipairs(drillsWithCost) do
    table.insert(dropdownOptions, drill.Name)
end

local selectedDrill = nil

ShopTab:CreateDropdown({
    Name = "Select Drill",
    Options = dropdownOptions,
    Callback = function(value)
        selectedDrill = value[1]
    end
})

ShopTab:CreateButton({
    Name = "Buy Hand Drill",
    Callback = function()
        if selectedDrill then
            ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("BuyHandDrill"):FireServer(selectedDrill)
        end
    end
})

local UiTab = Window:CreateTab("UI", "bolt")
local UiTab1 = UiTab:CreateSection("More")

UiTab:CreateButton({
    Name = "Infiniteyield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/refs/heads/master/source"))()
    end,
})

local themes = {"Default","AmberGlow","Amethyst","Bloom","DarkBlue","Green","Light","Ocean","Serenity"}

UiTab:CreateDropdown({
    Name = "เลือกธีม UI",
    Options = themes,
    Flag = "SelectedTheme",
    Callback = function(value)
        selectedTheme = value[1]
        Rayfield:Destroy()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Mxvxrixx/StrixzyHub/refs/heads/main/Loader.lua"))()
    end
})

local lastMoveTime = tick()

game:GetService("RunService").Heartbeat:Connect(function()
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        if (tick() - lastMoveTime) >= 900 then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input, gameProcessed)
    if not gameProcessed then
        lastMoveTime = tick()
    end
end)

Rayfield:LoadConfiguration()
