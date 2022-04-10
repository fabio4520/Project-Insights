"1. List of restaurants included in the research filter by ['' | category=string | city=string]"
select category, city
from restaurants;

"2. List of unique dishes included in the research"
select *
from dishes;

"3. Number and distribution (%) of clients by [group=[age | gender | occupation | nationality]]"
"by gender"
select age, count(age), round((count(age)/(round((select count(*) from clients),2))),2)*100 as score
from clients
group by age
order by age;

select age, count(age), ((count(age)/(select count(*) from clients)::float)*100) score
from clients
group by age
order by age;

"4. Top 10 restaurants by the number of visitors."

"8. The total sales of all the restaurants group by month [order=[asc | desc]]"
SELECT CONCAT('$',SUM(p.price_number)) total_sales, r.name AS restaurant_name 
FROM restaurants AS r
JOIN restaurants_dishes AS rd ON r.id = rd.restaurant_id
JOIN dishes AS d ON d.id = rd.dish_id
JOIN prices AS p ON d.id = p.dish_id
group by r.name order by total_sales;


select r.name, sum(price_number) as total_sales
from restaurants as r
inner join restaurants_dishes as rd on r.id = rd.restaurant_id
inner join dishes as d on d.id = rd.dish_id
inner join prices as p on p.dish_id = d.id
group by r.name
order by total_sales;

select r.name
from restaurants as r
inner join restaurants_dishes as rd on r.id = rd.restaurant_id
inner join dishes as d on d.id = rd.dish_id
inner join prices as p on p.dish_id = d.id
inner join restaurants_clients as rc on rc.restaurant_id = r.id
inner join clients as c on c.id = rc.client_id
inner join visit_dates as vd on c.id = vd.client_id;


select r.name
from restaurants_clients as rc
inner join restaurants as r on r.id = rc.restaurant_id
inner join restaurants_dishes as rd on rd.restaurant_id = r.id
inner join dishes as d on d.id = rd.dish_id
inner join prices as p on p.dish_id = d.id
inner join restaurants_clients as rc on rc.restaurant_id = r.id;

select visit_date, price_number
from visit_dates as vd
inner join clients as c on c.id = vd.client_id
inner join restaurants_clients as rc on c.id = rc.client_id
inner join restaurants as r on r.id = rc.restaurant_id
inner join restaurants_dishes as rd on r.id = rd.restaurant_id
inner join dishes as d on d.id = rd.dish_id
inner join prices as p on p.dish_id = d.id;


inner join restaurants_clients as rc on rc.restaurant_id = r.id
inner join clients as c on c.id = rc.client_id;
inner join 

select extract( MONTH FROM vd.visit_date) as MONTH, sum(price_number) as total_sales
from visit_dates as vd
inner join clients as c on vd.client_id = c.id
inner join restaurants_clients as rc on rc.id = c.id
inner join restaurants as r on rc.restaurant_id = r.id
inner join restaurants_dishes as rd on r.id = rd.restaurant_id
inner join dishes as d on d.id = rd.dish_id
inner join prices as p on p.dish_id = d.id
group by MONTH
order by MONTH;



select r.name
from restaurants_clients as rc 
inner join restaurants as r on rc.restaurant_id = r.id
inner join restaurants_dishes as rd on r.id = rd.restaurant_id
inner join dishes as d on d.id = rd.dish_id
inner join prices as p on p.dish_id = d.id