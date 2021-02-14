--[[
  This is the find routine originally from 5-Minute Multiboxing--an informal multiboxing system by Furyswipes of Youtube.
  Additional code was provided by FSRockT--he figured out how to read tooltips.
  furyswipesvg@gmail.com
  ]] --
local addon, _ns = ...
local FSMBFIND = CreateFrame("frame",addon,UIParent)
FSMBFIND.version = 0.2
print("Find version "..FSMBFIND.version.." loaded. Type /find for help.")
FSMBFIND.msgcd = GetTime()
FSMBFIND.AceComm = LibStub("AceComm-3.0")
SLASH_FIND1 = "/find"
SlashCmdList["FIND"] = function(item)
	if item == "" then 
		print("Finds and reports things in bags or on person into party or raid chat.")
		print("Everyone with addon will report when one person searches!")
		print("Usage /find <classname or all or nothing> <wearing> item slot or string")
		print("Usage /find crapgear (reports greens or less being worn)") 
		print("Usage /find boe (reports boe items in bags)")  
		print("You can search for the following slots: head, neck, shoulder, shirt, chest, waist, legs, feet, wrist, hand, finger, trinket, shield, sword (and all other weapon types), cloak, weapon, tabard")
		print("You can search for types, e.g. /find food")
		print("I have no idea what all the types are. Experiment and let me know on my discord.")
		return 
	end
	if IsInGroup() then
		FSMBFIND.AceComm.SendCommMessage(FSMBFIND,"FSMB_FIND", item ,"RAID")
	end
	FSMBFIND.find(item)
end
function FSMBFIND:OnCommReceived(prefix,msg,group,sender)
	if prefix == "FSMB_FIND" then
		if sender~=myname then 
			FSMBFIND.find(msg)
		end
	end
end
FSMBFIND.AceComm.RegisterComm(FSMBFIND,"FSMB_FIND")
local FSMBFINDtooltip=CreateFrame("GAMETOOLTIP", "FSMBFINDtooltip", UIParent, "GameTooltipTemplate")
if (region == "deDE") then
	FSMBFIND.rankName = "Rang"
	FSMBFIND.hearthStone = "Ruhestein"
	FSMBFIND.textSoulbound = "Seelengebunden"
	FSMBFIND.textBoe = "Wird beim Anlegen gebunden"
elseif (region == "frFR") then
	FSMBFIND.rankName = "Rang"
	FSMBFIND.hearthStone = "Pierre de foyer"
	FSMBFIND.textSoulbound = "Lié"
	FSMBFIND.textBoe = "Lié quand équipé"
elseif (region == "esES" or region == "esMX") then
	FSMBFIND.rankName = "Rango"
	FSMBFIND.hearthStone = "Piedra de hogar"
	FSMBFIND.textSoulbound = "Ligado"
	FSMBFIND.textBoe = "Se liga al equiparlo"
elseif (region == "ptBR") then
	FSMBFIND.rankName = "Grau"
	FSMBFIND.hearthStone = "Pedra de Regresso"
	FSMBFIND.textSoulbound = ""
	FSMBFIND.textBoe = "Vinculado quando equipado"
elseif (region == "itIT") then
	FSMBFIND.rankName = "Grado"
	FSMBFIND.hearthStone = "Hearthstone"
	FSMBFIND.textSoulbound = "Vincolato"
	FSMBFIND.textBoe = "Si vincola all'equipaggiamento"
elseif (region == "ruRU") then
	FSMBFIND.rankName = "???????"
	FSMBFIND.hearthStone = "?????? ???????????"
	FSMBFIND.textSoulbound = "???????????? ???????"
	FSMBFIND.textBoe = "?????????? ???????????? ??? ?????????"
elseif (region == "zhCN" or region == "zhTW") then
	FSMBFIND.rankName = "??"
	FSMBFIND.hearthStone = "??"
	FSMBFIND.textSoulbound = "???"
	FSMBFIND.textBoe = "?????????? ???????????? ??? ?????????"
elseif (region == "koKR") then
	FSMBFIND.rankName = "??"
	FSMBFIND.hearthStone = "???"
	FSMBFIND.textSoulbound = "?? ???"
	FSMBFIND.textBoe = "?? ? ??"
