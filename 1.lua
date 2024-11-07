-- Settings are in script.Loadstring
if not game:IsLoaded() then
	repeat 
		wait() 
	until game:IsLoaded()
	wait()
	for i = 1, 10 do 
		task.wait(1)
		warn("Autoexecuted, Waiting", i.."/10")
	end
end
wait(1)
warn("Start")

-- // Start of Settings
local s = getgenv().Settings

-- Farm Settings
local fs = s.FarmSettings
local TweenSpeed = fs.TweenSpeed
local MaxDist = fs.MaxDist
local MurderDist = fs.MurderDist
local MaxMurderDist = fs.MaxMurderDist
local IgnoreMurdererDist = fs.IgnoreMurdererDist
local TimeBetweenTween = fs.TimeBetweenTween

-- Buy Settings
local bs = s.BuySettings
local BuyBattlePass = bs.BuyBattlePass
local BuyCrates = bs.BuyCrates


-- Other Settings
local ots = s.OtherSettings
local Rendering3D = ots.Rendering3D
local ForceRejoin = ots.ForceRejoin
local FPSCap = ots.FPSCap
local KickRejoin = ots.KickRejoin
local BlacklistedPlayers = ots.BlacklistedPlayers

-- Webhook Settings
local whs = s.WebhookSettings
local Webhook_Frequency = whs.Frequency
local Webhook_URL = whs.Candy_URL
local FinishedWebhook_URL = whs.Finished_URL
local CrateWebhook = whs.Crate_URL

-- Dev Settings
local ds = s.DevSettings
local ForceChange = ds.ForceChange

-- // End Of Settings

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HTTP = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Prompts = CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
local TeleportService = game:GetService("TeleportService")

local function Hop()
	while task.wait() do
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	end
end

for Index, Plr in pairs(Players:GetPlayers()) do
	if table.find(BlacklistedPlayers, Plr.Name) then
		Hop()
	end
end

if KickRejoin then
	Prompts.ChildAdded:Connect(function(New)
		wait()
		if New.Name == "ErrorPrompt" then
			Hop()
		end
	end)

	for _,New in pairs(Prompts:GetChildren()) do
		if New.Name == "ErrorPrompt" then
			Hop()
		end
	end
end

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 120)
local OpenCrate = Remotes:WaitForChild("Shop", 120):WaitForChild("OpenCrate", 120)
local ChangeDevice = Remotes:WaitForChild("Extras", 120):WaitForChild("ChangeLastDevice", 120)
local BuyTiers = Remotes:WaitForChild("Events", 120):WaitForChild("Halloween2024", 120):WaitForChild("BuyTiers", 120)
local ClaimReward = Remotes:WaitForChild("Events", 120):WaitForChild("Halloween2024", 120):WaitForChild("ClaimReward", 120)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 120)
local Halloween2024 = PlayerGui:WaitForChild("CrossPlatform", 120):WaitForChild("Halloween2024")

local BPInfo = Halloween2024:WaitForChild("Container", 120):WaitForChild("EventFrames", 120):WaitForChild("BattlePass", 120):WaitForChild("Info", 120)
local CurrentCandy = BPInfo:WaitForChild("Tokens", 120):WaitForChild("Container", 120):WaitForChild("TextLabel", 120)
local CurrentTier = BPInfo:WaitForChild("YourTier", 120):WaitForChild("TextLabel", 120)

local ProfileData = require(ReplicatedStorage:WaitForChild("Modules", 120):WaitForChild("ProfileData", 120))

warn(ProfileData.Materials.Owned["Candies2024"], "FromModule")

warn(CurrentCandy.Text)
warn(CurrentTier.Text)

local function BuyAllTiers(Number)
	for Index = 1, 20 do 
		BuyTiers:FireServer(1)
		ClaimReward:FireServer(tostring(Index))
	end
	wait(0.5)
	return true
end 

local RarityColor = {
	["22005"] = "16711680"; -- Legendary
	["106106106"] = "9408399"; -- Common
	["0255255"] = "28390"; -- Uncommon
	["02000"] = "58917"; -- Rare
	["2550179"] = "13369599"; -- Godly
}

