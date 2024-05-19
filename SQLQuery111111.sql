USE master;
GO
DROP DATABASE IF EXISTS Dota2;
GO
CREATE DATABASE Dota2;
GO
USE Dota2;
GO

-- Создание графовых таблиц узлов

-- Создание графовых таблиц узлов

CREATE TABLE Heroes (
    HeroID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    HeroName NVARCHAR(100) NOT NULL
) AS NODE;

CREATE TABLE Players (
    PlayerID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    PlayerName NVARCHAR(100) NOT NULL
) AS NODE;

CREATE TABLE Teams (
    TeamID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    TeamName NVARCHAR(100) NOT NULL
) AS NODE;

-- Создание графовых таблиц рёбер

CREATE TABLE PlayerHeroes  AS EDGE;

CREATE TABLE PlayerTeams  AS EDGE;

CREATE TABLE Matches  AS EDGE;

-- Заполнение таблиц узлов

INSERT INTO Heroes (HeroName) VALUES
('Invoker'),
('Juggernaut'),
('Crystal Maiden'),
('Phantom Assassin'),
('Pudge'),
('Axe'),
('Drow Ranger'),
('Storm Spirit'),
('Lion'),
('Sven');

INSERT INTO Players (PlayerName) VALUES
('N0tail'),
('Miracle-'),
('Dendi'),
('Arteezy'),
('SumaiL'),
('Puppey'),
('s4'),
('Iceiceice'),
('KuroKy'),
('Ana');

INSERT INTO Teams (TeamName) VALUES
('OG'),
('Team Secret'),
('Natus Vincere'),
('Evil Geniuses'),
('Alliance'),
('Fnatic'),
('Liquid'),
('PSG.LGD'),
('Virtus.pro'),
('TNC Predator');

INSERT INTO PlayerHeroes ($from_id, $to_id) VALUES
((SELECT $node_id FROM Players WHERE Playerid = 1), (SELECT $node_id FROM Heroes WHERE HeroName = 'Invoker')),
((SELECT $node_id FROM Players WHERE PlayerName = 'Miracle-'), (SELECT $node_id FROM Heroes WHERE HeroName = 'Juggernaut')),
((SELECT $node_id FROM Players WHERE PlayerName = 'Dendi'), (SELECT $node_id FROM Heroes WHERE HeroName = 'Crystal Maiden')),
((SELECT $node_id FROM Players WHERE PlayerName = 'Arteezy'), (SELECT $node_id FROM Heroes WHERE HeroName = 'Phantom Assassin')),
((SELECT $node_id FROM Players WHERE PlayerName = 'SumaiL'), (SELECT $node_id FROM Heroes WHERE HeroName = 'Pudge')),
((SELECT $node_id FROM Players WHERE PlayerName = 'Puppey'), (SELECT $node_id FROM Heroes WHERE HeroName = 'Axe')),
((SELECT $node_id FROM Players WHERE PlayerName = 's4'), (SELECT $node_id FROM Heroes WHERE HeroName = 'Drow Ranger')),
((SELECT $node_id FROM Players WHERE PlayerName = 'Iceiceice'), (SELECT $node_id FROM Heroes WHERE HeroName = 'Storm Spirit')),
((SELECT $node_id FROM Players WHERE PlayerName = 'KuroKy'), (SELECT $node_id FROM Heroes WHERE HeroName = 'Lion')),
((SELECT $node_id FROM Players WHERE PlayerName = 'Ana'), (SELECT $node_id FROM Heroes WHERE HeroName = 'Sven'));

-- Привязываем игроков к их командам
INSERT INTO PlayerTeams ($from_id, $to_id) VALUES
((SELECT $node_id FROM Players WHERE PlayerName = 'N0tail'), (SELECT $node_id FROM Teams WHERE TeamName = 'OG')),
((SELECT $node_id FROM Players WHERE PlayerName = 'Miracle-'), (SELECT $node_id FROM Teams WHERE TeamName = 'Liquid')),
((SELECT $node_id FROM Players WHERE PlayerName = 'Dendi'), (SELECT $node_id FROM Teams WHERE TeamName = 'Natus Vincere')),
((SELECT $node_id FROM Players WHERE PlayerName = 'Arteezy'), (SELECT $node_id FROM Teams WHERE TeamName = 'Evil Geniuses')),
((SELECT $node_id FROM Players WHERE PlayerName = 'SumaiL'), (SELECT $node_id FROM Teams WHERE TeamName = 'Evil Geniuses')),
((SELECT $node_id FROM Players WHERE PlayerName = 'Puppey'), (SELECT $node_id FROM Teams WHERE TeamName = 'Team Secret')),
((SELECT $node_id FROM Players WHERE PlayerName = 's4'), (SELECT $node_id FROM Teams WHERE TeamName = 'Alliance')),
((SELECT $node_id FROM Players WHERE PlayerName = 'Iceiceice'), (SELECT $node_id FROM Teams WHERE TeamName = 'Fnatic')),
((SELECT $node_id FROM Players WHERE PlayerName = 'KuroKy'), (SELECT $node_id FROM Teams WHERE TeamName = 'Liquid')),
((SELECT $node_id FROM Players WHERE PlayerName = 'Ana'), (SELECT $node_id FROM Teams WHERE TeamName = 'OG'));

