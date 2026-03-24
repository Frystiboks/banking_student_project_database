CREATE OR REPLACE PROCEDURE kladda_insertrow (
    p_fra_id   IN VARCHAR2,
    p_til_id   IN VARCHAR2,
    p_flyting  IN NUMBER,
    p_egintekst IN VARCHAR2,
    p_mottokutekst IN   VARCHAR2

) IS
    v_motøku_tekst VARCHAR2(30);
    v_sendari_tekst VARCHAR2(30);
    v_fra_konto VARCHAR2;
    v_til_konto VARCHAR2;
    
BEGIN

    IF p_flyting <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Flyting má vera yvir 0');
    END IF;

    IF p_fra_id = p_til_id THEN
        RAISE_APPLICATION_ERROR(-20003, 'ERROR: Tú kanst ikki flyta til tín sjálvan');
    END IF;
    
    INSERT INTO Kladda (fra_id,til_id,egintekst,mottokutekst,flyting)
    VALUES (p_fra_id,p_til_id,p_egintekst,p_mottokutekst,p_flyting);
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