local RarityName = {
	["22005"] = "Legendary";
	["106106106"] = "Common";
	["0255255"] = "Uncommon";
	["02000"] = "Rare";
	["2550179"] = "Godly";
}

function color3torgb(color3)
	return color3.R*255,color3.G*255,color3.B*255
end

local c = false
local function OpenHalloweenCrate()
	c = true
	wait()
	OpenCrate:InvokeServer(unpack({
		[1] = "Halloween2024Box",
		[2] = "MysteryBox",
		[3] = "Candies2024"
	}))
	wait(2)
	c = false
	return true
end

if CurrentTier.Text == "Your Tier: 1 / 40" then
	warn("Serverhopping due to UI Issue.")
	Hop()
end

local SaveAs = LocalPlayer.Name.."_Candy_"..ForceChange
local DeviceSelect = PlayerGui:FindFirstChild("DeviceSelect")
if DeviceSelect and DeviceSelect.Enabled then
	warn("Device Select Screen is Showing.")
	local Tablet = DeviceSelect:WaitForChild("Container"):WaitForChild("Tablet"):WaitForChild("Button")

	repeat
		local FoundScreen = PlayerGui:FindFirstChild("DeviceSelect")
		if FoundScreen then
			local xPosition = Tablet.AbsolutePosition.X + (Tablet.AbsoluteSize.X / 2)
			local yPosition = Tablet.AbsolutePosition.Y + (Tablet.AbsoluteSize.Y / 2)
			VirtualInputManager:SendMouseButtonEvent(xPosition, yPosition, 0, true, game, 0)
			VirtualInputManager:SendMouseButtonEvent(xPosition, yPosition, 0, false, game, 0)
		end
		print("Clicking Button")
		wait()
	until not PlayerGui:FindFirstChild("DeviceSelect")
else
	print("Not Selecting Device.")
end

PlayerGui.ChildAdded:Connect(function(Child)
	wait(.1)
	local DeviceSelect = PlayerGui:FindFirstChild("DeviceSelect")
	if DeviceSelect and DeviceSelect.Enabled then
		warn("Device Select Screen is Showing.")
		local Tablet = DeviceSelect:WaitForChild("Container"):WaitForChild("Tablet"):WaitForChild("Button")

		repeat
			local FoundScreen = PlayerGui:FindFirstChild("DeviceSelect")
			if FoundScreen then
				local xPosition = Tablet.AbsolutePosition.X + (Tablet.AbsoluteSize.X / 2)
				local yPosition = Tablet.AbsolutePosition.Y + (Tablet.AbsoluteSize.Y / 2)
				VirtualInputManager:SendMouseButtonEvent(xPosition, yPosition, 0, true, game, 0)
				VirtualInputManager:SendMouseButtonEvent(xPosition, yPosition, 0, false, game, 0)
			end
			print("Clicking Button")
			wait()
		until not PlayerGui:FindFirstChild("DeviceSelect")
	else
		print("Not Selecting Device.")
	end
end)


local MessageID = ""
if isfile(SaveAs) then
	MessageID = readfile(SaveAs)
