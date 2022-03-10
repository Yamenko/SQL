--=============== ������ 3. ������ SQL =======================================

--������� �1
--�������� ��� ������� ���������� ��� ����� ����������, 
--����� � ������ ����������.
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

--������� �2
--� ������� SQL-������� ���������� ��� ������� �������� ���������� ��� �����������.

select store_id, count(store_id) 
from customer group by store_id;



--����������� ������ � �������� ������ �� ��������, 
--� ������� ���������� ����������� ������ 300-��.
--��� ������� ����������� ���������� �� ��������������� ������� 
--� �������������� ������� ���������.
select store_id, count(store_id)
from customer group by store_id having count(store_id) > 300;




-- ����������� ������, ������� � ���� ���������� � ������ ��������, 
-- � ����� ������� � ��� ��������, ������� �������� � ���� ��������.

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

--������� �3
--�������� ���-5 �����������, 
--������� ����� � ������ �� �� ����� ���������� ���������� �������
select customer_id, count(customer_id), first_name, last_name 
from rental
left join customer using(customer_id)
group by customer_id, first_name, last_name order by count(customer_id) desc limit 5;


--������� �4
--���������� ��� ������� ���������� 4 ������������� ����������:
--  1. ���������� �������, ������� �� ���� � ������
--  2. ����� ��������� �������� �� ������ ���� ������� (�������� ��������� �� ������ �����)
--  3. ����������� �������� ������� �� ������ ������
--  4. ������������ �������� ������� �� ������ ������
--������� ��������� ������� � ������� ��� �������� � ������� ������������� �������

select p.customer_id, count(p.customer_id), round(sum(p.amount)), min(p.amount), max (p.amount)
from payment p
left join rental r using(rental_id) 
left join inventory i using (inventory_id)
left join film f using (film_id)
group by p.customer_id
order by round desc;

--������� �5
--��������� ������ �� ������� ������� ��������� ����� �������� ������������ ���� ������� ����� �������,
--����� � ���������� �� ���� ��� � ����������� ���������� �������. 
--��� ������� ���������� ������������ ��������� ������������.
 
select a.city, b.city
from city a
cross join city b
where a.city <> b.city;

--������� �6
--��������� ������ �� ������� rental � ���� ������ ������ � ������ (���� rental_date)
--� ���� �������� ������ (���� return_date), 
--��������� ��� ������� ���������� ������� ���������� ����, �� ������� ���������� ���������� ������.
 
select customer_id, avg(return_date - rental_date) as using_date
from rental
group by customer_id
order by using_date desc;



--======== �������������� ����� ==============

--������� �1
--���������� ��� ������� ������ ������� ��� ��� ����� � ������ � �������� ����� ��������� ������ ������ �� �� �����.

select film_id, count(film_id), sum(p.amount) 
from film f
left join inventory i using (film_id)
left join rental r using (inventory_id)
left join payment p using (rental_id)
where payment_id is not null
group by film_id 
order by sum desc
;


--������� �2
--����������� ������ �� ����������� ������� � �������� � ������� ������� ������, ������� �� ���� �� ����� � ������.

select * 
from film f
left join inventory i using (film_id)
left join rental r using (inventory_id)
left join payment p using (rental_id)
where payment_id is null
;

--������� �3
--���������� ���������� ������, ����������� ������ ���������. �������� ����������� ������� "������".
--���� ���������� ������ ��������� 7300, �� �������� � ������� ����� "��", ����� ������ ���� �������� "���".
select staff_id, count(staff_id),
case 
	when count(staff_id) > 7300 then '��'
	else '���'
end as ������
from payment
group by staff_id;





