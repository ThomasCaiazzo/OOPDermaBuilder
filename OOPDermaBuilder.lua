--[[
	Object Orientated Derma form builder
	Version 1.0
	By Thomas Caiazzo
	Created 8/20/2013
]]--

MenuBase = {}
MenuBase.MM = {}
setmetatable(MenuBase, MenuBase.MM)
MenuBase.MM.__index = MenuBase

function MenuBase.MM.__call()
	self.Init()
end

function MenuBase.SetPos(x, y)
	self.object:SetPos(x, y)
end

function MenuBase.Close()
	self.object:Close()
end

function MenuBase.Open()
	self.object:SetVisible(true)
end

function MenuBase.Size(w, h)
	self.SizeW = w
	self.SizeH = h
end

function MenuBase.Init()
	self.NiceName = self.NiceName or "BaseMenu"
	self.ID = self.ID or "bmnu"
	self.SizeW = self.SizeW or ScrW()/2
	self.SizeH = self.SizeH or ScrH()/2
	self.Draggable = self.Draggable or true
	self.Closeable = self.Closeable or true
	self.ObInitialize = self.ObInitialize or nil
	if !self.object or !self.object:IsValid() then
		self.object = vgui.Create("DFrame")
		self.object:SetSize(self.SizeW, self.SizeH)
		self.object:SetVisible(true)
		self.object:SetDraggable(self.Draggable)
		self.object:ShowCloseButton(self.Closeable)
		self.object:MakePopup()
		self.object:SetTitle(self.NiceName)
		function self.object:Think()
			if self.Think then self.Think() return end
			if (!self.Dragging) then return end
			local x = gui.MouseX() - self.Dragging[1]
			local y = gui.MouseY() - self.Dragging[2]
			x = math.Clamp( x, 0, ScrW() - self:GetWide() )
			y = math.Clamp( y, 0, ScrH() - self:GetTall() )
			self:SetPos(x, y)
		end
		function self.object:Close()
			self.object:SetVisible(false)
			if self.CloseFunc then self.CloseFunc() end
		end
		if self.HookInit then self.HookInit() else self.object:Center() end
	else
		self.object:SetVisible(true)
		if self.HookInit then self.HookInit() else self.object:Center() end
	end
	if self.ObInitialize then self.ObInitialize(self.ID, self.SizeW, self.SizeH) end
end


MenuSheet = {}
MenuSheet.MM = {}
setmetatable(MenuSheet, MenuSheet.MM)
MenuSheet.MM.__index = MenuBase

function MenuSheet.MM.__call()
	self.Init()
end

function MenuSheet.AddSheet(sheet)
	table.insert(self.Sheets, sheet)
end

function MenuSheet.Build()
	self.Init()
end

function MenuSheet.ObInitialize(idname, sizew, sizeh)
	self.Sheets = self.Sheets or {}
	if !self.Sheet or !self.Sheet:IsValid() then
		self.Sheet = vgui.Create("DPropertySheet", self.object)
		self.Sheet:SetPos(5, 25)
		self.Sheet:SetSize(self.SizeW-10, self.SizeH-30)
		for k, sheet in pairs(self.Sheets) do
			sheet.Parent = self
			local build = sheet:Init()
			sheet.object = self.Sheet:AddSheet(sheet.Name, build.Object, nil, false, false)
			table.insert(self.Sheets, build)
		end
	end
	if self.Sheets then
		for k, sheet in pairs(self.Sheets) do sheet:Update() end
	end
end

Sheet = {}
Sheet.MM = {}
setmetatable(Sheet, Sheet.MM)
Sheet.MM.__index = Sheet

function Sheet.MM.__call(name)
	self.Name = name
	return self
end

function Sheet.Init(...)
	self.Object = SheetBody(...)
	self.Object.Parent = self
	return self
end

function Sheet.Update(...)

end

-- Build custom menu examples

ItemSpawnsMenu = MenuSheet

ItemSpawnsMenu.NiceName = "Item Spawns Menu" -- Menu Name
ItemSpawnsMenu.ID = "isc" -- Menu ID

--[[
Theses values specfied are the default values, no need to assign them.

ItemSpawnsMenu.Size(ScrW()/2, ScrH()/2)
ItemSpawnsMenu.Draggable = true
ItemSpawnsMenu.Closeable = true
]]--

ItemSpawnsMenuItemsSheetDisplay = Sheet
ItemSpawnsMenuItemsSheetDisplay("Items")

function ItemSpawnsMenuItemsSheetDisplay.SheetBody()
	local PanelList = vgui.Create("DPanelList")
	PanelList:EnableVerticalScrollbar(true)
	return PanelList
end

