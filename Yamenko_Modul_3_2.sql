--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.
select 
	customer_id, first_name, last_name, address, city, country
from
	customer
left join (
				select address_id, address, city, country 
				from address
				left join (
							select country, city, city_id
							from city
							left join country on city.country_id = country.country_id) as CT 
							on CT.city_id = address.city_id) as addr 
				on addr.address_id=customer.address_id;

--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.

select store_id, count(store_id) 
from customer group by store_id;



--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
select store_id, count(store_id)
from customer group by store_id having count(store_id) > 300;




-- Доработайте запрос, добавив в него информацию о городе магазина, 
-- а также фамилию и имя продавца, который работает в этом магазине.

select store_id, city, staff_first_name, staff_last_name, count(store_id)
	from customer 
	left join 
		(select store_id, city, first_name staff_first_name, last_name staff_last_name
		from staff			
		right join 
					(select city, manager_staff_id 
					from store
					left join (
							select address_id, city
							from address 
							left join city 
							using (city_id)) as address_city 
					using(address_id)) as address_store 
		on address_store.manager_staff_id = staff.staff_id) as address_store_manager
	using(store_id)
GROUP by store_id, city, staff_first_name, staff_last_name having count(store_id) > 300;

--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
select customer_id, count(customer_id), first_name, last_name 
from rental
left join customer using(customer_id)
group by customer_id, first_name, last_name order by count(customer_id) desc limit 5;


--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
--добавим стоимость фильмов к таблице для расчетов и выведем окончательную таблицу

select p.customer_id, count(p.customer_id), round(sum(p.amount)), min(p.amount), max (p.amount)
from payment p
left join rental r using(rental_id) 
left join inventory i using (inventory_id)
left join film f using (film_id)
group by p.customer_id
order by round desc;

--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
--чтобы в результате не было пар с одинаковыми названиями городов. 
--Для решения необходимо использовать декартово произведение.
 
select a.city, b.city
from city a
cross join city b
where a.city <> b.city;

--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
 
select customer_id, avg(return_date - rental_date) as using_date
from rental
group by customer_id
order by using_date desc;



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.

select film_id, count(film_id), sum(p.amount) 
from film f
left join inventory i using (film_id)
left join rental r using (inventory_id)
left join payment p using (rental_id)
where payment_id is not null
group by film_id 
order by sum desc
;


--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.

select * 
from film f
left join inventory i using (film_id)
left join rental r using (inventory_id)
left join payment p using (rental_id)
where payment_id is null
;

--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".
select staff_id, count(staff_id),
case 
	when count(staff_id) > 7300 then 'да'
	else 'нет'
end as Премия
from payment
group by staff_id;





