CREATE OR REPLACE PROCEDURE new_per (
    p_fornavn      IN VARCHAR2,
    p_eftirnavn    IN VARCHAR2,
    p_føðingardag  IN DATE,
    p_tlf          IN VARCHAR2
) IS
    v_p_tal VARCHAR2(11);
BEGIN
    v_p_tal := ptal_gen(TO_CHAR(p_føðingardag, 'DDMMYYYY'));

    IF v_p_tal IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Ógildugur føðingardagur');
    END IF;

    INSERT INTO pers (p_tal, fornavn, eftirnavn, tlf)
    VALUES (v_p_tal, p_fornavn, p_eftirnavn, p_tlf);

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
/
