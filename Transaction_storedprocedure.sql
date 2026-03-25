
CREATE OR REPLACE PROCEDURE nyggj_kladda (
    p_brukari_p_id   IN NUMBER,
    p_flyting        IN NUMBER,
    p_fra_id         IN VARCHAR2,
    p_til_id         IN VARCHAR2,
    p_egintekst      IN VARCHAR2,
    p_mottokutekst   IN VARCHAR2,
    p_slag           IN VARCHAR2
) IS
    v_dummy NUMBER;
BEGIN
    IF p_brukari_p_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Brúkari má veljast.');
    END IF;

    IF p_flyting IS NULL OR p_flyting <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Flyting má vera yvir 0.');
    END IF;

    IF p_slag NOT IN ('INNSETING', 'UTTOKA', 'FLYTING') THEN
        RAISE_APPLICATION_ERROR(-20003, 'ERROR: Ógildigt slag.');
    END IF;

    SELECT p_id
    INTO v_dummy
    FROM pers
    WHERE p_id = p_brukari_p_id;

    IF p_slag = 'INNSETING' THEN
        IF p_til_id IS NULL OR p_fra_id IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20004, 'ERROR: INNSETING krevur bert til-konto.');
        END IF;

        SELECT 1
        INTO v_dummy
        FROM konto
        WHERE konto_id = p_til_id
          AND eigari_p_id = p_brukari_p_id;

    ELSIF p_slag = 'UTTOKA' THEN
        IF p_fra_id IS NULL OR p_til_id IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20005, 'ERROR: UTTOKA krevur bert frá-konto.');
        END IF;

        SELECT 1
        INTO v_dummy
        FROM konto
        WHERE konto_id = p_fra_id
          AND eigari_p_id = p_brukari_p_id;

    ELSIF p_slag = 'FLYTING' THEN
        IF p_fra_id IS NULL OR p_til_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20006, 'ERROR: FLYTING krevur bæði frá- og til-konto.');
        END IF;

        IF p_fra_id = p_til_id THEN
            RAISE_APPLICATION_ERROR(-20007, 'ERROR: Frá- og til-konto kunnu ikki vera eins.');
        END IF;

        SELECT 1
        INTO v_dummy
        FROM konto
        WHERE konto_id = p_fra_id
          AND eigari_p_id = p_brukari_p_id;

        SELECT 1
        INTO v_dummy
        FROM konto
        WHERE konto_id = p_til_id;
    END IF;

    INSERT INTO kladda (
        kladdu_id,
        flyting,
        frá_id,
        til_id,
        egintekst,
        mottokutekst,
        slag,
        status,
        dato
    )
    VALUES (
        kladdu_seq.NEXTVAL,
        p_flyting,
        p_fra_id,
        p_til_id,
        p_egintekst,
        p_mottokutekst,
        p_slag,
        'OAVGJORD',
        SYSDATE
    );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20008, 'ERROR: Persónur ella konto fannst ikki, ella kontoin er ikki tín.');
    WHEN OTHERS THEN
        RAISE;
END nyggj_kladda;
/

create or replace PROCEDURE boka_kladdu (
    p_brukari_starv_id IN NUMBER,
    p_kladdu_id        IN NUMBER
) IS
    v_atgongd        starvsfolk.atgongd_typa%TYPE;
    v_flyting        kladda.flyting%TYPE;
    v_fra_id         kladda.frá_id%TYPE;
    v_til_id         kladda.til_id%TYPE;
    v_egintekst      kladda.egintekst%TYPE;
    v_mottokutekst   kladda.mottokutekst%TYPE;
    v_slag           kladda.slag%TYPE;
    v_status         kladda.status%TYPE;
    v_fra_saldo      konto.saldo%TYPE;
    v_til_saldo      konto.saldo%TYPE;
