insert into Bus values(bus_seq.nextval, '&type', NULL, &tot_seat, &rate);

insert into Bus_c values (&busno, '&city', TO_DATE('&time1', 'hh24:mi:ss'), &seat_av, &distance);

insert into passenger values(P_ID_seq.nextval, '&fname', '&lname', &age, '&g');

insert into ticket values(ticketNo_seq.nextval, &FARE);

insert into ticket_B values(ticketNo_seq.currval, &P_ID);

insert into ticket_B values(&busno, 1007, NULL, '&bcity', '&dcity', '&stime', '&ftime');

declare
a1 number;
t1 number;
begin
select ticket_no into t1 from ticket where fare = 0;
a1 := fare_cal1(t1);
update SYS.TICKET set fare = a1 where fare = 0;
--insert into ticket values(ticketNo_seq.nextval, 0);
DBMS_OUTPUT.PUT_LINE(a1);
end;
/

declare
begin
u_available(120, 'A');
end;
/