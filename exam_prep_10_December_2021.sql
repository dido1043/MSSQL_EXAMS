create database Airport
USE Airport
--1
CREATE TABLE Passengers
(
    Id INT PRIMARY KEY IDENTITY,
	FullName VARCHAR(100) UNIQUE NOT NULL,
	Email VARCHAR(50) UNIQUE NOT NULL
)
--Check
CREATE TABLE Pilots
(
    Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(30) UNIQUE NOT NULL,
	LastName VARCHAR(30) UNIQUE NOT NULL,
	Age TINYINT NOT NULL CHECK (Age >= 21 and Age <= 62),
	Rating FLOAT --check(Rating > 0.0 and Rating < 10.0)
)

CREATE TABLE AircraftTypes
(
	Id INT PRIMARY KEY IDENTITY,
	TypeName VARCHAR(30) UNIQUE NOT NULL
)

CREATE TABLE Aircraft
(
    Id INT PRIMARY KEY IDENTITY,
	Manufacturer VARCHAR(25) NOT NULL,
	Model VARCHAR(30) NOT NULL,
	[Year] INT NOT NULL,
	FlightHours INT,
	Condition CHAR(1) NOT NULL,
	TypeId INT NOT NULL FOREIGN KEY REFERENCES AircraftTypes (Id)
)

CREATE TABLE PilotsAircraft
(
	AircraftId INT NOT NULL FOREIGN KEY REFERENCES Aircraft (Id),
	PilotId INT NOT NULL FOREIGN KEY REFERENCES Pilots(Id),
	PRIMARY KEY(AircraftId, PilotId)
)

CREATE TABLE Airports
(
	Id INT PRIMARY KEY IDENTITY,
	AirportName VARCHAR(70) NOT NULL,
	Country VARCHAR(100) NOT NULL
)

CREATE TABLE FlightDestinations
(
    Id INT PRIMARY KEY IDENTITY,
	AirportId INT NOT NULL FOREIGN KEY REFERENCES Airports (Id),
	[Start] DATETIME NOT NULL,
	AircraftId INT NOT NULL FOREIGN KEY REFERENCES Aircraft (Id) ,
	PassengerId INT NOT NULL FOREIGN KEY REFERENCES Passengers(Id),
	TicketPrice DECIMAL(18,2) DEFAULT 15 NOT NULL
)
-- 2
INSERT INTO Passengers
SELECT 
 p.FirstName + ' '+ p.LastName AS FullName,
 P.FirstName + p.LastName + '@gmail.com' AS Email
FROM Pilots AS p
WHERE p.Id BETWEEN 5 AND 15
--3
UPDATE Aircraft
SET Condition = 'A'
WHERE Condition IN ('C', 'B')
AND (FlightHours IS NULL OR FlightHours <= 100)
AND [Year] >= 2013
--4
DELETE FROM FlightDestinations
WHERE PassengerId IN (
	SELECT Id 
	FROM Passengers
	WHERE LEN(FullName) <= 10
)

DELETE FROM Passengers
WHERE LEN(FullName) <= 10
--5
SELECT 
Manufacturer,
Model,
FlightHours,
Condition
FROM Aircraft
ORDER BY FlightHours DESC
--6
SELECT 
FirstName,
LastName,
Manufacturer,
Model,
FlightHours
FROM Pilots AS p
JOIN PilotsAircraft AS pa
ON p.Id = pa.PilotId
JOIN Aircraft AS a
ON pa.AircraftId = a.Id
WHERE FlightHours IS NOT NULL AND FlightHours < 304
ORDER BY FlightHours DESC, FirstName ASC

--7
SELECT 
TOP(20)
fd.Id,
fd.[Start],
p.FullName,
a.AirportName,
fd.TicketPrice
FROM FlightDestinations AS fd
JOIN Passengers AS p
ON p.Id = fd.PassengerId
JOIN Airports AS a
ON fd.AirportId = a.Id
WHERE DAY(fd.[Start]) % 2 = 0
ORDER BY TicketPrice DESC, AirportName ASC

-- 8
SELECT 
a.Id AS AircraftId,
Manufacturer,
FlightHours,
COUNT(fd.Id) AS FlightDestinationsCount,
AVG(TicketPrice) AS AvgPrice
FROM Aircraft AS a
JOIN FlightDestinations AS fd
ON fd.AircraftId = a.Id
GROUP BY a.Id,a.Manufacturer,a.FlightHours
HAVING COUNT(fd.Id) > 2
ORDER BY FlightDestinationsCount DESC, AircraftId ASC

--9
SELECT
FullName,
COUNT(a.Id) AS CountOfAircraft,
SUM(fd.TicketPrice) AS TotalPayed
FROM Passengers AS p
JOIN FlightDestinations AS fd
ON fd.PassengerId = p.Id
JOIN Aircraft AS a
ON a.Id = fd.AircraftId
WHERE FullName LIKE '_a%'
GROUP BY p.FullName
HAVING COUNT(a.Id) > 1
ORDER BY FullName ASC

--10
SELECT 
AirportName,
[Start] AS DayTime,
TicketPrice,
FullName,
Manufacturer,
Model
FROM FlightDestinations AS fd
JOIN Airports AS a
ON fd.AirportId = a.Id
JOIN Passengers AS p
ON p.Id = fd.PassengerId
JOIN Aircraft AS ac
ON ac.Id = fd.AircraftId
WHERE DATEPART(HOUR, Start) BETWEEN 6 AND 20 
AND TicketPrice > 2500
ORDER BY Model ASC

--11 ??
CREATE FUNCTION udf_FlightDestinationsByEmail(@email VARCHAR(100))
	RETURNS INT
	AS
	BEGIN
		DECLARE @passengerId INT = (SELECT Id FROM Passengers WHERE Email = @email)

	RETURN (
		SELECT COUNT(Id) 
		FROM FlightDestinations 
		WHERE Id = @passengerId
		GROUP BY PassengerId
		)
	END

	SELECT dbo.udf_FlightDestinationsByEmail('Montacute@gmail.com')

--12
CREATE PROCEDURE usp_SearchByAirportName
(@airportName VARCHAR(50))
AS 
SELECT 
AirportName,
p.FullName,
CASE
	WHEN TicketPrice <= 400 THEN 'Low'
	WHEN TicketPrice >= 401 AND TicketPrice <= 1500 THEN 'Medium'
	WHEN TicketPrice >= 1501 THEN 'High'
	END AS LevelOfTickerPrice,
ac.Manufacturer,
ac.Condition,
aType.TypeName
FROM Airports AS a
JOIN FlightDestinations AS fd
ON fd.AirportId = a.Id
JOIN Passengers AS p
ON p.Id = fd.PassengerId
JOIN Aircraft AS ac
ON ac.Id = fd.AircraftId
JOIN AircraftTypes AS aType
ON aType.Id = ac.TypeId
WHERE a.AirportName = @airportName
ORDER BY Manufacturer, FullName


EXEC usp_SearchByAirportName 'Sir Seretse Khama International Airport'