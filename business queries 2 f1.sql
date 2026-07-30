--Qn1. Does qualifying position actually predict how a driver finishes the race?
SELECT
    CASE
        WHEN position IS NULL THEN 'DNF'
        WHEN position < grid THEN 'Gained places'
        WHEN position > grid THEN 'Lost places'
        ELSE 'Held position'
    END AS outcome,
    COUNT(*) AS total_results
FROM results
GROUP BY
    CASE
        WHEN position IS NULL THEN 'DNF'
        WHEN position < grid THEN 'Gained places'
        WHEN position > grid THEN 'Lost places'
        ELSE 'Held position'
    END
ORDER BY total_results DESC;

--Qn2.
USE f1;
GO

IF OBJECT_ID('pit_stops_staging', 'U') IS NOT NULL DROP TABLE pit_stops_staging;
IF OBJECT_ID('pit_stops', 'U') IS NOT NULL DROP TABLE pit_stops;

CREATE TABLE pit_stops (
    race_id INT FOREIGN KEY REFERENCES races(race_id),
    driver_id INT FOREIGN KEY REFERENCES drivers(driver_id),
    stop INT,
    lap INT,
    duration DECIMAL(6,3)
);

CREATE TABLE pit_stops_staging (
    raceId NVARCHAR(20), driverId NVARCHAR(20), stop NVARCHAR(10),
    lap NVARCHAR(10), time NVARCHAR(20), duration NVARCHAR(20), milliseconds NVARCHAR(20)
);
BULK INSERT pit_stops_staging
FROM 'C:\Users\carva\OneDrive\Desktop\Risa Data Projects\F1 Race Project\Data\pit_stops.csv'
WITH (FORMAT='CSV', FIRSTROW=2, FIELDQUOTE='"', FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', CODEPAGE='65001', TABLOCK);

INSERT INTO pit_stops (race_id, driver_id, stop, lap, duration)
SELECT CAST(raceId AS INT), CAST(driverId AS INT), CAST(stop AS INT), CAST(lap AS INT),
       TRY_CAST(NULLIF(duration, '\N') AS DECIMAL(6,3))
FROM pit_stops_staging;

SELECT COUNT(*) AS pit_stops_loaded FROM pit_stops;
SELECT
    p.race_id,
    p.driver_id,
    AVG(p.duration) AS avg_pit_duration,
    r.position AS finishing_position
FROM pit_stops p
INNER JOIN results r
    ON p.race_id = r.race_id AND p.driver_id = r.driver_id
GROUP BY p.race_id, p.driver_id, r.position
ORDER BY avg_pit_duration;

SELECT TOP 20 * FROM pit_stops;

SELECT * FROM pit_stops WHERE race_id = 1128 AND driver_id = 852;

SELECT
    p.race_id,
    p.driver_id,
    AVG(p.duration) AS avg_pit_duration,
    r.position AS finishing_position
FROM pit_stops p
INNER JOIN results r
    ON p.race_id = r.race_id AND p.driver_id = r.driver_id
WHERE p.duration IS NOT NULL
GROUP BY p.race_id, p.driver_id, r.position
ORDER BY avg_pit_duration;

WITH pit_summary AS (
    SELECT
        p.race_id,
        p.driver_id,
        AVG(p.duration) AS avg_pit_duration,
        r.position AS finishing_position
    FROM pit_stops p
    INNER JOIN results r
        ON p.race_id = r.race_id AND p.driver_id = r.driver_id
    WHERE p.duration IS NOT NULL
        AND r.position IS NOT NULL
    GROUP BY p.race_id, p.driver_id, r.position
)
SELECT
    CASE
        WHEN avg_pit_duration < 20 THEN 'Fast'
        WHEN avg_pit_duration < 30 THEN 'Medium'
        ELSE 'Slow'
    END AS pit_speed_bucket,
    AVG(finishing_position) AS avg_finishing_position,
    COUNT(*) AS total_driver_races
FROM pit_summary
GROUP BY
    CASE
        WHEN avg_pit_duration < 20 THEN 'Fast'
        WHEN avg_pit_duration < 30 THEN 'Medium'
        ELSE 'Slow'
    END
ORDER BY avg_finishing_position;

--Qn3. Rank constructors by points, within each season
Select * from results;
select * from constructors;
select * from races;
WITH constructor_season_points AS (
    SELECT
        r.year,
        c.name AS constructor_name,
        SUM(res.points) AS total_points
    FROM results res
    INNER JOIN races r
        ON res.race_id = r.race_id
    INNER JOIN constructors c
        ON res.constructor_id = c.constructor_id
    GROUP BY r.year, c.name
)
SELECT
    year,
    constructor_name,
    total_points,
    RANK() OVER (PARTITION BY year ORDER BY total_points DESC) AS season_rank
FROM constructor_season_points
ORDER BY year, season_rank;

--Qn.4 Running total of a driver's career points over time
select * from results;
select * from races;
select * from drivers;
SELECT
    r.year,
    r.round,
    d.forename,
    d.surname,
    res.points AS race_points,
    SUM(res.points) OVER (
        PARTITION BY res.driver_id
        ORDER BY r.year, r.round
    ) AS career_points_running_total
FROM results res
INNER JOIN races r
    ON res.race_id = r.race_id
INNER JOIN drivers d
    ON res.driver_id = d.driver_id
WHERE d.forename = 'Lewis' AND d.surname = 'Hamilton'
ORDER BY r.year, r.round;

--Qn.5 Which drivers have the best/worst DNF rate?
SELECT
    d.forename, d.surname,
    COUNT(*) AS total_races,
    SUM(CASE WHEN res.position IS NULL THEN 1 ELSE 0 END) AS total_dnfs,
    (SUM(CASE WHEN res.position IS NULL THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) * 100 AS dnf_rate_pct
FROM results res
INNER JOIN drivers d
    ON res.driver_id = d.driver_id
GROUP BY d.driver_id, d.forename, d.surname
HAVING COUNT(*) >= 20
ORDER BY dnf_rate_pct DESC;

--Qn6. Which constructors performs best  at which circuit ("Home turf effect")
select * from results;
select * from races;
select * from constructors;
select * from circuits;
SELECT
    c.name AS constructor_name,
    ci.name AS circuit_name,
    AVG(res.position * 1.0) AS avg_finishing_position,
    COUNT(*) AS total_races
FROM results res
INNER JOIN races r
    ON res.race_id = r.race_id
INNER JOIN circuits ci
    ON r.circuit_id = ci.circuit_id
INNER JOIN constructors c
    ON res.constructor_id = c.constructor_id
WHERE res.position IS NOT NULL
GROUP BY c.name, ci.name
HAVING COUNT(*) >= 5
ORDER BY avg_finishing_position ASC;