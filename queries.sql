




SELECT r.restaurant_name, SUM(d.price) AS sales
FROM restaurants_clients AS c
JOIN restaurants AS r ON c.restaurant_id = r.id
JOIN dishes AS d ON c.dish_id = d.id
GROUP BY r.restaurant_name
ORDER BY sales DESC
LIMIT 10;










select c.age, avg(d.price) as avg_expense from clients as c
join restaurants_clients as rc on rc.client_id = c.id
join dishes as d on d.id = rc.dish_id
group by c.age;



select age, d.price from clients as c
join restaurants_clients as rc on rc.client_id = c.id
join dishes as d on d.id = rc.dish_id
join restaurants as r on r.id = rc.restaurant_id
group by age, d.price order by age asc;