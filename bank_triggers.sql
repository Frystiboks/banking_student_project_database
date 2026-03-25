-- allar kontoir mugu verğa stovnağar viğ saldo 0

create or replace trigger new_konto_trig_before before insert on konto
for each row
begin
    if :new.konto_id != '69690000016' then
        :new.konto_id := kontonummar_gen(:new.kontotypa);
    end if;
    :new.saldo := 0;
end;
/

create or replace trigger new_konto_trig_after after insert on konto
for each row
begin
    insert into loggur (konto_id,
                        saldo_broyting,
                        log_dato,
                        móttakari_id,
                        tekst,
                        leypandi_saldo
    ) 
            values (:new.konto_id,
                    nvl(:new.saldo, 0),   
                    sysdate,
                    null,                 
                    'Konto stovnağ',      
                    nvl(:new.saldo, 0)
    );
end;
/

create or replace trigger loggur_ins before insert on loggur
for each row
declare
    new_saldo number;
begin
    if :new.log_dato is null then
        :new.log_dato := sysdate;
    end if;
    
    if :new.saldo_broyting != 0  then
    update konto
    set saldo = saldo + :new.saldo_broyting
    where konto_id = :new.konto_id;
    
    end if;
    
    select saldo into new_saldo from konto where konto_id = :new.konto_id;
    :new.leypandi_saldo := new_saldo ;

end;
/

create or replace trigger new_pers_trig before insert on pers
for each row
begin
    :new.p_tal := ptal_gen(:new.føğingardag, :new.kyn);
end;
/

-- máğanarlig renturokning
begin
        -- drop the job if it already exists
    begin
        dbms_scheduler.drop_job('mánağarlig_renturokning', true); 
    exception
        when others then
            if sqlcode != -27475 then -- job does not exist
                raise;
            end if;
    end;

    dbms_scheduler.create_job (
        job_name        => 'mánağarlig_renturokning',
        job_type        => 'plsql_block',
        job_action      => 'begin
                            rentu_rokning_allar_konti(
                            add_months(trunc(sysdate), -1),
                            trunc(sysdate));
                            end;',
        start_date      => systimestamp,
        repeat_interval => 'freq=monthly;bymonthday=1;byhour=0;byminute=0;bysecond=0',
        enabled         => true
    );
end;
/