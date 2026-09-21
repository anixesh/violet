local Violet = {
	Release = "v0.0.1",
	Folder = "Violet",
}

local newref = cloneref or function(o)
    return o
end

local Services = setmetatable({}, {
    __index = function(self, service)
        self[service] = newref(game:GetService(service))
        return self[service]
    end
})

local CollectionService = Services.CollectionService
local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local RunService = Services.RunService
local Players = Services.Players

local CoreGui = Services.CoreGui

local IsStudio
if RunService:IsStudio() then
	IsStudio = true
end

local tween = {}
setmetatable(tween, {
	__call = function(self, object: Instance, goal, tweenin, callback)
		local tween = TweenService:Create(object, tweenin or TweenInfo.new(), goal)
		tween.Completed:Connect(callback or function() end)
		tween:Play()
	end,
})

function stack(tbl, container)
	local stacksize = 0
	local i = #tbl
	while i > 0 do
		local gui = tbl[i]
		if gui then
			stacksize = stacksize + gui.AbsoluteSize.Y + 5
			local pos = UDim2.new(0.5, 0, 1.04, -stacksize)
			tween(gui, { Position = pos }, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
			if pos.Y.Offset < -container.AbsoluteSize.Y then
				break
			end
		end
		i = i - 1
	end
end

local VioletUI = (IsStudio and script.Parent.Parent:WaitForChild("Violet")) or game:GetObjects("rbxassetid://77008296710097")[1]

if gethui then
    VioletUI.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(VioletUI)
    VioletUI.Parent = CoreGui
elseif not IsStudio and CoreGui:FindFirstChild("RobloxGui") then
    VioletUI.Parent = CoreGui:FindFirstChild("RobloxGui")
elseif not IsStudio then
    VioletUI.Parent = CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == VioletUI.Name and Interface ~= VioletUI then
			Interface:Destroy()
		end
	end
elseif not isStudio then
	for _, Interface in ipairs(CoreGui:GetChildren()) do
		if Interface.Name == VioletUI.Name and Interface ~= VioletUI then
			Interface:Destroy()
		end
	end
end

VioletUI.Enabled = true
VioletUI.DisplayOrder = 9999999999

local Base: Frame = VioletUI.Base
local SidePanel: Frame = Base.SidePanel
local Elements: Frame = Base.Elements
local Display: Frame = Base.Display

local Notifications: Frame = VioletUI.Notifications
local NotificationTemplate: Frame = Notifications.Template

local activeNotifications = {}
local activeTab

local function drag(window)
	pcall(function()
		local dragging = false
		local dragInput
		local mousePosition
		local framePosition

		window.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				dragging = true
				mousePosition = input.Position
				framePosition = window.Position

				dragInput = input

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		window.InputChanged:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			then
				dragInput = input
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - mousePosition

				local goal = UDim2.new(
					framePosition.X.Scale,
					framePosition.X.Offset + delta.X,
					framePosition.Y.Scale,
					framePosition.Y.Offset + delta.Y
				)
				tween(
					window,
					{ Position = goal },
					TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
				)
			end
		end)
	end)
end

local function ShowWindow()
	local tweenin = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	Base.Visible = true

	tween(Base, { Size = UDim2.fromOffset(481, 310) }, tweenin)

	task.delay(0.06, function()
		tween(Display.Label, { TextTransparency = 0.1 }, tweenin)
		tween(Display.SubLabel, { TextTransparency = 0.3 }, tweenin)

		tween(Base.Close, { ImageTransparency = 0.3 }, tweenin)
		tween(Base.Hide, { ImageTransparency = 0.3 }, tweenin)

		for _, tab in pairs(SidePanel.Tabs:GetChildren()) do
			if tab:IsA("Frame") and tab.Name ~= "Template" then
				if activeTab and activeTab.Button and activeTab.Button == tab then
					tween(tab, { BackgroundTransparency = 0.3 }, tweenin)
					tween(tab.Label, { TextTransparency = 0.4 }, tweenin)
					continue
				end
				tween(tab.Label, { TextTransparency = 0.7 }, tweenin)
			end
		end

		if activeTab and activeTab.Page then
			activeTab.Page.Visible = true
			tween(activeTab.Page, { Position = UDim2.fromScale(0.5, 0.485) }, tweenin)
		end
	end)
