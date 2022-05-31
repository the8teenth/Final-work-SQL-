		--Задача №1
	/*
	1. Вывел 2 колонки:
			- количество аэропортов, применив оператор count, чтобы посчитать города
			- города
	2. Выполнил группировку по городам
	3. Прописал условие, что кол-во аэропортов должно быть > 1, для вывода только тех городов, в которых более одного аэропорта
	 */
select
	count(airport_code),
	city
from airports
group by city
having count(airport_code) > 1
				
		--Задача №2
	/* 
	1. Вывел:
			- код аэропорта (применив distinct, чтобы вывести уникальные значения)
			- название аэропортов
			- модель самолёта
			- дальность полёта модели
	2. Присоединил таблицы полётов и самолётов
	3. Прописал условие, использовав подзапрос – вывести модель с максимальной дальностью полёта
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

		--Задача №3 
	/*
1. Вывел 2 колонки
		- номер рейса
		- задержка рейса (вычел «Время вылета по расписанию» из «Фактическое время вылета»
2. Прописал условие not null для задержки, чтобы исключить своевременные вылеты
3. Отсортировал значения задержек от большего к меньшему
4. Применил оператор limit для выдачи топ 10 по задержкам
	 */
select 
	flight_no,
	(actual_departure - scheduled_departure) as delay
from flights
where (actual_departure - scheduled_departure) is not null	
order by delay desc
limit 10
	
		--Задача №4
	/* 
	1. Вывел 2 колонки
		- номера брони
		- номера посадочных талонов
	2. Соединил таблицы bookings, tickets, boarding_passes. Для boarding_passes применил left join, чтобы вывести брони без посадочных талонов
	3 Прописал условие is null, чтобы оставить только брони без посадочных талонов
	 */
select 
	b.book_ref,
	bp.boarding_no
from bookings b 
join tickets t using(book_ref)
left join boarding_passes bp using (ticket_no)
where bp.boarding_no is null

		--Задача №6
	/* 
	1. Вывел 2 колонки
		- коды моделей самолётов
		- процентное соотношение
	2. разделил количество полётов каждой модели (посчитал, применив group by) на общеее количество полётов всех моделей (посчитал, применив
		подзапрос) и умножил на 100. Применял оператор cast, чтобы установить для чисел тип данных с плавающей точкой
	3. Группировка по кодам моделей самолётов
	 */
select 
	aircraft_code,
	round(count(flight_id)/cast((select count(flight_id) from flights) as float)*100) as percentage
from flights f 
group by aircraft_code

		--Задача №7
	/* 
	1. Прописал 2 CTE
		- эконом-класс
		- бизнес-класс
	2. Вывел колонку с городами, чтобы город, по условию задания, выводился единожды добавил оператор distinct
	3. Соединил с flights другие таблицы airports, cte_1, cte_2
	4. Прописал условие, по которому выведутся города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета
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
		
		--Задача №8
     /*
      	Я исходил из того, чтобы в t_1 вывести все варианты перелётов между аэропортами, какие могли бы быть,
      в t_2 вывести варианты, какие есть на самом деле. Distinct, чтобы убрать повторения.
      	Использовал оператор except, чтобы из t_1 убрать сущетвующие пары городов, между которыми осуществляются прямые рейсы
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

		--Задача №9
	/*
	 1. Сделал выборку из аэрорта отправления, прибытия их координат, а также дальности самолётов, осущетвлявших полёты на этих рейсах.
	 2. Присоединил дважды таблицу aiports под разными псевдонимами, чтобы у departure_airport и arrival_airport были соответствующие им координаты.
	 3. Присоединил таблицу aircrafts для вывода дальности самолётов
	 4. Вывел через запрос пары аэропортов с прямыми сообщениями, дистанцию между ними, использовав формулу и дальность самолётов для сравнения результата
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