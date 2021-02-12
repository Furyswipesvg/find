--[[
  This is the find routine originally from 5-Minute Multiboxing--an informal multiboxing system by Furyswipes of Youtube.
  Additional code was provided by FSRockT--he figured out how to read tooltips.
  ]] --
local addon, _ns = ...
local FSMBFIND
findver=0.2
print("Find version "..findver.." loaded.")
FSMBFIND_msgcd=GetTime()
AceComm=LibStub("AceComm-3.0")
SLASH_FIND1="/find"
SlashCmdList["FIND"]=function(item)
	if item=="" then 
		print("Usage /find <classname or all or nothing> <wearing> item slot or string")
		print("Usage /find crapgear (reports greens or less being worn)") 
		print("Usage /find boe (reports boe items in bags)")  
		print("You can search for the following slots: head, neck, shoulder, shirt, chest, waist, legs, feet, wrist, hand, finger, trinket, shield, sword (and all other weapon types), cloak, weapon, tabard")
		print("You can search for types, e.g. /find food")
		print("I have no idea what all the types are. Experiment and let me know on my discord.")
		return 
	end
	if IsInGroup() then
		AceComm.SendCommMessage(FSMBFIND,"FSMB_FIND", item ,"RAID")
	end
	FSMB_Find(item)
end
FSMBFIND = CreateFrame("frame","FSMBFIND",UIParent)
function FSMBFIND:OnCommReceived(prefix,msg,group,sender)
	if prefix=="FSMB_FIND" then
		if sender~=myname then 
			FSMB_Find(msg)
		end
	end
end
AceComm.RegisterComm(FSMBFIND,"FSMB_FIND")
FSMBFINDtooltip=CreateFrame("GAMETOOLTIP", "FSMBFINDtooltip", UIParent, "GameTooltipTemplate")
local rankName,hearthStone,textSoulbound,textBoe
if (region == "deDE") then
	rankName = "Rang"
	hearthStone = "Ruhestein"
	textSoulbound = "Seelengebunden"
	textBoe = "Wird beim Anlegen gebunden"
elseif (region == "frFR") then
	rankName = "Rang"
	hearthStone = "Pierre de foyer"
	textSoulbound = "Lié"
	textBoe = "Lié quand équipé"
elseif (region == "esES" or region == "esMX") then
	rankName = "Rango"
	hearthStone = "Piedra de hogar"
	textSoulbound = "Ligado"
	textBoe = "Se liga al equiparlo"
elseif (region == "ptBR") then
	rankName = "Grau"
	hearthStone = "Pedra de Regresso"
	textSoulbound = ""
	textBoe = "Vinculado quando equipado"
elseif (region == "itIT") then
	rankName = "Grado"
	hearthStone = "Hearthstone"
	textSoulbound = "Vincolato"
	textBoe = "Si vincola all'equipaggiamento"
elseif (region == "ruRU") then
	rankName = "???????"
	hearthStone = "?????? ???????????"
	textSoulbound = "???????????? ???????"
	textBoe = "?????????? ???????????? ??? ?????????"
elseif (region == "zhCN" or region == "zhTW") then
	rankName = "??"
	hearthStone = "??"
	textSoulbound = "???"
	textBoe = "?????????? ???????????? ??? ?????????"
elseif (region == "koKR") then
	rankName = "??"
	hearthStone = "???"
	textSoulbound = "?? ???"
	textBoe = "?? ? ??"
else
	rankName = "Rank"
	hearthStone = "Hearthstone"
	textSoulbound = "Soulbound"
	textBoe = "Binds when equipped"