end

local function HideWindow()
	local tweenin = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	tween(Display.Label, { TextTransparency = 1 }, tweenin)
	tween(Display.SubLabel, { TextTransparency = 1 }, tweenin)

	tween(Base.Close, { ImageTransparency = 1 }, tweenin)
	tween(Base.Hide, { ImageTransparency = 1 }, tweenin)

	for _, tab in pairs(SidePanel.Tabs:GetChildren()) do
		if tab:IsA("Frame") and tab.Name ~= "Template" then
			tween(tab, { BackgroundTransparency = 1 }, tweenin)
			tween(tab.Label, { TextTransparency = 1 }, tweenin)
		end
	end

	if activeTab and activeTab.Page then
		tween(activeTab.Page, { Position = UDim2.fromScale(0.5, 1.5) }, tweenin)
		task.wait(0.15)
		activeTab.Page.Visible = false
	end

	task.delay(0.06, function()
		tween(Base, { Size = UDim2.fromOffset(0, 0) }, tweenin, function()
			Base.Visible = false
		end)
	end)
end

function Violet:Notify(Title, Description, Duration)
	Title = Title or "Cosmic Hub"
	Description = Description or ""
	Duration = Duration or 5

	task.spawn(function()
		local Notification = NotificationTemplate:Clone()
		Notification.Name = "Notification-" .. #Notifications:GetChildren()

		Notification.Label.Text = Title
		Notification.SubLabel.Text = Description

		Notification.Parent = Notifications
		Notification.Visible = true

		tween(
			Notification,
			{ Position = UDim2.new(0.5, 0.94) },
			TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		)

		local function clearnotif(notif)
			for i, v in ipairs(activeNotifications) do
				if v == notif then
					table.remove(activeNotifications, i)
					break
				end
			end
			notif:Destroy()
		end

		Notification.Interact["MouseButton1Click"]:Connect(function()
			tween(
				Notification,
				{ Position = UDim2.fromScale(1.5, 0.94) },
				TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
				function()
					clearnotif(Notification)
				end
			)
		end)

		task.delay(Duration, function()
			tween(
				Notification,
				{ Position = UDim2.fromScale(1.5, 0.94) },
				TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
				function()
					clearnotif(Notification)
				end
			)
		end)

		table.insert(activeNotifications, Notification)
		stack(activeNotifications, Notifications)
	end)
end

