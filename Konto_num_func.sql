create or replace function kontonummar_gen(kontotypa IN varchar2)
return varchar2
is
    summ number;
    i number;
    j number;
    k number;
    x number;
    abc varchar2(3);
    rest number;
    j_end number;
    p_count number;
    new_kontonummar varchar(11);
    max_kontonummar varchar(11);
begin

if kontotypa = 'Lán' then
    abc := '100';
    select kontonum_seq_lán.nextval into x from dual;
elsif kontotypa = 'Nýtslu' then
    abc := '200';
    select kontonum_seq_nýtsla.nextval into x from dual;
elsif kontotypa = 'Uppsparing' then
    abc := '300';
    select kontonum_seq_uppsparing.nextval into x from dual;
else
    abc := '400';
    select kontonum_seq_default.nextval into x from dual;
end if;


i := mod(x,10);
j := mod(floor(x/10),10);
k := mod(floor(x/100),10);



new_kontonummar := null;
if x < 1000 then
loop
                summ := 
                5*6 +
                4*9 +
                3*6 +
                2*9 +
                7*to_number(SUBSTR(abc, 1, 1)) +
                6*to_number(SUBSTR(abc, 2, 1)) +
                5*to_number(SUBSTR(abc, 3, 1)) +
                4*k +
                3*j +
                2*i +
                1*0;
                
                
                rest :=11- mod(summ, 11);
                --return rest;
                if rest < 10 then
                    new_kontonummar := '6969' || abc || to_char(k) || to_char(j) || to_char(i)|| to_char(rest);
                end if;
                
                if kontotypa = 'Lán' then
                    abc := '100';
                    select kontonum_seq_lán.nextval into x from dual;
                elsif kontotypa = 'Nýtslu' then
                    abc := '200';
                    select kontonum_seq_nýtsla.nextval into x from dual;
                elsif kontotypa = 'Uppsparing' then
                    abc := '300';
                    select kontonum_seq_uppsparing.nextval into x from dual;
                else
                    abc := '400';
                    select kontonum_seq_default.nextval into x from dual;
                end if;
                i := mod(x,10);
                j := mod(floor(x/10),10);
                k := mod(floor(x/100),10);
                exit when x> 999 or new_kontonummar is not null;
            end loop;
end if;


return new_kontonummar;
end;