end
local function WebhookSend(TaiShii, Name, Rarity, Color)
	local JSONStuff
	local Date = os.date("!*t")
	local Hour = ((Date.hour-5) % 24)
	local AmOrPm = Hour < 12 and "AM" or "PM"
	local Time = string.format("%02i:%02i %s", ((Hour - 1) % 12) + 1, Date.min, AmOrPm)

	if TaiShii == "Candy" then
		local Candy = CurrentCandy.Text
		local Tier = CurrentTier.Text
		local Split = Tier:split(" ")
		local Comb = table.concat(Split, " ", 2)

		JSONStuff = [[
			{
			  "content": "Account: ]]..tostring(LocalPlayer.Name)..[[",
			  "embeds": [
			    {
			      "title": "]]..tostring(Time)..[[",
			      "description": "🍬 ]]..tostring(Candy)..[[ Candy\n💵 ]]..Comb..[[",
			      "color": 16735775
			    }
			  ],
			  "attachments": []
			}
		]]

		request({
			Url = Webhook_URL .. "/messages/" .. MessageID,
			Method = "PATCH",
			Body = JSONStuff,
			Headers = {["Content-Type"] = "application/json"}
		})
	elseif TaiShii == "Finished" then
		JSONStuff = [[
		{
		  "content": null,
		  "embeds": [
		    {
		      "title": "Account ]]..tostring(LocalPlayer.Name)..[[ Has 98,000 Candy and the entire battlepass.",
		      "color": 16744259,
		      "author": {
		        "name": ""
		      }
		    }
		  ],
		  "attachments": []
		}
		]]

		request({
			Url = FinishedWebhook_URL,
			Method = "POST",
			Body = JSONStuff,
			Headers = {["Content-Type"] = "application/json"}
		})
	elseif TaiShii == "Crate" then
		JSONStuff = [[
		{
		  "content": "Account ]]..tostring(LocalPlayer.Name)..[[",
		  "embeds": [
		    {
		      "title": "Opened Crate",
		      "description": "]]..tostring(Name)..[[\n- ]]..tostring(Rarity)..[[",
		      "color": ]]..tostring(Color)..[[
		    }
		  ],
		  "attachments": []
		}
		]]

		request({
			Url = CrateWebhook,
			Method = "POST",
			Body = JSONStuff,
			Headers = {["Content-Type"] = "application/json"}
		})
	elseif TaiShii == "Start" then
		if MessageID ~= "" then
			print("existing")
			JSONStuff = [[
			{
			  "content": "Account: ]]..tostring(LocalPlayer.Name)..[[",
			  "embeds": [
			    {
			      "title": "Started",
			      "color": 16744259,
			      "author": {
			        "name": "Existing"
			      }
			    }
			  ],
			  "attachments": []
			}
			]]

			request({
				Url = Webhook_URL .. "/messages/" .. MessageID,
				Method = "PATCH",
				Body = JSONStuff,
				Headers = {["Content-Type"] = "application/json"}
			})
			return
		end
		print("not existing")

		-- Creates the first Message
		JSONStuff = [[
		{
		  "content": "Account: ]]..tostring(LocalPlayer.Name)..[[",
		  "embeds": [
		    {
		      "title": "Started",
		      "color": 16744259,
		      "author": {
		        "name": "New"
		      }
		    }
		  ],
		  "attachments": []
		}
		]]

		local Response = request({
			Url = Webhook_URL .. "?wait=true",
			Method = "POST",
			Body = JSONStuff,
			Headers = {["Content-Type"] = "application/json"}
		})

		local ID = HTTP:JSONDecode(Response.Body)["id"]
		MessageID = ID
		writefile(SaveAs, MessageID)
		print("Saved")
	end
end

WebhookSend("Start")

LocalPlayer.Idled:connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

local function H()
	local Character = LocalPlayer.Character
	if not Character then return nil end
	local Returning = Character:FindFirstChild("Humanoid")
	if not Returning then return nil end
	return Returning
end

local function HRP()
	local Character = LocalPlayer.Character
	if not Character then return nil end
	local Returning = Character:FindFirstChild("HumanoidRootPart")
	if not Returning then return nil end
	return Returning
end

local function CHAR()
	local Character = LocalPlayer.Character
	if not Character then return nil end
	local Returning = Character:FindFirstChild("HumanoidRootPart")
	if not Returning then return nil end
	return Character
end

local AssumeDead = false
local ActiveTween = false
local function TPTween(Position)
	if ActiveTween then repeat wait() until not ActiveTween end
	ActiveTween = true
	if AssumeDead then return end
	local HRP_1 = HRP()
	if not HRP_1 then
		ActiveTween = false
		return
	end
	local Distance = (HRP_1.Position - Position).magnitude
	local Tween = TweenService:Create(HRP_1, TweenInfo.new(Distance/TweenSpeed, Enum.EasingStyle.Linear), {
		CFrame = CFrame.new(Position)
	})
	print("Tween Will Take", Distance/TweenSpeed)
	Tween:Play()
	Tween.Completed:Wait()
	ActiveTween = false
	return true
