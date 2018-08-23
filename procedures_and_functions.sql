-- code to calculate fare

create or replace function fare_cal1 (tick_no number)
return number
is
cnt number := 0;
f1 number;
t1 number;
begin
select count(*) into cnt from SYS.TICKET_P where ticket_no = tick_no;
f1 := fare01(1007);
t1 := f1 * cnt;
return t1;
end;
/
-------------------------------------------------------

-- code to calculate fare1

create or replace function fare01 (ticketno number)
return number
is
sum1 number;
sum2 number;
r number;
d1 number;
d2 number;
cursor c1 is
select bus_no, bording_city, drop_city from Ticket_B where ticket_no = ticketno;
rec1 c1%ROWTYPE;
begin
sum1 := 0;
sum2 := 0;
for rec1 in c1 loop
	select distance into d1 from Bus_C where city = rec1.drop_city AND bus_no = rec1.bus_no;
	select distance into d2 from Bus_C where city = rec1.bording_city AND bus_no = rec1.bus_no;
	sum1 := sum1 + d1 - d2;
	select rate_pkm into r from Bus where bus_no = rec1.bus_no;
	sum2 := sum2 + r*(d1 - d2);
end loop;
--close c1;
if sum2<50 then
	sum2 := 50;
end if;
return sum2;
end;
/
--------------------------------------------------------
--code to calculate available seats

create or replace procedure u_available (busno IN number, p_city IN varchar)
is
bCity varchar(20);
dCity varchar(20);
d1 number;
d2 number;
d number;
tick number;
c number;
sum1 number;
a number;
tot number;
cursor c1 is
select ticket_no, bording_city, drop_city from Ticket_B where bus_no = busno;
rec1 c1%ROWTYPE;
begin
sum1 := 0;
select distance into d from Bus_C where city = p_city AND bus_no = busno;
for rec1 in c1
loop
	select distance into d1 from Bus_C where city = rec1.bording_city AND bus_no = busno;
	select distance into d2 from Bus_C where city = rec1.drop_city AND bus_no = busno;
	if d1 <= d AND d2 > d then
		select count(*) into c from Ticket_P where ticket_no = rec1.ticket_no;
		sum1 := sum1 + c;
	end if;
end loop;
select total_seat into tot from Bus where bus_no = busno;
a := tot - sum1;
if a>=0 then
	update Bus_C set seat_av = a where bus_no = busno AND city = p_city;
else
	raise_application_error(-20001, 'Seats are already full');
end if;
end;
/
-------------------------------------------------------------------

create or replace function B_N_available (busno number, bCity varchar, dCity varchar)
return number
is
d1 number;
d2 number;
d number;
min1 number;
temp number;
cursor c1 is
select city from Bus_C where bus_no = busno;
rec1 c1%ROWTYPE;
begin
select total_seat into min1 from Bus where bus_no = busno;
select distance into d1 from Bus_c where city = bCity AND bus_no = busno;
select distance into d2 from Bus_c where city = dCity AND bus_no = busno;
for rec1 in c1 loop
	select distance into d from Bus_c where city = rec1.city AND bus_no = busno;
	if d1 <= d AND d2 > d then
		select seat_av into temp from Bus_C where bus_no = busno AND city = rec1.city;
		if temp < min1 then
			min1 := temp;
		end if;
	end if;
end loop;
close c1;
return min1;
end B_N_available;
/

--procedure to insert into passenger

create or replace procedure insertP (fname IN varchar, lname IN varchar, age IN number, gender IN varchar)
is
begin
	insert into Passenger values (P_ID_seq.nextval, 'fname', 'lname', age, 'gender');
end;

insert into Passenger values (P_ID_seq.nextval, '&fname', '&lname', &age, '&gender');
--------------------------------------------------------------

--procedure to insert into BUS

create or replace procedure BusI
is
begin
	insert into Bus values (BUS_seq.nextval, '&Type', TO_TIMESTAMP(:startTime, 'HH24:MI:SS'), &totalSeats, &ratePerKM);
end;


insert into Bus values (BUS_seq.nextval, '&Type', NULL, &totalSeats, &ratePerKM);
/
---------------------------------------------------------------

create or replace procedure buses 
as
begin
CREATE GLOBAL TEMPORARY TABLE a
ON COMMIT PRESERVE ROWS
AS
SELECT source1 src, destination dest, path, sum_dist shortest_dist
FROM
(SELECT DISTINCT source1, destination, path,
        sum(to_number( SUBSTR(x,
                       INSTR (x, ',', 1, LEVEL  ) + 1,
                       INSTR (x, ',', 1, LEVEL+1) -
      INSTR (x, ',', 1, LEVEL) -1 ))) OVER (PARTITION BY path) sum_dist
  FROM
 (
   WITH REMOVE_PATH AS (
   SELECT SUBSTR(str,
           INSTR(str, ',', 1, LEVEL  ) + 1,
           INSTR(str, ',', 1, LEVEL+1) -
           INSTR(str, ',', 1, LEVEL) -1 ) str     
   FROM (SELECT ','||NVL(:Remove_Path, ' ')||','||:src||','||:dest||','
         AS str FROM DUAL)
   CONNECT BY PRIOR STR = STR
   AND INSTR (str, ',', 1, LEVEL+1) > 0
   AND PRIOR dbms_random.string ('p', 10) IS NOT NULL )
   SELECT  connect_by_root source1 as source1,  destination,
           sys_connect_by_path(distance, ',')||',' x,
           :src|| sys_connect_by_path(destination, ',') path        
   FROM  SYS.GRAPH
   WHERE  destination = :dest
   START WITH source1  = :src
   CONNECT by nocycle PRIOR destination = source1
   AND source1 NOT IN (SELECT str FROM REMOVE_PATH)
  )
  CONNECT BY PRIOR path = path
  AND INSTR (x, ',', 1, LEVEL+1) > 0
  AND PRIOR dbms_random.string ('p', 10) IS NOT NULL
  ORDER BY sum_dist NULLS LAST
)
WHERE ROWNUM = 1;
end;
/