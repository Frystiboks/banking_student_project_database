select trim('   ' || name ||  ' said, The date is ' || sysdate || ' and it is sunny, and the number of instructors is ' || (select count(*) from instructor))
from instructor
--where substr(name, 1, 1) = 'S'
where lower(name) like 's%niv%';

select sysdate + 14 from dual;

select sqrt(49)
from dual;

select 5*5
from dual;

select nvl(null, '4')
from dual;

select name, course_id
from  student, takes
where student.ID = takes.ID;

select name, course_id 
from student natural join takes;

select name, course_id 
from student left  outer join takes on takes.id = student.id;
--where takes.COURSE_ID is not null;

select name, course_id 
from student , takes 
where student.id = takes.id (+)  ;

select * from department;
select * from instructor;

describe department;
describe instructor;

select * 
from instructor natural join department ;

select * 
from instructor inner join department on instructor.DEPT_NAME = department.DEPT_NAME;

select i.*, d.building, d.budget
from instructor i, department d 
where i.dept_name = d.dept_name ;


select nvl(i.id, 'No instructor yet'), nvl(i.name, ''), d.dept_name, d.building, d.budget
from instructor i, department d 
where i.dept_name (+)= d.dept_name
and i.dept_name is null;

CREATE TABLE person (
	id NUMBER NOT NULL ENABLE, 
	PTAL NUMBER unique, 
	NAME VARCHAR2(66), 
	 CHECK (ID > 0) ENABLE, 
	 PRIMARY KEY ("ID")
)

create table boking (
ID number not null,
ptal number,
tekstur varchar2(66),
upphadd number, check (ID > 0),
primary key (ID),
foreign key (ptal) references person (ptal)
);


select SYSTIMESTAMP AT TIME ZONE 'UTC' from dual;

select 'A', rowid
from  instructor, dual;

select name || ' at department ' || dept_name || ' has montly payment ' || round(salary/12,2) as monthly_payment
from instructor;

select *
from instructor  join teaches on instructor.id = teaches.id;

select *
from instructor i  right outer join teaches t on (i.id = t.id);

select *
from teaches  natural join instructor  ;

describe teaches;

select *
from
(select  t.id  as takes_id, s.id as student_id
from  student s,takes t
where  s.ID  = t.ID);

create view faculty as
select id, name, dept_name
from instructor
where dept_name = 'Biology';

select *
from faculty natural join teaches;

drop view faculty;

create view total_salary as
select dept_name, sum(salary) sum_salary
from instructor
group by dept_name;

select *
from total_salary;

create table manager_log as
select * from manager;

select id, name, dept_name
from (
select id, name, dept_name, 'B' sort
from instructor
union
select id, name, dept_name, 'B' sort
from student
union
select 'ID', 'Name', 'Department', 'A' sort
from dual
)
order by sort, name;


create or replace view smart_view_undir as
select id, name, department
from (
select 'ID' as ID, 'Name' as Name, 'Department' as department, 'A' sort
from dual
union
select id, name, dept_name as department, 'B' sort
from instructor
union
select id, name, dept_name, 'B' sort
from student
union 
select ' ', 'Total salary:', ' ' || (select sum(salary) from instructor), 'D'
from dual
)
order by sort, name;

drop table manager;

create or replace view smart_view
as (
select *
from smart_view_undir
where department in ('History', 'Department') or department like ' _%'
);

select * 
from smart_view;

select *
from smart_view_undir;

create table manager
(employee_name varchar2(100),
manager_name varchar2(100),
primary key(employee_name),
foreign key (manager_name) references manager
on delete set null);

alter table manager add id number;
alter table manager modify id not null;
alter table manager add id2 number default 1  not null;
alter table manager drop column id2;
alter table manager add created_by  varchar(100);
alter table manager add created_date  date;
alter table manager add modified_by  varchar(100);
alter table manager add modified_date  date;

create sequence manager_id_seq minvalue 1 maxvalue 99999 increment by 1 start with 3;

create table manager_log as
select *
from manager;

alter table manager_log add action varchar2(199);

ALTER TABLE person2 ADD  ptal2 varchar2(10);
UPDATE person2 SET ptal2 = ptal;
ALTER TABLE person2 DROP COLUMN ptal2;
alter table person2 RENAME COLUMN ptal2 TO ptal3;