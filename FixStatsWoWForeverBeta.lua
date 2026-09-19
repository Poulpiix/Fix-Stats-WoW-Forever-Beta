-- Fix Stats Locale
-- Cause probable : PaperDollFrame_SetStatTooltip2 cherche un texte de tooltip
-- avec une clef construite a partir du nom de stat LOCALISE (ex: "Force"),
-- par exemple PALADIN_Force_TOOLTIP, alors que les globales n'existent
-- qu'avec le nom anglais (PALADIN_STRENGTH_TOOLTIP). Resultat : nil dans format().
-- Cet addon cree les globales manquantes pour toutes les classes.

local CLASSES = {
  "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "DEATHKNIGHT",
  "SHAMAN", "MAGE", "WARLOCK", "MONK", "DRUID", "DEMONHUNTER", "EVOKER",
}
local ENGLISH = { "STRENGTH", "AGILITY", "STAMINA", "INTELLECT", "SPIRIT" }

local created = {}

local function setIfMissing(key, value)
  if _G[key] == nil then
    _G[key] = value
    created[#created + 1] = key
  end
end

local function Patch()
  wipe(created)
  for i = 1, 5 do
    local loc = _G["SPELL_STAT" .. i .. "_NAME"]
    local eng = ENGLISH[i]
    if loc then
      local variants = { loc, strupper(loc) }
      local defaultText = _G["DEFAULT_STAT" .. i .. "_TOOLTIP"] or ""
      for _, name in ipairs(variants) do
        setIfMissing("DEFAULT_STAT" .. name .. "_TOOLTIP", defaultText)
        setIfMissing("DEFAULT_" .. name .. "_TOOLTIP", defaultText)
        for _, class in ipairs(CLASSES) do
          local text = _G[class .. "_" .. eng .. "_TOOLTIP"] or defaultText
          setIfMissing(class .. "_" .. name .. "_TOOLTIP", text)
        end
      end
    end
  end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function() Patch() end)

SLASH_FIXSTATSLOCALE1 = "/fixstats"
SlashCmdList["FIXSTATSLOCALE"] = function()
  Patch()
  print("|cff33ff99FixStatsLocale|r : " .. #created .. " clef(s) creee(s) sur cet appel.")
  for i = 1, 5 do
    local loc = _G["SPELL_STAT" .. i .. "_NAME"]
    print(("Stat %d : %s (anglais : %s)"):format(i, tostring(loc), ENGLISH[i]))
  end
  local _, class = UnitClass("player")
  local loc = _G["SPELL_STAT1_NAME"]
  if loc and class then
    print("Test " .. class .. "_" .. loc .. "_TOOLTIP = " .. tostring(_G[class .. "_" .. loc .. "_TOOLTIP"]))
  end
end