end

if tonumber(FPSCap) and tonumber(FPSCap) ~= 60 then
	print("Capped FPS at", tostring(FPSCap))
	setfpscap(tonumber(FPSCap))
end

local MapNames = {
	"Mineshaft";
	"Manor";
	"Farmhouse";
	"BioLab";
	"Workplace";
	"Hotel";
	"Barn";
	"Factory";
	"PoliceStation";
	"ResearchFacility";
	"MilBase";
	"VampireCastle";

	"Bank";
	"Bank1";
	"Bank2";
	"Bank3";

	"House";
	"House1";
	"House2";
	"House3";

	"Mansion";
	"Mansion1";
	"Mansion2";
	"Mansion3";

	"Office";
	"Office1";
	"Office2";
	"Office3";

	"Hospital";
	"Hospital1";
	"Hospital2";
	"Hospital3";
}

local GunConnections = {}
local MapConnections = {}

print(Rendering3D, "3d Rendering")
RunService:Set3dRenderingEnabled(Rendering3D)

local ShutTheTheUpFuckFuck = false
task.spawn(function()
	WebhookSend("Candy")
	while wait(Webhook_Frequency) do
		local CandyNum = ProfileData.Materials.Owned["Candies2024"] and tonumber(ProfileData.Materials.Owned["Candies2024"]) and ProfileData.Materials.Owned["Candies2024"] > 0 and ProfileData.Materials.Owned["Candies2024"] or 1 
		if CandyNum >= 800 then
			if BuyBattlePass and CurrentTier.Text ~= "Your Tier: 20 / 20" then
				print("Buy BP Tiers")
				BuyAllTiers()
			end

			if BuyCrates and CurrentTier.Text == "Your Tier: 20 / 20" then
				print("Buy Halloween Crates")
				OpenHalloweenCrate()
			end
		end
		-- check if finished here

		if CurrentTier.Text == "Your Tier: 20 / 20" and CandyNum > 98_000 and not ShutTheTheUpFuckFuck then
			WebhookSend("Finished")
			ShutTheTheUpFuckFuck = true
		end

		WebhookSend("Candy")

		if #Players:GetPlayers() < 2 then
			print("under 2 players, leaving")
			Hop()
		end
	end
end)

if ForceRejoin > 0 then
	task.spawn(function()
		print("ForceRejoin In", ForceRejoin)
		while wait() do
			for i = 1, ForceRejoin do
				wait(1)
			end
			Hop()
		end
	end)
else
	print("ForceRejoin Off")
end

for Index, Child in pairs(workspace:GetChildren()) do 
	if table.find(MapNames, Child.Name) then 
		print(Child.Name, "Active Game")
	end
end

local ContainerHInv = PlayerGui:WaitForChild("MainGUI", 120):WaitForChild("Game", 120):WaitForChild("Inventory", 120):WaitForChild("Main", 120):WaitForChild("Weapons", 120):WaitForChild("Items", 120):WaitForChild("Container", 120):WaitForChild("Holiday", 120):WaitForChild("Container", 120):WaitForChild("Halloween", 120):WaitForChild("Container", 120)
ContainerHInv.ChildAdded:Connect(function(Child)
	wait(0.25)
	if not c then
		print("no c")
		return
	end

	if not Child:IsA("Frame") then print("not a frame") return end
	print("New Item.")
	wait(1)
	local Name = Child.ItemName
	local BGColorR = math.floor(Name.BackgroundColor3.R*255)
	local BGColorG = math.floor(Name.BackgroundColor3.G*255)
	local BGColorB = math.floor(Name.BackgroundColor3.B*255)
	local BGColor = BGColorR..BGColorG..BGColorB

	local RarityColor2 = RarityColor[BGColor] or 13369599
	local RarityName2 = RarityName[BGColor] or "Unknown"
	local WebName = Name.Label.Text

	print(WebName, RarityColor)
	WebhookSend("Crate", WebName, RarityName2,  RarityColor2)
end)


