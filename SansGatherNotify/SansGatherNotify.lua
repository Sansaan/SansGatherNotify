SansGatherNotify = {}
SansGatherNotify.ActiveTracking = ""

-- 1 classic, 2 tbc, 3 wrath
SansGatherNotify.ClientVersion = tonumber(string.sub((select(4, GetBuildInfo())), 1, 1))

SansGatherNotify.levels = {}

SansGatherNotify.Frame = CreateFrame("Frame")

--- Events ---

function SansGatherNotify.OnEvent(self, event, ...)
  -- Fired on a registered event
  if event == "ADDON_LOADED" then
    local addon_name = ...
    if addon_name == "SansGatherNotify" then
      GameTooltip:HookScript("OnShow", SansGatherNotify.ModifyTooltip)
      SansGatherNotify.origErrorFunc = UIErrorsFrame:GetScript('OnEvent')
      UIErrorsFrame:SetScript('OnEvent', SansGatherNotify.OnUIError)
    end
  
  elseif event == "CHAT_MSG_SKILL" then
    local msg = ...
    C_Timer.After(0.1, function()
      SansGatherNotify.OnSkillUpMessage(self, msg)
    end)
    
  end
end

local function split(str, pat, limit)
  local t = {}
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(t, cap)
    end
    last_end = e+1
    s, e, cap = str:find(fpat, last_end)

    if limit ~= nil and limit <= #t then
      break
    end
  end
  if last_end <= #str then
    cap = str:sub(last_end)
    table.insert(t, cap)
  end
  return t
end

local function firstToUpper(str)
  return (str:gsub("^%l", string.upper))
end

function SansGatherNotify.OnCommand(cmd)
  -- Fired when a slash command is entered
  cmd = cmd:lower()

  if #cmd > 0 then
    local args = split(cmd, " ")
    if string.find("skinning", args[1]) then
      SansGatherNotify.PrintHighestNode("skinning",args[2])
      return
    elseif string.find("mining", args[1]) or string.find("mine", args[1]) then
      SansGatherNotify.PrintHighestNode("mining",args[2])
      return
    elseif string.find("herbalism", args[1]) or string.find("herbing", args[1]) then
      SansGatherNotify.PrintHighestNode("herbalism",args[2])
      return
    elseif string.find("version", args[1]) then
      SansGatherNotify.Msg(format("SansGatherNotify version: |cff1aff1a%s|cffFFC300 (%s)", GetAddOnMetadata("SansGatherNotify","Version"), GetAddOnMetadata("SansGatherNotify","X-Date")), true)
      return
    end
  end

  SansGatherNotify.Msg("/sgn skinning [bonus] - Print highest level creature you can skin", true)
  SansGatherNotify.Msg("/sgn mining [bonus] - Print highest node you can mine", true)
  SansGatherNotify.Msg("/sgn herbalism [bonus] - Print highest herb you can pick", true)
  SansGatherNotify.Msg("/sgn version - Prints addon version", true)
end

function SansGatherNotify.OnUIError(self, event, errtype, err)
  -- Fired when a red error is shown at the top of the screen
  local skill = strmatch(err,"Requires (.*) ")
  local rlevel = tonumber(strmatch(err,"Requires .* (%d+)"))

  if skill and rlevel then -- Error was a "requires" error
    local level,temp = SansGatherNotify.GetProfessionLevel(skill)
    if level then
      SansGatherNotify.AddError(skill,rlevel,level,temp)
    else
      return SansGatherNotify.origErrorFunc(self, event, errtype, err)
    end
  else
    return SansGatherNotify.origErrorFunc(self, event, errtype, err)
  end
end

