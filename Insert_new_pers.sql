CREATE OR REPLACE PROCEDURE new_per (
    p_fornavn      IN VARCHAR2,
    p_eftirnavn    IN VARCHAR2,
    p_føðingardag  IN VARCHAR2,
    p_kyn          IN VARCHAR2,
    p_bústað_id    IN NUMBER
) IS
BEGIN
    IF p_føðingardag IS NULL OR LENGTH(p_føðingardag) <> 8 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR: Føðingardagur má vera DDMMYYYY.');
    END IF;

    IF p_kyn NOT IN ('m', 'k') THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR: Kyn má vera m ella k.');
    END IF;

    IF ptal_gen(p_føðingardag, p_kyn) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20003, 'ERROR: Ógildugur føðingardagur.');
    END IF;

    INSERT INTO pers(fornavn, eftirnavn, føðingardag, kyn, bústað_id)
    VALUES (p_fornavn, p_eftirnavn, p_føðingardag, p_kyn, p_bústað_id);

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
/
