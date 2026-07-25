/*==============================================================
Project: F1 Championship Analytics
Script: 02_load_data.sql
Purpose: Load CSVs into staging tables, then clean/insert into
         the real tables. Staging tables match CSV columns exactly.
         '\N' in the source data represents NULL.
==============================================================*/

USE f1;
GO

/* ---------- Clean slate: drop existing tables first ---------- */
IF OBJECT_ID('circuits_staging', 'U') IS NOT NULL DROP TABLE circuits_staging;
IF OBJECT_ID('circuits', 'U') IS NOT NULL DROP TABLE circuits;

/* ---------- Create real table ---------- */
CREATE TABLE circuits (
    circuit_id INT PRIMARY KEY,
    circuit_ref NVARCHAR(50),
    name NVARCHAR(100),
    location NVARCHAR(100),
    country NVARCHAR(50),
    lat DECIMAL(9,6),
    lng DECIMAL(9,6)
);

/* ---------- Create staging table (matches full CSV) ---------- */
CREATE TABLE circuits_staging (
    circuitId NVARCHAR(20),
    circuitRef NVARCHAR(50),
    name NVARCHAR(100),
    location NVARCHAR(100),
    country NVARCHAR(50),
    lat NVARCHAR(20),
    lng NVARCHAR(20),
    alt NVARCHAR(20),
    url NVARCHAR(255)
);

/* ---------- Load CSV into staging ---------- */
BULK INSERT circuits_staging
FROM 'C:\Users\carva\OneDrive\Desktop\Risa Data Projects\F1 Race Project\Data\circuits.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);

/* ---------- Check staging loaded correctly ---------- */
SELECT COUNT(*) AS staging_row_count FROM circuits_staging;

/* ---------- Clean + insert into real table ---------- */
INSERT INTO circuits (circuit_id, circuit_ref, name, location, country, lat, lng)
SELECT
    CAST(circuitId AS INT),
    circuitRef,
    name,
    location,
    country,
    TRY_CAST(NULLIF(lat, '\N') AS DECIMAL(9,6)),
    TRY_CAST(NULLIF(lng, '\N') AS DECIMAL(9,6))
FROM circuits_staging;

SELECT * FROM circuits;

/* ================= DRIVERS ================= */
IF OBJECT_ID('drivers_staging', 'U') IS NOT NULL DROP TABLE drivers_staging;
IF OBJECT_ID('drivers', 'U') IS NOT NULL DROP TABLE drivers;

CREATE TABLE drivers (
    driver_id INT PRIMARY KEY,
    driver_ref NVARCHAR(50),
    forename NVARCHAR(50),
    surname NVARCHAR(50),
    dob DATE,
    nationality NVARCHAR(50)
);

CREATE TABLE drivers_staging (
    driverId NVARCHAR(20), driverRef NVARCHAR(50), number NVARCHAR(10),
    code NVARCHAR(10), forename NVARCHAR(50), surname NVARCHAR(50),
    dob NVARCHAR(20), nationality NVARCHAR(50), url NVARCHAR(255)
);

BULK INSERT drivers_staging
FROM 'C:\Users\carva\OneDrive\Desktop\Risa Data Projects\F1 Race Project\Data\drivers.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='"', FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', CODEPAGE='65001', TABLOCK);

INSERT INTO drivers (driver_id, driver_ref, forename, surname, dob, nationality)
SELECT CAST(driverId AS INT), driverRef, forename, surname,
       TRY_CAST(NULLIF(dob, '\N') AS DATE), nationality
FROM drivers_staging;

/* ================= CONSTRUCTORS ================= */
IF OBJECT_ID('constructors_staging', 'U') IS NOT NULL DROP TABLE constructors_staging;
IF OBJECT_ID('constructors', 'U') IS NOT NULL DROP TABLE constructors;

CREATE TABLE constructors (
    constructor_id INT PRIMARY KEY,
    constructor_ref NVARCHAR(50),
    name NVARCHAR(100),
    nationality NVARCHAR(50)
);

CREATE TABLE constructors_staging (
    constructorId NVARCHAR(20), constructorRef NVARCHAR(50),
    name NVARCHAR(100), nationality NVARCHAR(50), url NVARCHAR(255)
);

BULK INSERT constructors_staging
FROM 'C:\Users\carva\OneDrive\Desktop\Risa Data Projects\F1 Race Project\Data\constructors.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='"', FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', CODEPAGE='65001', TABLOCK);

INSERT INTO constructors (constructor_id, constructor_ref, name, nationality)
SELECT CAST(constructorId AS INT), constructorRef, name, nationality
FROM constructors_staging;

/* ================= RACES (depends on circuits) ================= */
IF OBJECT_ID('races_staging', 'U') IS NOT NULL DROP TABLE races_staging;
IF OBJECT_ID('races', 'U') IS NOT NULL DROP TABLE races;

