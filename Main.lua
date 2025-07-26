local Player = _ENV.Player
local IsAlive = _ENV.IsAlive
local Settings = _ENV.Settings
local EquippedTool = _ENV.EquippedTool
local EnemiesFolders = _ENV.EnemiesFolders
local QuestsNpcs = _ENV.QuestsNpcs
local Enemys = _ENV.Enemys
local GetCurrentQuest = _ENV.GetCurrentQuest
local PlayerTP = _ENV.PlayerTP

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DialogueEvent = ReplicatedStorage.BetweenSides.Remotes.Events.DialogueEvent
local CombatEvent = ReplicatedStorage.BetweenSides.Remotes.Events.CombatEvent

local CFrameAngle = CFrame.Angles(math.rad(-90), 0, 0)

local function DealDamage(Enemies)
    local CurrentTime = workspace:GetServerTimeNow()
    CombatEvent:FireServer("DealDamage", {
        CallTime = CurrentTime;
        DelayTime = workspace:GetServerTimeNow() - CurrentTime;
        Combo = 1;
        Results = Enemies;
    })
end

local function GetMobFromFolder(Folder, EnemyName)
    for _, Enemy in Folder:GetChildren() do
        if Enemy:GetAttribute("Respawned") and Enemy:GetAttribute("Ready") then
            if Enemy:GetAttribute("OriginalName") == EnemyName then
                return Enemy
            end
        end
    end
end

local function GetClosestEnemy(EnemyName)
    local Folder = EnemiesFolders[EnemyName]
    if Folder then return GetMobFromFolder(Folder, EnemyName) end
    for _, Island in ipairs(Enemys:GetChildren()) do
        for _, Enemy in ipairs(Island:GetChildren()) do
            if Enemy:GetAttribute("OriginalName") == EnemyName then
                EnemiesFolders[EnemyName] = Island
                return GetMobFromFolder(Island, EnemyName)
            end
        end
    end
end

local function HasQuest(EnemyName)
    local QuestFrame = Player.PlayerGui.MainUI.MainFrame.CurrentQuest
    return QuestFrame.Visible and QuestFrame.Goal.Text:find(EnemyName)
end

local function TakeQuest(QuestName, QuestId)
    local Npc = QuestsNpcs:FindFirstChild(QuestName, true)
    if Npc and Npc.PrimaryPart then
        DialogueEvent:FireServer("Quests", { ["NpcName"] = QuestName; ["QuestName"] = QuestId })
        PlayerTP(Npc.PrimaryPart.CFrame)
    end
end

local function EquipCombat(Activate)
    if not IsAlive(Player.Character) then return end
    local Tool = Player.Character:FindFirstChildOfClass("Tool") or Player.Backpack:FindFirstChildOfClass("Tool")
    if Tool and Tool:GetAttribute(Settings.SelectedTool) then
        EquippedTool = Tool
        if Activate then Tool:Activate() end
        if Tool.Parent == Player.Backpack then
            Player.Character.Humanoid:EquipTool(Tool)
        end
    end
end

local Libary = loadstring(game:HttpGet("https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/V5/Source.lua"))()
local Window = Libary:MakeWindow({ "Anonymous", "by NightShadow", "rz-VoxSeas.json" })
local MainTab = Window:MakeTab({ "Farm", "Home" })
local ConfigTab = Window:MakeTab({ "Config", "Settings" })

MainTab:AddSection("Farming")
MainTab:AddToggle({"Auto Farm Level", false, function(Value)
    _ENV.OnFarm = Value
    while task.wait() and _ENV.OnFarm do
        local Quest = GetCurrentQuest()
        if not Quest then continue end
        if not HasQuest(Quest.Target) then
            TakeQuest(Quest.NpcName, Quest.Id)
            continue
        end
        local Enemy = GetClosestEnemy(Quest.Target)
        if not Enemy then continue end
        local HRP = Enemy:FindFirstChild("HumanoidRootPart")
        if HRP then
            HRP.Size = Vector3.one * 35
            HRP.CanCollide = false
            EquipCombat(true)
            DealDamage({ Enemy })
            PlayerTP((HRP.CFrame + Vector3.yAxis * 10) * CFrameAngle)
        end
    end
end})

ConfigTab:AddToggle({"Click V2", false, {Settings, "ClickV2"} })
ConfigTab:AddToggle({"Tween Speed", 50, 200, 10, 125, {Settings, "TweenSpeed"} })
ConfigTab:AddDropdown({"Select Tool", {"CombatType"}, "CombatType", {Settings, "SelectedTool"} })
