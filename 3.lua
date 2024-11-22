if not game:IsLoaded() then repeat task.wait() until game:IsLoaded() task.wait(10) end local rs = game:GetService("RunService") local Studio = rs:IsStudio() local global = Studio and _G or getgenv()
if Studio then
	warn("Studio")
	function request()
		return true
	end

	function readfile()
		return true
	end

	function isfile()
		return true
	end

	function writefile()
		return true
	end

	function setfpscap()
		return true
	end
end
local ScriptVersion = "3.01"
print("Starting MM2 Farm "..ScriptVersion)

-- // Settings
local Settings = global.Settings
local Event = Settings.Event
local FarmSettings = Settings.FarmSettings
local OtherSettings = Settings.OtherSettings
local WebhookSettings = Settings.WebhookSettings
local DevSettings = Settings.DevSettings
-- Farm Settings
local TweenSpeed = FarmSettings.TweenSpeed
local MaxDist = FarmSettings.MaxDist
local MurderDist = FarmSettings.MurderDist
local MaxMurderDist = FarmSettings.MaxMurderDist
local IgnoreMurdererDist = FarmSettings.IgnoreMurdererDist
local TimeBetweenTween = FarmSettings.TimeBetweenTween
-- Other Settings
local Rendering3D = OtherSettings.Rendering3D
local ForceRejoin = OtherSettings.ForceRejoin
local FPSCap = OtherSettings.FPSCap
local KickRejoin = OtherSettings.KickRejoin
local BlacklistedPlayers = OtherSettings.BlacklistedPlayers
-- Dev Settings
local ForceChange = DevSettings.ForceChange


-- // Event Settings
-- Halloween2024 Event Settings
local EventSettings = Settings.EventSettings
local Halloween2024_Settings = EventSettings["Halloween2024"]
local Halloween2024_BuyBattlePass
local Halloween2024_BuyCrates
local Halloween2024_Webhook_Frequency
local Halloween2024_Webhook_URL
local Halloween2024_FinishedWebhook_URL
local Halloween2024_CrateWebhook_URL
if Event == "Halloween2024" and Halloween2024_Settings then
	Halloween2024_BuyBattlePass = Halloween2024_Settings.BuyBattlePass
	Halloween2024_BuyCrates = Halloween2024_Settings.BuyCrates
	Halloween2024_Webhook_Frequency = Halloween2024_Settings.Frequency
	Halloween2024_Webhook_URL = Halloween2024_Settings.Candy_URL
	Halloween2024_FinishedWebhook_URL = Halloween2024_Settings.Finished_URL
	Halloween2024_CrateWebhook_URL = Halloween2024_Settings.Crate_URL
	warn("Halloween2024 Settings", Halloween2024_Settings)
end


-- // Main
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- // Dont execute Twice.
--if global.Executed then
--	LocalPlayer:Kick("Do not Execute Twice. Rejoining.")
--else
--	global.Executed = true	
--end


local TeleportService = game:GetService("TeleportService")
local CoreGui
local Prompts

if not Studio then
	CoreGui = game:GetService("CoreGui")
	Prompts = CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
end

-- Kick Check
local function Time()
	local Date = os.date("!*t")
	local Hour = ((Date.hour-6) % 24)
	local AmOrPm = Hour < 12 and "AM" or "PM"
	local Time = string.format("%02i:%02i %s", ((Hour - 1) % 12) + 1, Date.min, AmOrPm)
	return Time
end

print("Starting Main")
local function Hop(delayed)
	print("ServerHopping")
	if delayed then
		wait(3)
	end
	while task.wait() do
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	end
end

for Index, Plr in pairs(Players:GetPlayers()) do
	if table.find(BlacklistedPlayers, Plr.Name) and not Studio then
		Hop()
	end
end

