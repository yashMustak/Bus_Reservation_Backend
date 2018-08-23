--sequence for ticket no

create or replace sequence ticketNo_seq
minvalue 1000
start with 1000
increment by 1
cache 20;

----------------------------------------------------------------

--sequence for P_ID

create or replace sequence P_ID_seq
minvalue 1
start with 1
increment by 1
cache 20;

---------------------------------------------------------------

--sequence for bus no

create or replace sequence BUS_seq
minvalue 100
start with 100
increment by 1
cache 20;