function SansGatherNotify.OnSkillUpMessage(self, msg)
  -- Fired when we get a "Your skill in x has increased to y." message
  local skill = strmatch(msg, "Your skill in (%a*) has increased to")
  if skill ~= "Mining" and skill ~= "Herbalism" and skill ~= "Skinning" then return end

  local level,temp = SansGatherNotify.GetProfessionLevel(skill)
  local skillcolor = SansGatherNotify.GetChatColor("SKILL")

  ----- First, print if you can mine something new, without taking temp bonuses into account -----
  local new = SansGatherNotify.GetAllGatherable(skill,level)
  local newtemp = SansGatherNotify.GetAllGatherable(skill,level+temp)

  if new then
    local newmessage = ""
    local tempmsg = " (without any bonuses)"

    if skill == "Skinning" then
      newmessage = "Now able to skin level "..new.." creatures"

    elseif skill == "Mining" then
      newmessage = "Now able to mine "..new

    elseif skill == "Herbalism" then
      newmessage = "Now able to pick "..new

    end

    if newtemp and newtemp ~= new then
      tempmsg = " ("

      if skill == "Skinning" then tempmsg = tempmsg.."level "..newtemp.." creatures"
      elseif skill == "Mining" then tempmsg = tempmsg..newtemp.." ("..level..")"
      elseif skill == "Herbalism" then tempmsg = tempmsg..newtemp.." ("..level..")"
      end

      tempmsg = tempmsg.." with current |cff1aff1a+"..temp.."|cffFFC300 bonus)"
    end

    SansGatherNotify.Msg(newmessage..tempmsg, false)

  end
  ----- End -----
end

--- Functions ---

function SansGatherNotify.UpdateActive()
  if SansGatherNotify.ClientVersion == 1 then
    -- Classic

    local trackingaura = GetTrackingTexture()
    if trackingaura == 136025 then
      SansGatherNotify.ActiveTracking = "Mining"

    elseif trackingaura == 133939 then
      SansGatherNotify.ActiveTracking = "Herbalism"

    else
      SansGatherNotify.ActiveTracking = ""

    end

  elseif SansGatherNotify.ClientVersion == 2 then
    -- TBC

    local count = GetNumTrackingTypes()
    for i=1,count do 
      local name, texture, active, category = GetTrackingInfo(i);
      if active and category == "spell" then

        if name == "Find Minerals" then
          SansGatherNotify.ActiveTracking = "Mining"

        elseif name == "Find Herbs" then
          SansGatherNotify.ActiveTracking = "Herbalism"

        else
          SansGatherNotify.ActiveTracking = ""

        end
      end
    end
  end
end

function SansGatherNotify.Msg(msg, printname, color)
  -- Print a message to the chat frame
  if not color then
    color = "FFC300"
  end

  if printname then
    DEFAULT_CHAT_FRAME:AddMessage("|cffd2b48c[San's GatherNotify]|r |cff"..color..msg)
  else
    DEFAULT_CHAT_FRAME:AddMessage("|cff"..color..msg)
  end
end

function SansGatherNotify.GetChatColor(chattype)
  -- Get the default color of a chat type (like SKILL or WHISPER)
  local chatinfo = ChatTypeInfo[chattype]
  return format("%02x%02x%02x", chatinfo.r*255, chatinfo.g*255, chatinfo.b*255)
end

function SansGatherNotify.AddError(skill,rlevel,current,temp)
  -- Print a modified red error to the top of the screen
  if temp == 0 then
    UIErrorsFrame:AddMessage(string.format("Requires %s %s (currently %s)",skill,rlevel,current),1.0,0.1,0.1,1.0)
  else
    UIErrorsFrame:AddMessage(string.format("Requires %s %s (currently %s|cff1aff1a+%s|r)",skill,rlevel,current,temp),1.0,0.1,0.1,1.0)
  end
end

