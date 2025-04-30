local function registerPanel(p)
	require("core.panels." .. p)
end

registerPanel("kbutton")
registerPanel("ktextentry")