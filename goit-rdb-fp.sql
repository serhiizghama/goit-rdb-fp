
-- 1. Step
CREATE SCHEMA pandemic;
USE pandemic;
SELECT * FROM pandemic.infectious_cases;


-- 2. Step
SET SQL_SAFE_UPDATES = 0;

-- Створення таблиці країн
CREATE TABLE countries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity VARCHAR(255) NOT NULL UNIQUE,
    code VARCHAR(255) NOT NULL UNIQUE
);

-- Заповнюємо Code, там де він відсутній
UPDATE infectious_cases
SET Code = Entity
WHERE Code = '';

-- Заповнення таблиці країн з таблиці infectious_cases
INSERT INTO countries (entity, code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;

-- Додавання country_id як зовнішнього ключа
ALTER TABLE infectious_cases
ADD COLUMN country_id INT,
ADD FOREIGN KEY (country_id) REFERENCES countries(id) ON DELETE CASCADE;

-- Заповнення country_id
UPDATE infectious_cases ic
JOIN countries c ON ic.Entity = c.entity AND ic.Code = c.code
SET ic.country_id = c.id;

-- Видалення стовпців Entity і Code з infectious_cases
ALTER TABLE infectious_cases
DROP COLUMN Entity,
DROP COLUMN Code;

SET SQL_SAFE_UPDATES = 1;

-- 3. Step
use pandemic;

-- середнє, мінімальне, максимальне значення та сума для Number_rabies
SELECT 
    c.entity, 
    c.code, 
    AVG(ic.Number_rabies) AS avg_number_rabies, 
    MIN(ic.Number_rabies) AS min_number_rabies, 
    MAX(ic.Number_rabies) AS max_number_rabies, 
    SUM(ic.Number_rabies) AS sum_number_rabies
FROM 
    infectious_cases ic
JOIN 
    countries c ON ic.country_id = c.id
WHERE 
    ic.Number_rabies != '' AND ic.Number_rabies IS NOT NULL
GROUP BY 
    c.entity, c.code
ORDER BY 
    avg_number_rabies DESC
LIMIT 10;


-- 4. Step
use pandemic;

SELECT 
    ic.Year,
    -- Створюємо атрибут, що містить дату першого січня відповідного року
    CONCAT(ic.Year, '-01-01') AS first_january_date,
    
    -- Створюємо атрибут, що дорівнює поточній даті
    CURDATE() AS current_date_value,
    
    -- Створюємо атрибут, що обчислює різницю в роках між поточною датою і датою першого січня
    TIMESTAMPDIFF(YEAR, CONCAT(ic.Year, '-01-01'), CURDATE()) AS year_difference
FROM 
    infectious_cases ic;

-- 5. Step
DELIMITER $$

CREATE FUNCTION year_difference(input_year YEAR)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE first_january_date DATE;
    DECLARE years_diff INT;
    SET first_january_date = CONCAT(input_year, '-01-01');
    SET years_diff = TIMESTAMPDIFF(YEAR, first_january_date, CURDATE());
    RETURN years_diff;
END $$

DELIMITER ;