end
function FSMB_Find(item)
	FSMBFIND_slotmap={ [0]="ammo",[1]="head",[2]="neck",[3]="shoulder",[4]="shirt",[5]="chest",[6]="waist",[7]="legs",[8]="feet",[9]="wrist",[10]="hands",[11]="finger 1",[12]="finger 2",[13]="trinket 1",[14]="trinket 2",[15]="back",[16]="main hand",[17]="off hand",[18]="ranged",[19]="tabard"}
	FSMBFIND_slotmap_i=TableReverse(FSMBFIND_slotmap)
	local Rarity={["poor"]=0,["common"]=1,["uncommon"]=2,["rare"]=3,["epic"]=4,["legendary"]=5}
	--This is the function that determines what happens when you type /find
	local class="all"
	local _,_,key=string.find(item,"(%a+)%s*")
	key=string.lower(key)
	local FSMBFIND_classlist={"DEMONHUNTER","MONK","DEATHKNIGHT","WARRIOR","MAGE","SHAMAN","PALADIN","PRIEST","ROGUE","DRUID","HUNTER","WARLOCK"}
	classlist={}
	for _,class in pairs(FSMBFIND_classlist) do
		table.insert(classlist,string.lower(class))
	end
	if FindInTable(classlist,key) then
		class=key
		_,_,item=string.find(item,"%a+%s(.*)")
		if not item then
			item=key
		else
			print("Checking class "..key)
			_,_,key=string.find(item,"(%a+)%s*")
		end
	end
	if key=="all" then
		_,_,item=string.find(item,"%a+%s(.*)")
		_,_,key=string.find(item,"(%a+)%s*")
	end
	if key=="wearing" or key=="crapgear" then
		_,_,item=string.find(item,"%a+%s(.*)")
	end
	local myClass=string.lower(UnitClass("player"))
	if myClass=="demon hunter" then myClass="demonhunter" end
	if key=="crapgear" then
		if class~="all" and class~=myClass then return end
		print("Finding crappy gear.")
		for inv=1,16 do
			if inv~=4 then
				local itemLink = GetInventoryItemLink("player",inv)
				local quality=GetInventoryItemQuality("player",inv)
				if not quality then
					FSMBFIND_msg("MISSING: slot "..FSMBFIND_slotmap[inv])
				elseif quality<3 then
					local bsnum=string.gsub(itemLink,".-\124H([^\124]*)\124h.*", "%1")
					local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
					FSMBFIND_msg("CRAP: "..itemEquipLoc.." "..inv.." "..itemLink)
				end
			end
		end
		return
	end
	if key=="boe" then
		print("Finding boe items in bags")
		if class~="all" and class~=myClass then return end
		for bag=-1,11 do for slot=1,GetContainerNumSlots(bag) do
			local texture,itemCount,locked,quality,readable,lootable,link=GetContainerItemInfo(bag,slot)
			if texture then
				local link=GetContainerItemLink(bag,slot)
				local bsnum=string.gsub(link,".-\124H([^\124]*)\124h.*", "%1")
				local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
				_,itemCount=GetContainerItemInfo(bag,slot)
				local match=nil
				link=GetContainerItemLink(bag,slot)
				links=string.lower(link)
				items=string.lower(item)
				match = string.find(links, items)
				if IsUnboundBOE(bag,slot) then
					FSMBFIND_msg("Found boe "..link.." in bag "..bag.." slot "..slot)
			return
				end
			end
		end end
		return
	end
	if key=="wearing" then
		if not item then print("You need to name an item or slot") return end
		print("Finding "..class.." wearing "..item)
		if class~="all" and class~=myClass then return end
		for inv=1,19 do
			local itemLink = GetInventoryItemLink("player",inv)
			local quality=GetInventoryItemQuality("player",inv)
			if itemLink then
				local bsnum=string.gsub(itemLink,".-\124H([^\124]*)\124h.*", "%1")
				local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
				local match=nil
				links=string.lower(itemLink)
				items=string.lower(item)
				match = string.find(links, items)
				if itemEquipLoc then
					match= match or string.find(string.lower(itemEquipLoc),items)
				end
				if itemRarity then
					match= match or itemRarity==Rarity[items]
				end
				if itemType then
					itemType=string.lower(itemType)
					match= match or string.find(itemType,items)
				end
				if itemSubType then
					itemSubType=string.lower(itemSubType)
					match= match or string.find(itemSubType,items)
				end
				if match then
					FSMBFIND_msg("Found "..itemLink.." in slot "..FSMBFIND_slotmap[inv])
				end
			end
		end
		return
	else
		if not item then print("You need to name an item or slot") return end
		print("Finding item "..item)
		if class~="all" and class~=myClass then return end
		for bag=-1,11 do
			local maxIndex=GetContainerNumSlots(bag)
			if bag==-1 then maxIndex=12 end
			for slot=1,maxIndex do
				local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bag,slot)
				if icon then
					local bsnum=string.gsub(itemLink,".-\124H([^\124]*)\124h.*", "%1")
					local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(bsnum)
					local match=nil
					if itemName then
						links=string.lower(itemName)
					else
						links=string.lower(itemLink)
					end
					items=string.lower(item)
					match = string.find(links, items)
					if itemEquipLoc then
						itemEquipLoc=string.lower(itemEquipLoc)
						match= match or string.find(itemEquipLoc,items)
					end
					if itemRarity then
						match= match or itemRarity==Rarity[items]
					end
					if itemType then
						itemType=string.lower(itemType)
						match= match or string.find(itemType,items)
					end
					if itemSubType then
						itemSubType=string.lower(itemSubType)
						match= match or string.find(itemSubType,items)
					end
					if match then
						FSMBFIND_msg("Found "..itemLink.."x"..itemCount.." in bag "..bag.." slot "..slot)
					end
				end
			end
		end
	end
end
function IsUnboundBOE(b,s)
	local soulbound=nil
	local boe=nil
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
			if string.find(ltext,"Soulbound") or string.find(ltext,textSoulbound) then
				soulbound=true
			end
			if string.find(ltext,"Binds when equipped") or string.find(ltext,textBoe) then
				boe=true
			end
		end
		index=index+1
	end
	if not soulbound and boe then return true end
end
function FSMBFIND_msg(msg)
	--this is a raid message function with a 2 second cooldown to kind-of avoid some spamming.
	if not IsInGroup() then 
		print(msg)
		return
	end
	local cooldown=5
	local time=GetTime()
	if MB_prev_msg==msg and FSMBFIND_msgcd+cooldown>time then return end
	MB_prev_msg=msg
	FSMBFIND_msgcd=time
	if UnitInRaid("player") then
		SendChatMessage(msg,"RAID") return
	else
		SendChatMessage(msg,"PARTY") return
	end
	print(msg)
end
function TableReverse(table)
	local t={}
	if not table then return end
		for key,value in pairs(table) do
			t[value]=key
		end
	return t
end
function FindInTable(table,string)
	--only works on 1D tables
	if not table then return end
	for i,v in pairs(table) do
		if v==string then return i end
	end
	return nil
end
