-- . List of restaurants included in the research filter by ['' | category=string | city=string]

select gender, ROUND(AVG(p.price_number),2) from clients as c
join restaurants_clients as rc on c.id = rc.client_id
join restaurants as r on rc.restaurant_id = r.id
join restaurants_dishes as rd on r.id = rd.restaurant_id
join dishes as d on d.id = rd.dish_id
join prices as p on d.id = p.dish_id
group by gender ;







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

-- 8. The total sales of all the restaurants group by month [order=[asc | desc]]
select extract( month from vd.visit_date) as month, sum(p.price_number) from visit_dates as vd
join clients as c on c.id = vd.client_id
join restaurants_clients as rc on c.id = rc.client_id
join restaurants as r on rc.restaurant_id = r.id
join restaurants_dishes as rd on r.id = rd.restaurant_id
join dishes as d on d.id = rd.dish_id
join prices as p on d.id = p.dish_id
group by month ;