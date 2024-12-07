-- Guilds
INSERT INTO Guilds (GuildID, Name) VALUES (1, 'Knights of Azeroth');
INSERT INTO Guilds (GuildID, Name) VALUES (2, 'The Horde');

-- Characters
INSERT INTO Characters (CharacterID, Name, Race, Class, "Level", GuildID)
VALUES (1, 'Thrall', 'Orc', 'Shaman', 60, 2);
INSERT INTO Characters (CharacterID, Name, Race, Class, "Level", GuildID)
VALUES (2, 'Jaina', 'Human', 'Mage', 60, 1);
INSERT INTO Characters (CharacterID, Name, Race, Class, "Level", GuildID)
VALUES (3, 'Arthas', 'Human', 'Death Knight', 55, NULL);

-- Quests
INSERT INTO Quests (QuestID, Name, Description, Reward, DifficultyLevel)
VALUES (1, 'Retrieve the Lost Artifact', 'Find and return the lost artifact to the mage tower.', '100 gold', 3);
INSERT INTO Quests (QuestID, Name, Description, Reward, DifficultyLevel)
VALUES (2, 'Defend the Village', 'Protect the village from invading forces.', '50 gold', 2);

-- Items
INSERT INTO Items (ItemID, Name, Type, Quality)
VALUES (1, 'Sword of Valor', 'Weapon', 'Epic');
INSERT INTO Items (ItemID, Name, Type, Quality)
VALUES (2, 'Healing Potion', 'Consumable', 'Common');

-- Professions
INSERT INTO Professions (ProfessionID, Name, Category)
VALUES (1, 'Blacksmithing', 'Crafting');
INSERT INTO Professions (ProfessionID, Name, Category)
VALUES (2, 'Alchemy', 'Crafting');

-- Achievements
INSERT INTO Achievements (AchievementID, Name, Description)
VALUES (1, 'Defender of Azeroth', 'Completed 100 quests in Azeroth.');
INSERT INTO Achievements (AchievementID, Name, Description)
VALUES (2, 'Master of Professions', 'Reached max level in all professions.');

-- Character_Quests
INSERT INTO Character_Quests (CharacterQuestID, CharacterID, QuestID, Status)
VALUES (1, 1, 1, 'Active');
INSERT INTO Character_Quests (CharacterQuestID, CharacterID, QuestID, Status)
VALUES (2, 2, 2, 'Completed');

-- Character_Items
INSERT INTO Character_Items (CharacterItemID, CharacterID, ItemID, Quantity)
VALUES (1, 1, 1, 1);
INSERT INTO Character_Items (CharacterItemID, CharacterID, ItemID, Quantity)
VALUES (2, 2, 2, 5);

-- Character_Professions
INSERT INTO Character_Professions (CharacterProfessionID, CharacterID, ProfessionID, SkillLevel)
VALUES (1, 1, 1, 150);
INSERT INTO Character_Professions (CharacterProfessionID, CharacterID, ProfessionID, SkillLevel)
VALUES (2, 2, 2, 200);

-- Guild_Events
INSERT INTO Guild_Events (EventID, GuildID, Name, EventDate)
VALUES (1, 1, 'Guild Raid on Blackrock Mountain', TO_DATE('2023-12-01', 'YYYY-MM-DD'));
INSERT INTO Guild_Events (EventID, GuildID, Name, EventDate)
VALUES (2, 2, 'Horde Gathering in Orgrimmar', TO_DATE('2023-12-05', 'YYYY-MM-DD'));


COMMIT;