-- Send Entire Inventory
--for Index, Child in pairs(ContainerHInv:GetChildren()) do
--	if not Child:IsA("Frame") then continue end
--	local Name = Child.ItemName


--	local BGColorR = math.floor(Name.BackgroundColor3.R*255)
--	local BGColorG = math.floor(Name.BackgroundColor3.G*255)
--	local BGColorB = math.floor(Name.BackgroundColor3.B*255)
--	local BGColor = BGColorR..BGColorG..BGColorB

--	local RarityColor2 = RarityColor[BGColor] or 13369599
--	local RarityName2 = RarityName[BGColor] or "Unknown"
--	local WebName = Name.Label.Text

--	print("CRATE", WebName, RarityColor2, RarityName2)
--	WebhookSend("Crate", WebName, RarityName2,  RarityColor2)
--	wait()
--end

workspace.ChildAdded:Connect(function(Child)
	wait()
	if table.find(MapNames, Child.Name) then 
		print("Map Found", Child.Name)

		-- Gun Dropped
		AssumeDead = false
		local TPdUp = false
		local LocalPlayerMurderer = false
		local Container = Child:WaitForChild("CoinContainer", 120)
		print("Start Coin", Child.Name)
		MapConnections[Child.Name] = true
		while MapConnections[Child.Name] == true do
			wait(TimeBetweenTween)
			local MainGui = LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
			if not MainGui then
				AssumeDead = true
				repeat
					wait()
				until LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
				wait(.25)
			end
			local Candy = MainGui.Game.CoinBags.Container.Candy
			if not Candy.Visible then 
				AssumeDead = true
				continue
			end

			local HRP_2 = HRP()
			if not HRP_2 then
				AssumeDead = true
				print("Died (?)")
				continue 
			end

			print("-----------------------------------")

			-- Check for Nearby Murderer
			for Index, Player in pairs(Players:GetPlayers()) do 
				local PlrChar = Player.Character
				if not PlrChar then continue end 
				local PlrHRP = PlrChar:FindFirstChild("HumanoidRootPart")
				if not PlrHRP then continue end

				local FoundKnife = PlrChar:FindFirstChild("Knife") or Player.Backpack:FindFirstChild("Knife") or false
				local FoundGun = PlrChar:FindFirstChild("Gun") or Player.Backpack:FindFirstChild("Gun") or false

				local LocalChar = CHAR()
				if not LocalChar then
					warn("No Character")
					continue
				end

				local IgnoreMurdererDistance = false
				local LocalFoundGun = LocalChar:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun") or false
				if FoundKnife and Child.Name ~= "Barn" then

					if Player.Name == LocalPlayer.Name then
						print("LocalPlayer Is the Murderer")
					else
						print(Player.Name, "Is the Murderer")
					end

					if LocalFoundGun then
						print("LocalPlayer has gun.")

						local aughhimsofull = Candy:FindFirstChild("Full")
						if aughhimsofull and aughhimsofull.Visible then 
							print("Full Candy. Killing Murderer")
							IgnoreMurdererDistance = true
							local H_1 = H()
							if not H_1 then 
								warn("No Humanoid")
								continue
							end

							if LocalFoundGun.Parent ~= LocalChar.Parent then
								H_1:EquipTool(LocalFoundGun)
								print("Equipped Gun")
							end
							wait()
							print("Shooting Murderer")

							HRP_2.CFrame = PlrHRP.CFrame * CFrame.new(0, 0, 5)

							wait(0.25)

							local Remote = LocalFoundGun.KnifeLocal.CreateBeam.RemoteFunction
							Remote:InvokeServer(1, PlrHRP.Position, "AH2")
							LocalFoundGun:Activate()
							print("Shot At Murderer")
						end
					end

					if Player.Name ~= LocalPlayer.Name then
						local Distance = (HRP_2.Position - PlrHRP.Position).magnitude
						print("Murderer Distance", Distance)
						if Distance < MurderDist and not IgnoreMurdererDistance and not IgnoreMurdererDist then
							print("Murderer Nearby", Distance)
							-- Get Farthest Coin
							local Farthest = nil 
							local FarthestDist = 0
							for Index, Coin in pairs(Container:GetChildren()) do
								if Coin.Name ~= "Coin_Server" or not Coin:FindFirstChild("TouchInterest") then continue end
								local Distance = (PlrHRP.Position - HRP_2.Position).magnitude
								if not Farthest then 
									FarthestDist = Distance
									Farthest = Coin 
									continue
								end
								if Distance > FarthestDist and Distance < MaxMurderDist then 
									FarthestDist = Distance
									Farthest = Coin
								end
							end
							if FarthestDist > 1 then
								local wft = TPTween(Farthest.Position)
								HRP_2.CFrame = CFrame.new(Farthest.Position)
								print("Tweened away from murderer")
								wait(2)
								continue
							end
						end
					else -- fuck this stupid ass else it got me kiicked like 5 times
						local aughhimsofull = Candy:FindFirstChild("Full")
						if aughhimsofull and aughhimsofull.Visible then 
							print("Murderer and Full Candy")
							local H_1 = H()
							if not H_1 then 
								warn("No Humanoid")
								continue
							end
							H_1.Health = 0
						end
						LocalPlayerMurderer = true
						print("LocalPlayer is Murderer")
					end
				end
			end

			-- Get Gun If Full
			local SoFullWearyFace = false
			local aughhimsofull = Candy:FindFirstChild("Full")
			if aughhimsofull and aughhimsofull.Visible then 
				print("Full Candy, Finding Gun.")
				SoFullWearyFace = true
				local H_1 = H()
				if not H_1 then 
					warn("No Humanoid")
					continue
				end
				local FoundGun_2 = false
				for Index, Child_2 in pairs(Child:GetDescendants()) do
					if Child_2.Name == "GunDrop" and not AssumeDead then
						if LocalPlayerMurderer then
							print("Gun was Dropped, but LocalPlayer is the Murderer")
							return
						end

						FoundGun_2 = true

						local MainGui = LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
						if not MainGui then
							return
						end
						local Candy = MainGui.Game.CoinBags.Container.Candy
						if not Candy.Visible then 
							return
						end
						print("Gun was Dropped, Picking Up.")
						local wft = TPTween(Child_2.Position)
						print("Got Gun Maybe")
					end
				end

				if not FoundGun_2 and not TPdUp then
					print("TP'D Up")
					TPdUp = true
					HRP_2.CFrame = HRP_2.CFrame * CFrame.new(0, 70, 0)
				end
			end


			-- Get Closest Coin
			if not SoFullWearyFace then
				print("Not Full, Getting Candy.")
				local Closest = nil 
				local ClosestDist = math.huge
				for Index, Coin in pairs(Container:GetChildren()) do
					if Coin.Name ~= "Coin_Server" or not Coin:FindFirstChild("TouchInterest") then continue end
					local Distance = (Coin.Position - HRP_2.Position).magnitude
					if not Closest then 
						ClosestDist = Distance
						Closest = Coin 
						continue
					end
					if Distance < ClosestDist then 
						--print("New Closest", Distance)
						ClosestDist = Distance
						Closest = Coin
					end
				end

				print(math.ceil(ClosestDist), "Closest")
				if ClosestDist < MaxDist then 
					local wft = TPTween(Closest.Position)
				end
			end

			print("-----------------------------------")
		end

		print("Ended", Child.Name)
	end
end)

workspace.ChildRemoved:Connect(function(Child)
	wait(.1)
	if table.find(MapNames, Child.Name) then
		print("Disable all Loops", Child.Name)
		for Index, a in pairs(MapConnections) do 
			MapConnections[Index] = false
		end
		for Index, c in pairs(GunConnections) do 
			c:Disconnect()
		end
	end
end)
