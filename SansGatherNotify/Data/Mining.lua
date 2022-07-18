-- Table format: {level, prettyName, objectName, clientVersion}
-- If prettyName is nil, it's only used for modifying object tooltips, it should not be reported in chat that it is now mineable
-- If objectName is missing, it's assumed that it's the same as prettyName (as in most herbs)

SansGatherNotify.levels.mining = {
  {1,   "Copper", 	       "Copper Vein", 1},
  {65,  "Tin",			       "Tin Vein", 1},
  {65,  nil,				       "Incendicite Mineral Vein", 1},
  {75,  "Silver",		       "Silver Vein", 1},
  {125, "Iron",			       "Iron Deposit", 1},
  {150, nil,               "Indurium Mineral Vein", 1},
  {155, nil, 				       "Lesser Bloodstone Deposit", 1},
  {155, "Gold",			       "Gold Vein", 1},
  {175, "Mithril",	       "Mithril Deposit", 1},
  {175, nil,				       "Ooze Covered Mithril Deposit", 1},
  {230, "Truesilver",	     "Truesilver Deposit", 1},
  {230, nil,				       "Ooze Covered Truesilver Deposit", 1},
  {230, "Dark Iron",		   "Dark Iron Deposit", 1},
  {245, "Small Thorium",   "Small Thorium Vein", 1},
  {245, nil,				       "Ooze Covered Thorium Vein", 1},
  {275, "Rich Thorium",  	 "Rich Thorium Vein", 1},
  {275, nil,		  		     "Ooze Covered Rich Thorium Vein", 1},
  {305, "Obsidian Chunk",	 "Small Obsidian Chunk", 1},
  {305, nil,               "Large Obsidian Chunk", 1},
  {300, "Fel Iron",	       "Fel Iron Deposit", 2},
  {325, "Adamantite",      "Adamantite Deposit", 2},
  {350, "Rich Adamantite", "Rich Adamantite Deposit", 2},
  {375, "Khorium",         "Khorium Vein", 2},
  {350, "Cobalt",          "Cobalt Deposit", 3},
  {375, "Rich Cobalt",     "Rich Cobalt Deposit", 3},
  {400, "Saronite",        "Saronite Deposit", 3},
  {425, "Rich Saronite",   "Rich Saronite Deposit", 3},
  {450, "Pure Saronite",   "Pure Saronite Deposit", 3},  
}
