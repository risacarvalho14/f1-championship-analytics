/*==============================================================
Project: F1 Championship analytics
Script: 02_create_tables.sql
Purpose:
    Create the foundational SQL tables used to store
    Formula 1 circuit, driver, constructor, race and result data.
==============================================================*/

USE f1;
GO
CREATE TABLE circuits (
    circuit_id INT PRIMARY KEY,
    circuit_ref NVARCHAR(50),
    name NVARCHAR(100),
    location NVARCHAR(100),
    country NVARCHAR(50),
    lat DECIMAL(9,6),
    lng DECIMAL(9,6)
);

Select * from circuits;

CREATE TABLE drivers (
    driver_id INT PRIMARY KEY,
    driver_ref NVARCHAR(50),
    forename NVARCHAR(50),
    surname NVARCHAR(50),
    dob DATE,
    nationality NVARCHAR(50)
);

CREATE TABLE constructors (
    constructor_id INT PRIMARY KEY,
    constructor_ref NVARCHAR(50),
    name NVARCHAR(100),
    nationality NVARCHAR(50)
);

CREATE TABLE races (
    race_id INT PRIMARY KEY,
    year INT,
    round INT,
    circuit_id INT FOREIGN KEY REFERENCES circuits(circuit_id),
    name NVARCHAR(100),
    date DATE
);

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

CREATE TABLE status (
    status_id INT PRIMARY KEY,
    status NVARCHAR(100)
);