function ItemSpawnsMenuItemsSheetDisplay.SearchItems(id)
	self:Clear(true)
	for k, invd in pairs(GetSelfVar("itbl")) do
		if tonumber(k) == tonumber(id) then
			local DTextEntry2 = vgui.Create('DTextEntry')
			DTextEntry2:SetText('')
			DTextEntry2.OnEnter = function()
				local idnum = DTextEntry2:GetValue()
				self:SearchItems(idnum)
			end
			self:AddItem(DTextEntry2)
			local DButton1 = vgui.Create('DButton')
			DButton1:SetText('Search ID')
			DButton1.DoClick = function()
				local idnum = DTextEntry2:GetValue()
				self:SearchItems(idnum)
			end
			self:AddItem(DButton1)
			local itemstring = invd.class
			if type(itemstring) == "table" then
				itemstring = table.concat(itemstring, "\n")
			end
			local DLabel1s = vgui.Create('DLabel')
			DLabel1s:SetText("ID: "..tostring(k).." Classes: "..itemstring)
			DLabel1s:SizeToContents()
			self:AddItem(DLabel1s)
			local DButton3s = vgui.Create('DButton')
			DButton3s:SetText('Remove item')
			DButton3s.DoClick = function()
				CLMsg("itcom", {id = k}, function() net.WriteString("rem") end)
				self.Parent.object:Close()
			end
			self:AddItem(DButton3s)
			local ddvas = vgui.Create('DButton')
			ddvas:SetText('Edit item')
			ddvas.DoClick = function()
				SetSelfVar("activeitemspawn", invd)
				SetSelfVar("activeitemspawnid", k)
				self.Parent.Sheet:SetActiveTab( self.Parent.Sheets[3].object.Tab )
			end
			self:AddItem(ddvas)
			break
		end
	end
end

function ItemSpawnsMenuItemsSheetDisplay.Update()
	self.Object:Clear(true)
	local strtbl = GetSelfVar("itbl")
	if strtbl == 0 then local status = vgui.Create('DLabel')
	status:SetText("No items found.")
	status:SizeToContents()
	self.Object:AddItem(status) return end
	local SpawnToggleButton = vgui.Create('DButton')
	SpawnToggleButton:SetText('Toggle Spawn Display')
	SpawnToggleButton.DoClick = function() LocalPlayer():ConCommand("ev_com showspawns") end
	self.Object:AddItem(SpawnToggleButton)
	local SearchTextEntry = vgui.Create('DTextEntry')
	SearchTextEntry:SetText('')
	SearchTextEntry.OnEnter = function()
		local id = SearchTextEntry:GetValue()
		self:SearchItems(id)
	end
	self.Object:AddItem(SearchTextEntry)
	local SearchButton = vgui.Create('DButton')
	SearchButton:SetText('Search ID')
	SearchButton.DoClick = function()
		local id = DTextEntry2:GetValue()
		self:SearchItems(id)
	end
	self.Object:AddItem(SearchButton)
	local ListTitle = vgui.Create('DLabel')
	ListTitle:SetText("List:")
	ListTitle:SizeToContents()
	self.Object:AddItem(ListTitle)
	for id2, invd in pairs(strtbl) do
		local itemstring = invd.class
		if type(itemstring) == "table" then
			itemstring = table.concat(itemstring, "\n")
		end
		local ItemTextDisplay = vgui.Create('DLabel')
		ItemTextDisplay:SetText("ID: "..tostring(id2).."\nInterval: "..invd.interval.."\nClasses: "..itemstring)
		ItemTextDisplay:SizeToContents()
		self.Object:AddItem(ItemTextDisplay)
		local RemoveItemButton = vgui.Create('DButton')
		RemoveItemButton:SetText('Remove item')
		RemoveItemButton.DoClick = function()
			CLMsg("itcom", {id = id2}, function() net.WriteString("rem") end)
			self.Parent.object:Close()
		end
		self.Object:AddItem(RemoveItemButton)
		local EditItemButton = vgui.Create('DButton')
		EditItemButton:SetText('Edit item')
		EditItemButton.DoClick = function()
			SetSelfVar("activeitemspawn", invd)
			SetSelfVar("activeitemspawnid", id2)
			self.Parent.Sheet:SetActiveTab( self.Sheets[3].Sheet.Tab )
		end
		self.Object:AddItem(EditItemButton)
	end
end
ItemSpawnsMenu:AddSheet(ItemSpawnsMenuItemsSheetDisplay)
CreateCLCommand("iscmenu", ItemSpawnsMenu)

