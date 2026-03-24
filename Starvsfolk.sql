CREATE OR REPLACE PROCEDURE new_starv (
    p_brukari_p_id   IN NUMBER, -- Er admin sum loggar inn
    p_p_id         IN NUMBER,   -- er nýggji starvsfólk
    p_starv_navn   IN VARCHAR2,
    p_lon          IN NUMBER
) IS
    v_brukari_atgongd  starvsfolk.atgongd_typa%TYPE;
    v_dummy          NUMBER;
BEGIN
    IF p_lon <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Løn má vera yvir 0');
    END IF;

    SELECT atgongd_typa
    INTO v_brukari_atgongd
    FROM starvsfolk
    WHERE p_id = p_brukari_p_id;

    IF v_brukari_atgongd <> 'ADMIN' THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Bert administrator kann stovna starvsfólk.');
    END IF;

    SELECT p_id
    INTO v_dummy
    FROM pers
    WHERE p_id = p_p_id;

    INSERT INTO starvsfolk (starv_navn, lon, p_id)
    VALUES (p_starv_navn, p_lon, p_p_id,);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'ERROR: Annaðhvørt er aktørurin ikki starvsfólk, ella persónurin er ikki til.');
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20004, 'ERROR: Hesin persónur er longu skrásettur sum starvsfólk.');
    WHEN OTHERS THEN
        RAISE;
END;
/

-- Rolle broytari er fyri at broyta rolluna hjá starvfólkum, har ein admin kann broyta løn,
-- Starv navn, access typa og meira
CREATE OR REPLACE PROCEDURE rolle_broytari ( 
    p_brukari_starv_id IN NUMBER,
    p_starv_id         IN NUMBER,
    p_starv_navn       IN VARCHAR2,
    p_lon              IN NUMBER,
    p_atgongd_typa     IN VARCHAR2
) IS
    v_brukari_atgongd  starvsfolk.atgongd_typa%TYPE;
    v_dummy            NUMBER;
BEGIN
    SELECT atgongd_typa
    INTO v_brukari_atgongd
    FROM starvsfolk
    WHERE starv_id = p_brukari_starv_id;

    IF v_brukari_atgongd <> 'ADMIN' THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Bert administrator kann broyta starvsfólk.');
    END IF;

    SELECT starv_id
    INTO v_dummy
    FROM starvsfolk
    WHERE starv_id = p_starv_id;

    IF p_lon IS NOT NULL THEN
        IF p_lon <= 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'ERROR: Løn má vera yvir 0.');
        END IF;
    END IF;

    IF p_atgongd_typa IS NOT NULL THEN
        IF p_atgongd_typa NOT IN ('ONEYDUGT', 'STARVSFOLK', 'ADMIN') THEN
            RAISE_APPLICATION_ERROR(-20005, 'ERROR: Ógildig atgongd_typa.');
        END IF;
    END IF;

    IF p_starv_navn IS NOT NULL THEN
        UPDATE starvsfolk
        SET starv_navn = p_starv_navn
        WHERE starv_id = p_starv_id;
    END IF;

    IF p_lon IS NOT NULL THEN
        UPDATE starvsfolk
        SET lon = p_lon
        WHERE starv_id = p_starv_id;
    END IF;

    IF p_atgongd_typa IS NOT NULL THEN
        UPDATE starvsfolk
        SET atgongd_typa = p_atgongd_typa
        WHERE starv_id = p_starv_id;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'ERROR: Annaðhvørt finst broytarin ikki sum starvsfólk, ella finst starvsfólkið ikki.');
    WHEN OTHERS THEN
        RAISE;
END rolle_broytari;
/
    