if KickRejoin and not Studio then
	Prompts.ChildAdded:Connect(function(New)
		wait()
		if New.Name == "ErrorPrompt" then
			Hop()
		end
	end)

	for Index, New in pairs(Prompts:GetChildren()) do
		if New.Name == "ErrorPrompt" then
			Hop()
		end
	end
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 120)
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HTTP = game:GetService("HttpService")
local SendInvChange = false
if tonumber(FPSCap) and tonumber(FPSCap) ~= 60 then
	print("Capped FPS at", tostring(FPSCap))
	setfpscap(tonumber(FPSCap))
end
if not Studio then
	RunService:Set3dRenderingEnabled(Rendering3D)
end

local function Character()
	local C = LocalPlayer.Character
	if not C then return false end
	local HRP = C:FindFirstChild("HumanoidRootPart")
	local H = C:FindFirstChild("Humanoid")
	if not HRP or not H then return false end
	if H.Health <= 0 then return false end
	return C
end

local AssumeDead = false
local ActiveTween = false
local function TPTween(Position)
	if ActiveTween then repeat wait() until not ActiveTween end
	ActiveTween = true
	if AssumeDead then return end
	local Char_1 = Character()
	if not Char_1 then
		ActiveTween = false
		return
	end
	local Distance = (Char_1.HumanoidRootPart.Position - Position).magnitude
	local Tween = TweenService:Create(Char_1.HumanoidRootPart, TweenInfo.new(Distance/TweenSpeed, Enum.EasingStyle.Linear), {
		CFrame = CFrame.new(Position)
	})
	print("Tween Will Take", Distance/TweenSpeed)
	Tween:Play()
	Tween.Completed:Wait()
	ActiveTween = false
	return true
end

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local Shop = Remotes:WaitForChild("Shop")

local OpenCrate = Shop:WaitForChild("OpenCrate")
local ProfileData = Modules:WaitForChild("ProfileData")
local ProfileDataReq = require(ProfileData)

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

local function color3torgb(color3)
	return color3.R*255,color3.G*255,color3.B*255
end


-- // Halloween 2024 Event - "it works"
local Halloween2024_GUI
local Halloween2024_BPInfo
local Halloween2024_CurrentCandy
local Halloween2024_CurrentTier
local Halloween2024_BuyTiers
local Halloween2024_ClaimReward
local Halloween2024_CandyFromMod = 0
local Halloween2024_BuyAllTiers = function() return false end
local Halloween2024_BuyCrate = function() return false end
local Halloween2024_CandyFile = LocalPlayer.Name.."_Candy_"..ForceChange
local Halloween2024_MessageID = ""
if isfile(Halloween2024_CandyFile) then
	Halloween2024_MessageID = readfile(Halloween2024_CandyFile)
end
if Event == "Halloween2024" then
	warn("Event is Halloween2024")
	warn("Halloween2024", ProfileDataReq.Materials.Owned["Candies2024"], "Candies From Module")

	Halloween2024_BuyAllTiers = function()
		if Halloween2024_CandyFromMod >= 800 then
			warn("Halloween2024", "Buying Battle Pass Tiers.")
			for Index = 1, 20 do 
				Halloween2024_BuyTiers:FireServer(1)
				Halloween2024_ClaimReward:FireServer(tostring(Index))
			end
		end
		Halloween2024_CandyFromMod = ProfileDataReq.Materials.Owned["Candies2024"]
		return true
	end 

	Halloween2024_BuyCrate = function()
		if Halloween2024_CandyFromMod >= 800 then
			warn("Halloween2024", "Buying Crate.")
			SendInvChange = true
			wait()
			OpenCrate:InvokeServer(unpack({
				[1] = "Halloween2024Box",
				[2] = "MysteryBox",
				[3] = "Candies2024"
			}))
			task.wait(1)
			SendInvChange = false
		end
		Halloween2024_CandyFromMod = ProfileDataReq.Materials.Owned["Candies2024"]
		return true
	end

	Halloween2024_CandyFromMod = ProfileDataReq.Materials.Owned["Candies2024"]
	Halloween2024_GUI = PlayerGui:WaitForChild("CrossPlatform", 120):WaitForChild("Halloween2024", 120)

	Halloween2024_BuyTiers = Remotes:WaitForChild("Events", 120):WaitForChild("Halloween2024", 120):WaitForChild("BuyTiers", 120)
	Halloween2024_ClaimReward = Remotes:WaitForChild("Events", 120):WaitForChild("Halloween2024", 120):WaitForChild("ClaimReward", 120)


	Halloween2024_BPInfo = Halloween2024_GUI:WaitForChild("Container", 120):WaitForChild("EventFrames", 120):WaitForChild("BattlePass", 120):WaitForChild("Info", 120)
	Halloween2024_CurrentCandy = Halloween2024_BPInfo:WaitForChild("Tokens", 120):WaitForChild("Container", 120):WaitForChild("TextLabel", 120)
	Halloween2024_CurrentTier = Halloween2024_BPInfo:WaitForChild("YourTier", 120):WaitForChild("TextLabel", 120)

	if Halloween2024_CurrentTier.Text == "Your Tier: 1 / 40" then
		warn("Halloween2024", "Serverhopping due to UI Issue.")
		Hop()
	end

	warn("Halloween2024 Setup Complete")
