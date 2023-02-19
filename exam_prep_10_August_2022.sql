CREATE DATABASE NationalTouristSitesOfBulgaria

USE NationalTouristSitesOfBulgaria
--1
CREATE TABLE Categories
(
    Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Locations
(
    Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Municipality  VARCHAR(50),
	Province VARCHAR(50)
)

CREATE TABLE Sites
(
    Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(100) NOT NULL,
	LocationId INT NOT NULL FOREIGN KEY REFERENCES Locations(Id),
	CategoryId INT NOT NULL FOREIGN KEY REFERENCES Categories(Id),
	Establishment VARCHAR(15)
)

CREATE TABLE Tourists
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Age INT NOT NULL CHECK(Age BETWEEN 0 AND 120),
	PhoneNumber VARCHAR(20) NOT NULL,
	Nationality VARCHAR(30) NOT NULL,
	Reward VARCHAR(20)
)

CREATE TABLE SitesTourists
(
	TouristId INT NOT NULL FOREIGN KEY REFERENCES Tourists(Id),
	SiteId INT NOT NULL FOREIGN KEY REFERENCES Sites(Id)
	PRIMARY KEY(TouristId, SiteId)
)

CREATE TABLE BonusPrizes
(
    Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)
CREATE TABLE TouristsBonusPrizes
(
    TouristId INT NOT NULL FOREIGN KEY REFERENCES Tourists(Id),
	BonusPrizeId INT NOT NULL FOREIGN KEY REFERENCES BonusPrizes(Id)
	PRIMARY KEY(TouristId,BonusPrizeId)
)
--2

INSERT INTO Tourists 
VALUES	('Borislava Kazakova',	52,	'+359896354244',	'Bulgaria',	NULL),
		('Peter Bosh',	48,	'+447911844141',	'UK',	NULL),
		('Martin Smith',	29,	'+353863818592',	'Ireland',	'Bronze badge'),
		('Svilen Dobrev',	49,	'+359986584786',	'Bulgaria',	'Silver badge'),
		('Kremena Popova',	38,	'+359893298604',	'Bulgaria',	NULL)

INSERT INTO Sites
VALUES ('Ustra fortress',	90,	7,	'X'),
	   ('Karlanovo Pyramids',	65,	7,	NULL),
	   ('The Tomb of Tsar Sevt',	63,	8,	'V BC'),
	   ('Sinite Kamani Natural Park',	17,	1,	NULL),
	   ('St. Petka of Bulgaria – Rupite',	92,	6,	'1994')

--3
UPDATE Sites 
SET Establishment = '(not defined)'
WHERE Establishment IS NULL
--4
DECLARE @PrizeId INT =(SELECT Id FROM BonusPrizes WHERE [Name] = 'Sleeping bag') 
DELETE FROM TouristsBonusPrizes WHERE BonusPrizeId = @PrizeId
DELETE FROM BonusPrizes WHERE Id = @PrizeId
--5

SELECT 
[Name],
Age,
PhoneNumber,
Nationality
FROM Tourists
ORDER BY Nationality ASC, Age DESC, [Name] ASC

--6
SELECT 
s.[Name],
l.[Name],
Establishment,
c.[Name]
FROM Sites AS s
JOIN Locations AS l
ON l.Id = s.LocationId
JOIN Categories AS c
ON s.CategoryId = C.Id
ORDER BY c.[Name] DESC, l.[Name] ASC, s.[Name] ASC

--7
SELECT 
Province,
Municipality,
l.[Name] AS [Location],
COUNT(s.Id) AS CountOfSites
FROM Locations AS l
JOIN Sites AS s
ON s.LocationId = l.Id
WHERE Province = 'Sofia'
GROUP BY l.[Name], Municipality, Province
ORDER BY COUNT(s.Id) DESC, [Location] ASC
--8
SELECT 
s.[Name] AS [Site],
l.[Name] AS [Location],
Municipality,
Province,
Establishment
FROM Sites AS s
JOIN Locations AS l
ON l.Id = s.LocationId
WHERE LEFT(l.[Name],1) NOT IN('B', 'M', 'D') AND 
Establishment LIKE '%BC'
ORDER BY s.[Name] ASC
--9
SELECT 
t.[Name],
Age,
PhoneNumber,
Nationality,
ISNULL(bp.[Name],'(no bonus prize)') AS Reward
FROM Tourists AS t
LEFT JOIN TouristsBonusPrizes AS tbp
ON tbp.TouristId = t.Id
LEFT JOIN BonusPrizes AS bp
ON bp.Id = tbp.BonusPrizeId
ORDER BY t.[Name] ASC
--10
SELECT 
DISTINCT
RIGHT(t.[Name], CHARINDEX(' ', REVERSE(' ' + t.[Name])) - 1) AS LastName,
Nationality,
Age,
PhoneNumber
FROM Tourists AS t
JOIN SitesTourists AS st
ON st.TouristId = t.Id
JOIN Sites AS s
ON s.Id = st.SiteId
JOIN Categories AS c
ON c.Id = s.CategoryId
WHERE c.[Name] = 'History and archaeology'
ORDER BY LastName ASC
--11

CREATE FUNCTION udf_GetTouristsCountOnATouristSite (@Site VARCHAR(50))
RETURNS INT
AS 
BEGIN

	DECLARE @SiteId INT = (SELECT Id FROM Sites WHERE [Name] = @Site)

	RETURN	(SELECT COUNT(Id)
			FROM Sites AS s
			JOIN SitesTourists AS st ON
			st.SiteId = s.Id
			WHERE st.SiteId = @SiteId)
END

SELECT dbo.udf_GetTouristsCountOnATouristSite ('Regional History Museum – Vratsa')
SELECT dbo.udf_GetTouristsCountOnATouristSite ('Samuil’s Fortress')
SELECT dbo.udf_GetTouristsCountOnATouristSite ('Gorge of Erma River')
--12

CREATE PROCEDURE usp_AnnualRewardLottery(@TouristName VARCHAR(50))
	AS
	BEGIN
		
		DECLARE @TouristId INT = ( SELECT Id FROM Tourists WHERE [Name] = @TouristName) 
		SELECT 
		@TouristName AS [Name],
		CASE 
			WHEN COUNT(SiteId) >= 100 THEN 'Gold badge'
			WHEN COUNT(SiteId) >= 50 THEN 'Silver badge'
			WHEN COUNT(SiteId) >= 25 THEN 'Silver badge'
		END AS Reward
		FROM SitesTourists
		WHERE TouristId = @TouristId
		
	END

	EXEC usp_AnnualRewardLottery 'Gerhild Lutgard'