else
	FSMBFIND.rankName = "Rank"
	FSMBFIND.hearthStone = "Hearthstone"
	FSMBFIND.textSoulbound = "Soulbound"
	FSMBFIND.textBoe = "Binds when equipped"
end
function FSMBFIND.find(item)
	FSMBFIND.slotmap = { [0]="ammo",[1]="head",[2]="neck",[3]="shoulder",[4]="shirt",[5]="chest",[6]="waist",[7]="legs",[8]="feet",[9]="wrist",[10]="hands",[11]="finger 1",[12]="finger 2",[13]="trinket 1",[14]="trinket 2",[15]="back",[16]="main hand",[17]="off hand",[18]="ranged",[19]="tabard"}
	FSMBFIND.slotmap_i=FSMBFIND.TableReverse(FSMBFIND.slotmap)
	local Rarity = {["poor"]=0,["common"]=1,["uncommon"]=2,["rare"]=3,["epic"]=4,["legendary"]=5}
	--This is the function that determines what happens when you type /find
	local class="all"
	local _,_,key=string.find(item,"(%a+)%s*")
	key=string.lower(key)
	FSMBFIND.classlist = {"DEMONHUNTER","MONK","DEATHKNIGHT","WARRIOR","MAGE","SHAMAN","PALADIN","PRIEST","ROGUE","DRUID","HUNTER","WARLOCK"}
	local lclasslist = {}
	for _,class in pairs(FSMBFIND.classlist) do
		table.insert(lclasslist,string.lower(class))
	end
	if FSMBFIND.FindInTable(lclasslist,key) then
		class = key
		_,_,item = string.find(item,"%a+%s(.*)")
		if not item then
			item = key
		else
			print("Checking class "..key)
			_,_,key = string.find(item,"(%a+)%s*")
		end
	end
	if key=="all" then
		_,_,item = string.find(item,"%a+%s(.*)")
		_,_,key = string.find(item,"(%a+)%s*")
	end
	if key == "wearing" or key == "crapgear" then
		_,_,item = string.find(item,"%a+%s(.*)")
	end
	local myClass = string.lower(UnitClass("player"))
	if myClass == "demon hunter" then myClass = "demonhunter" end
	if key == "crapgear" then
		if class ~= "all" and class ~= myClass then return end
		print("Finding crappy gear.")
		for inv = 1,16 do
			if inv ~= 4 then
				local itemLink = GetInventoryItemLink("player",inv)
				local quality = GetInventoryItemQuality("player",inv)
				if not quality then
					FSMBFIND.msg("MISSING: slot "..FSMBFIND.slotmap[inv])
				elseif quality<3 then
					local bsnum = string.gsub(itemLink,".-\124H([^\124]*)\124h.*", "%1")
					local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
					FSMBFIND.msg("CRAP: "..itemEquipLoc.." "..inv.." "..itemLink)
				end
			end
		end
		return
	end
	if key == "boe" then
		print("Finding boe items in bags")
		if class ~= "all" and class ~= myClass then return end
		for bag = -1,11 do for slot = 1,GetContainerNumSlots(bag) do
			local texture,itemCount,locked,quality,readable,lootable,link=GetContainerItemInfo(bag,slot)
			if texture then
				local link = GetContainerItemLink(bag,slot)
				local bsnum = string.gsub(link,".-\124H([^\124]*)\124h.*", "%1")
				local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
				_,itemCount = GetContainerItemInfo(bag,slot)
				local match = nil
				link = GetContainerItemLink(bag,slot)
				local links = string.lower(link)
				local items = string.lower(item)
				match = string.find(links, items)
				if FSMBFIND.IsUnboundBOE(bag,slot) then
					FSMBFIND.msg("Found boe "..link.." in bag "..bag.." slot "..slot)
			return
				end
			end
		end end
		return
	end
	if key == "wearing" then
		if not item then print("You need to name an item or slot") return end
		print("Finding "..class.." wearing "..item)
		if class ~= "all" and class ~= myClass then return end
		for inv = 1,19 do
			local itemLink = GetInventoryItemLink("player",inv)
			local quality = GetInventoryItemQuality("player",inv)
			if itemLink then
				local bsnum = string.gsub(itemLink,".-\124H([^\124]*)\124h.*", "%1")
				local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
				local match = nil
				local links = string.lower(itemLink)
				local items = string.lower(item)
				match = string.find(links, items)
				if itemEquipLoc then
					match = match or string.find(string.lower(itemEquipLoc),items)
				end
				if itemRarity then
					match = match or itemRarity == Rarity[items]
				end
				if itemType then
					itemType = string.lower(itemType)
					match = match or string.find(itemType,items)
				end
				if itemSubType then
					itemSubType = string.lower(itemSubType)
					match = match or string.find(itemSubType,items)
				end
				if match then
					FSMBFIND.msg("Found "..itemLink.." in slot "..FSMBFIND.slotmap[inv])
				end
			end
		end
		return
	else
		if not item then print("You need to name an item or slot") return end
		print("Finding item "..item)
		if class ~= "all" and class ~= myClass then return end
		for bag = -1,11 do
			local maxIndex = GetContainerNumSlots(bag)
			if bag == -1 then maxIndex = 12 end
			for slot = 1,maxIndex do
				local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bag,slot)
				if icon then
					local bsnum = string.gsub(itemLink,".-\124H([^\124]*)\124h.*", "%1")
					local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
					local match = nil
					local links
					if itemName then
						links = string.lower(itemName)
					else
						links = string.lower(itemLink)
					end
					local items = string.lower(item)
					match = string.find(links, items)
					if itemEquipLoc then
						itemEquipLoc = string.lower(itemEquipLoc)
						match = match or string.find(itemEquipLoc,items)
					end
					if itemRarity then
						match = match or itemRarity == Rarity[items]
					end
					if itemType then
						itemType = string.lower(itemType)
						match = match or string.find(itemType,items)
					end
					if itemSubType then
						itemSubType = string.lower(itemSubType)
						match = match or string.find(itemSubType,items)
					end
					if match then
						FSMBFIND.msg("Found "..itemLink.."x"..itemCount.." in bag "..bag.." slot "..slot)
					end
				end
			end
		end
	end
