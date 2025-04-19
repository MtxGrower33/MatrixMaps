


-- a = {}
-- a.external = { 1, 2, 5 }

-- local lists = {
--     { values = a.external, index = 1 },  -- insert external list directly
--     { values = { 10, 20, 30 }, index = 1 },
-- }

-- local function MakeListButton(w, txt, parent, listData, point)
--     local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
--     btn:SetWidth(w)
--     btn:SetHeight(22)
--     btn:SetPoint(unpack(point))
--     btn:SetText(txt)

--     btn:SetScript("OnClick", function()
--         local i = listData.index
--         DEFAULT_CHAT_FRAME:AddMessage(listData.values[i])
--         i = i + 1
--         if i > table.getn(listData.values) then
--             i = 1
--         end
--         listData.index = i
--     end)

--     return btn
-- end

-- MakeListButton(50, ">", UIParent, lists[1], { "CENTER", -50, 0 })
-- MakeListButton(50, "<", UIParent, lists[2], { "CENTER", 50, 0 })