end

-- // Thanksgiving 2024 - Better.
if Event == "Thanksgiving2024" then
	warn("Event Is Thanksgiving2024")
end

--[[
		["Thanksgiving2024"] = {
			BuyBattlePass = true;
			BuyCrates = true;
			
			Frequency = 30;
			Currency_URL = "https://discord.com/api/webhooks/1306434694434263081/tLKnL_02GIQQwIpYtM9dy-_7MOMhcEHd6GrjRHRwwGGGNZNEqjymhA9fjCqNePXMZdVC";
			Crate_URL = "https://discord.com/api/webhooks/1306434876446212096/D7iI8IOHGFHLzwVGwgMfzcY1pTkttJJe-Ltuv3-L-ZXncDohXGx3V18qtCt4brA7fR8q";
		};
]]


-- // Check for Device Selection Screen
local function SelectPhone()
	local DeviceSelect = PlayerGui:FindFirstChild("DeviceSelect")

	if not DeviceSelect then
		return false
	end

	local Phone = DeviceSelect:WaitForChild("Container"):WaitForChild("Phone"):WaitForChild("Button")

	repeat
		local FoundScreen = PlayerGui:FindFirstChild("DeviceSelect")
		if FoundScreen then
			local xPosition = Phone.AbsolutePosition.X + (Phone.AbsoluteSize.X / 2)
			local yPosition = Phone.AbsolutePosition.Y + (Phone.AbsoluteSize.Y / 2)
			VirtualInputManager:SendMouseButtonEvent(xPosition, yPosition, 0, true, game, 0)
			VirtualInputManager:SendMouseButtonEvent(xPosition, yPosition, 0, false, game, 0)
		end
		wait()
	until not PlayerGui:FindFirstChild("DeviceSelect")
	print("Selected Device")
end

SelectPhone()

PlayerGui.ChildAdded:Connect(function(Child)
	wait(.1)
	SelectPhone()
end)

