		--������ �1
	/*
	1. ����� 2 �������:
			- ���������� ����������, �������� �������� count, ����� ��������� ������
			- ������
	2. �������� ����������� �� �������
	3. �������� �������, ��� ���-�� ���������� ������ ���� > 1, ��� ������ ������ ��� �������, � ������� ����� ������ ���������
	 */
select
	count(airport_code),
	city
from airports
group by city
having count(airport_code) > 1
				
		--������ �2
	/* 
	1. �����:
			- ��� ��������� (�������� distinct, ����� ������� ���������� ��������)
			- �������� ����������
			- ������ �������
			- ��������� ����� ������
	2. ����������� ������� ������ � ��������
	3. �������� �������, ����������� ��������� � ������� ������ � ������������ ���������� �����
	 */
select 
	distinct a.airport_code,
	a.airport_name,
	a2.model,
	a2."range"
from airports a 
join flights f on f.departure_airport=a.airport_code
join aircrafts a2 using(aircraft_code)
where "range"=(select max("range") from aircrafts)

		--������ �3 
	/*
1. ����� 2 �������
		- ����� �����
		- �������� ����� (����� ������ ������ �� ����������� �� ������������ ����� ������
2. �������� ������� not null ��� ��������, ����� ��������� ������������� ������
3. ������������ �������� �������� �� �������� � ��������
4. �������� �������� limit ��� ������ ��� 10 �� ���������
	 */
select 
	flight_no,
	(actual_departure - scheduled_departure) as delay
from flights
where (actual_departure - scheduled_departure) is not null	
order by delay desc
limit 10
	
		--������ �4
	/* 
	1. ����� 2 �������
		- ������ �����
		- ������ ���������� �������
	2. �������� ������� bookings, tickets, boarding_passes. ��� boarding_passes �������� left join, ����� ������� ����� ��� ���������� �������
	3 �������� ������� is null, ����� �������� ������ ����� ��� ���������� �������
	 */
select 
	b.book_ref,
	bp.boarding_no
from bookings b 
join tickets t using(book_ref)
left join boarding_passes bp using (ticket_no)
where bp.boarding_no is null

		--������ �6
	/* 
	1. ����� 2 �������
		- ���� ������� ��������
		- ���������� �����������
	2. �������� ���������� ������ ������ ������ (��������, �������� group by) �� ������ ���������� ������ ���� ������� (��������, ��������
		���������) � ������� �� 100. �������� �������� cast, ����� ���������� ��� ����� ��� ������ � ��������� ������
	3. ����������� �� ����� ������� ��������
	 */
select 
	aircraft_code,
	round(count(flight_id)/cast((select count(flight_id) from flights) as float)*100) as percentage
from flights f 
group by aircraft_code

		--������ �7
	/* 
	1. �������� 2 CTE
		- ������-�����
		- ������-�����
	2. ����� ������� � ��������, ����� �����, �� ������� �������, ��������� �������� ������� �������� distinct
	3. �������� � flights ������ ������� airports, cte_1, cte_2
	4. �������� �������, �� �������� ��������� ������, � ������� �����  ��������� ������ - ������� �������, ��� ������-������� � ������ ��������
	 */
with cte_1 as (
	select 
		flight_id, 
		fare_conditions,
		amount 
	from ticket_flights
	where fare_conditions='Economy'
	order by amount
	),
	cte_2 as (
	select 
		flight_id, 
		fare_conditions,
		amount 
	from ticket_flights
	where fare_conditions='Business'
	order by amount
	)
select 
	distinct a.city
from flights f
join cte_1 c1 using(flight_id)
join cte_2 c2 using(flight_id)
join airports a on f.arrival_airport=a.airport_code
where c2.amount<c1.amount
		
		--������ �8
     /*
      	� ������� �� ����, ����� � t_1 ������� ��� �������� �������� ����� �����������, ����� ����� �� ����,
      � t_2 ������� ��������, ����� ���� �� ����� ����. Distinct, ����� ������ ����������.
      	����������� �������� except, ����� �� t_1 ������ ����������� ���� �������, ����� �������� �������������� ������ �����
      */
create view t_1 as
select
	distinct a1.city as c1, a2.city as c2
from airports a1, airports a2
where a1.city<a2.city

create view t_2 as
select
	distinct departure_city, arrival_city 
from flights_v

Select * from t_1
Except
Select * from t_2

		--������ �9
	/*
	 1. ������ ������� �� ������� �����������, �������� �� ���������, � ����� ��������� ��������, ������������� ����� �� ���� ������.
	 2. ����������� ������ ������� aiports ��� ������� ������������, ����� � departure_airport � arrival_airport ���� ��������������� �� ����������.
	 3. ����������� ������� aircrafts ��� ������ ��������� ��������
	 4. ����� ����� ������ ���� ���������� � ������� �����������, ��������� ����� ����, ����������� ������� � ��������� �������� ��� ��������� ����������
	 */
with coordinates as (
	select 
		distinct r.departure_airport as da,
		r.departure_airport_name,
		a1.latitude as la1,
		a1.longitude as lo1,
		r.arrival_airport as aa,
		r.arrival_airport_name,
		a2.latitude as la2,
		a2.longitude as lo2,
		ac."range" as ran
	from routes r
	join airports a1 on r.departure_airport=a1.airport_code
	join airports a2 on r.arrival_airport=a2.airport_code
	join aircrafts ac using(aircraft_code)
)
select 
	da, aa,
	acos(sind(la1)*sind(la2)+cosd(la1)*cosd(la2)*cosd(lo1-lo2))*6371 as distance,
	ran
from coordinates