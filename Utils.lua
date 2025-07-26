local _ENV = (getgenv or getrenv or getfenv)()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer;

local QuestsNpcs = workspace.IgnoreList.Int.NPCs.Quests;
local Enemys = workspace.Playability.Enemys;
local QuestsDecriptions = require(ReplicatedStorage.MainModules.Essentials.QuestDescriptions)

local EnemiesFolders = {}
local QuestsData = {}

local Settings = {
    ClickV2 = false;
    TweenSpeed = 125;
    SelectedTool = "CombatType";
}
local EquippedTool = nil

local function IsAlive(Character)
    if Character then
        local Humanoid = Character:FindFirstChildOfClass("Humanoid");
        return Humanoid and Humanoid.Health > 0;
    end
end

_ENV.IsAlive = IsAlive
_ENV.Settings = Settings
_ENV.EquippedTool = EquippedTool
_ENV.QuestsData = QuestsData
_ENV.EnemiesFolders = EnemiesFolders
_ENV.QuestsNpcs = QuestsNpcs
_ENV.Enemys = Enemys
_ENV.Player = Player
_ENV.QuestsDecriptions = QuestsDecriptions
_ENV.GetCurrentQuest = (function()
    QuestsData.QuestsList = {}
    table.clear(QuestsData.QuestsList)
    local CurrentQuest, CurrentLevel = nil, -1;
    for _, QuestData in QuestsDecriptions do
        if QuestData.Goal <= 1 then continue end
        table.insert(QuestsData.QuestsList, {
            Level = QuestData.MinLevel;
            Target = QuestData.Target;
            NpcName = QuestData.Npc;
            Id = QuestData.Id;
        })
    end
    table.sort(QuestsData.QuestsList, function(a, b) return a.Level > b.Level end)
    return function()
        local Level = tonumber(Player.PlayerGui.MainUI.MainFrame.StastisticsFrame.LevelBackground.Level.Text);
        if Level == CurrentLevel then return CurrentQuest end
        for _, QuestData in QuestsData.QuestsList do
            if QuestData.Level <= Level then
                CurrentLevel, CurrentQuest = Level, QuestData
                return QuestData
            end
        end
    end
end)()
