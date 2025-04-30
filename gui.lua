---@author Klen_list <https://github.com/klen-list>

---@diagnostic disable-next-line: lowercase-global
gui = gui or {}
local Classes = {}

do
	local PANEL = {}

	function PANEL:Init() end
	function PANEL:Paint(w, h) end
	function PANEL:PerformLayout(x, y, w, h) end

	function PANEL:SetSize(w, h)
		local size_changed = (w ~= self.W) or (h ~= self.H)

		self.W = w
		self.H = h

		if not size_changed then return end

		self:PerformLayout(self.X, self.Y, self.W, self.H)
	end

	function PANEL:GetSize()
		return self.W, self.H
	end

	function PANEL:SetPos(x, y)
		local pos_changed = (x ~= self.X) or (y ~= self.Y)

		self.X, self.Y = x, y

		if not pos_changed then return end

		self:PerformLayout(self.X, self.Y, self.W, self.H)
	end

	function PANEL:GetPos()
		return self.X, self.Y
	end

	function PANEL:LegacyPaintPos(enable)
		if enable then
			rl.rlTranslatef(-self.X, -self.Y, 0)
		else
			rl.rlTranslatef(self.X, self.Y, 0)
		end
	end

	function gui.Register(class, panel)
		for name, func in pairs(PANEL) do
			if not panel[name] then
				panel[name] = func
			end
		end

		panel.__index = panel
		Classes[class] = panel
	end
end

---Создает глобальный экземпляр корневой панели<br>
---Все созданные панели фактически являются ее дочерней
---@return table rootPanel Глобальная корневая панель
function gui.CreateRootPanel()
	if ROOT_PANEL then return ROOT_PANEL end

	gui.Register("KGUI_ROOT", {})
	ROOT_PANEL = gui.Create("KGUI_ROOT")
	ROOT_PANEL:SetSize(ScrW(), ScrH())

	return ROOT_PANEL
end

---Создает новый экземпляр панели из ранее зарегистрированного класса
---@param class string Класс создаваемой панели
---@param parent? table Родительская панель
---@return table panel Новый экземпляр панели
function gui.Create(class, parent)
	assert(TableOk(Classes[class]), "Invalid panel class!")
	parent = parent or ROOT_PANEL

	local pnl = setmetatable({
		X = 0,
		Y = 0,
		W = 50,
		H = 50,
		childs = {}
	}, Classes[class])

	-- Parent is nil when ROOT_PANEL not exists yet
	-- Or will be created just now
	if not parent then
		return pnl
	end

	table.insert(parent.childs, pnl)
	pnl:Init()

	return pnl
end

---Запускает событие `Paint` на панели и ее дочерних элементах
---@param panel table Панель на которой нужно запустить событие
function gui.PaintPanel(panel)
	-- Bug: children scissor modes can override olds
	-- TODO: Clamp new modes to old modes bounds
	-- local w, h = ScrW(), ScrH()
	rl.BeginScissorMode(panel.X, panel.Y, panel.X + panel.W, panel.Y + panel.H)
		rl.rlPushMatrix()
		rl.rlTranslatef(panel.X, panel.Y, 0)
			panel:Paint(panel.W, panel.H)
		rl.rlPopMatrix()
		for _, pnl in pairs(panel.childs) do
			gui.PaintPanel(pnl)
		end
	rl.EndScissorMode()
end

---Запускает событие `Think` на панели и ее дочерних элементах
---@param panel table Панель на которой нужно запустить событие
function gui.ThinkPanel(panel)
	if panel.Think then
		panel:Think()
	end
	for _, pnl in pairs(panel.childs) do
		gui.ThinkPanel(pnl)
	end
end