CREATE TABLE races (
    race_id INT PRIMARY KEY,
    year INT,
    round INT,
    circuit_id INT FOREIGN KEY REFERENCES circuits(circuit_id),
    name NVARCHAR(100),
    date DATE
);

CREATE TABLE races_staging (
    raceId NVARCHAR(20), year NVARCHAR(10), round NVARCHAR(10), circuitId NVARCHAR(20),
    name NVARCHAR(100), date NVARCHAR(20), time NVARCHAR(20), url NVARCHAR(255),
    fp1_date NVARCHAR(20), fp1_time NVARCHAR(20), fp2_date NVARCHAR(20), fp2_time NVARCHAR(20),
    fp3_date NVARCHAR(20), fp3_time NVARCHAR(20), quali_date NVARCHAR(20), quali_time NVARCHAR(20),
    sprint_date NVARCHAR(20), sprint_time NVARCHAR(20)
);

BULK INSERT races_staging
FROM 'C:\Users\carva\OneDrive\Desktop\Risa Data Projects\F1 Race Project\Data\races.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='"', FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', CODEPAGE='65001', TABLOCK);

INSERT INTO races (race_id, year, round, circuit_id, name, date)
SELECT CAST(raceId AS INT), CAST(year AS INT), CAST(round AS INT), CAST(circuitId AS INT),
       name, TRY_CAST(NULLIF(date, '\N') AS DATE)
FROM races_staging;

/* ================= RESULTS (depends on races, drivers, constructors) ================= */
IF OBJECT_ID('results_staging', 'U') IS NOT NULL DROP TABLE results_staging;
IF OBJECT_ID('results', 'U') IS NOT NULL DROP TABLE results;

CREATE TABLE results (
    result_id INT PRIMARY KEY,
    race_id INT FOREIGN KEY REFERENCES races(race_id),
    driver_id INT FOREIGN KEY REFERENCES drivers(driver_id),
    constructor_id INT FOREIGN KEY REFERENCES constructors(constructor_id),
    grid INT,
    position INT,
    points DECIMAL(6,2),
    laps INT,
    status_id INT
);

CREATE TABLE results_staging (
    resultId NVARCHAR(20), raceId NVARCHAR(20), driverId NVARCHAR(20), constructorId NVARCHAR(20),
    number NVARCHAR(10), grid NVARCHAR(10), position NVARCHAR(10), positionText NVARCHAR(10),
    positionOrder NVARCHAR(10), points NVARCHAR(10), laps NVARCHAR(10), time NVARCHAR(20),
    milliseconds NVARCHAR(20), fastestLap NVARCHAR(10), rank NVARCHAR(10),
    fastestLapTime NVARCHAR(20), fastestLapSpeed NVARCHAR(20), statusId NVARCHAR(20)
);

BULK INSERT results_staging
FROM 'C:\Users\carva\OneDrive\Desktop\Risa Data Projects\F1 Race Project\Data\results.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='"', FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', CODEPAGE='65001', TABLOCK);

INSERT INTO results (result_id, race_id, driver_id, constructor_id, grid, position, points, laps, status_id)
SELECT CAST(resultId AS INT), CAST(raceId AS INT), CAST(driverId AS INT), CAST(constructorId AS INT),
       TRY_CAST(NULLIF(grid, '\N') AS INT), TRY_CAST(NULLIF(position, '\N') AS INT),
       TRY_CAST(NULLIF(points, '\N') AS DECIMAL(6,2)), TRY_CAST(NULLIF(laps, '\N') AS INT),
       CAST(statusId AS INT)
FROM results_staging;

/* ================= STATUS ================= */
IF OBJECT_ID('status_staging', 'U') IS NOT NULL DROP TABLE status_staging;
IF OBJECT_ID('status', 'U') IS NOT NULL DROP TABLE status;

CREATE TABLE status (
    status_id INT PRIMARY KEY,
    status NVARCHAR(100)
);

CREATE TABLE status_staging (
    statusId NVARCHAR(20), status NVARCHAR(100)
);

BULK INSERT status_staging
FROM 'C:\Users\carva\OneDrive\Desktop\Risa Data Projects\F1 Race Project\Data\status.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='"', FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', CODEPAGE='65001', TABLOCK);

INSERT INTO status (status_id, status)
SELECT CAST(statusId AS INT), status FROM status_staging;

/* ================= Verify everything loaded ================= */
SELECT 'circuits' AS tbl, COUNT(*) AS row_count FROM circuits
UNION ALL SELECT 'drivers', COUNT(*) FROM drivers
UNION ALL SELECT 'constructors', COUNT(*) FROM constructors
UNION ALL SELECT 'status', COUNT(*) FROM status
UNION ALL SELECT 'races', COUNT(*) FROM races
UNION ALL SELECT 'results', COUNT(*) FROM results;