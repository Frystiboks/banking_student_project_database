drop table person;
drop table zipcodes;
drop table country;

create table zipcodes(
zip             varchar2(20),
town            varchar2(20),
primary key(zip)
);


create table person(
ptal              number,
name              varchar2(20),
address           varchar2(20),
zip               varchar2(20),
primary key(ptal),
foreign key(zip) references zipcodes (zip)
);

create table country(
countrycode       number,
name              varchar2(20),
"vat%"            number,
primary key(countrycode)
--foreign key(zip) references zipcodes (zip)
);

alter table zipcodes add countrycode number default '0' not null;
alter table zipcodes add constraint countrycode foreign key(countrycode) references country (countrycode);

insert into country (countrycode, name, "vat%") values (298, 'Føroyar', 0);
insert into country (countrycode, name, "vat%") values (0, 'unknown', 25);
insert into country (countrycode, name, "vat%") values (1, 'United States', 25);


insert into zipcodes (zip, town, countrycode) values ('270', 'Nólsoy', 298);
insert into zipcodes (zip, town, countrycode) values ('100', 'Tórshavn', 298);
insert into zipcodes (zip, town, countrycode) values ('160', 'Argir', 298);

insert into zipcodes (zip, town, countrycode) values ('6969', 'Gayland', 1);



insert into person (ptal, name, address, zip) values (6969666420, 'Torkil', 'Eggjargøta', '270');
insert into person (ptal, name, address, zip) values (1234694321, 'Andreas', 'Breydgøta', '160');

insert into person (ptal, name, address, zip) values (42069420, 'Gaylord', 'streetstreet', '6969');


select *
from zipcodes
;

select *
from person
;

select name
from person
union
select town
from zipcodes;

select zip
from person
intersect
select zip
from zipcodes;


select *
from country;


select person.name, town, "vat%"
from person, zipcodes, country
where person.zip = zipcodes.zip and country.countrycode = zipcodes.countrycode;