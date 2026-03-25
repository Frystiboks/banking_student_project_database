create or replace function rentu_rokning(kontotypa IN varchar2, p_konto_id IN varchar2, dato_start IN date, dato_end IN date)
return number
is
    saldo number(12,2);
    last_dato date;
    max_dato date;
    dato_current date;
    end_of_month date;
    renta number;
    samla_renta number;
    debit_renta number;
    credit_renta number;
    max_trans_id number;
begin

select credit_renta into credit_renta 
from kontoslag
where kontotypa = kontoslag.kontoslag_id;

select debit_renta into debit_renta 
from kontoslag
where kontotypa = kontoslag.kontoslag_id;

     samla_renta := 0;
    
    select max(log_dato) into max_dato
    from loggur
    where p_konto_id = loggur.konto_id and log_dato <= dato_start;

-- makes sure we get the latest transaction in the case where we have duplicate dates.
    select max(log_id) into max_trans_id
    from loggur
    where p_konto_id = loggur.konto_id and log_dato = max_dato;


-- loys trupuleikan um eingin bóking er. kanska ger eina 0 bóking tá kontoin er stovna.
    select leypandi_saldo into saldo
    from loggur
    where p_konto_id = loggur.konto_id and log_dato = max_dato and max_trans_id = loggur.log_id;
    
    select last_day(dato_start) into end_of_month from dual;
    dato_current := dato_start;

    loop
    if saldo < 0 then
        renta := credit_renta;
    else
        renta := debit_renta;
    end if;
    samla_renta :=  samla_renta + saldo*renta;
       
   
    select max(log_id) into max_trans_id
    from loggur
    where p_konto_id = loggur.konto_id and log_dato >= dato_current and log_dato < dato_current + 1;

    if max_trans_id is not null then
        select leypandi_saldo into saldo
        from loggur
        where p_konto_id = loggur.konto_id and max_trans_id = loggur.log_id;
    end if;


    if dato_current = end_of_month then
        saldo := saldo +  samla_renta;
         samla_renta := 0;
        select last_day(ADD_MONTHS(dato_current, 1)) into end_of_month from dual;
    end if;
         
    exit when dato_current >= dato_end;
    select dato_current + 1 into dato_current from dual;
    end loop;
return saldo;
end;
/

create or replace procedure rentu_rokning_allar_konti(dato_start IN date, dato_end IN date)
is
    rentu_saldo number;
    bankaboks varchar2(11);
BEGIN
    bankaboks := '69690000016';
    FOR rec IN (
        SELECT konto_id, kontotypa, saldo
        FROM konto
    ) LOOP
        select rentu_rokning(rec.kontotypa, rec.konto_id, dato_start, dato_end) into rentu_saldo from dual;
        
        INSERT INTO loggur (konto_id, saldo_broyting, móttakari_id)
        VALUES (rec.konto_id, rentu_saldo - rec.saldo, bankaboks);
        
        INSERT INTO loggur (konto_id, saldo_broyting, móttakari_id)
        VALUES (bankaboks, -(rentu_saldo - rec.saldo), rec.konto_id);
        
    END LOOP;
END;
/