local function WebhookSend(TaiShii, Name, Rarity, Color)
	local JSONStuff

	-- Halloween Stuff :( (i want to kill myself looking at this)	
	if Event == "Halloween2024" then
		warn("Halloween2024", "Webhook", TaiShii)
		if TaiShii == "Candy" then

			if not Halloween2024_Webhook_URL then
				warn("Halloween2024 Webhook_URL is not set.")
				return
			end
			local Candy = Halloween2024_CurrentCandy.Text
			local Tier = Halloween2024_CurrentTier.Text
			local Split = Tier:split(" ")
			local Comb = table.concat(Split, " ", 2)

			JSONStuff = [[
				{
				  "content": "Account: ]]..tostring(LocalPlayer.Name)..[[",
				  "embeds": [
				    {
				      "title": "]]..tostring(Time())..[[",
				      "description": "🍬 ]]..tostring(Candy)..[[ Candy\n💵 ]]..Comb..[[",
				      "color": 16735775
				    }
				  ],
				  "attachments": []
				}
			]]

			request({
				Url = Halloween2024_Webhook_URL .. "/messages/" .. Halloween2024_MessageID,
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
				Url = Halloween2024_FinishedWebhook_URL,
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
				Url = Halloween2024_CrateWebhook_URL,
				Method = "POST",
				Body = JSONStuff,
				Headers = {["Content-Type"] = "application/json"}
			})
		elseif TaiShii == "Start" then
			if Halloween2024_MessageID ~= "" then
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
					Url = Halloween2024_Webhook_URL .. "/messages/" .. Halloween2024_MessageID,
					Method = "PATCH",
					Body = JSONStuff,
					Headers = {["Content-Type"] = "application/json"}
				})
				return
			end

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
				Url = Halloween2024_Webhook_URL .. "?wait=true",
				Method = "POST",
				Body = JSONStuff,
				Headers = {["Content-Type"] = "application/json"}
			})

			local ID = HTTP:JSONDecode(Response.Body)["id"]
			Halloween2024_MessageID = ID
			writefile(Halloween2024_CandyFile, Halloween2024_MessageID)
		end
	end
end

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
end

if Event == "Halloween2024" then
	local SentFinished = false
	task.spawn(function()
		WebhookSend("Candy")
		while wait(Halloween2024_Webhook_Frequency) do
			Halloween2024_CandyFromMod = ProfileDataReq.Materials.Owned["Candies2024"]
			local CandyNum = Halloween2024_CandyFromMod and tonumber(Halloween2024_CandyFromMod) and Halloween2024_CandyFromMod > 0 and Halloween2024_CandyFromMod or 1 
			if CandyNum >= 800 then
				if Halloween2024_BuyBattlePass and Halloween2024_CurrentTier.Text ~= "Your Tier: 20 / 20" then
					print("Buy BP Tiers")
					Halloween2024_BuyAllTiers()
				end

				if Halloween2024_BuyCrates and Halloween2024_CurrentTier.Text == "Your Tier: 20 / 20" then
					print("Buy Halloween Crates")
					Halloween2024_BuyCrates()
				end
			end

			if Halloween2024_CurrentTier.Text == "Your Tier: 20 / 20" and CandyNum > 98_000 and not SentFinished then
				WebhookSend("Finished")
				SentFinished = true
			end

			WebhookSend("Candy")
			if #Players:GetPlayers() < 2 then
				warn("under 2 players, leaving")
				Hop()
			end
		end
	end)
end

print("Finished Main")
print("Starting Farm")
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

for Index, Child in pairs(workspace:GetChildren()) do 
	if table.find(MapNames, Child.Name) then 
		warn(Child.Name, "Active Game, Starting Next Round")
	end
end
WebhookSend("Start")

