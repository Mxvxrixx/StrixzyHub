-- Theme and Rayfield Setup
local selectedTheme = "DarkBlue"
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

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = Packages:WaitForChild("Knit")
local Services = Knit:WaitForChild("Services")
local OreService = Services:WaitForChild("OreService")
local PlotService = Services:WaitForChild("PlotService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local SellAll = OreService:WaitForChild("RE"):WaitForChild("SellAll")
local RequestRandomOre = OreService:WaitForChild("RE"):WaitForChild("RequestRandomOre")
local CollectDrill = PlotService:WaitForChild("RE"):WaitForChild("CollectDrill")
local rebirthsValue = localPlayer:WaitForChild("leaderstats"):WaitForChild("Rebirths").Value

-- Main Auto Play Section
local MainTab = Window:CreateTab("Auto", "swords")
local PlaySelection = MainTab:CreateSection("Auto Play")

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
    
            player.CharacterAdded:Connect(function(char)
                if ToggleOreFarm then
                    task.wait(1)
                    equipDrill()
                end
            end)
    
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
    end
})

-- Auto Rebirth Section
local RebirthSection = MainTab:CreateSection("Auto Rebirth")
local ToggleAutoLock = false
local selectedOreNames = {}

local predefinedOreNames = {
    ["Rebirth 1"] = {"Uranium", "Adamantite"},
    ["Rebirth 2"] = {"Radiant Quartz", "Celestine"},
    ["Rebirth 3"] = {"Obscurite", "Lunaris"},
    ["Rebirth 4"] = {"Elerium", "Stellarite"},
    ["Rebirth 5"] = {"Phantomite", "Bloodsteel"}
}

MainTab:CreateDropdown({
    Name = "Select Lock Item Rebirth",
    Options = {"Rebirth 1", "Rebirth 2", "Rebirth 3", "Rebirth 4", "Rebirth 5"},
    Callback = function(value)
        selectedOreNames = predefinedOreNames[value[1]]
    end
})

MainTab:CreateToggle({
    Name = "Auto Lock",
    CurrentValue = false,
    Callback = function(Value)
        ToggleAutoLock = Value
        if Value then
            task.spawn(function()
                while ToggleAutoLock do
                    pcall(function()
                        local backpack = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
                        if backpack and #selectedOreNames > 0 then
                            for _, item in ipairs(backpack:GetChildren()) do
                                for _, oreName in ipairs(selectedOreNames) do
                                    if item.Name == oreName and not item:GetAttribute("Locked") then
                                        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("LockItem"):FireServer(item)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end
})

-- Rebirth Logic
local oreNamesForRebirth = {
    [0] = {"Uranium", "Adamantite"},
    [1] = {"Radiant Quartz", "Celestine"},
    [2] = {"Obscurite", "Lunaris"},
    [3] = {"Elerium", "Stellarite"},
    [4] = {"Phantomite", "Bloodsteel"}
}

local function checkAndRebirth()
    local selectedOres = oreNamesForRebirth[rebirthsValue]
    if selectedOres then
        local backpack = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
        local foundOres = 0

        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                for _, oreName in ipairs(selectedOres) do
                    if item.Name == oreName then
                        foundOres = foundOres + 1
                    end
                end
            end
        end

        if foundOres == 2 then
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("RebirthService"):WaitForChild("RE"):WaitForChild("RebirthRequest"):FireServer()
            end)
        end
    end
end

MainTab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Flag = "AutoRebirthToggle",
    Callback = function(Value)
        ToggleAutoRebirth = Value
        if Value then
            task.spawn(function()
                while ToggleAutoRebirth do
                    checkAndRebirth()
                    task.wait(0.1)
                end
            end)
        end
    end,
})

-- Auto Sell Section
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

                            task.wait(2)

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

-- Auto Collect Drill/Storage Section
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
                    task.wait(1)
                end
            end)
        end
    end,
})

-- Shop Tab for Hand Drills, Drills, and Storages
local ShopTab = Window:CreateTab("Shop", "shopping-basket")

-- Hand Drills Section
local HandDrillsSection = ShopTab:CreateSection("Shop Hand Drills")
local HandDrillsFolder = ReplicatedStorage:WaitForChild("HandDrills")
local HanddrillsWithCost = {}

for _, tool in ipairs(HandDrillsFolder:GetChildren()) do
    local cost = tool:GetAttribute("Cost") or 0
    table.insert(HanddrillsWithCost, {Name = tool.Name, Cost = cost})
end

table.sort(HanddrillsWithCost, function(a, b)
    return a.Cost < b.Cost
end)

local function formatNumberWithCommas(n)
    local left, right = tostring(n):match("^([^%.]+)%.?(%d*)$")
    left = string.reverse(left):gsub("(%d%d%d)", "%1,")
    left = string.reverse(left):gsub("^,", "")
    return right ~= "" and (left .. "." .. right) or left
