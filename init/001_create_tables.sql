-- Characters Table
CREATE TABLE Characters (
    CharacterID NUMBER PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL,
    Race VARCHAR2(50) NOT NULL,
    Class VARCHAR2(50) NOT NULL,
    "Level" NUMBER(3) DEFAULT 1,
    GuildID NUMBER NULL
);



-- Guilds Table
CREATE TABLE Guilds (
    GuildID NUMBER PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL,
    LeaderID NUMBER
);

ALTER TABLE Characters 
ADD CONSTRAINT fk_character_to_guild FOREIGN KEY (GuildID) REFERENCES Guilds (GuildID);

ALTER TABLE Guilds 
ADD CONSTRAINT fk_guild_to_character FOREIGN KEY (LeaderID) REFERENCES Characters (CharacterID);

-- Quests Table
CREATE TABLE Quests (
    QuestID NUMBER PRIMARY KEY,
    Name VARCHAR2(200) NOT NULL,
    Description VARCHAR2(500),
    Reward VARCHAR2(100),
    DifficultyLevel NUMBER(3)
);

-- Items Table
CREATE TABLE Items (
    ItemID NUMBER PRIMARY KEY,
    Name VARCHAR2(200) NOT NULL,
    Type VARCHAR2(50),
    Quality VARCHAR2(50)
);

-- Professions Table
CREATE TABLE Professions (
    ProfessionID NUMBER PRIMARY KEY,
    Name VARCHAR2(100) NOT NULL,
    Category VARCHAR2(50)
);

-- Achievements Table
CREATE TABLE Achievements (
    AchievementID NUMBER PRIMARY KEY,
    Name VARCHAR2(200) NOT NULL,
    Description VARCHAR2(500)
);

-- Character_Quests Table (Many-to-Many between Characters and Quests)
CREATE TABLE Character_Quests (
    CharacterQuestID NUMBER PRIMARY KEY,
    CharacterID NUMBER NOT NULL,
    QuestID NUMBER NOT NULL,
    Status VARCHAR2(50) CHECK (Status IN ('Active', 'Completed', 'Failed')),
    CompletionDate DATE,
    FOREIGN KEY (CharacterID) REFERENCES Characters(CharacterID),
    FOREIGN KEY (QuestID) REFERENCES Quests(QuestID)
);

-- Character_Items Table (Many-to-Many between Characters and Items)
CREATE TABLE Character_Items (
    CharacterItemID NUMBER PRIMARY KEY,
    CharacterID NUMBER NOT NULL,
    ItemID NUMBER NOT NULL,
    Quantity NUMBER(10),
    FOREIGN KEY (CharacterID) REFERENCES Characters(CharacterID),
    FOREIGN KEY (ItemID) REFERENCES Items(ItemID)
);

-- Character_Professions Table (Many-to-Many between Characters and Professions)
CREATE TABLE Character_Professions (
    CharacterProfessionID NUMBER PRIMARY KEY,
    CharacterID NUMBER NOT NULL,
    ProfessionID NUMBER NOT NULL,
    SkillLevel NUMBER(3) DEFAULT 1,
    FOREIGN KEY (CharacterID) REFERENCES Characters(CharacterID),
    FOREIGN KEY (ProfessionID) REFERENCES Professions(ProfessionID)
);

-- Guild_Events Table
CREATE TABLE Guild_Events (
    EventID NUMBER PRIMARY KEY,
    GuildID NUMBER NOT NULL,
    Name VARCHAR2(200) NOT NULL,
    EventDate DATE,
    FOREIGN KEY (GuildID) REFERENCES Guilds(GuildID)
);