function Violet:CreateWindow(WindowSettings)
	WindowSettings = WindowSettings
		or {
			Title = "<b>Cosmic Hub</b> " .. Violet.Release,
			SubTitle = "by nigma",
			DefaultTab = 1,
			Keybind = Enum.KeyCode.RightControl,
		}

	Display.Label.Text = WindowSettings.Title
	Display.SubLabel.Text = WindowSettings.SubTitle

	drag(Base)
	ShowWindow()

	local Tabs = {}
	function Tabs:NewTab(TabSettings)
		local Tab = SidePanel.Tabs.Template:Clone()
		Tab.Name = TabSettings.Title or "Tab-" .. #SidePanel.Tabs:GetChildren() - 2

		Tab.Label.Text = TabSettings.Title

		local Page = Elements.Template:Clone()
		Page.Name = TabSettings.Title
		Page.Visible = false
		Page.Position = UDim2.fromScale(0.5, 1.5)
		Page.Parent = Elements

		local Data = {
			Button = Tab,
			Page = Page,
		}

		table.insert(Tabs, Data)

		Tab.Parent = SidePanel.Tabs
		Tab.Visible = true

		local function selectTab(tab)
			if activeTab == tab then
				tween(
					tab.Button,
					{ BackgroundTransparency = 1 },
					TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
				)
				tween(
					tab.Button.Label,
					{ TextTransparency = 0.7 },
					TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
				)

				tween(
					tab.Page,
					{ Position = UDim2.fromScale(0.5, 1.5) },
					TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
					function()
						tab.Page.Visible = false
					end
				)
				activeTab = nil
				return
			end

			if activeTab then
				tween(
					activeTab.Button,
					{ BackgroundTransparency = 1 },
					TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
				)
				tween(
					activeTab.Button.Label,
					{ TextTransparency = 0.7 },
					TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
				)

				tween(
					activeTab.Page,
					{ Position = UDim2.fromScale(0.5, 1.5) },
					TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
				)
				task.wait(0.2)
				activeTab.Page.Visible = false
			end

			tween(
				tab.Button,
				{ BackgroundTransparency = 0.3 },
				TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				tab.Button.Label,
				{ TextTransparency = 0.4 },
				TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)

			tab.Page.Visible = true
			tween(
				tab.Page,
				{ Position = UDim2.fromScale(0.5, 0.485) },
				TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			activeTab = tab
		end

		if #Tabs == WindowSettings.DefaultTab then
			selectTab(Data)
		end

		local normal = Tab.Size
		local hover = 1.04
		local press = 0.96

		local clickSize = UDim2.new(
			Tab.Size.X.Scale * press,
			Tab.Size.Y.Scale * press,
			Tab.Size.X.Offset * press,
			Tab.Size.Y.Offset * press
		)

		local hoverSize = UDim2.new(
			Tab.Size.X.Scale * hover,
			Tab.Size.Y.Scale * hover,
			Tab.Size.X.Offset * hover,
			Tab.Size.Y.Offset * hover
		)

		Tab["MouseEnter"]:Connect(function()
			if activeTab == Data then
				return
			end

			tween(
				Tab,
				{ BackgroundTransparency = 0.85, Size = hoverSize },
				TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Tab.Label,
				{ TextTransparency = 0.5 },
				TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
		end)

		Tab["MouseLeave"]:Connect(function()
			if activeTab == Data then
				return
			end

			tween(
				Tab,
				{ BackgroundTransparency = 1, Size = normal },
				TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Tab.Label,
				{ TextTransparency = 0.7 },
				TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
		end)

		Tab.Interact["MouseButton1Down"]:Connect(function()
			--if activeTab == Data then return end
			tween(Tab, { Size = clickSize }, TweenInfo.new(0.06, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
		end)

		Tab.Interact["MouseButton1Up"]:Connect(function()
			--if activeTab == Data then return end
			tween(Tab, { Size = normal }, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
		end)

		Tab.Interact["MouseButton1Click"]:Connect(function()
			selectTab(Data)
		end)

		function Data:CreateToggle(ToggleSettings)
			local Toggle = Data.Page.Toggle:Clone()
			Toggle.Name = ToggleSettings.Title

			Toggle.BackgroundTransparency = 1
			Toggle.Switch.BackgroundTransparency = 1
			Toggle.Switch.UIStroke.Transparency = 1

			Toggle.Switch.State.BackgroundTransparency = 1
			Toggle.Switch.State.Icon.ImageTransparency = 1
			Toggle.Label.TextTransparency = 1

			Toggle.Label.Text = ToggleSettings.Title

			Toggle.Parent = Data.Page
			Toggle.Visible = true

			local function switchState(state)
				if state then
					tween(
						Toggle.Switch.State,
						{ Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0 },
						TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					)
					tween(
						Toggle.Switch.State.Icon,
						{ ImageTransparency = 0.2 },
						TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					)
				else
					tween(
						Toggle.Switch.State,
						{ Size = UDim2.fromScale(0, 0), BackgroundTransparency = 1 },
						TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					)
					tween(
						Toggle.Switch.State.Icon,
						{ ImageTransparency = 1 },
						TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					)
				end
			end

			tween(
				Toggle,
				{ BackgroundTransparency = 0.5 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Toggle.Switch,
				{ BackgroundTransparency = 0.5 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Toggle.Switch.UIStroke,
				{ Transparency = 0.7 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)

			tween(
				Toggle.Label,
				{ TextTransparency = 0.3 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)

			if ToggleSettings.Enabled then
				switchState(true)
			else
				switchState(false)
			end

			Toggle["MouseEnter"]:Connect(function()
				tween(
					Toggle,
					{ BackgroundTransparency = 0.4 },
					TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				)
			end)

			Toggle["MouseLeave"]:Connect(function()
				tween(
					Toggle,
					{ BackgroundTransparency = 0.5 },
					TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				)
			end)

			Toggle.Interact["MouseButton1Click"]:Connect(function()
				ToggleSettings.Enabled = not ToggleSettings.Enabled
				switchState(ToggleSettings.Enabled)

				local success, response = pcall(function()
					ToggleSettings.Callback(ToggleSettings.Enabled)
				end)

				if not success then
					Violet:Notify("Callback Error", "Check console to view the whole error.")
					warn("[Violet]: Callback error | " .. tostring(response))
				end
			end)

			return ToggleSettings
		end

		function Data:CreateButton(ButtonSettings)
			local Button = Data.Page.Button:Clone()
			Button.Name = ButtonSettings.Title

			Button.BackgroundTransparency = 1
			Button.Label.TextTransparency = 1
			Button.SubLabel.TextTransparency = 1

			Button.Label.Text = ButtonSettings.Title

			Button.Parent = Data.Page
			Button.Visible = true

			tween(
				Button,
				{ BackgroundTransparency = 0.5 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Button.Label,
				{ TextTransparency = 0.3 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Button.SubLabel,
				{ TextTransparency = 0.5 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)

			Button["MouseEnter"]:Connect(function()
				tween(
					Button,
					{ BackgroundTransparency = 0.4 },
					TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				)
			end)

			Button["MouseLeave"]:Connect(function()
				tween(
					Button,
					{ BackgroundTransparency = 0.5 },
					TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				)
			end)

			Button.Interact["MouseButton1Click"]:Connect(function()
				local success, response = pcall(ButtonSettings.Callback)
				if not success then
					Violet:Notify("Callback Error", "Check console to view the whole error.")
					warn("[Violet]: Callback error | " .. tostring(response))
				end
			end)

			return ButtonSettings
		end

		function Data:CreateDropdown(DropdownSettings)
			local debounce = false
			local isOpen = false

			local Dropdown = Data.Page.Dropdown:Clone()
			Dropdown.Name = DropdownSettings.Title

			Dropdown.BackgroundTransparency = 1
			Dropdown.Top.BackgroundTransparency = 1
			Dropdown.Top.Label.TextTransparency = 1
			Dropdown.Top.SubLabel.TextTransparency = 1
			Dropdown.Top.Icon.ImageTransparency = 1

			Dropdown.Top.Label.Text = DropdownSettings.Title
			Dropdown.Top.SubLabel.Text = ""
			Dropdown.List.Visible = false

			Dropdown.Parent = Data.Page
			Dropdown.Visible = true

			tween(
				Dropdown.Top,
				{ BackgroundTransparency = 0.5 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Dropdown.Top.Label,
				{ TextTransparency = 0.3 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Dropdown.Top.SubLabel,
				{ TextTransparency = 0.5 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Dropdown.Top.Icon,
				{ ImageTransparency = 0.3 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)

			if DropdownSettings.CurrentOption then
				if type(DropdownSettings.CurrentOption) == "string" then
					DropdownSettings.CurrentOption = { DropdownSettings.CurrentOption }
				end
				if not DropdownSettings.MultipleOptions and type(DropdownSettings.CurrentOption) == "table" then
					DropdownSettings.CurrentOption = { DropdownSettings.CurrentOption[1] }
				end
			else
				DropdownSettings.CurrentOption = {}
			end

			local function updateSubLabel()
				local cur = DropdownSettings.CurrentOption
				if DropdownSettings.MultipleOptions then
					if #cur == 0 then
						Dropdown.Top.SubLabel.Text = "None"
					elseif #cur == 1 then
						Dropdown.Top.SubLabel.Text = cur[1]
					else
						Dropdown.Top.SubLabel.Text = "Various"
					end
				else
					Dropdown.Top.SubLabel.Text = cur[1] or "None"
				end
			end

			updateSubLabel()

			local optionheight = 25
			local padding = 6
			local topheight = 35

			local function calculateOpenHeight()
				local count = #DropdownSettings.Options
				return topheight + math.min(count, 5) * (optionheight + padding)
			end

			local function SetOptions()
				for _, option in ipairs(DropdownSettings.Options) do
					local dOption = Dropdown.List.Template:Clone()
					dOption.Name = option
					dOption.Label.Text = option

					dOption.LayoutOrder = #Dropdown.List:GetChildren() - 3

					dOption.Parent = Dropdown.List
					dOption.Visible = true

					tween(
						dOption.Label,
						{ TextTransparency = 0.4 },
						TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					)

					dOption.Interact["MouseEnter"]:Connect(function()
						if not table.find(DropdownSettings.CurrentOption, option) then
							tween(
								dOption,
								{ BackgroundTransparency = 0.75 },
								TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							)
							tween(
								dOption.Label,
								{ TextTransparency = 0.25 },
								TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							)
						end
					end)

					dOption.Interact["MouseLeave"]:Connect(function()
						if not table.find(DropdownSettings.CurrentOption, option) then
							tween(
								dOption,
								{ BackgroundTransparency = 1 },
								TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
							)
							tween(
								dOption.Label,
								{ TextTransparency = 0.4 },
								TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
							)
						end
					end)

					dOption.Interact["MouseButton1Click"]:Connect(function()
						local idx = table.find(DropdownSettings.CurrentOption, option)

						if idx then
							table.remove(DropdownSettings.CurrentOption, idx)
							tween(
								dOption,
								{ BackgroundTransparency = 1 },
								TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
							)
							tween(
								dOption.Label,
								{ TextTransparency = 0.4 },
								TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
							)
							tween(
								dOption.Icon,
								{ ImageTransparency = 1 },
								TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
							)
						else
							table.insert(DropdownSettings.CurrentOption, option)
							tween(
								dOption,
								{ BackgroundTransparency = 0.3 },
								TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							)
							tween(
								dOption.Label,
								{ TextTransparency = 0.2 },
								TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							)
							tween(
								dOption.Icon,
								{ ImageTransparency = 0.2 },
								TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
							)
						end

						updateSubLabel()

						local success, response = pcall(function()
							DropdownSettings.Callback(DropdownSettings.CurrentOption)
						end)

						if not success then
							warn("[Violet]: " .. tostring(response))
						end
					end)
				end
			end

			SetOptions()

			Dropdown.Top["MouseEnter"]:Connect(function()
				tween(
					Dropdown.Top,
					{ BackgroundTransparency = 0.4 },
					TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				)
			end)

			Dropdown.Top["MouseLeave"]:Connect(function()
				tween(
					Dropdown.Top,
					{ BackgroundTransparency = 0.5 },
					TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				)
			end)

			Dropdown.Top.Interact["MouseButton1Click"]:Connect(function()
				local openHeight = calculateOpenHeight()
				if not debounce then
					tween(
						Dropdown,
						{ BackgroundTransparency = 0.75 },
						TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					)
					tween(
						Dropdown,
						{ Size = UDim2.fromOffset(266, openHeight) },
						TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					)
					tween(
						Dropdown.Top.Icon,
						{ Rotation = 180 },
						TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					)

					task.wait(0.07)
					Dropdown.List.Visible = true
					debounce = true
					return
				end
				tween(
					Dropdown,
					{ Size = UDim2.fromOffset(266, 35) },
					TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				)
				tween(
					Dropdown.Top.Icon,
					{ Rotation = 0 },
					TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				)
				tween(
					Dropdown,
					{ BackgroundTransparency = 1 },
					TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				)

				task.wait(0.05)
				Dropdown.List.Visible = false
				debounce = false
			end)

			return DropdownSettings
		end

		function Data:CreateInput(InputSettings)
			local Input = Data.Page.Input:Clone()
			Input.Name = InputSettings.Title
			Input.Label.Text = InputSettings.Title

			Input.BackgroundTransparency = 1
			Input.Label.TextTransparency = 1
			Input.Holder.BackgroundTransparency = 1
			Input.Holder.UIStroke.Transparency = 1
			Input.Holder.InputBox.TextTransparency = 1

			Input.Holder.InputBox.Text = InputSettings.CurrentValue or ""

			Input.Parent = Data.Page
			Input.Visible = true

			tween(
				Input,
				{ BackgroundTransparency = 0.5 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Input.Label,
				{ TextTransparency = 0.3 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Input.Holder,
				{ BackgroundTransparency = 0.5 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Input.Holder.UIStroke,
				{ Transparency = 0.7 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Input.Holder.InputBox,
				{ TextTransparency = 0.4 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)

			Input.Holder.Size = UDim2.new(0, Input.Holder.InputBox.TextBounds.X + 24, 0, 23)

			Input.Holder.InputBox["FocusLost"]:Connect(function()
				local success, response = pcall(function()
					InputSettings.Callback(Input.Holder.InputBox.Text)
					InputSettings.CurrentValue = Input.Holder.InputBox.Text
				end)

				if not success then
					Violet:Notify("Callback error", "check console for more information.")
					warn(tostring(response))
				end
			end)

			Input["MouseEnter"]:Connect(function()
				tween(
					Input,
					{ BackgroundTransparency = 0.4 },
					TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				)
			end)

			Input["MouseLeave"]:Connect(function()
				tween(
					Input,
					{ BackgroundTransparency = 0.5 },
					TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				)
			end)

			Input.Holder.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
				tween(
					Input.Holder,
					{ Size = UDim2.new(0, Input.Holder.InputBox.TextBounds.X + 24, 0, 23) },
					TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				)
			end)

			return InputSettings
		end
		--[[
		function Data:CreateSlider(SliderSettings)
			local dragging = false
			local Slider = Elements.Template.Slider:Clone()
			Slider.Name = SliderSettings.Title
			Slider.Label.Text = SliderSettings.Title
			
			Slider.BackgroundTransparency = 1
			Slider.Label.TextTransparency = 1
			Slider.Range.TextTransparency = 1
			
			Slider.Container.BackgroundTransparency = 1
			Slider.Container.Bar.BackgroundTransparency = 1
			Slider.Container.Bar.Knob.BackgroundTransparency = 1
			
			Slider.Range.Text = tostring(SliderSettings.CurrentValue).." / "..tostring(SliderSettings.Range[2])
			
			Slider.Parent = Data.Page
			Slider.Visible = true
			
			tween(Slider, { BackgroundTransparency = 0.5 }, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
			tween(Slider.Label, { TextTransparency = 0.3 }, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
			tween(Slider.Range, { TextTransparency = 0.3 }, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))

			tween(Slider.Container, { BackgroundTransparency = 0.5 }, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
			tween(Slider.Container.Bar, { BackgroundTransparency = 0 }, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
			tween(Slider.Container.Bar.Knob, { BackgroundTransparency = 0.2 }, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))

			Slider.Container.Bar.Size = UDim2.new(0, Slider.Container.AbsoluteSize.X * ((SliderSettings.CurrentValue - SliderSettings.Range[1]) / (SliderSettings.Range[2] - SliderSettings.Range[1])) > 5 and Slider.Container.AbsoluteSize.X * ((SliderSettings.CurrentValue - SliderSettings.Range[1]) / (SliderSettings.Range[2] - SliderSettings.Range[1])) or 5, 1, 0)
			
			Slider["MouseEnter"]:Connect(function()
				tween(Slider, { BackgroundTransparency = 0.4 },TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
			end)

			Slider["MouseLeave"]:Connect(function()
				tween(Slider, { BackgroundTransparency = 0.5 }, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
			end)
			
			Slider.Container.Interact.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
				end
			end)
			
			Slider.Container.Interact.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			
			Slider.Container.Interact.MouseButton1Down:Connect(function(x)
				local current = Slider.Container.Bar.AbsolutePosition.X + Slider.Container.Bar.AbsoluteSize.X
				local start = current
				local location = x
				local loop; loop = RunService.Stepped:Connect(function()
					if dragging then
						location = UserInputService:GetMouseLocation().X
						current = current + 0.025 * (location - start)
						
						if location < Slider.Container.AbsolutePosition.X then
							location = Slider.Container.AbsolutePosition.X
						elseif location > Slider.Container.AbsolutePosition.X + Slider.Container.AbsoluteSize.X then
							location = Slider.Container.AbsolutePosition.X + Slider.Container.AbsoluteSize.X
						end
						
						if current < Slider.Container.AbsolutePosition.X + 5 then
							current = Slider.Container.AbsolutePosition.X + 5
						elseif current > Slider.Container.AbsolutePosition.X + Slider.Container.AbsoluteSize.X then
							current = Slider.Container.AbsolutePosition.X + Slider.Container.AbsoluteSize.X
						end
						
						if current <= location and (location - start) < 0 then
							start = location
						elseif current >= location and (location - start) > 0 then
							start = location
						end
						
						tween(Slider.Container.Bar, { Size = UDim2.new(0, current - Slider.Container.AbsolutePosition.X, 1, 0) }, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.In))
						local newvalue = SliderSettings.Range[1] + (location - Slider.Container.AbsolutePosition.X) / Slider.Container.AbsoluteSize.X * (SliderSettings.Range[2] - SliderSettings.Range[1])
						
						newvalue = math.floor(newvalue / SliderSettings.Increment + 0.5) * (SliderSettings.Increment * 10000000) / 10000000
						newvalue = math.clamp(newvalue, SliderSettings.Range[1], SliderSettings.Range[2])
						
						if SliderSettings.CurrentValue ~= newvalue then
							local success, response = pcall(function()
								SliderSettings.Callback(newvalue)
							end)
							
							if not success then
								warn(tostring(response))
							end
							
							SliderSettings.CurrentValue = newvalue
							Slider.Range.Text = tostring(SliderSettings.CurrentValue).." / "..tostring(SliderSettings.Range[2])
						end
					else
						tween(Slider.Container.Bar, { Size = UDim2.new(0, location - Slider.Container.AbsolutePosition.X > 5 and location - Slider.Container.AbsolutePosition.X or 5, 1, 0) }, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out))
						loop:Disconnect()	
					end
				end)
			end)
			
			return SliderSettings
		end
		]]
		function Data:CreateSlider(SliderSettings)
			local dragging = false
			local Slider = Elements.Template.Slider:Clone()
			Slider.Name = SliderSettings.Title
			Slider.Label.Text = SliderSettings.Title

			Slider.BackgroundTransparency = 1
			Slider.Label.TextTransparency = 1
			Slider.Range.TextTransparency = 1

			Slider.Container.BackgroundTransparency = 1
			Slider.Container.Bar.BackgroundTransparency = 1
			Slider.Container.Bar.Knob.BackgroundTransparency = 1

			Slider.Range.Text = tostring(SliderSettings.CurrentValue) .. " / " .. tostring(SliderSettings.Range[2])

			Slider.Parent = Data.Page
			Slider.Visible = true

			tween(
				Slider,
				{ BackgroundTransparency = 0.5 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Slider.Label,
				{ TextTransparency = 0.3 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Slider.Range,
				{ TextTransparency = 0.3 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Slider.Container,
				{ BackgroundTransparency = 0.5 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Slider.Container.Bar,
				{ BackgroundTransparency = 0 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)
			tween(
				Slider.Container.Bar.Knob,
				{ BackgroundTransparency = 0.2 },
				TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			)

			local min = SliderSettings.Range[1]
			local max = SliderSettings.Range[2]
			local inc = SliderSettings.Increment

			local function valuetopixel(val)
				local t = (val - min) / (max - min)
				return math.max(Slider.Container.AbsoluteSize.X * t, 5)
			end

			local function pixelstovalue(px)
				local t = math.clamp((px - Slider.Container.AbsolutePosition.X) / Slider.Container.AbsoluteSize.X, 0, 1)
				local raw = min + t * (max - min)
				local stepped = math.floor(raw / inc + 0.5) * inc

				stepped = math.floor(stepped * 10000000 + 0.5) / 10000000
				return math.clamp(stepped, min, max)
			end

			Slider.Container.Bar.Size = UDim2.new(0, valuetopixel(SliderSettings.CurrentValue), 1, 0)

			local function applyValue(val, smooth)
				local px = valuetopixel(val)
				if smooth then
					tween(
						Slider.Container.Bar,
						{ Size = UDim2.new(0, px, 1, 0) },
						TweenInfo.new(0.18, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
					)
				else
					Slider.Container.Bar.Size = UDim2.new(0, px, 1, 0)
				end

				if SliderSettings.CurrentValue ~= val then
					SliderSettings.CurrentValue = val
					Slider.Range.Text = tostring(val) .. " / " .. tostring(max)

					local ok, err = pcall(SliderSettings.Callback, val)
					if not ok then
						warn("[Violet]: Slider Callback | " .. tostring(err))
					end
				end
			end

			Slider["MouseEnter"]:Connect(function()
				tween(
					Slider,
					{ BackgroundTransparency = 0.4 },
					TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				)
			end)

			Slider["MouseLeave"]:Connect(function()
				tween(
					Slider,
					{ BackgroundTransparency = 0.5 },
					TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				)
			end)

			Slider.Container.Interact.InputBegan:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					dragging = true

					local clickVal = pixelstovalue(input.Position.X)
					applyValue(clickVal, true)

					local loop
					loop = RunService.Stepped:Connect(function()
						if not dragging then
							loop:Disconnect()
							return
						end

						local mouseX = UserInputService:GetMouseLocation().X
						local val = pixelstovalue(mouseX)
						applyValue(val, true)
					end)
				end
			end)

			local function endDragInput(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					if not dragging then
						return
					end
					dragging = false

					local finalpx = valuetopixel(SliderSettings.CurrentValue)
					tween(
						Slider.Container.Bar,
						{ Size = UDim2.new(0, finalpx, 1, 0) },
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
					)
				end
			end

			Slider.Container.Interact.InputEnded:Connect(endDragInput)
			UserInputService.InputEnded:Connect(endDragInput)
		end

		return Data
	end

	Base.Close["MouseButton1Click"]:Connect(function()
		HideWindow()
		Violet:Notify("Cosmic Hub", "Script unloaded, re-execute to load the script again.", 5)
		task.wait(5)
		VioletUI:Destroy()
	end)

	Base.Hide["MouseButton1Click"]:Connect(function()
		HideWindow()
		Violet:Notify(
			"Cosmic Hub",
			"Window hidden, press '"
				.. tostring(WindowSettings.Keybind.Name:gsub("(%l)(%u)", "%1 %2"))
				.. "'' to open the window again."
		)
	end)

	local active = false
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		if input.KeyCode == WindowSettings.Keybind then
			if not active then
				HideWindow()
				task.wait(0.25)
				active = true
				return
			end
			ShowWindow()
			task.wait(0.25)
			active = false
		end
	end)

	return Tabs
end

return Violet