end

local dropdownOptions = {}
for _, Handdrill in ipairs(HanddrillsWithCost) do
    table.insert(dropdownOptions, string.format("%s (Cost : %s)", Handdrill.Name, formatNumberWithCommas(Handdrill.Cost)))
end

local selectedHandDrill = nil

ShopTab:CreateDropdown({
    Name = "Select Hand Drill",
    Options = dropdownOptions,
    Callback = function(value)
        local nameOnly = string.match(value[1], "^(.-) %(")
        selectedHandDrill = nameOnly
    end
})

ShopTab:CreateButton({
    Name = "Buy Hand Drill",
    Callback = function()
        if selectedHandDrill then
            ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("BuyHandDrill"):FireServer(selectedHandDrill)
        end
    end
})

-- Drills Section
local DrillsSection = ShopTab:CreateSection("Shop Drills")
local drillsForRebirth = {
    [0] = {"Standard Drill", "Reinforced Drill", "Twin Drill", "Tri Drill", "Charged Drill", "Plasma Drill", "Laser Drill", "Quad Drill", "Thermal Drill", "Surge Drill", "Surge Drill", "Surge Drill", "Surge Drill"},
    [1] = {"Fusion Drill", "Nuclear Drill"},
    [2] = {"Quantum Drill", "Colossal Drill"},
    [3] = {"Graviton Drill", "Singularity Drill"},
    [4] = {"Nebula Drill"},
    [5] = {"Starflare Drill"}
}

local drillNameSet = {}
for i = 0, rebirthsValue do
    local drills = drillsForRebirth[i]
    if drills then
        for _, name in ipairs(drills) do
            drillNameSet[name] = true
        end
    end
end

local DrillsFolder = ReplicatedStorage:WaitForChild("Drills")
local DrillsWithCost = {}

for _, model in ipairs(DrillsFolder:GetChildren()) do
    if model:IsA("Model") and drillNameSet[model.Name] then
        local cost = model:GetAttribute("Cost") or 0
        table.insert(DrillsWithCost, {Name = model.Name, Cost = cost})
    end
end

table.sort(DrillsWithCost, function(a, b)
    return a.Cost < b.Cost
end)

local drilldropdownOptions = {}
for _, drill in ipairs(DrillsWithCost) do
    table.insert(drilldropdownOptions, string.format("%s (Cost : %s)", drill.Name, formatNumberWithCommas(drill.Cost)))
end

local selectedDrillRebirth = nil

ShopTab:CreateDropdown({
    Name = "Select Drill",
    Options = drilldropdownOptions,
    Callback = function(value)
        local nameOnly = string.match(value[1], "^(.-) %(")
        selectedDrillRebirth = nameOnly
    end
})

ShopTab:CreateButton({
    Name = "Buy Drill",
    Callback = function()
        if selectedDrillRebirth then
            ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("BuyDrill"):FireServer(selectedDrillRebirth)
        end
    end
})

-- Storages Section
local StoragesSection = ShopTab:CreateSection("Shop Storages")

local StorageForRebirth = {
    [0] = {"Standard Vault"},
    [1] = {"Nano Pod"},
    [2] = {"Drift Capsule"},
    [3] = {"Eclipse Chamber"},
    [4] = {"Astral Node"},
}

local StorageNameSet = {}
for i = 0, rebirthsValue do
    local storages = StorageForRebirth[i]
    if storages then
        for _, name in ipairs(storages) do
            StorageNameSet[name] = true
        end
    end
end

local StoragesFolder = ReplicatedStorage:WaitForChild("Drills")
local StoragesWithCost = {}

for _, model in ipairs(StoragesFolder:GetChildren()) do
    if model:IsA("Model") and StorageNameSet[model.Name] then
        local cost = model:GetAttribute("Cost") or 0
        table.insert(StoragesWithCost, {Name = model.Name, Cost = cost})
    end
end

table.sort(StoragesWithCost, function(a, b)
    return a.Cost < b.Cost
end)

local StoragedropdownOptions = {}
for _, Storage in ipairs(StoragesWithCost) do
    table.insert(StoragedropdownOptions, string.format("%s (Cost : %s)", Storage.Name, formatNumberWithCommas(Storage.Cost)))
end

local selectedStorageRebirth = nil

ShopTab:CreateDropdown({
    Name = "Select Storages",
    Options = StoragedropdownOptions,
    Callback = function(value)
        local nameOnly = string.match(value[1], "^(.-) %(")
        selectedStorageRebirth = nameOnly
    end
})

ShopTab:CreateButton({
    Name = "Buy Storage",
    Callback = function()
        if selectedStorageRebirth then
            ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("BuyDrill"):FireServer(selectedStorageRebirth)
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

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

Rayfield:LoadConfiguration()