end
function FSMBFIND.IsUnboundBOE(b,s)
	local soulbound = nil
	local boe = nil
	--local _,_,itemID = string.find(itemlink, "item:(%d+)")
	FSMBFINDtooltip:SetOwner(UIParent, "ANCHOR_NONE");
	FSMBFINDtooltip:ClearLines()
	FSMBFINDtooltip:SetBagItem(b,s);
	FSMBFINDtooltip:Show()
	local index = 1
	local ltext = getglobal("FSMBFINDtooltipTextLeft"..index):GetText()
	while ltext ~= nil do
		ltext = getglobal("FSMBFINDtooltipTextLeft"..index):GetText()
		if ltext ~= nil then
			if string.find(ltext,"Soulbound") or string.find(ltext,FSMBFIND.textSoulbound) then
				soulbound = true
			end
			if string.find(ltext,"Binds when equipped") or string.find(ltext,FSMBFIND.textBoe) then
				boe = true
			end
		end
		index = index+1
	end
	if not soulbound and boe then return true end
end
function FSMBFIND.msg(msg)
	--this is a raid message function with a 2 second cooldown to kind-of avoid some spamming.
	if not IsInGroup() then 
		print(msg)
		return
	end
	local cooldown = 5
	local time = GetTime()
	if FSMBFIND.prev_msg == msg and FSMBFIND.msgcd+cooldown>time then return end
	FSMBFIND.prev_msg = msg
	FSMBFIND.msgcd = time
	if UnitInRaid("player") then
		SendChatMessage(msg,"RAID") return
	else
		SendChatMessage(msg,"PARTY") return
	end
	print(msg)
end
function FSMBFIND.TableReverse(table)
	local t = {}
	if not table then return end
		for key,value in pairs(table) do
			t[value] = key
		end
	return t
end
function FSMBFIND.FindInTable(table,string)
	--only works on 1D tables
	if not table then return end
	for i,v in pairs(table) do
		if v == string then return i end
	end
	return nil
end
