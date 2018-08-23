create table Passenger
(P_ID number primary key,
First_name varchar(20) not null,
Last_name varchar(20),
age number,
gender varchar(1));

-------------------------------------------------------

create table Ticket
(ticket_no number primary key,
*fare number not null);

-------------------------------------------------------

create table Ticket_P
(ticket_no number,
P_ID number,
CONSTRAINT ticket_P_pk primary key(ticket_no, P_ID));

-------------------------------------------------------

create table Ticket_B
(bus_no number,
ticket_no number,
date_B date,
bording_city varchar(20),
drop_city varchar(20),
start_J_time timestamp,
finish_J_time timestamp,
CONSTRAINT ticket_B_pk primary key(bus_no,ticket_no));

-------------------------------------------------------

create table Bus
(bus_no number primary key,
type varchar(10),
start_time date,
total_seat number,
rate_pkm number);

-------------------------------------------------------

create table Bus_C
(bus_no number,
city varchar(20),
timeC date,
seat_av number,
distance number,
CONSTRAINT bus_c_pk primary key(bus_no, city));

-------------------------------------------------------

create table graph
(source1 VARCHAR(20),
destination VARCHAR(20),
distance number,
CONSTRAINT graph_pk PRIMARY KEY (source1, destination)
) ORGANIZATION INDEX compress 1;

INSERT into SYS.GRAPH values('&s', '&d', &dist);

variable remove_Path varchar(28)
variable src VARCHAR(28)
variable dest VARCHAR(28)
exec :remove_Path :=''

exec :src :='B'

exec :dest :='P'

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
WHERE ROWNUM = 1