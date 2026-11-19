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
 local env=(type(getgenv)=="function" and getgenv()) or _G
 if env.LegacyTurkeyRetryActive then
  warn("LEGACY TELEPORT RETRY ALREADY RUNNING")
  return
 end
 env.LegacyTurkeyRetryActive=true

 local q=queue_on_teleport or queueonteleport
  or (syn and syn.queue_on_teleport)
  or (fluxus and fluxus.queue_on_teleport)
 if q then
  local ok=pcall(q,SOLO)
  print("AUTO CONTINUE:",ok)
  if not ok then warn("RUN AGAIN IN LEGACY IF NEEDED") end
 else
  warn("AUTO CONTINUE UNAVAILABLE; RUN AGAIN IN LEGACY")
 end

 local P=game:GetService("Players").LocalPlayer
 local TS=game:GetService("TeleportService")
 local B=P:WaitForChild("PlayerGui"):WaitForChild("Lobby")
  :WaitForChild("GameModes"):WaitForChild("Modes")
  :WaitForChild("Legacy"):WaitForChild("Card")
  :WaitForChild("PlayButton")

 local going=false
 local since=0
 local attempts=0
 P.OnTeleport:Connect(function(state)
  if state==Enum.TeleportState.Failed then
   going=false
   warn("TELEPORT FAILED; RETRYING")
  elseif state==Enum.TeleportState.Started
   or state==Enum.TeleportState.WaitingForServer
   or state==Enum.TeleportState.InProgress then
   going=true
   since=os.clock()
   print("TELEPORT STARTED:",state.Name)
  end
 end)
 TS.TeleportInitFailed:Connect(function(player,result,message)
  if player==P then
   going=false
   warn("TELEPORT INIT FAILED:",tostring(result),tostring(message))
  end
 end)

 while game.PlaceId==13775256536 and P.Parent do
  if not going or os.clock()-since>20 then
   going=false
   attempts=attempts+1
   since=os.clock()
   local ok,err=pcall(function()
    if firesignal then firesignal(B.Activated)
    else B:Activate() end
   end)
   print("LEGACY TELEPORT ATTEMPT",attempts,"OK",ok)
   if not ok then warn(tostring(err)) end
  end
  task.wait(3)
 end
else
 warn("UNKNOWN PLACE:",game.PlaceId)
end
