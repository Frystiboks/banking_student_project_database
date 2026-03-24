CREATE OR REPLACE PROCEDURE flyt_pengar (
    p_fra_id   IN VARCHAR2,
    p_til_id   IN VARCHAR2,
    p_flyting  IN NUMBER,
    p_tekst    IN VARCHAR2
) IS
    v_fra_saldo VARCHAR2;
    v_til_saldo VARCHAR2;
BEGIN
    IF p_flyting <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Flyting má vera yvir 0');
    END IF;

    IF p_fra_id = p_til_id THEN
        RAISE_APPLICATION_ERROR(-20003, 'ERROR: Tú kanst ikki flyta til tín sjálvan');
    END IF;

    SELECT saldo
    INTO v_fra_saldo
    FROM konto
    WHERE konto_id = p_fra_id
    FOR UPDATE;

    SELECT saldo
    INTO v_til_saldo
    FROM konto
    WHERE konto_id = p_til_id
    FOR UPDATE;

    IF p_flyting > v_fra_saldo THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Flyting má ikki vera yvir saldo');
    END IF;

    UPDATE konto
    SET saldo = saldo - p_flyting
    WHERE konto_id = p_fra_id;

    UPDATE konto
    SET saldo = saldo + p_flyting
    WHERE konto_id = p_til_id;

    INSERT INTO loggur (
        log_id,
        konto_id,
        saldo_broyting,
        log_dato,
        móttakari_id,
        tekst
    )
    VALUES (
        log_seq.NEXTVAL,
        p_fra_id,
        -p_flyting,
        SYSDATE,
        p_til_id,
        p_tekst
    );

    INSERT INTO loggur (
        log_id,
        konto_id,
        saldo_broyting,
        log_dato,
        móttakari_id,
        tekst
    )
    VALUES (
        log_seq.NEXTVAL,
        p_til_id,
        p_flyting,
        SYSDATE,
        p_fra_id,
        p_tekst
    );

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20004, 'ERROR: Konto fannst ikki');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/