function SansGatherNotify.GetHighestNode(skill,level)
  -- Get the highest herb/mine/corpse usable at the current skill level
  skill = skill:lower()
  if skill ~= "skinning" and skill ~= "herbalism" and skill ~= "mining" then return end

  local highest = 1
  for i,v in pairs(SansGatherNotify.levels[skill]) do
    if v[#v] <= SansGatherNotify.ClientVersion and v[1] <= level and v[2] then
      highest = v[1]
    end
  end

  return SansGatherNotify.GetAllGatherable(skill,highest)
end

function SansGatherNotify.PrintHighestNode(skill,argtemp)
  -- Print the highest herb/mine/corpse usable at the current skill level, with bonuses

  local level,temp = SansGatherNotify.GetProfessionLevel(skill)
  temp = tonumber(argtemp) or temp

  if level then
    local withoutbonuses = SansGatherNotify.GetHighestNode(skill,level) or "???"
    local withbonuses = SansGatherNotify.GetHighestNode(skill,level+temp) or "???"

    if withoutbonuses == withbonuses then
      SansGatherNotify.Msg(firstToUpper(skill).." "..level..": "..withoutbonuses.." (regardless of |cff1aff1a+"..temp.."|cffFFC300 bonus)", true)
    else
      local tempmsg = " (without any bonuses)"
      if temp>0 then
        tempmsg = " (without current |cff1aff1a+"..temp.."|cffFFC300 bonus)"
      end

      if skill == "skinning" then
        withoutbonuses = "level "..withoutbonuses.." creatures"
        withbonuses = "level "..withbonuses.." creatures"
      end
      SansGatherNotify.Msg(firstToUpper(skill).." "..level..": "..withoutbonuses..tempmsg, true)

      if temp>0 then
        tempmsg = " (with current |cff1aff1a+"..temp.."|cffFFC300 bonus)"
        SansGatherNotify.Msg(firstToUpper(skill).." |cff1aff1a"..level+temp.."|cffFFC300: "..withbonuses..tempmsg, true)
      end
    end
  else
    SansGatherNotify.Msg("You don't have "..skill, true)
  end
end

function SansGatherNotify.GetAllGatherable(skill,level)
  -- Get a list of all herbs/mines/corpses usable at the current skill level
  skill = skill:lower()
  if skill ~= "skinning" and skill ~= "herbalism" and skill ~= "mining" then return end

  local i2 = 1
  local ret = {}
  for i,v in pairs(SansGatherNotify.levels[skill]) do
    if v[#v] <= SansGatherNotify.ClientVersion and v[1] == level and v[2] then
      ret[i2] = v[2]
      i2=i2+1
    end
  end

  if #ret == 0 then return nil else return table.concat(ret,", ") end
end

function SansGatherNotify.GetRequiredLevel(skill,name)
  -- Get the required herbalism/mining/skinning level required to use a node/corpse
  name = tostring(name)
  skill = skill:lower()
  if skill ~= "skinning" and skill ~= "herbalism" and skill ~= "mining" then return end

  local ret = 0

  for i,v in pairs(SansGatherNotify.levels[skill]) do
    if v[#v] <= SansGatherNotify.ClientVersion and (v[2] == name or v[3] == name) then
      ret = v[1]
    end
  end

  return ret
end

function SansGatherNotify.GetProfessionLevel(name)
  -- Get a profession's level
  local numSkills = GetNumSkillLines()
  for i=1, numSkills do
    local skillname,_,_,skillrank,_,skillmodifier = GetSkillLineInfo(i)
    if skillname:lower() == name:lower() then
      return skillrank, skillmodifier
    end
  end
end

local escapes = {
  ["|c%x%x%x%x%x%x%x%x"] = "", -- color start
  ["|r"] = "", -- color end
  ["|H.-|h(.-)|h"] = "%1", -- links
  ["|T.-|t"] = "", -- textures
  ["{.-}"] = "", -- raid target icons
}
local function unescape(str)
  for k, v in pairs(escapes) do
    str = gsub(str, k, v)
  end
  return str
end

function SansGatherNotify.ModifyTooltip(self, ...)
  -- Modify an herb's/mine's/corpse's tooltip
  local skillname,objname,r,g,b,a,linenum,reqlevel

  SansGatherNotify.UpdateActive()

  if GameTooltipTextLeft2:GetText() == "Mining" then
    skillname = "Mining"
    objname = GameTooltipTextLeft1:GetText()
    r,g,b,a = GameTooltipTextLeft2:GetTextColor()
    linenum = 2
  elseif GameTooltipTextLeft2:GetText() == "Requires Herbalism" or GameTooltipTextLeft2:GetText() == "Herbalism" then
    skillname = "Herbalism"
    objname = GameTooltipTextLeft1:GetText()
    r,g,b,a = GameTooltipTextLeft2:GetTextColor()
    linenum = 2
  elseif UnitExists("mouseover") then
    skillname = "Skinning"
    objname = UnitLevel("mouseover") -- Skinning takes a mob level, not an object/node name
    local skinning_line = 0
    for i=1,GameTooltip:NumLines() do
      if _G["GameTooltipTextLeft"..i]:GetText() == "Skinnable" then
        skinning_line = i
      end
    end
    if skinning_line == 0 then return end -- Not a skinnable mob, so abort
    r,g,b,a = _G["GameTooltipTextLeft"..skinning_line]:GetTextColor()
    linenum = skinning_line
  else
    objname = unescape(GameTooltipTextLeft1:GetText())
    reqlevel = SansGatherNotify.GetRequiredLevel(SansGatherNotify.ActiveTracking,objname)
    --DEFAULT_CHAT_FRAME:AddMessage(unescape(objname));

    if reqlevel == nil then
      return
    end

    if reqlevel > 0 then
      skillname = SansGatherNotify.ActiveTracking
      --objname = GameTooltipTextLeft1:GetText()
      r,g,b,a = 1, 1, 1, 1 -- GameTooltipTextLeft1:GetTextColor()
      GameTooltip:AddLine("Skill Required", r,g,b)
      linenum = 2

    else
      return -- Not a tooltip we care about
    end
  end

  -- Modify the tooltip
  local req = SansGatherNotify.GetRequiredLevel(skillname,objname)

  if not req then
    return
  end

  local newstr = _G["GameTooltipTextLeft"..linenum]:GetText() .. " " .. req

  local skill,tempboost = SansGatherNotify.GetProfessionLevel(skillname)

  if skill then
    if tempboost > 0 then
      newstr = newstr .. format(" (currently %s|cff1aff1a+%s|r)", skill, tempboost)
    else
      newstr = newstr .. " (currently "..skill .. ")"
    end
  end

  _G["GameTooltipTextLeft"..linenum]:SetText(newstr)
  GameTooltip:Show() -- Re-show the tooltip to update its size
end

-- Debug functions

function SansGatherNotify.Debug(...)
  -- Print a debug message to the chat frame
  local str = table.concat({...}, " ")
  DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[GN]|r " .. str)
end

function SansGatherNotify.DebugErr(skill,level)
  -- Generates a fake error message - GN.err("mining", 500) etc.
  UIErrorsFrame:GetScript("OnEvent")(UIErrorsFrame,"UI_ERROR_MESSAGE", format("Requires %s %s", skill, level))
end

function SansGatherNotify.DebugSkillup(str)
  -- Generates a fake skillup message in chat
  SansGatherNotify.OnEvent(self, "CHAT_MSG_SKILL", str)
end

SLASH_SGN1, SLASH_SGN2, SLASH_SGN3 = '/sgn', '/SansGatherNotify', '/sgnotify'
SlashCmdList["SGN"] = SansGatherNotify.OnCommand

SansGatherNotify.Frame:SetScript("OnEvent", SansGatherNotify.OnEvent)
SansGatherNotify.Frame:RegisterEvent("CHAT_MSG_SKILL")
SansGatherNotify.Frame:RegisterEvent("ADDON_LOADED")
SansGatherNotify.Frame:RegisterEvent("UI_ERROR_MESSAGE")
