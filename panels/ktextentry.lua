local PANEL = {}

function PANEL:Init()
	local w, h = self:GetSize()
	self.rlRect = ffi.new("Rectangle", { 0, 0, w, h })

	self.entryText = ffi.new("char[?]", 256)

	rl.GuiSetStyle(rl.TEXTBOX, rl.BASE_COLOR_PRESSED, rl.ColorToInt({0, 0, 0}))
	rl.GuiSetStyle(rl.TEXTBOX, rl.BORDER_COLOR_PRESSED, rl.ColorToInt(ColorWhite))
	rl.GuiSetStyle(rl.TEXTBOX, rl.TEXT_COLOR_PRESSED, rl.ColorToInt(ColorWhite))

	self.Selected = false
end

function PANEL:GetText()
	return ffi.string(self.entryText)
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

	self:LegacyPaintPos(true)
	rl.GuiTextBox(self.rlRect, self.entryText, 16, self.Selected)
end

gui.Register("KTextEntry", PANEL)