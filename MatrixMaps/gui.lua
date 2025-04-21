-- --==================================================
-- -- gui
-- --==================================================
-- mainframe section
-- template section
-- placement section
-- update section
-- events section
-- --==================================================

MMaps.Debug("> gui.lua loading...")

function MMaps.CreateUI()
    MMaps.Debug("Creating UI...")

    -- --==================================================
    -- -- mainframe section
    -- --==================================================

    MMaps.UIElements = {}

    local function ApplyBackdrop(f, bg)
        f:SetBackdrop({
            bgFile = bg or "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })
        f:SetBackdropColor(0, 0, 0, 1)
        f:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    end

    local gui = CreateFrame("Frame", "MMapsGUI", UIParent)
    gui:SetWidth(450)
    gui:SetHeight(550)
    gui:SetPoint("CENTER", 0, 0)
    gui:SetMovable(true)
    gui:EnableMouse(true)
    gui:SetClampedToScreen(true)
    gui:SetToplevel(true)
    gui:SetFrameLevel(10)
    gui:SetFrameStrata("DIALOG")
    gui:SetScale(0.8)
    gui:RegisterForDrag("LeftButton")
    gui:SetScript("OnMouseDown", function() this:StartMoving() end)
    gui:SetScript("OnMouseUp", function() this:StopMovingOrSizing() end)
    ApplyBackdrop(gui)

    tinsert(UISpecialFrames, gui:GetName())

    gui:Hide()

    -- top
    local titleFrame = CreateFrame("Frame", nil, gui)
    titleFrame:SetPoint("BOTTOM", gui, "TOP", 80, -30)
    titleFrame:SetWidth(200)
    titleFrame:SetHeight(50)
    ApplyBackdrop(titleFrame, "Interface\\Buttons\\WHITE8X8")

    local titleText = titleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("CENTER", titleFrame, "CENTER", 0, 1)
    titleText:SetText("Matrix Maps")

    -- bot
    local statusFrame = CreateFrame("Frame", nil, gui)
    statusFrame:SetPoint("TOP", gui, "BOTTOM", 0, 9)
    statusFrame:SetWidth(320)
    statusFrame:SetHeight(90)
    ApplyBackdrop(statusFrame)

    local currentProfileLabel, versionLabel
    local function CreateCurrentProfileLabel(parent)
        if not currentProfileLabel then
            currentProfileLabel = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
            currentProfileLabel:SetPoint("CENTER", 0, 13)
            currentProfileLabel:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
        end
        if not versionLabel then
            versionLabel = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
            versionLabel:SetPoint("CENTER", 0, -13)
            versionLabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        end
        return currentProfileLabel, versionLabel
    end

    local profileLabel, verLabel = CreateCurrentProfileLabel(statusFrame)
    profileLabel:SetText("Current Profile : |cff00ff00" .. MMaps.GetProfile().name .. "|r")
    verLabel:SetText(   "Current Version: |cffff6060" .. MMaps.addonInfo.version .. "|r")

    -- --==================================================
    -- -- template section
    -- --==================================================

    local function CreateButton(point, x, y, text)
        local button = CreateFrame("Button", nil, gui, "UIPanelButtonTemplate")
        button:SetHeight(22)
        button:SetWidth(100)
        button:SetPoint(point, gui, point, x, y)
        button:SetText(text or "Button")
        return button
    end

    local function CreateSlider(point, x, y, label, minVal, maxVal, stepSize)
        local sliderName = "MMapsSlider" .. tostring(math.random(1, 1000))
        local slider = CreateFrame("Slider", sliderName, gui, "OptionsSliderTemplate")
        slider:SetOrientation('HORIZONTAL')
        slider:SetMinMaxValues(minVal or 0, maxVal or 1)
        slider:SetValueStep(stepSize or 0.1)
        slider:SetWidth(200)
        slider:SetHeight(20)
        slider:SetPoint(point, gui, point, x, y)

        getglobal(slider:GetName() .. "Low"):SetText(minVal or 0)
        getglobal(slider:GetName() .. "High"):SetText(maxVal or 1)
        getglobal(slider:GetName() .. "Text"):SetText(label)

        -- Create value text
        local valueText = slider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        valueText:SetPoint("TOP", slider, "BOTTOM", 0, 0)

        -- Add mouse wheel support
        slider:EnableMouseWheel(true)
        slider:SetScript("OnMouseWheel", function()
            local currentValue = this:GetValue()
            local newValue = currentValue + (arg1 * stepSize)

            -- Ensure we stay within bounds
            newValue = math.max(minVal, math.min(maxVal, newValue))
            this:SetValue(newValue)
        end)

        return slider, valueText
    end

    local function CreateCheckbox(point, x, y, label)
        local checkbox = CreateFrame("CheckButton", nil, gui, "UICheckButtonTemplate")
        checkbox:SetWidth(24)
        checkbox:SetHeight(24)
        checkbox:SetPoint(point, gui, point, x, y)

        local text = checkbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        text:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
        text:SetText(label)

        return checkbox
    end

    local function CreateDropdown(items, pointArg, xArg, yArg)
        local dd = CreateFrame("Frame", nil, gui)
        dd:SetWidth(100)
        dd:SetHeight(30)
        dd:SetPoint(pointArg, gui, pointArg, xArg, yArg)

        dd.items = items

        dd.clickCatcher = CreateFrame("Frame", nil, UIParent)
        dd.clickCatcher:SetFrameStrata("FULLSCREEN_DIALOG")
        dd.clickCatcher:SetAllPoints(UIParent)
        dd.clickCatcher:EnableMouse(true)
        dd.clickCatcher:Hide()
        dd.clickCatcher:SetScript("OnMouseDown", function()
            dd.list:Hide()
            dd.clickCatcher:Hide()
        end)

        dd.button = CreateFrame("Button", nil, dd, "UIPanelButtonTemplate")
        dd.button:SetWidth(100)
        dd.button:SetHeight(30)
        dd.button:SetPoint("CENTER", dd, "CENTER", 0, 0)
        dd.button:SetText("Menu")
        dd.button:SetScript("OnClick", function()
            if dd.list:IsShown() then
                dd.list:Hide()
                dd.clickCatcher:Hide()
            else
                dd.list:Show()
                dd.clickCatcher:Show()
            end
        end)

        dd.list = CreateFrame("Frame", nil, UIParent)
        dd.list:SetFrameStrata("FULLSCREEN_DIALOG")
        dd.list:SetWidth(80)
        local count = 0
        for _ in pairs(items) do count = count + 1 end
        count = count + 1  -- add 1 for the "None" option
        dd.list:SetHeight(count * 16 + 5)

        dd.list:SetPoint("TOP", dd, "BOTTOM", 0, 0)
        dd.list:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = nil,
            tile = true,
            tileSize = 16,
            edgeSize = 0,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        dd.list:SetBackdropColor(0, 0, 0, 1)
        dd.list:Hide()
        dd.list:SetScript("OnHide", function()
            dd.clickCatcher:Hide()
        end)

        -- button creation loop
        dd.buttons = {}
        local i = 0
        -- first we add "None" explicitly if the key exists in the table
        if rawget(items, "None") ~= nil or next(items) ~= nil then  -- check if key exists or if table is not empty
        i = i + 1
        local btn = CreateFrame("Button", nil, dd.list)
        btn:SetWidth(90)
        btn:SetHeight(16)
        btn:SetPoint("TOP", dd.list, "TOP", 0, -(i-1)*16 - 2)

        local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        btnText:SetPoint("CENTER", btn, "CENTER", 0, 0)
        btnText:SetText("None")

        local highlightTexture = btn:CreateTexture(nil, "HIGHLIGHT")
        highlightTexture:SetAllPoints()
        highlightTexture:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        highlightTexture:SetBlendMode("ADD")

        dd.buttons["None"] = btn
        end

        -- then add all other items
        for shapeName, value in pairs(items) do
            if shapeName ~= "None" then  -- skip "None" as we already added it
                i = i + 1
                local btn = CreateFrame("Button", nil, dd.list)
                btn:SetWidth(90)
                btn:SetHeight(16)
                btn:SetPoint("TOP", dd.list, "TOP", 0, -(i-1)*16 - 2)

                local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                btnText:SetPoint("CENTER", btn, "CENTER", 0, 0)
                btnText:SetText(shapeName)

                local highlightTexture = btn:CreateTexture(nil, "HIGHLIGHT")
                highlightTexture:SetAllPoints()
                highlightTexture:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
                highlightTexture:SetBlendMode("ADD")

                dd.buttons[shapeName] = btn
            end
        end

        function dd:SetItemClickHandler(handler)
            for shapeName, btn in pairs(self.buttons) do
                local nameCopy = shapeName
                btn:SetScript("OnClick", function()
                    if nameCopy == "None" then
                        handler(nameCopy, {path = nil})  -- pass a table with nil path instead of just nil
                        self.list:Hide()
                    elseif nameCopy and self.items and self.items[nameCopy] then
                        handler(nameCopy, self.items[nameCopy])
                        self.list:Hide()
                    else
                        MMaps.Debug("Missing data: " .. tostring(nameCopy))
                    end
                end)
            end
        end



        return dd
    end

    local function CreateLine(anchor, x, y)
        local line = gui:CreateTexture(nil, "ARTWORK")
        line:SetTexture("Interface\\Buttons\\WHITE8x8")
        line:SetWidth(gui:GetWidth() - 30)
        line:SetHeight(3)
        line:SetPoint(anchor, x or 0, y or 0)
        line:SetVertexColor(0.2, 0.2, 0.2, 1)
    end

    local function CreateTitle(text, anchorPoint, x, y, size)
        local title = gui:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        title:SetText(text)
        title:SetPoint(anchorPoint, x or 0, y or 0)
        title:SetFont("Fonts\\FRIZQT__.TTF", size or 16, "OUTLINE")
        title:SetTextColor(1, 1, 1, 1)
        return title
    end

    -- --==================================================
    -- -- placement section
    -- --==================================================

    CreateLine("TOP", 0, -80)
    CreateLine("BOTTOM", 0, 100)
    CreateTitle("General", "TOPLEFT", 70, -91, 12)
    CreateTitle("Border & Textures", "TOPRIGHT", -80, -91, 12)
    CreateTitle("Profiles", "BOTTOMLEFT", 70, 80, 12)
    CreateTitle("Shapes", "TOPRIGHT", -177, -115, 10)
    CreateTitle("Borders", "TOPRIGHT", -69, -115, 10)
    CreateTitle("Specials", "LEFT", 70, -69, 11)

    -- FPS limit button
    MMaps.UIElements.fpsLimitButton = CreateButton("TOPRIGHT", -80, -40)
        if MMaps.GetProfile().fpsLimit then
            MMaps.UIElements.fpsLimitButton:SetText("FPS Limit: |cFF00FF00ON|r")
        else
            MMaps.UIElements.fpsLimitButton:SetText("FPS Limit: |cFFFF0000OFF|r")
        end
        MMaps.UIElements.fpsLimitButton:SetScript("OnClick", function()
            MMaps.misc.ToggleFPSLimit()
            if MMaps.GetProfile().fpsLimit then
                MMaps.UIElements.fpsLimitButton:SetText("FPS Limit: |cFF00FF00ON|r")
            else
                MMaps.UIElements.fpsLimitButton:SetText("FPS Limit: |cFFFF0000OFF|r")
            end
    end)

    -- minimap
    MMaps.UIElements.showMinimapCheckbox = CreateCheckbox("TOPLEFT", 70, -40, "Show Minimap")
    MMaps.UIElements.showMinimapCheckbox:SetChecked(MMaps.GetProfile().minimap)
    MMaps.UIElements.showMinimapCheckbox:SetScript("OnClick", function()
        local profile = MMaps.GetProfile()
        profile.minimap = not profile.minimap
        MMaps.HandleFeature("minimap", profile.minimap)
    end)

    -- movable checkbox
    MMaps.UIElements.movableCheckbox = CreateCheckbox("TOPLEFT", 40, -130, "Movable Minimap")
    MMaps.UIElements.movableCheckbox:SetChecked(MMaps.GetProfile().movable)
    MMaps.UIElements.movableCheckbox:SetScript("OnClick", function()
        local profile = MMaps.GetProfile()
        profile.movable = not profile.movable
        MMaps.HandleFeature("movable", profile.movable)
    end)

    -- zoom checkbox
    MMaps.UIElements.zoomCheckbox = CreateCheckbox("TOPLEFT", 40, -160, "Zoom Minimap")
    MMaps.UIElements.zoomCheckbox:SetChecked(MMaps.GetProfile().zoom)
    MMaps.UIElements.zoomCheckbox:SetScript("OnClick", function()
        local profile = MMaps.GetProfile()
        profile.zoom = not profile.zoom
        MMaps.HandleFeature("zoom", profile.zoom)
    end)

    -- auto zoom out checkbox
    MMaps.UIElements.autoZoomOutCheckbox = CreateCheckbox("TOPLEFT", 40, -190, "Auto Zoom Out")
    MMaps.UIElements.autoZoomOutCheckbox:SetChecked(MMaps.GetProfile().autoZoomOut)
    MMaps.UIElements.autoZoomOutCheckbox:SetScript("OnClick", function()
        local profile = MMaps.GetProfile()
        profile.autoZoomOut = not profile.autoZoomOut
        MMaps.HandleFeature("autoZoomOut", profile.autoZoomOut)
    end)

    -- border checkbox
    MMaps.UIElements.borderCheckbox = CreateCheckbox("TOPLEFT", 40, -220, "Border")
    MMaps.UIElements.borderCheckbox:SetChecked(MMaps.GetProfile().border == "Alternative")
    MMaps.UIElements.borderCheckbox:SetScript("OnClick", function()
        local profile = MMaps.GetProfile()
        profile.border = profile.border == "Alternative" and "None" or "Alternative"
        MMaps.HandleFeature("border", profile.border)
    end)

    -- border top checkbox
    MMaps.UIElements.borderTopCheckbox = CreateCheckbox("TOPLEFT", 40, -250, "Border Top")
    MMaps.UIElements.borderTopCheckbox:SetChecked(MMaps.GetProfile().borderTop == "Alternative")
    MMaps.UIElements.borderTopCheckbox:SetScript("OnClick", function()
        local profile = MMaps.GetProfile()
        profile.borderTop = profile.borderTop == "Alternative" and "None" or "Alternative"
        MMaps.HandleFeature("borderTop", profile.borderTop)
    end)

    -- extra buttons checkbox
    MMaps.UIElements.extraButtonsCheckbox = CreateCheckbox("TOPLEFT", 40, -280, "Extra Buttons")
    MMaps.UIElements.extraButtonsCheckbox:SetChecked(MMaps.GetProfile().extraButtons)
    MMaps.UIElements.extraButtonsCheckbox:SetScript("OnClick", function()
        local profile = MMaps.GetProfile()
        profile.extraButtons = not profile.extraButtons
        MMaps.HandleFeature("extraButtons", profile.extraButtons)
    end)

    -- snowfall checkbox
    MMaps.UIElements.snowfallCheckbox = CreateCheckbox("TOPLEFT", 40, -360, "Snowfall")
    MMaps.UIElements.snowfallCheckbox:SetChecked(MMaps.GetProfile().snowEnabled)
    MMaps.UIElements.snowfallCheckbox:SetScript("OnClick", function()
        local profile = MMaps.GetProfile()
        profile.snowEnabled = not profile.snowEnabled
        MMaps.HandleFeature("snowfall", profile.snowEnabled)
    end)

    -- shape dropdown
    MMaps.UIElements.shapeDropdown = CreateDropdown(MMaps.shapes, "TOPRIGHT", -150, -130)
    MMaps.UIElements.shapeDropdown:SetItemClickHandler(function(shapeName, path)
        if shapeName and path then
            MMaps.HandleFeature("shape", shapeName)
            MMaps.Debug("Selected: " .. tostring(shapeName))
            MMaps.Debug("Path: " .. tostring(path))
        else
            MMaps.Debug("Handler received nil values:".. shapeName.. path)
        end
    end)

    -- rotatingBorder dropdown
    MMaps.UIElements.rotatingBorderDropdown = CreateDropdown(MMaps.rotatingTextures, "TOPRIGHT", -40, -130)
    MMaps.UIElements.rotatingBorderDropdown:SetItemClickHandler(function(rotatingName, path)
        if rotatingName and path then
            MMaps.HandleFeature("rotatingBorder", rotatingName)
            MMaps.Debug("Selected: " .. tostring(rotatingName))
            MMaps.Debug("Path: " .. tostring(path))
        else
            MMaps.Debug("Handler received nil values:".. rotatingName.. path)
        end
    end)

    -- scale slider
    local scaleSlider, scaleValueText = CreateSlider("TOPLEFT", 205, -180, "Minimap Scale", 0.5, 2, 0.1)
    MMaps.UIElements.scaleSlider = scaleSlider
    local scaleInitialValue = MMaps.GetProfile().minimapScale
    MMaps.UIElements.scaleSlider:SetValue(scaleInitialValue)
    scaleValueText:SetText(string.format("%.1f", scaleInitialValue))
    scaleValueText:SetPoint("TOP", scaleSlider, "BOTTOM", 0, 4)
    MMaps.UIElements.scaleSlider:SetScript("OnValueChanged", function()
        local value = this:GetValue()
        if value then
            value = math.floor(value * 10 + 0.5) / 10
            local profile = MMaps.GetProfile()
            profile.minimapScale = value
            MMaps.HandleFeature("minimapScale", value)
            MMaps.Debug("Scale slider changed to: " .. value)
            scaleValueText:SetText(string.format("%.1f", value))
        end
    end)

    -- alpha slider
    local alphaSlider, alphaValueText = CreateSlider("TOPLEFT", 205, -225, "Minimap Alpha", 0, 1, 0.1)
    MMaps.UIElements.alphaSlider = alphaSlider
    local alphaInitialValue = MMaps.GetProfile().minimapAlpha
    MMaps.UIElements.alphaSlider:SetValue(alphaInitialValue)
    alphaValueText:SetText(string.format("%.1f", alphaInitialValue))
    alphaValueText:SetPoint("TOP", alphaSlider, "BOTTOM", 0, 4)
    MMaps.UIElements.alphaSlider:SetScript("OnValueChanged", function()
        local value = this:GetValue()
        if value then
            value = math.floor(value * 10 + 0.5) / 10
            local profile = MMaps.GetProfile()
            profile.minimapAlpha = value
            MMaps.HandleFeature("minimapAlpha", value)
            MMaps.Debug("Alpha slider changed to: " .. value)
            alphaValueText:SetText(string.format("%.1f", value))
        end
    end)

    -- rotating speed slider
    local speedSlider, speedValueText = CreateSlider("TOPLEFT", 205, -270, "Rotating Speed", -5, 5, 0.1)
    MMaps.UIElements.rotatingSpeedSlider = speedSlider
    local speedInitialValue = MMaps.GetProfile().speed
    MMaps.UIElements.rotatingSpeedSlider:SetValue(speedInitialValue)
    speedValueText:SetText(string.format("%.1f", speedInitialValue))
    speedValueText:SetPoint("TOP", speedSlider, "BOTTOM", 0, 4)
    MMaps.UIElements.rotatingSpeedSlider:SetScript("OnValueChanged", function()
        local value = math.floor(arg1 * 10 + 0.5) / 10
        MMaps.HandleFeature("rotatingSpeed", value)
        speedValueText:SetText(string.format("%.1f", value))
    end)

    -- rotating scale slider
    local rotScaleSlider, rotScaleValueText = CreateSlider("TOPLEFT", 205, -315, "Rotating Scale", 0.1, 3.0, 0.1)
    MMaps.UIElements.rotatingScaleSlider = rotScaleSlider
    local rotScaleInitialValue = MMaps.GetProfile().scale
    MMaps.UIElements.rotatingScaleSlider:SetValue(rotScaleInitialValue)
    rotScaleValueText:SetText(string.format("%.1f", rotScaleInitialValue))
    rotScaleValueText:SetPoint("TOP", rotScaleSlider, "BOTTOM", 0, 4)
    MMaps.UIElements.rotatingScaleSlider:SetScript("OnValueChanged", function()
        local value = math.floor(arg1 * 10 + 0.5) / 10
        MMaps.HandleFeature("rotatingScale", value)
        rotScaleValueText:SetText(string.format("%.1f", value))
    end)

    -- rotating color slider
    ---@diagnostic disable-next-line: deprecated
    local colorSlider, colorValueText = CreateSlider("TOPLEFT", 205, -360, "Rotating Color", 1, table.getn(MMaps.colors), 1)
    MMaps.UIElements.rotatingColorSlider = colorSlider
    local colorInitialValue = MMaps.GetProfile().colorIndex
    MMaps.UIElements.rotatingColorSlider:SetValue(colorInitialValue)
    colorValueText:SetText(string.format("%.1f", colorInitialValue))
    colorValueText:SetPoint("TOP", colorSlider, "BOTTOM", 0, 4)
    MMaps.UIElements.rotatingColorSlider:SetScript("OnValueChanged", function()
        local value = math.floor(arg1 + 0.5)  -- round to nearest integer
        MMaps.HandleFeature("texColour", value)
        colorValueText:SetText(string.format("%.1f", value))
    end)

    -- copy profile button
    MMaps.UIElements.copyProfileButton = CreateButton("BOTTOMLEFT", 40, 35, "Copy Profile")
    MMaps.UIElements.copyProfileButton:SetScript("OnClick", function()
        MMaps.CopyProfileFrom()
    end)

    -- reset profile button
    MMaps.UIElements.resetProfileButton = CreateButton("BOTTOMLEFT", 150, 35, "Reset Profile")
    MMaps.UIElements.resetProfileButton:SetScript("OnClick", function()
        MMaps.ResetProfileToDefaults()
    end)

    -- close button
    MMaps.UIElements.closeButton = CreateButton("BOTTOMRIGHT", -40, 35, "Close")
    MMaps.UIElements.closeButton:SetScript("OnClick", function()
        gui:Hide()
    end)

    -- --==================================================
    -- -- update section
    -- --==================================================

    function MMaps:UpdateUI()
        MMaps.Debug("Updating UI elements")

        local profile = self.GetProfile()

        if self.UIElements.showMinimapCheckbox then
            self.UIElements.showMinimapCheckbox:SetChecked(profile.minimap)
        end

        if self.UIElements.movableCheckbox then
            self.UIElements.movableCheckbox:SetChecked(profile.movable)
        end

        if self.UIElements.zoomCheckbox then
            self.UIElements.zoomCheckbox:SetChecked(profile.zoom)
        end

        if self.UIElements.autoZoomOutCheckbox then
            self.UIElements.autoZoomOutCheckbox:SetChecked(profile.autoZoomOut)
        end

        if self.UIElements.alphaSlider then
            self.UIElements.alphaSlider:SetValue(profile.minimapAlpha)
        end

        if self.UIElements.scaleSlider then
            self.UIElements.scaleSlider:SetValue(profile.minimapScale)
        end

        if self.UIElements.borderCheckbox then
            self.UIElements.borderCheckbox:SetChecked(profile.border == "Alternative")
        end

        if self.UIElements.extraButtonsCheckbox then
            self.UIElements.extraButtonsCheckbox:SetChecked(profile.extraButtons)
        end

        if self.UIElements.borderTopCheckbox then
            self.UIElements.borderTopCheckbox:SetChecked(profile.borderTop == "Alternative")
        end

        if self.UIElements.rotatingSpeedSlider then
            self.UIElements.rotatingSpeedSlider:SetValue(profile.speed)
        end

        if self.UIElements.rotatingScaleSlider then
            self.UIElements.rotatingScaleSlider:SetValue(profile.scale)
        end

        if self.UIElements.rotatingColorSlider then
            self.UIElements.rotatingColorSlider:SetValue(profile.colorIndex)
        end

        if self.UIElements.snowfallCheckbox then
            self.UIElements.snowfallCheckbox:SetChecked(profile.snowEnabled)
        end

        if self.UIElements.fpsLimitButton then
            if profile.fpsLimit then
                self.UIElements.fpsLimitButton:SetText("FPS Limit: |cFF00FF00ON|r")
            else
                self.UIElements.fpsLimitButton:SetText("FPS Limit: |cFFFF0000OFF|r")
            end
        end
    end

    -- --==================================================
    -- -- events section
    -- --==================================================

    if not Minimap.hookScript then
        function Minimap:hookScript(event, func)
            local oldScript = self:GetScript(event)
            self:SetScript(event, function()
                if oldScript then oldScript() end
                func()
            end)
        end
    end

    Minimap:hookScript("OnMouseUp", function()
        if arg1 == "RightButton" and IsShiftKeyDown() then
            if gui:IsShown() then
                gui:Hide()
            else
                gui:ClearAllPoints()
                gui:SetPoint("CENTER", 0, 0)
                gui:Show()
                MMaps:UpdateUI()
            end
        end
    end)

    SLASH_MMAPSGUI1 = "/mmaps"
    SlashCmdList["MMAPSGUI"] = function()
        if gui:IsShown() then
            gui:Hide()
        else
            gui:ClearAllPoints()
            gui:SetPoint("CENTER", 0, 0)
            gui:Show()
            MMaps:UpdateUI()
        end
    end
end
