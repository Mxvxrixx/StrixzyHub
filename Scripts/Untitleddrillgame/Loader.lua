local selectedTheme = "Default" -- ตั้งค่าเริ่มต้น

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

-- Cache Services และ Events ที่ต้องใช้ WaitForChild
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = Packages:WaitForChild("Knit")
local Services = Knit:WaitForChild("Services")
local OreService = Services:WaitForChild("OreService")
local PlotService = Services:WaitForChild("PlotService")

local SellAll = OreService:WaitForChild("RE"):WaitForChild("SellAll")
local RequestRandomOre = OreService:WaitForChild("RE"):WaitForChild("RequestRandomOre")
local CollectDrill = PlotService:WaitForChild("RE"):WaitForChild("CollectDrill")

-- MainTab และ Toggle UI
local MainTab = Window:CreateTab("Auto", "swords")
local Selection = MainTab:CreateSection("Auto Play")

-- ตัวแปรควบคุมเปิด/ปิดฟีเจอร์ Auto Drill
local ToggleOreFarm = false

-- สร้าง toggle สำหรับ Auto Drill
MainTab:CreateToggle({
    Name = "Auto Drill", -- ชื่อ toggle
    CurrentValue = false, -- เริ่มต้นปิดไว้
    Flag = "AutoDrillToggle",
    Callback = function(Value)
        ToggleOreFarm = Value
        if Value then
            -- หยิบ Tool จาก Backpack ถ้าตรงกับ HandDrills
            local player = game.Players.LocalPlayer
            local backpack = player:WaitForChild("Backpack")
            local handDrillsFolder = ReplicatedStorage:WaitForChild("HandDrills")

            local drillNames = {}
            for _, tool in ipairs(handDrillsFolder:GetChildren()) do
                table.insert(drillNames, tool.Name)
            end

            -- ฟังก์ชันหยิบเครื่องมือขึ้น
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

            -- เรียกฟังก์ชันครั้งแรกเพื่อหยิบเครื่องมือ
            equipDrill()

            -- ตรวจสอบทุกๆ 5 วินาที หากเครื่องมือหายให้หยิบใหม่
            task.spawn(function()
                while ToggleOreFarm do
                    pcall(function()
                        -- ตรวจสอบหากไม่มีเครื่องมือหรือถูกเปลี่ยน
                        local char = player.Character or player.CharacterAdded:Wait()
                        if not char:FindFirstChild("Humanoid") or not char.Humanoid:FindFirstChildOfClass("Tool") then
                            equipDrill() -- ถ้าไม่มีเครื่องมือให้หยิบใหม่
                        end
                    end)
                    task.wait(1) -- รอ 5 วินาที
                end
            end)

            -- ถ้าเปิด toggle ให้เริ่ม loop ขุดแร่
            task.spawn(function()
                while ToggleOreFarm do
                    pcall(function()
                        -- สั่งขุดแร่แบบสุ่มผ่านเซิร์ฟเวอร์
                        RequestRandomOre:FireServer()
                    end)
                    task.wait() -- รอเล็กน้อยระหว่างรอบ
                end
            end)
        end
    end,
})

local SellSelection = MainTab:CreateSection("Auto Sell")

-- ตัวแปรควบคุมเปิด/ปิด Auto Sell
local ToggleSellAll = false

-- สร้าง toggle สำหรับ Auto Sell All
MainTab:CreateToggle({
    Name = "Auto Sell All",
    CurrentValue = false,
    Callback = function(Value)
        ToggleSellAll = Value
        if Value then
            -- ถ้าเปิด toggle ให้เริ่ม loop ขายแร่อัตโนมัติ
            task.spawn(function()
                while ToggleSellAll do
                    pcall(function()
                        local player = game.Players.LocalPlayer
                        local character = player.Character or player.CharacterAdded:Wait()
                        local hrp = character:FindFirstChild("HumanoidRootPart")

                        if hrp then
                            -- บันทึกตำแหน่งเดิมของตัวละคร
                            local originalCFrame = hrp.CFrame

                            -- วาร์ปไปยังจุดขายแร่
                            hrp.CFrame = CFrame.new(Vector3.new(-395.50, 92.04, 269.37))

                            task.wait(1) -- รอโหลดแผนที่เล็กน้อย

                            -- ขายแร่หลายรอบ (5 ครั้ง)
                            for i = 1, 10 do
                                SellAll:FireServer()
                                task.wait() -- รอเล็กน้อยแต่ละรอบ
                            end

                            -- วาร์ปกลับตำแหน่งเดิม
                            hrp.CFrame = originalCFrame
                        end 
                    end)
                    task.wait(30) -- รอ 30 วินาทีก่อนเริ่มรอบถัดไป
                end
            end)
        end
    end,
})