ItemSpawnsMenu.Sheets = {{name = "Items", func = function(frame, w, h, name, sheet)
	local Lpanel = vgui.Create("DPanelList")
	Lpanel:EnableVerticalScrollbar( true )
	function Lpanel:Update(frame, w, h, mname, sheet, btbl)
		self:Clear(true)
		local strtbl = GetSelfVar("itbl")
		if strtbl == 0 then local DLabel1 = vgui.Create('DLabel')
		DLabel1:SetText("No items found.")
		DLabel1:SizeToContents()
		self:AddItem(DLabel1) return end
		local sfadsd = vgui.Create('DButton')
		sfadsd:SetText('Toggle Spawn Display')
		sfadsd.DoClick = function()
			LocalPlayer():ConCommand("ev_com showspawns")
		end
		self:AddItem(sfadsd)
		local DTextEntry2 = vgui.Create('DTextEntry')
		DTextEntry2:SetText('')
		DTextEntry2.OnEnter = function()
			local txtent = DTextEntry2:GetValue()
			SearchItems(frame, self, txtent, sheet, btbl)
		end
		self:AddItem(DTextEntry2)
		local DButton1 = vgui.Create('DButton')
		DButton1:SetText('Search ID')
		DButton1.DoClick = function()
			local txtent = DTextEntry2:GetValue()
			SearchItems(frame, self, txtent, sheet, btbl)
		end
		self:AddItem(DButton1)
		local asgas = vgui.Create('DLabel')
		asgas:SetText("List:")
		asgas:SizeToContents()
		self:AddItem(asgas)
		for id2, invd in pairs(strtbl) do
			local itemstring = invd.class
			if type(itemstring) == "table" then
				itemstring = table.concat(itemstring, "\n")
			end
			local DLabel1s = vgui.Create('DLabel')
			DLabel1s:SetText("ID: "..tostring(id2).."\nInterval: "..invd.interval.."\nClasses: "..itemstring)
			DLabel1s:SizeToContents()
			self:AddItem(DLabel1s)
			local DButton3s = vgui.Create('DButton')
			DButton3s:SetText('Remove item')
			DButton3s.DoClick = function()
				CLMsg("itcom", {id = id2}, function() net.WriteString("rem") end)
				frame:Close()
			end
			self:AddItem(DButton3s)
			local ddvas = vgui.Create('DButton')
			ddvas:SetText('Edit item')
			ddvas.DoClick = function()
				SetSelfVar("activeitemspawn", invd)
				SetSelfVar("activeitemspawnid", id2)
				sheet:SetActiveTab( btbl[3].sheet.Tab, mname )
			end
			self:AddItem(ddvas)
		end
	end
	return Lpanel
end}, {name = "Add", func = function(frame, w, h, sheet)
	local Lpanel = vgui.Create("DPanelList")
	Lpanel:EnableVerticalScrollbar( true )
	function Lpanel:Update(frame, w, h, mname)
		self:Clear(true)
		
		local dl2 = vgui.Create('DLabel')
		dl2:SetText("Classes(Separated by spaces):")
		dl2:SizeToContents()
		self:AddItem(dl2)
		local DTextEntry2 = vgui.Create('DTextEntry')
		DTextEntry2:SetText('')
		self:AddItem(DTextEntry2)
		
		local clas22 = vgui.Create('DLabel')
		clas22:SetText("Interval:")
		clas22:SizeToContents()
		self:AddItem(clas22)
		local classtxt = vgui.Create('DTextEntry')
		classtxt:SetText('')
		self:AddItem(classtxt)
		
		local DButton1 = vgui.Create('DButton')
		DButton1:SetText('Submit')
		DButton1.DoClick = function()
			CLMsg("itcom", {class = DTextEntry2:GetValue(), interval = classtxt:GetValue()}, function() net.WriteString("add") end)
		end
		self:AddItem(DButton1)
	end
	return Lpanel
end}, {name = "Edit", func = function(frame, w, h, sheet)
	local Lpanel = vgui.Create("DPanelList")
	Lpanel:EnableVerticalScrollbar( true )
	function Lpanel:Update(frame, w, h, mname)
		self:Clear(true)
		local act = GetSelfVar("activeitemspawn")
		if act == 0 then local DLabel1 = vgui.Create('DLabel')
		DLabel1:SetText("Not actively editing item! Select item in the items tab.")
		DLabel1:SizeToContents()
		self:AddItem(DLabel1) return end
		
		local tblstring = act.class
		if type(tblstring) == "table" then
			tblstring = table.concat(tblstring, " ")
		end
		local clas22 = vgui.Create('DLabel')
		clas22:SetText("Classes:")
		clas22:SizeToContents()
		self:AddItem(clas22)
		local classtxt = vgui.Create('DTextEntry')
		classtxt:SetText(tblstring)
		self:AddItem(classtxt)

		local clas2222 = vgui.Create('DLabel')
		clas2222:SetText("Interval:")
		clas2222:SizeToContents()
		self:AddItem(clas2222)
		local classtxt2 = vgui.Create('DTextEntry')
		classtxt2:SetText(act.interval)
		self:AddItem(classtxt2)
		
		local DButton1 = vgui.Create('DButton')
		DButton1:SetText('Submit')
		DButton1.DoClick = function()
			CLMsg("itcom", {id = GetSelfVar("activeitemspawnid"), class = classtxt:GetValue(), interval = tonumber(classtxt2:GetValue())}, function() net.WriteString("edit") end)
		end
		self:AddItem(DButton1)
	end
	return Lpanel
end}}

function ItemSpawnsMenu.HookInit()
	if !tobool(GetSelfVar("admin")) then
		self:Close()
	else
		self:Center()
	end
end

/* No need for this hook, just for example purposes
function ItemSpawnsMenu.CloseFunc()

end
*/