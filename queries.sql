-- . List of restaurants included in the research filter by ['' | category=string | city=string]

SELECT age, COUNT(age), concat( round(( count(age) * 100.0 / (select count(*) from clients)),2), ' % ')
FROM clients
GROUP BY age ORDER BY age ASC;




SELECT d.name, MIN(p.price_number) as Lowest_price, r.name
FROM dishes AS d
JOIN restaurants_dishes AS rd ON rd.dish_id = d.id
JOIN restaurants AS r ON r.id = rd.restaurant_id
JOIN prices AS p ON d.id = p.dish_id
GROUP BY d.name;


SELECT CONCAT('$',SUM(p.price_number)) total_sales, r.name AS restaurant_name 
FROM restaurants AS r
JOIN restaurants_dishes AS rd ON r.id = rd.restaurant_id
JOIN dishes AS d ON d.id = rd.dish_id
JOIN prices AS p ON d.id = p.dish_id
group by r.name order by total_sales ASC;