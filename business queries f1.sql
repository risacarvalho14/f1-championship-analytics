
--Question 1: How many races have there been per decade?
SELECT
    (year / 10) * 10 AS decade,
    COUNT(*) AS total_races
FROM races
GROUP BY (year / 10) * 10
ORDER BY decade;

--Qn2. Which circuit has hosted most of the races?
Select r.circuit_id,count(r.circuit_id) as total_circuit,c.name
FROM races r
INNER JOIN circuits c 
ON r.circuit_id = c.circuit_id
GROUP BY (r.circuit_id),(c.name)
ORDER BY total_circuit DESC;

--Qn3. Which driver has the most race wins (finishing in position 1) all-time?
SELECT TOP 10 WITH TIES
    d.driver_id,
    CONCAT(d.forename, ' ', d.surname) AS driver_name,
    COUNT(*) AS total_wins
FROM results AS r
INNER JOIN drivers AS d
    ON r.driver_id = d.driver_id
WHERE r.position = 1
GROUP BY
    d.driver_id,
    d.forename,
    d.surname
ORDER BY total_wins DESC;

--Qn4. Which constructor has the most race wins all-time?
SELECT TOP 10 WITH TIES
    c.constructor_id,c.name,c.constructor_ref,c.nationality,
    COUNT(*) AS total_wins
FROM constructors AS c
INNER JOIN results AS r
    ON c.constructor_id = r.constructor_id
WHERE r.position = 1
GROUP BY c.constructor_id,c.name,c.constructor_ref,c.nationality
ORDER BY total_wins DESC;

-- Qn.5 List the top 10 drivers by total career points
SELECT TOP 10
    d.driver_id,
    CONCAT(d.forename,' ',d.surname) as full_name,
    d.nationality,
    SUM(r.points) AS total_career_points
FROM results AS r
INNER JOIN drivers AS d
    ON r.driver_id = d.driver_id
GROUP BY
    d.driver_id,
    d.forename,
    d.surname,
    d.nationality
ORDER BY total_career_points DESC;

--Q6 Which country (via circuits) has hosted the most F1 races?
select c.country,COUNT(*) AS total_races
from races r 
INNER JOIN circuits c 
ON r.circuit_id = c.circuit_id
GROUP BY c.country
ORDER BY total_races DESC;

--Qn7. What's the average number of laps completed per race, and has it changed over the decades?
SELECT (r.year/10)*10 as decade, AVG(laps) as avg_laps
from races r
INNER JOIN results r1
ON r.race_id = r1.race_id
GROUP BY (r.year/10)*10
ORDER BY (year/10)*10

--Qn8.Which drivers have started from pole position (grid = 1) most often?
select * from results 
select * from drivers 