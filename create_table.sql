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
