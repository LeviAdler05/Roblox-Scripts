local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = _ENV.Player
local Settings = _ENV.Settings
local IsAlive = _ENV.IsAlive

local CFrameAngle = CFrame.Angles(math.rad(-90), 0, 0)
local BodyVelocity = Instance.new("BodyVelocity")
BodyVelocity.Velocity = Vector3.zero
BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
BodyVelocity.P = 1000

_ENV.tween_bodyvelocity = BodyVelocity

local Connections = _ENV.rz_connections or {}
_ENV.rz_connections = Connections
for _, conn in ipairs(Connections) do conn:Disconnect() end
table.clear(Connections)

local function NewCharacter(Character)
    for _, Object in Character:GetDescendants() do
        if Object:IsA("BasePart") and Object.CanCollide then
            Object.CanCollide = false
        end
    end
end

table.insert(Connections, Player.CharacterAdded:Connect(NewCharacter))
task.spawn(NewCharacter, Player.Character)

table.insert(Connections, RunService.Stepped:Connect(function()
    local Character = Player.Character
    if IsAlive(Character) then
        local BasePart = Character:FindFirstChild("UpperTorso")
        local Humanoid = Character:FindFirstChild("Humanoid")
        if _ENV.OnFarm and BasePart and Humanoid and Humanoid.Health > 0 then
            if BodyVelocity.Parent ~= BasePart then
                BodyVelocity.Parent = BasePart
            end
        elseif BodyVelocity.Parent then
            BodyVelocity.Parent = nil
        end
    end
end))

local TweenCreator = {}
TweenCreator.__index = TweenCreator
local tweens = {}

function TweenCreator.new(obj, time, prop, value)
    local self = setmetatable({}, TweenCreator)
    self.tween = TweenService:Create(obj, TweenInfo.new(time), { [prop] = value })
    self.tween:Play()
    tweens[obj] = self
    return self
end

function TweenCreator:destroy()
    self.tween:Pause()
    self.tween:Destroy()
    tweens[self.object] = nil
end

function TweenCreator:stopTween(obj)
    if tweens[obj] then tweens[obj]:destroy() end
end

local lastCFrame, lastTeleport = nil, 0
_ENV.PlayerTP = function(TargetCFrame)
    local Character = Player.Character
    if not IsAlive(Character) or not Character.PrimaryPart then return false end
    if (tick() - lastTeleport) <= 1 and lastCFrame == TargetCFrame then return false end
    lastTeleport = tick()
    lastCFrame = TargetCFrame
    _ENV.OnFarm = true
    local Distance = (Character.PrimaryPart.Position - TargetCFrame.Position).Magnitude
    if Distance < Settings.TweenSpeed then
        Character.PrimaryPart.CFrame = TargetCFrame
        return TweenCreator:stopTween(Character.PrimaryPart)
    end
    TweenCreator.new(Character.PrimaryPart, Distance / Settings.TweenSpeed, "CFrame", TargetCFrame)
end
