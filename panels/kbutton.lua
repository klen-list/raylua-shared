local PANEL = {}

function PANEL:Init()
	local w, h = self:GetSize()
	self.rlRect = rl.new("Rectangle", { 0, 0, w, h })
	self.strText = "Кнопка"
end

function PANEL:SetText(text)
	self.strText = text
end

function PANEL:PerformLayout(x, y, w, h)
	local rlRect = self.rlRect

	rlRect.x = x
	rlRect.y = y
	rlRect.width = w
	rlRect.height = h
end

function PANEL:Paint(w, h)
	self:LegacyPaintPos(true)
	if rl.GuiButton(self.rlRect, self.strText) then
		self:DoClick()
	end
end

function PANEL:DoClick() end

gui.Register("KButton", PANEL)