-- Заполнение таблицы Matches
INSERT INTO Matches ($from_id, $to_id) VALUES
((SELECT $node_id FROM Teams WHERE TeamName = 'OG'), (SELECT $node_id FROM Teams WHERE TeamName = 'Team Secret')),
((SELECT $node_id FROM Teams WHERE TeamName = 'Natus Vincere'), (SELECT $node_id FROM Teams WHERE TeamName = 'Evil Geniuses')),
((SELECT $node_id FROM Teams WHERE TeamName = 'Alliance'), (SELECT $node_id FROM Teams WHERE TeamName = 'Fnatic')),
((SELECT $node_id FROM Teams WHERE TeamName = 'Liquid'), (SELECT $node_id FROM Teams WHERE TeamName = 'PSG.LGD')),
((SELECT $node_id FROM Teams WHERE TeamName = 'Virtus.pro'), (SELECT $node_id FROM Teams WHERE TeamName = 'TNC Predator')),
((SELECT $node_id FROM Teams WHERE TeamName = 'OG'), (SELECT $node_id FROM Teams WHERE TeamName = 'Natus Vincere')),
((SELECT $node_id FROM Teams WHERE TeamName = 'Team Secret'), (SELECT $node_id FROM Teams WHERE TeamName = 'Evil Geniuses')),
((SELECT $node_id FROM Teams WHERE TeamName = 'Alliance'), (SELECT $node_id FROM Teams WHERE TeamName = 'Liquid')),
((SELECT $node_id FROM Teams WHERE TeamName = 'Fnatic'), (SELECT $node_id FROM Teams WHERE TeamName = 'PSG.LGD')),
((SELECT $node_id FROM Teams WHERE TeamName = 'Virtus.pro'), (SELECT $node_id FROM Teams WHERE TeamName = 'OG'));




------------------------------------------------

SELECT p1.PlayerName, t.TeamName
FROM Players AS p1, PlayerTeams AS pt, Teams AS t
WHERE MATCH(p1-(pt)->t);

SELECT t1.TeamName, t2.TeamName AS [MatchID]
FROM Teams AS t1, Matches AS m, Teams AS t2
WHERE MATCH(t1-(m)->t2)
AND t1.TeamName = N'Team Secret';

SELECT p.PlayerName, h.HeroName
FROM Players AS p, PlayerHeroes AS ph, Heroes AS h
WHERE MATCH(p-(ph)->h)
GROUP BY p.PlayerName, h.HeroName
ORDER BY COUNT(*) DESC;

SELECT p.PlayerName, h.HeroName
FROM Players AS p, PlayerTeams AS pt, Teams AS t, PlayerHeroes AS ph, Heroes AS h
WHERE MATCH(p-(pt)->t) AND t.TeamName = 'OG'
AND MATCH(p-(ph)->h);

SELECT p.PlayerName, t2.TeamName AS Opponent
FROM Players AS p, PlayerTeams AS pt, Teams AS t, Matches AS m, Teams AS t2
WHERE MATCH(p-(pt)->t) AND t.TeamName = 'Team Secret'
AND MATCH(t-(m)->t2);

---------------------------------

WITH RecursivePath AS (
    SELECT p1.$node_id AS Player1ID, p2.$node_id AS Player2ID, 0 AS CommonHeroes
    FROM Players AS p1, Players AS p2
    WHERE p1.$node_id <> p2.$node_id
    UNION ALL
    SELECT r.Player1ID, r.Player2ID, CommonHeroes + 1
    FROM RecursivePath AS r
    JOIN PlayerHeroes AS ph1 ON r.Player1ID = ph1.$from_id
    JOIN PlayerHeroes AS ph2 ON r.Player2ID = ph2.$from_id AND ph1.$to_id = ph2.$to_id
)
SELECT p1.PlayerName AS Player1, p2.PlayerName AS Player2, MIN(CommonHeroes) AS CommonHeroes
FROM RecursivePath AS r
JOIN Players AS p1 ON r.Player1ID = p1.$node_id
JOIN Players AS p2 ON r.Player2ID = p2.$node_id
GROUP BY p1.PlayerName, p2.PlayerName;

WITH RecursivePath AS (
    SELECT t1.$node_id AS Team1ID, t2.$node_id AS Team2ID, 0 AS CommonPlayers
    FROM Teams AS t1, Teams AS t2
    WHERE t1.$node_id <> t2.$node_id
    UNION ALL
    SELECT r.Team1ID, r.Team2ID, CommonPlayers + 1
    FROM RecursivePath AS r
    JOIN PlayerTeams AS pt1 ON r.Team1ID = pt1.$from_id
    JOIN PlayerTeams AS pt2 ON r.Team2ID = pt2.$from_id AND pt1.$to_id = pt2.$to_id
)
SELECT t1.TeamName AS Team1, t2.TeamName AS Team2, MIN(CommonPlayers) AS CommonPlayers
FROM RecursivePath AS r
JOIN Teams AS t1 ON r.Team1ID = t1.$node_id
JOIN Teams AS t2 ON r.Team2ID = t2.$node_id
WHERE t1.TeamName = 'OG' AND t2.TeamName = 'Team Secret'
GROUP BY t1.TeamName, t2.TeamName;