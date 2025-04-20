local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Load Kavo UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Configuration
local SWERVE_COORDS = Vector3.new(38405, 230, 1088) -- Swerve coordinates (unused, kept for reference)
local MOTORUSH_COORDS = Vector3.new(-341, 12, -2979) -- MotoRush coordinates
local SWERVE_FLING_SPEED = 1000 -- Forward speed for Swerve
local SWERVE_DOWNWARD_SPEED = -500 -- Downward speed for Swerve
local MOTORUSH_FLING_SPEED = 1100 -- Forward speed for MotoRush
local MOTORUSH_UPWARD_SPEED = 250 -- Upward speed for MotoRush
local isAnchored = false -- Track anchor state

-- Global reference to the Kavo UI Window
local Window = nil

-- Clean up any existing UI instances at script start
for _, gui in pairs(game.CoreGui:GetChildren()) do
	if gui.Name == "Vacs Multi Autofarmer V2 | Thank you Grok <3" then
		gui:Destroy()
		print("Cleaned up existing UI at script start")
	end
end

-- Function to handle Swerve boost
local function swerveBoost()
	if character and humanoidRootPart then
		if isAnchored then
			humanoidRootPart.Anchored = false
			isAnchored = false
			return
		end
		
		-- Get forward direction
		local forwardDirection = humanoidRootPart.CFrame.LookVector
		
		-- Combine forward and downward velocity
		local launchVelocity = forwardDirection * SWERVE_FLING_SPEED + Vector3.new(0, SWERVE_DOWNWARD_SPEED, 0)
		
		-- Apply velocity
		humanoidRootPart.Velocity = launchVelocity
		
		-- Anchor after short delay
		wait(0.5)
		if humanoidRootPart then
			humanoidRootPart.Anchored = true
			isAnchored = true
		end
	end
end

-- Function to handle MotoRush boost
local function motoRushBoost()
	if character and humanoidRootPart then
		if isAnchored then
			humanoidRootPart.Anchored = false
			isAnchored = false
			return
		end
		
		-- Get forward direction
		local forwardDirection = humanoidRootPart.CFrame.LookVector
		
		-- Combine forward and upward velocity
		local launchVelocity = forwardDirection * MOTORUSH_FLING_SPEED + Vector3.new(0, MOTORUSH_UPWARD_SPEED, 0)
		
		-- Apply velocity
		humanoidRootPart.Velocity = launchVelocity
		
		-- Anchor after short delay
		wait(0.5)
		if humanoidRootPart then
			humanoidRootPart.Anchored = true
			isAnchored = true
			-- Teleport to MotoRush coordinates after anchoring
			humanoidRootPart.CFrame = CFrame.new(MOTORUSH_COORDS)
		end
	end
end

-- Function to handle unanchoring
local function unanchorPlayer()
	if character and humanoidRootPart and isAnchored then
		humanoidRootPart.Anchored = false
		isAnchored = false
	end
end

-- Setup UI with Kavo (called only once)
local function setupUI()
	-- Double-check if UI already exists in CoreGui or Window is set
	if Window or game.CoreGui:FindFirstChild("Vacs Multi Autofarmer V2 | Thank you Grok <3") then
		print("UI already exists, skipping creation")
		if Window then
			Library:ToggleUI() -- Ensure the existing UI is visible
		end
		return
	end

	-- Create the UI
	print("Creating new UI")
	Window = Library.CreateLib("Vacs Multi Autofarmer V2 | Thank you Grok <3", "Midnight")

	-- MotoRush Farm Tab
	local MotoRushFarmTab = Window:NewTab("MotoRush Farm")
	local MotoRushFarmSection = MotoRushFarmTab:NewSection("MotoRush Farm Keybind")
	MotoRushFarmSection:NewKeybind("MotoRush Farm", "Press your keybind to start the Autofarm...", Enum.KeyCode.Q, function()
		print("MotoRush keybind pressed")
		motoRushBoost()
	end)

	-- Swerve Farm Tab
	local SwerveFarmTab = Window:NewTab("Swerve Farm")
	local SwerveFarmSection = SwerveFarmTab:NewSection("Swerve Farm Keybind")
	SwerveFarmSection:NewKeybind("Swerve Farm", "Press your keybind to start the Autofarm...", Enum.KeyCode.E, function()
		print("Swerve keybind pressed")
		swerveBoost()
	end)

	-- Un-Anchor Tab
	local UnAnchorTab = Window:NewTab("Unfreeze")
	local UnAnchorSection = UnAnchorTab:NewSection("Un-Anchor Keybind")
	UnAnchorSection:NewKeybind("Unfreeze", "This is only really needed for the Swerve Autofarm!", Enum.KeyCode.Equals, function()
		print("Unfreeze keybind pressed")
		unanchorPlayer()
	end)

	-- Settings Tab
	local SettingsTab = Window:NewTab("Settings")
	local SettingsSection = SettingsTab:NewSection("UI Toggle Keybind")
	SettingsSection:NewKeybind("Toggle UI", "Key to toggle the UI", Enum.KeyCode.Insert, function()
		print("Toggling UI...")
		Library:ToggleUI()
	end)
end

-- Handle character respawn
local function onCharacterAdded(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	
	-- Sync anchor state
	isAnchored = humanoidRootPart.Anchored
	if isAnchored then
		humanoidRootPart.Anchored = false
		isAnchored = false
	end
	
	-- Ensure the UI is visible (but don't recreate it)
	if Window then
		print("Toggling existing UI visibility on respawn")
		Library:ToggleUI() -- Make sure the UI is visible
	else
		-- If Window is nil for some reason, try to set up the UI
		print("Window not found on respawn, attempting to set up UI")
		setupUI()
	end
end

-- Initial UI setup (called only once)
setupUI()

-- Connect character respawn
player.CharacterAdded:Connect(onCharacterAdded)