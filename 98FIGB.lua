local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "etanhub", HidePremium = false, SaveConfig = false})

local Tab = Window:MakeTab({
	Name = "Tab",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Misc"
})

OrionLib:MakeNotification({
	Name = "fellveit#8812 discord",
	Content = "TRASH GAME",
	Image = "rbxassetid://4483345998",
	Time = 5
})

Tab:AddButton({
	Name = "Give Gears",
	Callback = function()
        local player = game.Players.LocalPlayer
        local backpack = player.Backpack
        
        for _, tool in ipairs(game:GetService("ReplicatedStorage").Tools:GetChildren()) do
            local toolCopy = tool:Clone()
            toolCopy.Parent = backpack
        end

  	end    
})

Tab:AddButton({
	Name = "See correct glasses",
	Callback = function()
        local function changePartColor(part, color)
            if part:IsA("BasePart") then
                part.Color = color
            end
            for _, descendant in ipairs(part:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    descendant.Color = color
                end
            end
        end
        
        local tilesFolder = game:GetService("Workspace"):FindFirstChild("tiles")
        if not tilesFolder or not tilesFolder:IsA("Folder") then
            return
        end
        
        for _, child in ipairs(tilesFolder:GetChildren()) do
            local breakScript = child:FindFirstChild("Break", true)
            if breakScript then
                changePartColor(child, Color3.new(1, 0, 0))
            else
                changePartColor(child, Color3.new(0, 1, 0))
            end
        end
        
  	end    
})

Tab:AddButton({
	Name = "TP to finish",
	Callback = function()
        local targetCFrame = CFrame.new(-693.367, 61.2128, -584.122)

        game.Players.LocalPlayer.Character:MoveTo(targetCFrame.p)        
  	end    
})
OrionLib:Init()