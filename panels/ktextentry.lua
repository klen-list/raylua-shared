local PANEL = {}

function PANEL:Init()
	local w, h = self:GetSize()
	self.rlRect = rl.new("Rectangle", { 0, 0, w, h })

	self.entryText = ffi.new("char[?]", 256)
	self.maxText = 255

	rl.GuiSetStyle(rl.TEXTBOX, rl.BASE_COLOR_PRESSED, rl.ColorToInt({0, 0, 0}))
	rl.GuiSetStyle(rl.TEXTBOX, rl.BORDER_COLOR_PRESSED, rl.ColorToInt(ColorWhite))
	rl.GuiSetStyle(rl.TEXTBOX, rl.TEXT_COLOR_PRESSED, rl.ColorToInt(ColorWhite))

	rl.GuiSetStyle(rl.TEXTBOX, rl.BASE_COLOR_DISABLED, rl.ColorToInt({0, 0, 0}))

	self.Selected = false
end

function PANEL:GetText()
	return ffi.string(self.entryText)
end

function PANEL:SetText(text)
	ffi.fill(self.entryText, 256, 0)
	if StringOk(text) and text ~= "" then
		ffi.copy(self.entryText, text, math.min(#text, self.maxText))
	end
end

function PANEL:PerformLayout(x, y, w, h)
	local rlRect = self.rlRect

	rlRect.x = x
	rlRect.y = y
	rlRect.width = w
	rlRect.height = h
end

function PANEL:Paint(w, h)
	if rl.IsMouseButtonReleased(rl.MOUSE_BUTTON_LEFT) then
		if gui.MouseInBounds(self.rlRect) then
			self.Selected = true
		else
			self.Selected = false
		end
	end

	if self.Selected then
		rl.GuiEnable()
	else
		-- Система отрисовки raygui использует глобальный флаг guiState
		--
		-- Со значением STATE_DISABLED при выключении ввода у GuiTextBox
		-- используется GuiGetStyle от BASE_COLOR_DISABLED, иначе BLANK (нет фона)
		--
		-- Сам BLANK мы поменять не можем, поэтому остается временно менять guiState
		rl.GuiDisable()
	end

	self:LegacyPaintPos(true)
	rl.GuiTextBox(self.rlRect, self.entryText, self.maxText, self.Selected)

	rl.GuiEnable()
end

gui.Register("KTextEntry", PANEL)
