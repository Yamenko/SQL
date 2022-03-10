--=============== Итоговая =======================================
--======== 1. В каких городах больше одного аэропорта? ===========

select  city ->> 'en' as city_air
FROM airports_data
group by city_air
HAVING count(city ->> 'en') > 1
; 
-- Из таблицы Аэропортов поулчаем города,
-- Группируем их по названию и пересчитываем
-- выводим только те которые больше одного


--======== 2. В каких аэропортах есть рейсы, выполняемые ==========
--======== самолетом с максимальной дальностью перелета? ==========

select distinct arrival_airport
from flights
where aircraft_code = (
						select aircraft_code
						from aircrafts_data
						order by range desc
						limit 1
						)
;

-- В Подзапросе из таблицы данных о самолетах
-- получаем код самолета с максимальной дальностью
-- отсортировав по убыванию и оставив только одно значение
-- В основном запросе из таблицы перелетов ищем аэропорты отправления
-- с этим кодом самолетов
-- оставляем только уникальные значения 

--======== 3. Вывести 10 рейсов с максимальным =====================
--======== временем задержки вылета ================================

select flight_id, (actual_departure - scheduled_departure) as dif
from flights
where actual_departure is not null 
order by dif desc 
limit 10
;

-- Из таблицы перелетов получаем данные о плановом и актуальном времени вылета
-- Сортируем по убыванию
-- Оставляем только первые 10

--======== 4. Были ли брони, по которым не были ===================
--======== получены посадочные талоны? ============================

select *
from tickets
left join boarding_passes using (ticket_no)
where seat_no is NULL
;

-- К таблице всех биетов добавляем полученные талоны
-- оставляем только те в которых место равно NULL
-- тоесть не присвоено место данному билету 

--======== 5. Найдите свободные места для каждого рейса, ============
--======== их % отношение к общему количеству мест в самолете. ======
--======== Добавьте столбец с накопительным итогом - ================
--======== суммарное накопление количества вывезенных пассажиров ====
--======== из каждого аэропорта на каждый день. Т.е. в этом столбце =
--======== должна отражаться накопительная сумма - сколько человек ==
--======== уже вылетело из данного аэропорта на этом ================
--======== или более ранних рейсах за день.==========================

with SBP as (
		select aircraft_code, count(aircraft_code) as all_seats_by_plane 
		from bookings.seats
		group by aircraft_code
),
info_by_flights as (
		select 	flight_id, 
				flight_no, 
				departure_airport, 
				aircraft_code,
				all_seats_by_plane,
				cast(flights.actual_departure as date) as actual_departure	
		from bookings.tickets
		left join bookings.ticket_flights using(ticket_no)
		left join bookings.flights using(flight_id)
		left join SBP using(aircraft_code)
),
count_passagers as (
	select flight_id, count(flight_id) as passagers
	from info_by_flights
	group by flight_id
)
select 	flight_no, 
		departure_airport, 
		(all_seats_by_plane - passagers) as empty_seats,
		round(((	cast (all_seats_by_plane 	as numeric) 
				- 	cast (passagers			 	as numeric)) * 100 
				/ 	cast (all_seats_by_plane 	as numeric)), 2) 
		as percen_t,
		actual_departure,
		passagers,
		sum(passagers) over (partition by actual_departure, departure_airport order by actual_departure, flight_id)
from info_by_flights
	left join count_passagers using(flight_id)
group by flight_id, 
		flight_no, 
		departure_airport, 
		all_seats_by_plane,
		actual_departure,
		passagers
;

-- Создаем сначала CTE-таблицы
-- 1. считаем кол-во мест для каждого типа самолетов
-- 2. Информация о всех перелетах
-- 3. Кол-во пассажиров на кажом рейсе
-- в общем запросе уже считаем необходимые данные
-- и добавляем кол-во пассажиров
-- в оконной функции считаем кол-во вылетевших пассажиров в день, нарастающим итогом по каждому аэропорту 


--======== 6. Найдите процентное соотношение перелетов ===============
--======== по типам самолетов от общего количества. ==================

select 	aircraft_code,  
		round(100 * cast(count(aircraft_code) as numeric)/(select cast(count(aircraft_code) as numeric) from flights), 2)			
from flights
group by aircraft_code
;

-- Группируем талицу по кодам самолетов и пересчитываем для каждого уникального
-- подзапросом получаем общее кол-во перелетов
-- получаем процент 


--======== 7. Были ли города, в которые можно добраться бизнес-классом
--======== дешевле, чем эконом-классом в рамках перелета? ============

with 
big_cte_tbl as (
	select fare_conditions, amount, flight_no, city->>'ru' as city
	from tickets
	left join ticket_flights using (ticket_no)
	left join flights using (flight_id)
	left join airports_data on airport_code = arrival_airport
),
cost_travel_Business as (	
	select fare_conditions, min(amount) as cost_fly, flight_no, city
	from big_cte_tbl
	where fare_conditions = 'Business'
	group by flight_no, city, fare_conditions
),
cost_travel_Economy as (	
	select fare_conditions, max(amount) as cost_fly, flight_no, city
	from big_cte_tbl
	where fare_conditions = 'Economy'
	group by flight_no, city, fare_conditions
)
select *
from cost_travel_Business
left join cost_travel_Economy using (flight_no)
where cost_travel_Business.cost_fly < cost_travel_Economy.cost_fly
;

-- Создаем 3 таблицы CTE
-- Первая общая, последовательно добавляем к Таблице Билетов выкупленные билеты,
-- данные о билетах и аэропортах
-- Вторая балица - Получение минимальной цены для каждого рейса бизнес
-- третья таблица - Получение максимальной цены для каждого рейса эконом
-- основной запрос обхединение второй и третьей таблицы по условию 
-- Если выполниться условие то будет добавлена запись.
-- В данном случае - цена бизнеса ниже эконома.


--======== 8. Между какими городами нет прямых рейсов? ===============

with flight_and_sity as (
	select DISTINCT port1.city->>'en' as dep, port2.city->>'en' as arr
	from flights
	left join airports_data as port1 on port1.airport_code = departure_airport
	left join airports_data as port2 on port2.airport_code = arrival_airport
)
select port1.city->>'en' as dep, port2.city->>'en' as arr
from  airports_data port1
cross join airports_data port2
where port1.airport_code <> port2.airport_code
except 
select dep, arr
from flight_and_sity
order by dep, arr
;

-- Создаем СТЕ, в таблицу перелетов добавляем название городов вылета и прилета
-- Оставляем только уникальные значения для городов  
-- Делаем перекресное объединение 2х таблиц aircrafts_data (полей с названием городов)
-- Пары с одинаковыми городами не добавляем.
-- Исключаем пары городов из CTE таблицы.
-- Сортируем сначала по вылету потом по прилету.
