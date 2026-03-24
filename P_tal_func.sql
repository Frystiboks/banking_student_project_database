create or replace function ptal_gen(føðingardag IN varchar2)
return varchar2
is
    summ number;
    i number;
    j number;
    rest number;
    j_end number;
    p_count number;
    new_ptal varchar(9);
begin
    if length(føðingardag) != 8 then
        return '';
    end if;
    
    
    if mod(to_number(SUBSTR(føðingardag, 5)),2) = 0 then
        j := 5;
        else
        j := 0;
    end if;
    j_end := j +4;
    i := 0;
    
        loop
            loop
            
                new_ptal := NULL;
                p_count := NULL;
                
                summ := 
                3*to_number(SUBSTR(føðingardag, 1, 1)) +
                2*to_number(SUBSTR(føðingardag, 2, 1)) +
                7*to_number(SUBSTR(føðingardag, 3, 1)) +
                6*to_number(SUBSTR(føðingardag, 4, 1)) +
                5*to_number(SUBSTR(føðingardag, 7, 1)) +
                4*to_number(SUBSTR(føðingardag, 8, 1)) +
                3*j +
                2*i +
                1*0;
                
                rest :=11- mod(summ, 11);
                if rest < 10 then
                    new_ptal := SUBSTR(føðingardag, 1, 4) || SUBSTR(føðingardag, 7, 8) || to_char(j) || to_char(i)|| to_char(rest);
                    --return rest;
                    SELECT COUNT(*)
                    INTO p_count
                    FROM pers
                    WHERE p_tal = new_ptal;
                end if;
                i := i+1;
                exit when i > 9 or (p_count = 0 and new_ptal is not null);
            end loop;
            i := 0;
            j := j+1;
            exit when j > j_end or (p_count = 0 and new_ptal is not null);
        end loop;
    return new_ptal;
end;