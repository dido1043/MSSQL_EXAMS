CREATE DATABASE Zoo

USE Zoo
--1
CREATE TABLE Owners
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	PhoneNumber VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50)
)

CREATE TABLE AnimalTypes
(
	Id INT PRIMARY KEY IDENTITY,
	AnimalType VARCHAR(30) NOT NULL
)

CREATE TABLE Cages
(
	Id INT PRIMARY KEY IDENTITY,
	AnimalTypeId INT NOT NULL FOREIGN KEY REFERENCES AnimalTypes (Id)
)
CREATE TABLE Animals
(
    Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	BirthDate DATE NOT NULL,
	OwnerId INT FOREIGN KEY REFERENCES Owners (Id),
	AnimalTypeId INT NOT NULL FOREIGN KEY REFERENCES AnimalTypes (Id)
)

CREATE TABLE AnimalsCages
(
	CageId INT NOT NULL FOREIGN KEY REFERENCES Cages(Id),
	AnimalId INT NOT NULL FOREIGN KEY REFERENCES Animals (Id)
	PRIMARY KEY(CageId, AnimalId)
)

CREATE TABLE VolunteersDepartments
(
	Id INT PRIMARY KEY IDENTITY,
	DepartmentName VARCHAR(30) NOT NULL
)

CREATE TABLE Volunteers
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	PhoneNumber VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50),
	AnimalId INT FOREIGN KEY REFERENCES Animals (Id),
	DepartmentId INT NOT NULL FOREIGN KEY REFERENCES VolunteersDepartments (Id)
)
--2
INSERT INTO Volunteers ([Name], PhoneNumber, [Address],AnimalId, DepartmentId)
VALUES  ('Anita Kostova', '0896365412',	'Sofia, 5 Rosa str.',15,1),
		('Dimitur Stoev',	'0877564223',	null,	42,	4),
		('Kalina Evtimova',	'0896321112', 'Silistra, 21 Breza str.', 9,	7),
		('Stoyan Tomov',	'0898564100',	'Montana, 1 Bor str.',	18,	8),
		('Boryana Mileva',	'0888112233',	null,	31,	5)
INSERT INTO Animals ([Name], BirthDate, OwnerId, AnimalTypeId)
VALUES	('Giraffe',	'2018-09-21',	21,	1),
		('Harpy Eagle',	'2015-04-17',	15,	3),
		('Hamadryas Baboon',	'2017-11-02',	null,	1),
		('Tuatara',	'2021-06-30',	2,	4)

--3
UPDATE Animals
SET OwnerId = (SELECT Id 
			   FROM Owners
			   WHERE [Name] = 'Kaloqn Stoqnov ') 
WHERE OwnerId IS NULL
--4
DECLARE @VolunteerDepartmentId INT = (
		SELECT Id 
		FROM VolunteersDepartments
		WHERE DepartmentName = 'Education program assistant'
)

DELETE FROM Volunteers WHERE DepartmentId = @VolunteerDepartmentId
DELETE FROM VolunteersDepartments WHERE Id = @VolunteerDepartmentId

--5
SELECT [Name],
		PhoneNumber,
		[Address],
		AnimalId,
		DepartmentId
FROM Volunteers
ORDER BY [Name] ASC,
		 AnimalId ASC,
		 DepartmentId DESC

--6
SELECT 
[Name],
[at].AnimalType,
FORMAT(BirthDate , 'dd.MM.yyyy') AS BirthDate
FROM Animals AS a
JOIN AnimalTypes AS [at]
ON [at].Id = a.AnimalTypeId
ORDER BY [Name]

--7
SELECT
TOP(5)
o.[Name] AS [Owner],
COUNT(a.Id) AS CountOfAnimals
FROM Owners AS o
JOIN Animals AS a
ON a.OwnerId = o.Id
GROUP BY o.[Name]
ORDER BY CountOfAnimals DESC, [Owner] ASC

--8
SELECT 
o.[Name] + '-' + a.[Name] AS 'OwnersAnimals',
o.PhoneNumber,
ac.CageId
FROM Owners AS o
JOIN Animals AS a
ON a.OwnerId = o.Id
JOIN AnimalsCages AS ac
ON ac.AnimalId = a.Id
WHERE AnimalTypeId = (SELECT Id FROM AnimalTypes WHERE AnimalType = 'mammals')
ORDER BY o.[Name] ASC, a.[Name] DESC
--9

SELECT
v.[Name],
v.PhoneNumber,
SUBSTRING(v.[Address],CHARINDEX(',', v.Address) + 2,LEN(v.Address) - CHARINDEX(',', v.Address)) AS [Address]
FROM Volunteers AS v
JOIN VolunteersDepartments AS vd
ON vd.Id = v.DepartmentId	
WHERE vd.DepartmentName = 'Education program assistant'  AND
v.[Address] LIKE '%Sofia%'
ORDER BY v.[Name] ASC

--10
SELECT 
	a.[Name],
	DATEPART(YEAR ,a.BirthDate) AS BirthYear,
	[at].AnimalType
FROM Animals AS a
JOIN AnimalTypes AS [at]
ON [at].Id = a.AnimalTypeId
WHERE
	a.OwnerId IS NULL
	AND AnimalType <> 'Birds'
	AND a.BirthDate >= '2018-01-01'
ORDER BY a.[Name]

--11
CREATE FUNCTION udf_GetVolunteersCountFromADepartment (@VolunteersDepartment VARCHAR(100))
RETURNS INT
AS
BEGIN
	DECLARE @DepartmentIDS INT = (
			SELECT Id FROM VolunteersDepartments WHERE DepartmentName = @VolunteersDepartment
	)
	RETURN (
			SELECT COUNT(*) 
			FROM Volunteers
			WHERE DepartmentId = @DepartmentIDS
	)
END

--12
CREATE PROCEDURE usp_AnimalsWithOwnersOrNot(@AnimalName VARCHAR(50))
AS 
SELECT 
a.[Name],
IIF(o.[Name] IS NULL, 'For adoption',o.[Name])
FROM Animals AS a
JOIN Owners AS o
ON a.OwnerId = o.Id
WHERE a.[Name] =  @AnimalName






