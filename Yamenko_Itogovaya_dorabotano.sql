--=============== �������� =======================================
--======== 1. � ����� ������� ������ ������ ���������? ===========

select  city ->> 'en' as city_air
FROM airports_data
group by city_air
HAVING count(city ->> 'en') > 1
; 
-- �� ������� ���������� �������� ������,
-- ���������� �� �� �������� � �������������
-- ������� ������ �� ������� ������ ������


--======== 2. � ����� ���������� ���� �����, ����������� ==========
--======== ��������� � ������������ ���������� ��������? ==========

select distinct arrival_airport
from flights
where aircraft_code = (
						select aircraft_code
						from aircrafts_data
						order by range desc
						limit 1
						)
;

-- � ���������� �� ������� ������ � ���������
-- �������� ��� �������� � ������������ ����������
-- ������������ �� �������� � ������� ������ ���� ��������
-- � �������� ������� �� ������� ��������� ���� ��������� �����������
-- � ���� ����� ���������
-- ��������� ������ ���������� �������� 

--======== 3. ������� 10 ������ � ������������ =====================
--======== �������� �������� ������ ================================

select flight_id, (actual_departure - scheduled_departure) as dif
from flights
where actual_departure is not null 
order by dif desc 
limit 10
;

-- �� ������� ��������� �������� ������ � �������� � ���������� ������� ������
-- ��������� �� ��������
-- ��������� ������ ������ 10

--======== 4. ���� �� �����, �� ������� �� ���� ===================
--======== �������� ���������� ������? ============================

select *
from tickets
left join boarding_passes using (ticket_no)
where seat_no is NULL
;

-- � ������� ���� ������ ��������� ���������� ������
-- ��������� ������ �� � ������� ����� ����� NULL
-- ������ �� ��������� ����� ������� ������ 

--======== 5. ������� ��������� ����� ��� ������� �����, ============
--======== �� % ��������� � ������ ���������� ���� � ��������. ======
--======== �������� ������� � ������������� ������ - ================
--======== ��������� ���������� ���������� ���������� ���������� ====
--======== �� ������� ��������� �� ������ ����. �.�. � ���� ������� =
--======== ������ ���������� ������������� ����� - ������� ������� ==
--======== ��� �������� �� ������� ��������� �� ���� ================
--======== ��� ����� ������ ������ �� ����.==========================

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

-- ������� ������� CTE-�������
-- 1. ������� ���-�� ���� ��� ������� ���� ���������
-- 2. ���������� � ���� ���������
-- 3. ���-�� ���������� �� ����� �����
-- � ����� ������� ��� ������� ����������� ������
-- � ��������� ���-�� ����������
-- � ������� ������� ������� ���-�� ���������� ���������� � ����, ����������� ������ �� ������� ��������� 


--======== 6. ������� ���������� ����������� ��������� ===============
--======== �� ����� ��������� �� ������ ����������. ==================

select 	aircraft_code,  
		round(100 * cast(count(aircraft_code) as numeric)/(select cast(count(aircraft_code) as numeric) from flights), 2)			
from flights
group by aircraft_code
;

-- ���������� ������ �� ����� ��������� � ������������� ��� ������� �����������
-- ����������� �������� ����� ���-�� ���������
-- �������� ������� 


--======== 7. ���� �� ������, � ������� ����� ��������� ������-�������
--======== �������, ��� ������-������� � ������ ��������? ============

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

-- ������� 3 ������� CTE
-- ������ �����, ��������������� ��������� � ������� ������� ����������� ������,
-- ������ � ������� � ����������
-- ������ ������ - ��������� ����������� ���� ��� ������� ����� ������
-- ������ ������� - ��������� ������������ ���� ��� ������� ����� ������
-- �������� ������ ����������� ������ � ������� ������� �� ������� 
-- ���� ����������� ������� �� ����� ��������� ������.
-- � ������ ������ - ���� ������� ���� �������.


--======== 8. ����� ������ �������� ��� ������ ������? ===============

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

-- ������� ���, � ������� ��������� ��������� �������� ������� ������ � �������
-- ��������� ������ ���������� �������� ��� �������  
-- ������ ����������� ����������� 2� ������ aircrafts_data (����� � ��������� �������)
-- ���� � ����������� �������� �� ���������.
-- ��������� ���� ������� �� CTE �������.
-- ��������� ������� �� ������ ����� �� �������.
