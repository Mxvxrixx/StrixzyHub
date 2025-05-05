local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "RAMPANT REBORN PvP",
    LoadingTitle = "RAMPANT REBORN PvP",
    LoadingSubtitle = "Made by Strixzy",
    Theme = "Default",

    DisableBuildWarnings = false,
    DisableRayfieldPrompts = false,

    ConfigurationSaving = {
        Enabled = true,
        FolderName = "StrixzyConfig",
        FileName = "RAMPANTREBORN"
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

local MainTab = Window:CreateTab("Class", "swords")
local Selection = MainTab:CreateSection("Select Class")

local Classname = {"Assassin", "Atomic Samurai", "Viking", "Vampire", "Marauder","Knight", "Kaiju", "Guardian", "Fighter", "Dark Mage", "Berserker"}

for _, Classname in ipairs(Classname) do
    MainTab:CreateButton({
        Name = Classname,
        Callback = function()
            local args = {
                [1] = Classname,
                [2] = false
            }
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("ChangeClass"):InvokeServer(unpack(args))
        end,
    })
end

local UiTab = Window:CreateTab("UI", "bolt")
local UiTab1 = UiTab:CreateSection("More")

    UiTab:CreateButton({
        Name = "Infiniteyield",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/refs/heads/master/source"))()
        end,
    })
