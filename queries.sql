-- 8. The total sales of all the restaurants group by month [order=[asc | desc]]
-- order = asc | desc
select sum(p.price_number) as total_sales, r.name as restaurant_name 
from restaurants as r
join restaurants_dishes as rd on r.id = rd.restaurant_id
join dishes as d on d.id = rd.dish_id
join prices as p on d.id = p.dish_id
group by r.name order by total_sales ASC;


-- 9. The list of dishes and the restaurant where you can find it at a lower price.
-- works but no list rest name
select d.name, min(p.price_number) from dishes as d
join restaurants_dishes as rd on rd.dish_id = d.id
join restaurants as r on r.id = rd.restaurant_id
join prices as p on d.id = p.dish_id
group by d.name;

-- 

-- having p.price_number = min(p.price_number);

-- 10. The favorite dish for [age=number | gender=string | occupation=string | nationality=string]

-- For AGE
select c.age, count(d.name), d.name from clients as c
join restaurants_clients as rc on rc.client_id = c.id
join restaurants as r on r.id = rc.restaurant_id
join restaurants_dishes as rd on r.id = rd.restaurant_id
join dishes as d on d.id = rd.dish_id
group by c.age, d.name
order by count(d.name);

select c.age, count(d.name), d.name from clients as c
left join restaurants_clients as rc on rc.client_id = c.id
left join restaurants as r on r.id = rc.restaurant_id
left join restaurants_dishes as rd on r.id = rd.restaurant_id
join dishes as d on d.id = rd.dish_id
where c.age = 150
group by c.age, d.name
order by count(d.name) desc limit 1;
