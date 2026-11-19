local SOLO=[=[
if not game:IsLoaded() then game.Loaded:Wait() end
if game.PlaceId~=93712201161812 then return end

local P=game.Players.LocalPlayer
local G=P:WaitForChild("PlayerGui")
local H=(P.Character or P.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
local Q=G:WaitForChild("Lobby"):WaitForChild("QueueFrame")
local L=workspace:WaitForChild("Lifts")

local function count(l)
 local t=l:FindFirstChild("PlayersCount",true)
 return t and tonumber(t.Text:match("(%d+)%s*/%s*%d+"))
end

local function visible(b)
 local p=b
 while p and p~=G do
  if p:IsA("GuiObject") and not p.Visible then return false end
  if p:IsA("ScreenGui") and not p.Enabled then return false end
  p=p.Parent
 end
 return true
end

local function start(l)
 if count(l)~=1 then return false end
 for _,b in ipairs(Q:GetDescendants()) do
  if b:IsA("GuiButton") and visible(b) then
   local s=b.Name:lower()
   if b:IsA("TextButton") then s=s.." "..b.Text:lower() end
   for _,v in ipairs(b:GetDescendants()) do
    if v:IsA("TextLabel") then s=s.." "..v.Text:lower() end
   end
   if s:find("start") then
    if count(l)~=1 then return false end
    local ok=pcall(function()
     if firesignal then firesignal(b.Activated)
     else b:Activate() end
    end)
    print("START:",ok)
    return ok
   end
  end
 end
 return false
end

local T={}
for _,l in ipairs(L:GetChildren()) do
 if l.Name=="TurkeyTown" and count(l)==0 then
  local a=l:FindFirstChild("Area",true)
  if a and a:IsA("BasePart") then
   T[#T+1]={l=l,a=a}
  end
 end
end

table.sort(T,function(a,b)
 return (a.a.Position-H.Position).Magnitude<
 (b.a.Position-H.Position).Magnitude
end)

for _,v in ipairs(T) do
 if count(v.l)==0 then
  H.CFrame=v.a.CFrame*CFrame.new(0,2,0)
  print("ENTERING TURKEY TOWN")

  for i=1,25 do
   task.wait(.2)
   if count(v.l)==1 or (count(v.l) or 0)>1 then break end
  end

  if count(v.l)==1 then
   for i=1,25 do
    if count(v.l)~=1 then break end
    if start(v.l) then return end
    task.wait(.2)
   end
  end
 end
end
warn("NO CONFIRMED SOLO START")
]=]

if game.PlaceId==93712201161812 then
 loadstring(SOLO)()
elseif game.PlaceId==13775256536 then
 local q=queue_on_teleport
  or (syn and syn.queue_on_teleport)
  or (fluxus and fluxus.queue_on_teleport)

 if q then
  local ok=pcall(q,SOLO)
  print("AUTO CONTINUE:",ok)
  if not ok then
   warn("Run script again after teleport")
  end
 else
  warn("Auto continue unavailable; run again in Legacy")
 end

 local G=game.Players.LocalPlayer:WaitForChild("PlayerGui")
 local B=G:WaitForChild("Lobby")
  :WaitForChild("GameModes")
  :WaitForChild("Modes")
  :WaitForChild("Legacy")
  :WaitForChild("Card")
  :WaitForChild("PlayButton")

 if firesignal then
  firesignal(B.Activated)
 else
  B:Activate()
 end
 print("TELEPORT TO LEGACY")
else
 warn("UNKNOWN PLACE:",game.PlaceId)
end