if not Studio then
	print("Waiting for Inventory.")
	local ContainerHInv = PlayerGui:WaitForChild("MainGUI", 120):WaitForChild("Game", 120):WaitForChild("Inventory", 120):WaitForChild("Main", 120):WaitForChild("Weapons", 120):WaitForChild("Items", 120):WaitForChild("Container", 120):WaitForChild("Holiday", 120):WaitForChild("Container", 120):WaitForChild("Halloween", 120):WaitForChild("Container", 120)
	ContainerHInv.ChildAdded:Connect(function(Child)
		wait()
		if not SendInvChange then
			return
		end

		if not Child:IsA("Frame") then return end
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
	print("Setup Inventory")
end

local function GetClosestPart(CloseTable)
	local Char_Close = Character()
	if not Char_Close then
		AssumeDead = true
		warn("GetClosestPart Failed, No Character.")
		return
	end

	local Closest = nil 
	local ClosestDist = math.huge
	for Index, Coin in pairs(CloseTable) do
		if Coin.Name ~= "Coin_Server" or not Coin:FindFirstChild("TouchInterest") then continue end
		local Distance = (Coin.Position - Char_Close.HumanoidRootPart.Position).magnitude
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
	return {Closest, ClosestDist}
end

workspace.ChildAdded:Connect(function(Child)
	wait()
	if table.find(MapNames, Child.Name) then 
		print("Map Found", Child.Name)

		-- Gun Dropped
		AssumeDead = false
		local TPdUp = false
		local LocalPlayerMurderer = false
		local Container = Child:WaitForChild("CoinContainer", 120)
		print("Start Scanning", Child.Name)
		MapConnections[Child.Name] = true
		while MapConnections[Child.Name] == true do
			task.wait(TimeBetweenTween)
			local MainGui = LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
			if not MainGui then
				AssumeDead = true
				repeat
					wait()
				until LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
				wait(.25)
			end


			-- // Check for Full Coin Bag
			--[[
				BeachBall
				Candy
				Coin
				Egg
			]]
			local CoinBag = nil
			for Index, Child_1 in pairs(MainGui.Game.CoinBags.Container:GetChildren()) do
				if not Child_1:IsA("Frame") then continue end

				if Child_1.Visible then
					CoinBag = Child_1
					-- print(Child_1.Name, "Visible")
				else
					-- print(Child_1.Name, "Not Visible")
				end
			end
			
			print("-----------------------------------")

			if CoinBag == nil then
				warn("Default Coin Bag")
				CoinBag = MainGui.Game.CoinBags.Container.Coin
			end
			print("CoinBag: ", CoinBag.Name)

			if not CoinBag.Visible then
				AssumeDead = true
				continue
			end

			local FullCoinBag = CoinBag:FindFirstChild("Full")


			local Char_2 = Character()
			if not Char_2 then
				AssumeDead = true
				print("Died (?)")
				continue 
			end


			-- // Check for Nearby Murderer
			for Index, Player in pairs(Players:GetPlayers()) do 
				local PlrChar = Player.Character
				if not PlrChar then continue end 
				local PlrHRP = PlrChar:FindFirstChild("HumanoidRootPart")
				if not PlrHRP then continue end

				local FoundKnife = PlrChar:FindFirstChild("Knife") or Player.Backpack:FindFirstChild("Knife") or false
				local FoundGun = PlrChar:FindFirstChild("Gun") or Player.Backpack:FindFirstChild("Gun") or false

				local LocalChar = Character()
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
						print("LocalPlayer has Gun.")

						if FullCoinBag and FullCoinBag.Visible then 
							print("Full Candy. Killing Murderer")
							IgnoreMurdererDistance = true
							local Char_3 = Character()
							if not Char_3 then 
								warn("No Humanoid")
								continue
							end

							if LocalFoundGun.Parent ~= LocalChar.Parent then
								Char_3.Humanoid:EquipTool(LocalFoundGun)
								print("Equipped Gun")
							end
							wait()
							print("Shooting Murderer")

							Char_3.HumanoidRootPart.CFrame = PlrHRP.CFrame * CFrame.new(0, 0, 5)

							wait(0.1)

							local Remote = LocalFoundGun.KnifeLocal.CreateBeam.RemoteFunction
							Remote:InvokeServer(1, PlrHRP.Position, "AH2")
							LocalFoundGun:Activate()
							print("Shot At Murderer")
						end
					end

					if Player.Name ~= LocalPlayer.Name then
						local Distance = (Char_2.HumanoidRootPart.Position - PlrHRP.Position).magnitude
						print("Murderer Distance", Distance)
						if Distance < MurderDist and not IgnoreMurdererDistance and not IgnoreMurdererDist then
							print("Murderer Nearby", Distance)
							-- Get Farthest Coin
							local Farthest = nil 
							local FarthestDist = 0
							for Index, Coin in pairs(Container:GetChildren()) do
								if Coin.Name ~= "Coin_Server" or not Coin:FindFirstChild("TouchInterest") then continue end
								local Distance = (PlrHRP.Position - Char_2.HumanoidRootPart.Position).magnitude
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
								Char_2.HumanoidRootPart.CFrame = CFrame.new(Farthest.Position)
								print("Tweened away from murderer")
								wait(2)
								continue
							end
						end
					else -- fuck this stupid ass else it got me kiicked like 5 times
						if FullCoinBag and FullCoinBag.Visible then 
							print("Murderer and Full Candy")
							local Char_4 = Character()
							if not Char_4 then 
								warn("No Humanoid")
								continue
							end
							Char_4.Humanoid.Health = 0
						end
						LocalPlayerMurderer = true
						print("LocalPlayer is Murderer")
					end
				end
			end

			-- // Get Gun If Full
			local SoFullWearyFace = false
			if FullCoinBag and FullCoinBag.Visible then 
				print("Full Candy, Finding Gun.")
				SoFullWearyFace = true
				local Char_5 = Character()
				if not Char_5 then 
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
					end
				end

				if not FoundGun_2 and not TPdUp then
					print("TP'D Up")
					TPdUp = true
					Char_5.HumanoidRootPart.CFrame = Char_5.HumanoidRootPart.CFrame * CFrame.new(0, 70, 0)
				end
			end


			-- // Get Closest Coin
			if FullCoinBag and not FullCoinBag.Visible then
				print("Not Full, Getting Coin.")

				if Event == "Halloween2024" then
					
					-- // Halloween Pickup
					warn("Halloween2024 Closest")
					local CheckTable = {}
					for Index, Coin in pairs(Container:GetChildren()) do
						if Coin.Name ~= "Coin_Server" or not Coin:FindFirstChild("TouchInterest") then continue end
						-- Checks for Candy Only, in events this would maybe say BeachBall_Server instead of Coin_Server
						table.insert(CheckTable, Coin)
					end

					local GetClosest = GetClosestPart(CheckTable)
					local Closest = GetClosest[1]
					local ClosestDist = GetClosest[2]

					warn("Halloween2024", math.ceil(ClosestDist), "Closest Candy")
					if ClosestDist < MaxDist and Closest then 
						local wft = TPTween(Closest.Position)
					end
					
				elseif Event == "Thanksgiving2024" then
					
					-- // Thanksgiving Pickup
					warn("Thanksgiving2024 Closest - Needs Testing")
					local CheckTable = {}
					for Index, Coin in pairs(Container:GetChildren()) do
						if Coin.Name ~= "Coin_Server" or not Coin:FindFirstChild("TouchInterest") then continue end
						-- Checks for Candy Only, in events this would maybe say BeachBall_Server instead of Coin_Server
						table.insert(CheckTable, Coin)
					end

					local GetClosest = GetClosestPart(CheckTable)
					local Closest = GetClosest[1]
					local ClosestDist = GetClosest[2]

					warn("Thanksgiving2024", math.ceil(ClosestDist), "Closest Coin")
					if ClosestDist < MaxDist and Closest then 
						local wft = TPTween(Closest.Position)
					end
					
				else
					-- // Default Coin Pickup
					print("Normal Closest - Needs Testing")
					local CheckTable = {}
					for Index, Coin in pairs(Container:GetChildren()) do
						if Coin.Name ~= "Coin_Server" or not Coin:FindFirstChild("TouchInterest") then continue end
						table.insert(CheckTable, Coin)
					end

					local GetClosest = GetClosestPart(CheckTable)
					local Closest = GetClosest[1]
					local ClosestDist = GetClosest[2]

					print(math.ceil(ClosestDist), "Closest Coin")
					if ClosestDist < MaxDist and Closest then 
						local wft = TPTween(Closest.Position)
					end
				end
			end

			print("-----------------------------------")
		end

		print("Loop Ended", Child.Name)
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

print("Everything Finished")

warn("- ============== - If Anything is here that isnt 'script' tell me. ")
for Index, Thing in pairs(getfenv()) do
	warn(tostring(Index), tostring(Thing))
end 
warn("- ============== -")
