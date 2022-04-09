-- . List of restaurants included in the research filter by ['' | category=string | city=string]

SELECT r.name, r.category, r.city FROM restaurants AS r LIMIT 3;

SELECT r.name, r.category, r.city FROM restaurants AS r 
WHERE r.category = 'Italian' LIMIT 3;