local CollectSelection = MainTab:CreateSection("Auto Collect Drill/Storage")

-- เพิ่มตัวแปรควบคุม Auto Collect Drill
local ToggleCollectDrill = false

-- สร้าง toggle สำหรับเก็บทรัพยากรจาก Drills และ Storage
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
                    task.wait(30) -- เก็บทุกๆ 5 วินาที
                end
            end)
        end
    end,
})

local ShopTab = Window:CreateTab("Shop", "shopping-basket")
local ShopSection = ShopTab:CreateSection("Shop Hand Drill")

local BuyHandDrill = OreService:WaitForChild("RE"):WaitForChild("BuyHandDrill")
local HandDrillsFolder = ReplicatedStorage:WaitForChild("HandDrills")

-- ดึงชื่อ Drill และ Cost จาก Attributes
local drillsWithCost = {}

for _, tool in ipairs(HandDrillsFolder:GetChildren()) do
    local cost = tool:GetAttribute("Cost") or 0  -- ดึงค่า Cost จาก Attribute หรือค่าเริ่มต้นเป็น 0
    table.insert(drillsWithCost, {Name = tool.Name, Cost = cost})
end

-- เรียง Drill ตาม Cost (จากน้อยไปมาก)
table.sort(drillsWithCost, function(a, b)
    return a.Cost < b.Cost
end)

-- สร้างรายการชื่อ Drill สำหรับ Dropdown
local dropdownOptions = {}
for _, drill in ipairs(drillsWithCost) do
    table.insert(dropdownOptions, drill.Name)  -- ใช้แค่ชื่อ Drill ใน Dropdown
end

local selectedDrill = nil

ShopTab:CreateDropdown({
    Name = "Select Drill",
    Options = dropdownOptions,  -- ใช้ชื่อ Drill ที่เรียงตามราคาน้อยไปมาก
    Callback = function(value)
        selectedDrill = value[1]
    end
})
ShopTab:CreateButton({
    Name = "Buy Hand Drill",
    Callback = function()
        if selectedDrill then
            -- เมื่อเลือกเครื่องมือแล้วจะส่งชื่อเครื่องมือไปที่เซิร์ฟเวอร์เพื่อซื้อ
            ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("BuyHandDrill"):FireServer(selectedDrill)
        end
    end
})


-- สร้างแท็บ UI แยกต่างหากสำหรับปุ่มเสริม
local UiTab = Window:CreateTab("UI", "bolt") -- สร้างแท็บ UI
local UiTab1 = UiTab:CreateSection("More") -- หัวข้อย่อย

-- ปุ่มกดสำหรับรัน Infiniteyield (admin command)
UiTab:CreateButton({
    Name = "Infiniteyield",
    Callback = function()
        -- โหลด Infiniteyield จาก GitHub
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/refs/heads/master/source"))()
    end,
})

local themes = {"Default","AmberGlow","Amethyst","Bloom","DarkBlue","Green","Light","Ocean","Serenity"}

UiTab:CreateDropdown({
    Name = "เลือกธีม UI",
    Options = themes,
    Flag = "uithemes",
    Callback = function(value)
        selectedTheme = value[1]
        Rayfield:Destroy() -- ปิด UI เดิม

        -- โหลดสคริปต์ใหม่เพื่อสร้าง UI ด้วย Theme ใหม่
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Mxvxrixx/StrixzyHub/refs/heads/main/Loader.lua"))()
        -- 🔁 เปลี่ยนลิงก์ Pastebin ด้านบนให้ชี้ไปที่สคริปต์นี้ของคุณเองที่อัปโหลดไว้
    end
})


-- Anti-AFK: กระโดดเมื่อไม่ขยับ 15 นาที
local lastMoveTime = tick() -- เวลาที่สุดท้ายที่ผู้เล่นขยับ

-- เช็คการขยับทุกๆ 1 วินาที (หรือทุก frame)
game:GetService("RunService").Heartbeat:Connect(function()
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        if (tick() - lastMoveTime) >= 900 then  -- ถ้าไม่ได้ขยับเกิน 15 นาที
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping) -- กระโดด 1 ครั้ง
        end
    end
end)

-- อัพเดตเวลาที่ขยับทุกครั้งที่มีอินพุตจากผู้เล่น
game:GetService("UserInputService").InputChanged:Connect(function(input, gameProcessed)
    if not gameProcessed then
        lastMoveTime = tick() -- อัพเดตเวลาล่าสุดที่ขยับ
    end
end)

Rayfield:LoadConfiguration()