BEGIN
    SELECT atgongd_typa
    INTO v_atgongd
    FROM starvsfolk
    WHERE starv_id = p_brukari_starv_id;

    IF v_atgongd != 'STARVSFOLK' AND v_atgongd != 'ADMIN' THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Bert starvsfólk ella admin kunnu bóka.');
    END IF;

    SELECT flyting, frá_id, til_id, egintekst, mottokutekst, slag, status
    INTO v_flyting, v_fra_id, v_til_id, v_egintekst, v_mottokutekst, v_slag, v_status
    FROM kladda
    WHERE kladdu_id = p_kladdu_id
    FOR UPDATE;

    IF v_status != 'OAVGJORD' THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Kladdan er longu viðgjørd.');
    END IF;

    IF v_slag = 'INNSETING' THEN
        SELECT saldo
        INTO v_til_saldo
        FROM konto
        WHERE konto_id = v_til_id
        FOR UPDATE;

        UPDATE konto
        SET saldo = saldo + v_flyting
        WHERE konto_id = v_til_id;

        SELECT saldo
        INTO v_til_saldo
        FROM konto
        WHERE konto_id = v_til_id;

        INSERT INTO loggur (
            konto_id,
            saldo_broyting,
            log_dato,
            móttakari_id,
            tekst,
            leypandi_saldo
        )
        VALUES (
            v_til_id,
            v_flyting,
            SYSDATE,
            NULL,
            v_mottokutekst,
            v_til_saldo
        );

    ELSIF v_slag = 'UTTOKA' THEN
        SELECT saldo
        INTO v_fra_saldo
        FROM konto
        WHERE konto_id = v_fra_id
        FOR UPDATE;

        IF v_flyting > v_fra_saldo THEN
            RAISE_APPLICATION_ERROR(-20003, 'ERROR: Upphædd er hægri enn saldo.');
        END IF;

        UPDATE konto
        SET saldo = saldo - v_flyting
        WHERE konto_id = v_fra_id;

        SELECT saldo
        INTO v_fra_saldo
        FROM konto
        WHERE konto_id = v_fra_id;

        INSERT INTO loggur (
            konto_id,
            saldo_broyting,
            log_dato,
            móttakari_id,
            tekst,
            leypandi_saldo
        )
        VALUES (
            v_fra_id,
            -v_flyting,
            SYSDATE,
            NULL,
            v_egintekst,
            v_fra_saldo
        );

    ELSIF v_slag = 'FLYTING' THEN
        IF v_fra_id < v_til_id THEN
            SELECT saldo
            INTO v_fra_saldo
            FROM konto
            WHERE konto_id = v_fra_id
            FOR UPDATE;

            SELECT saldo
            INTO v_til_saldo
            FROM konto
            WHERE konto_id = v_til_id
            FOR UPDATE;
        ELSE
            SELECT saldo
            INTO v_til_saldo
            FROM konto
            WHERE konto_id = v_til_id
            FOR UPDATE;

            SELECT saldo
            INTO v_fra_saldo
            FROM konto
            WHERE konto_id = v_fra_id
            FOR UPDATE;
        END IF;

        IF v_flyting > v_fra_saldo THEN
            RAISE_APPLICATION_ERROR(-20004, 'ERROR: Flyting má ikki vera yvir saldo.');
        END IF;

        UPDATE konto
        SET saldo = saldo - v_flyting
        WHERE konto_id = v_fra_id;

        UPDATE konto
        SET saldo = saldo + v_flyting
        WHERE konto_id = v_til_id;

        SELECT saldo
        INTO v_fra_saldo
        FROM konto
        WHERE konto_id = v_fra_id;

        SELECT saldo
        INTO v_til_saldo
        FROM konto
        WHERE konto_id = v_til_id;

        INSERT INTO loggur (
            konto_id,
            saldo_broyting,
            log_dato,
            móttakari_id,
            tekst,
            leypandi_saldo
        )
        VALUES (
            v_fra_id,
            -v_flyting,
            SYSDATE,
            v_til_id,
            v_egintekst,
            v_fra_saldo
        );

        INSERT INTO loggur (
            konto_id,
            saldo_broyting,
            log_dato,
            móttakari_id,
            tekst,
            leypandi_saldo
        )
        VALUES (
            v_til_id,
            v_flyting,
            SYSDATE,
            v_fra_id,
            v_mottokutekst,
            v_til_saldo
        );

    ELSE
        RAISE_APPLICATION_ERROR(-20006, 'ERROR: Ókent slag á kladdu.');
    END IF;

    UPDATE kladda
    SET status = 'BOKAD',
        bokad_av_starv_id = p_brukari_starv_id,
        bokad_dato = SYSDATE
    WHERE kladdu_id = p_kladdu_id;

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, 'ERROR: Starvsfólk, kladda ella konto fannst ikki.');
    WHEN OTHERS THEN
        RAISE;
END boka_kladdu;

/



create or replace PROCEDURE avvisa_kladdu (
    p_brukari_starv_id IN NUMBER,
    p_kladdu_id        IN NUMBER
) IS
    v_atgongd starvsfolk.atgongd_typa%TYPE;
BEGIN
    SELECT atgongd_typa
    INTO v_atgongd
    FROM starvsfolk
    WHERE starv_id = p_brukari_starv_id;

    IF v_atgongd != 'STARVSFOLK' AND v_atgongd != 'ADMIN' THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Bert starvsfólk ella admin kunnu avvísa.');
    END IF;

    UPDATE kladda
    SET status = 'AVVIST',
        bokad_av_starv_id = p_brukari_starv_id,
        bokad_dato = SYSDATE
    WHERE kladdu_id = p_kladdu_id
      AND status = 'OAVGJORD';

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Kladdan finst ikki ella er longu viðgjørd.');
    END IF;

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'ERROR: Starvsfólk fannst ikki.');
    WHEN OTHERS THEN
        RAISE;
END avvisa_kladdu;
