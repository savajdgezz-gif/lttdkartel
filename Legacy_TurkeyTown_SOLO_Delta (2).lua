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

local MAIN_ID=13775256536
local LEGACY_ID=93712201161812

if not game:IsLoaded() then game.Loaded:Wait() end

if game.PlaceId==LEGACY_ID then
 loadstring(SOLO)()
elseif game.PlaceId==MAIN_ID then
 local env=(type(getgenv)=="function" and getgenv()) or _G
 if env.LegacyTurkeyRetryActive then
  warn("TELEPORT LOOP ALREADY ACTIVE")
  return
 end
 env.LegacyTurkeyRetryActive=true

 local q=queue_on_teleport or queueonteleport
  or (syn and syn.queue_on_teleport)
  or (fluxus and fluxus.queue_on_teleport)
 if type(q)=="function" then
  local ok,err=pcall(q,SOLO)
  print("QUEUED SOLO:",ok)
  if not ok then warn("QUEUE ERROR:",err) end
 else
  warn("NO QUEUE SUPPORT: RUN SCRIPT AGAIN AFTER TELEPORT")
 end

 local P=game:GetService("Players").LocalPlayer
 local TS=game:GetService("TeleportService")
 local active=false
 local confirmedStart=false
 local startedAt=0
 local attempt=0

 P.OnTeleport:Connect(function(state)
  if state==Enum.TeleportState.Failed then
   active=false
   confirmedStart=false
   warn("TELEPORT FAILED")
  elseif state==Enum.TeleportState.Started
   or state==Enum.TeleportState.WaitingForServer
   or state==Enum.TeleportState.InProgress then
   active=true
   confirmedStart=true
   startedAt=os.clock()
   print("TELEPORT STATE:",state.Name)
  end
 end)
 TS.TeleportInitFailed:Connect(function(player,result,message)
  if player==P then
   active=false
   confirmedStart=false
   warn("TELEPORT INIT FAILED:",result,message)
  end
 end)

 local function pressLegacy()
  local G=P:FindFirstChild("PlayerGui")
  local obj=G
  for _,name in ipairs({"Lobby","GameModes","Modes","Legacy","Card","PlayButton"}) do
   obj=obj and obj:FindFirstChild(name)
  end
  if not obj then return false,"Legacy PlayButton missing" end
  return pcall(function()
   if type(firesignal)=="function" then
    firesignal(obj.Activated)
   else
    obj:Activate()
   end
  end)
 end

 while P.Parent and game.PlaceId==MAIN_ID do
  if not active or os.clock()-startedAt>(confirmedStart and 30 or 8) then
   attempt=attempt+1
   active=true
   confirmedStart=false
   startedAt=os.clock()
   local ok,err
   if attempt%4==0 then
    print("FALLBACK LEGACY BUTTON #"..attempt)
    ok,err=pressLegacy()
   else
    print("TELEPORT BY PLACE ID #"..attempt,"->",LEGACY_ID)
    ok,err=pcall(function()
     TS:Teleport(LEGACY_ID,P)
    end)
   end
   if not ok then
    active=false
    warn("TELEPORT ERROR:",err)
   end
  end
  task.wait(3)
 end
else
 warn("UNKNOWN PLACE:",game.PlaceId)
end
