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
	end,
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

local ease = {
	open = TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	close = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
	fadeIn = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	fadeOut = TweenInfo.new(0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
	tabIn = TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	tabOut = TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
	pageIn = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	pageOut = TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
	hover = TweenInfo.new(0.09, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	leave = TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	press = TweenInfo.new(0.05, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	spring = TweenInfo.new(0.20, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	notifIn = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	notifOut = TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
	dropIn = TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	dropOut = TweenInfo.new(0.10, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
	toggle = TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	sliderSnap = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	sliderMove = TweenInfo.new(0.04, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
}

function stack(tbl, container)
	local stacksize = 0
	local i = #tbl
	while i > 0 do
		local gui = tbl[i]
		if gui then
			stacksize = stacksize + gui.AbsoluteSize.Y + 5
			local pos = UDim2.new(0.5, 0, 1.04, -stacksize)
			tween(gui, { Position = pos }, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
			if pos.Y.Offset < -container.AbsoluteSize.Y then
				break
			end
		end
		i = i - 1
	end
end

local VioletUI = (IsStudio and script.Parent.Parent:WaitForChild("Violet"))
	or game:GetObjects("rbxassetid://77008296710097")[1]

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
elseif not IsStudio then
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
					TweenInfo.new(0.04, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
				)
			end
		end)
	end)
end

local function ShowWindow()
	Base.Visible = true

	-- window pops open with a slight overshoot
	tween(Base, { Size = UDim2.fromOffset(481, 310) }, ease.open)

	task.delay(0.05, function()
		tween(Display.Label, { TextTransparency = 0.1 }, ease.fadeIn)
		tween(Display.SubLabel, { TextTransparency = 0.3 }, ease.fadeIn)
		tween(Base.Close, { ImageTransparency = 0.3 }, ease.fadeIn)
		tween(Base.Hide, { ImageTransparency = 0.3 }, ease.fadeIn)

		for _, tab in pairs(SidePanel.Tabs:GetChildren()) do
			if tab:IsA("Frame") and tab.Name ~= "Template" then
				if activeTab and activeTab.Button and activeTab.Button == tab then
					tween(tab, { BackgroundTransparency = 0.3 }, ease.tabIn)
					tween(tab.Label, { TextTransparency = 0.4 }, ease.tabIn)
					continue
				end
				tween(tab.Label, { TextTransparency = 0.7 }, ease.tabIn)
			end
		end

		if activeTab and activeTab.Page then
			activeTab.Page.Visible = true
			tween(activeTab.Page, { Position = UDim2.fromScale(0.5, 0.485) }, ease.pageIn)
		end
	end)
end

local function HideWindow()
	tween(Display.Label, { TextTransparency = 1 }, ease.fadeOut)
	tween(Display.SubLabel, { TextTransparency = 1 }, ease.fadeOut)
	tween(Base.Close, { ImageTransparency = 1 }, ease.fadeOut)
	tween(Base.Hide, { ImageTransparency = 1 }, ease.fadeOut)

	for _, tab in pairs(SidePanel.Tabs:GetChildren()) do
		if tab:IsA("Frame") and tab.Name ~= "Template" then
			tween(tab, { BackgroundTransparency = 1 }, ease.tabOut)
			tween(tab.Label, { TextTransparency = 1 }, ease.tabOut)
		end
	end

	if activeTab and activeTab.Page then
		tween(activeTab.Page, { Position = UDim2.fromScale(0.5, 1.5) }, ease.pageOut)
		task.wait(0.12)
		activeTab.Page.Visible = false
	end

	task.delay(0.04, function()
		tween(Base, { Size = UDim2.fromOffset(0, 0) }, ease.close, function()
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

		tween(Notification, { Position = UDim2.new(0.5, 0.94) }, ease.notifIn)

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
			tween(Notification, { Position = UDim2.fromScale(1.5, 0.94) }, ease.notifOut, function()
				clearnotif(Notification)
			end)
		end)

		task.delay(Duration, function()
			tween(Notification, { Position = UDim2.fromScale(1.5, 0.94) }, ease.notifOut, function()
				clearnotif(Notification)
			end)
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

	Display.Label.FontFace.Weight = Enum.FontWeight.Bold
	Display.Label.Text = WindowSettings.Title
	Display.SubLabel.Text = WindowSettings.SubTitle

	drag(Base)
	ShowWindow()

	local Tabs = {}

	function Tabs:NewTab(TabName)
        TabName = TabName or "Tab-"..#SidePanel.Tabs:GetChildren() - 2

		local Tab = SidePanel.Tabs.Template:Clone()
		Tab.Name = TabName
		Tab.Label.Text = TabName

		local Page = Elements.Template:Clone()
		Page.Name = TabName
		Page.Visible = false
		Page.Position = UDim2.fromScale(0.5, 1.5)
		Page.Parent = Elements

		local Data = { Button = Tab, Page = Page }
		table.insert(Tabs, Data)

		Tab.Parent = SidePanel.Tabs
		Tab.Visible = true

		local function selectTab(tab)
			if activeTab == tab then
				tween(tab.Button, { BackgroundTransparency = 1 }, ease.tabOut)
				tween(tab.Button.Label, { TextTransparency = 0.7 }, ease.tabOut)
				tween(tab.Page, { Position = UDim2.fromScale(0.5, 1.5) }, ease.pageOut, function()
					tab.Page.Visible = false
				end)
				activeTab = nil
				return
			end

			if activeTab then
				tween(activeTab.Button, { BackgroundTransparency = 1 }, ease.tabOut)
				tween(activeTab.Button.Label, { TextTransparency = 0.7 }, ease.tabOut)
				tween(activeTab.Page, { Position = UDim2.fromScale(0.5, 1.5) }, ease.pageOut)
				task.wait(0.14)
				activeTab.Page.Visible = false
			end

			tween(tab.Button, { BackgroundTransparency = 0.3 }, ease.tabIn)
			tween(tab.Button.Label, { TextTransparency = 0.4 }, ease.tabIn)

			tab.Page.Visible = true
			tween(tab.Page, { Position = UDim2.fromScale(0.5, 0.485) }, ease.pageIn)
			activeTab = tab
		end

		if #Tabs == WindowSettings.DefaultTab then
			selectTab(Data)
		end

		local normal = Tab.Size
		local hoverSize = UDim2.new(
			Tab.Size.X.Scale * 1.04,
			Tab.Size.Y.Scale * 1.04,
			Tab.Size.X.Offset * 1.04,
			Tab.Size.Y.Offset * 1.04
		)
		local clickSize = UDim2.new(
			Tab.Size.X.Scale * 0.96,
			Tab.Size.Y.Scale * 0.96,
			Tab.Size.X.Offset * 0.96,
			Tab.Size.Y.Offset * 0.96
		)

		Tab["MouseEnter"]:Connect(function()
			if activeTab == Data then
				return
			end
			tween(Tab, { BackgroundTransparency = 0.85, Size = hoverSize }, ease.hover)
			tween(Tab.Label, { TextTransparency = 0.5 }, ease.hover)
		end)

		Tab["MouseLeave"]:Connect(function()
			if activeTab == Data then
				return
			end
			tween(Tab, { BackgroundTransparency = 1, Size = normal }, ease.leave)
			tween(Tab.Label, { TextTransparency = 0.7 }, ease.leave)
		end)

		Tab.Interact["MouseButton1Down"]:Connect(function()
			tween(Tab, { Size = clickSize }, ease.press)
		end)

		Tab.Interact["MouseButton1Up"]:Connect(function()
			tween(Tab, { Size = normal }, ease.spring)
		end)

		Tab.Interact["MouseButton1Click"]:Connect(function()
			selectTab(Data)
		end)

		function Data:CreateToggle(ToggleSettings)
			local Toggle = Elements.Template.Toggle:Clone()
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
						ease.toggle
					)
					tween(Toggle.Switch.State.Icon, { ImageTransparency = 0.2 }, ease.toggle)
				else
					tween(
						Toggle.Switch.State,
						{ Size = UDim2.fromScale(0, 0), BackgroundTransparency = 1 },
						ease.toggle
					)
					tween(Toggle.Switch.State.Icon, { ImageTransparency = 1 }, ease.toggle)
				end
			end

			tween(Toggle, { BackgroundTransparency = 0.5 }, ease.hover)
			tween(Toggle.Switch, { BackgroundTransparency = 0.5 }, ease.hover)
			tween(Toggle.Switch.UIStroke, { Transparency = 0.7 }, ease.hover)
			tween(Toggle.Label, { TextTransparency = 0.3 }, ease.hover)

			switchState(ToggleSettings.Enabled)

			Toggle["MouseEnter"]:Connect(function()
				tween(Toggle, { BackgroundTransparency = 0.38 }, ease.hover)
			end)

			Toggle["MouseLeave"]:Connect(function()
				tween(Toggle, { BackgroundTransparency = 0.5 }, ease.leave)
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
			local Button = Elements.Template.Button:Clone()
			Button.Name = ButtonSettings.Title

			Button.BackgroundTransparency = 1
			Button.Label.TextTransparency = 1
			Button.SubLabel.TextTransparency = 1

			Button.Label.Text = ButtonSettings.Title
			Button.Parent = Data.Page
			Button.Visible = true

			tween(Button, { BackgroundTransparency = 0.5 }, ease.hover)
			tween(Button.Label, { TextTransparency = 0.3 }, ease.hover)
			tween(Button.SubLabel, { TextTransparency = 0.5 }, ease.hover)

			Button["MouseEnter"]:Connect(function()
				tween(Button, { BackgroundTransparency = 0.38 }, ease.hover)
			end)

			Button["MouseLeave"]:Connect(function()
				tween(Button, { BackgroundTransparency = 0.5 }, ease.leave)
			end)

			-- quick squish feedback on click
			Button.Interact["MouseButton1Down"]:Connect(function()
				tween(Button, { BackgroundTransparency = 0.25 }, ease.press)
			end)

			Button.Interact["MouseButton1Up"]:Connect(function()
				tween(Button, { BackgroundTransparency = 0.5 }, ease.spring)
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
			local Dropdown = Elements.Template.Dropdown:Clone()
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

			tween(Dropdown.Top, { BackgroundTransparency = 0.5 }, ease.hover)
			tween(Dropdown.Top.Label, { TextTransparency = 0.3 }, ease.hover)
			tween(Dropdown.Top.SubLabel, { TextTransparency = 0.5 }, ease.hover)
			tween(Dropdown.Top.Icon, { ImageTransparency = 0.3 }, ease.hover)

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
				return topheight + math.min(#DropdownSettings.Options, 5) * (optionheight + padding)
			end

			local function SetOptions()
				for _, option in ipairs(DropdownSettings.Options) do
					local dOption = Dropdown.List.Template:Clone()
					dOption.Name = option
					dOption.Label.Text = option
					dOption.LayoutOrder = #Dropdown.List:GetChildren() - 3
					dOption.Parent = Dropdown.List
					dOption.Visible = true

					tween(dOption.Label, { TextTransparency = 0.4 }, ease.hover)

					dOption.Interact["MouseEnter"]:Connect(function()
						if not table.find(DropdownSettings.CurrentOption, option) then
							tween(dOption, { BackgroundTransparency = 0.75 }, ease.hover)
							tween(dOption.Label, { TextTransparency = 0.25 }, ease.hover)
						end
					end)

					dOption.Interact["MouseLeave"]:Connect(function()
						if not table.find(DropdownSettings.CurrentOption, option) then
							tween(dOption, { BackgroundTransparency = 1 }, ease.leave)
							tween(dOption.Label, { TextTransparency = 0.4 }, ease.leave)
						end
					end)

					dOption.Interact["MouseButton1Click"]:Connect(function()
						local idx = table.find(DropdownSettings.CurrentOption, option)
						if idx then
							table.remove(DropdownSettings.CurrentOption, idx)
							tween(dOption, { BackgroundTransparency = 1 }, ease.leave)
							tween(dOption.Label, { TextTransparency = 0.4 }, ease.leave)
							tween(dOption.Icon, { ImageTransparency = 1 }, ease.leave)
						else
							table.insert(DropdownSettings.CurrentOption, option)
							tween(dOption, { BackgroundTransparency = 0.3 }, ease.toggle)
							tween(dOption.Label, { TextTransparency = 0.2 }, ease.toggle)
							tween(dOption.Icon, { ImageTransparency = 0.2 }, ease.toggle)
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
				tween(Dropdown.Top, { BackgroundTransparency = 0.38 }, ease.hover)
			end)

			Dropdown.Top["MouseLeave"]:Connect(function()
				tween(Dropdown.Top, { BackgroundTransparency = 0.5 }, ease.leave)
			end)

			Dropdown.Top.Interact["MouseButton1Click"]:Connect(function()
				if not debounce then
					tween(Dropdown, { BackgroundTransparency = 0.75 }, ease.dropIn)
					tween(Dropdown, { Size = UDim2.fromOffset(266, calculateOpenHeight()) }, ease.dropIn)
					tween(Dropdown.Top.Icon, { Rotation = 180 }, ease.dropIn)
					task.wait(0.06)
					Dropdown.List.Visible = true
					debounce = true
				else
					tween(Dropdown, { Size = UDim2.fromOffset(266, 35) }, ease.dropOut)
					tween(Dropdown.Top.Icon, { Rotation = 0 }, ease.dropOut)
					tween(Dropdown, { BackgroundTransparency = 1 }, ease.dropOut)
					task.wait(0.04)
					Dropdown.List.Visible = false
					debounce = false
				end
			end)

			return DropdownSettings
		end

		function Data:CreateInput(InputSettings)
			local Input = Elements.Template.Input:Clone()
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

			tween(Input, { BackgroundTransparency = 0.5 }, ease.hover)
			tween(Input.Label, { TextTransparency = 0.3 }, ease.hover)
			tween(Input.Holder, { BackgroundTransparency = 0.5 }, ease.hover)
			tween(Input.Holder.UIStroke, { Transparency = 0.7 }, ease.hover)
			tween(Input.Holder.InputBox, { TextTransparency = 0.4 }, ease.hover)

			Input.Holder.Size = UDim2.new(0, Input.Holder.InputBox.TextBounds.X + 24, 0, 23)

			-- brighter stroke while focused
			Input.Holder.InputBox.Focused:Connect(function()
				tween(Input.Holder.UIStroke, { Transparency = 0.3 }, ease.hover)
			end)

			Input.Holder.InputBox.FocusLost:Connect(function()
				tween(Input.Holder.UIStroke, { Transparency = 0.7 }, ease.leave)
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
				tween(Input, { BackgroundTransparency = 0.38 }, ease.hover)
			end)

			Input["MouseLeave"]:Connect(function()
				tween(Input, { BackgroundTransparency = 0.5 }, ease.leave)
			end)

			Input.Holder.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
				tween(
					Input.Holder,
					{ Size = UDim2.new(0, Input.Holder.InputBox.TextBounds.X + 24, 0, 23) },
					ease.dropIn
				)
			end)

			return InputSettings
		end

		-- ── Slider ───────────────────────────────────────────────────────────
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

			tween(Slider, { BackgroundTransparency = 0.5 }, ease.hover)
			tween(Slider.Label, { TextTransparency = 0.3 }, ease.hover)
			tween(Slider.Range, { TextTransparency = 0.3 }, ease.hover)
			tween(Slider.Container, { BackgroundTransparency = 0.5 }, ease.hover)
			tween(Slider.Container.Bar, { BackgroundTransparency = 0 }, ease.hover)
			tween(Slider.Container.Bar.Knob, { BackgroundTransparency = 0.2 }, ease.hover)

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
				local step = math.floor(raw / inc + 0.5) * inc
				step = math.floor(step * 10000000 + 0.5) / 10000000
				return math.clamp(step, min, max)
			end

			Slider.Container.Bar.Size = UDim2.new(0, valuetopixel(SliderSettings.CurrentValue), 1, 0)

			local function applyValue(val, smooth)
				local px = valuetopixel(val)
				if smooth then
					tween(Slider.Container.Bar, { Size = UDim2.new(0, px, 1, 0) }, ease.sliderMove)
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
				tween(Slider, { BackgroundTransparency = 0.38 }, ease.hover)
			end)

			Slider["MouseLeave"]:Connect(function()
				tween(Slider, { BackgroundTransparency = 0.5 }, ease.leave)
			end)

			Slider.Container.Interact.InputBegan:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					dragging = true
					applyValue(pixelstovalue(input.Position.X), true)

					local loop
					loop = RunService.Stepped:Connect(function()
						if not dragging then
							loop:Disconnect()
							return
						end
						applyValue(pixelstovalue(UserInputService:GetMouseLocation().X), true)
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
					tween(
						Slider.Container.Bar,
						{ Size = UDim2.new(0, valuetopixel(SliderSettings.CurrentValue), 1, 0) },
						ease.sliderSnap
					)
				end
			end

			Slider.Container.Interact.InputEnded:Connect(endDragInput)
			UserInputService.InputEnded:Connect(endDragInput)

			return SliderSettings
		end

		return Data
	end

	-- ── Window buttons ────────────────────────────────────────────────────────
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
				task.wait(0.20)
				active = true
				return
			end
			ShowWindow()
			task.wait(0.20)
			active = false
		end
	end)

	return Tabs
end

return Violet
