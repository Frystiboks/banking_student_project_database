CREATE OR REPLACE PROCEDURE barn (
    p_p1_p_id   IN NUMBER,
    p_p2_p_id   IN NUMBER,
    p_barn_p_id IN NUMBER
) IS
    v_dummy NUMBER;
BEGIN
    IF p_p1_p_id IS NULL OR p_barn_p_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20006, 'Foreldur 1 og barn mugu veljast.');
    END IF;

    SELECT p_id
      INTO v_dummy
      FROM pers
     WHERE p_id = p_p1_p_id;

    SELECT p_id
      INTO v_dummy
      FROM pers
     WHERE p_id = p_barn_p_id;

    IF p_p1_p_id = p_barn_p_id THEN
        RAISE_APPLICATION_ERROR(-20001, 'Foreldur 1 kann ikki vera sami persónur sum barnið.');
    END IF;

    IF p_p2_p_id IS NOT NULL THEN
        SELECT p_id
          INTO v_dummy
          FROM pers
         WHERE p_id = p_p2_p_id;

        IF p_p2_p_id = p_p1_p_id THEN
            RAISE_APPLICATION_ERROR(-20002, 'Foreldur 1 og foreldur 2 kunnu ikki vera sami persónur.');
        END IF;

        IF p_p2_p_id = p_barn_p_id THEN
            RAISE_APPLICATION_ERROR(-20003, 'Foreldur 2 kann ikki vera sami persónur sum barnið.');
        END IF;
    END IF;

    INSERT INTO børn (p1_id, p2_id, barn_id)
    VALUES (p_p1_p_id, p_p2_p_id, p_barn_p_id);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20004, 'Ein av persónunum er ikki til í pers.');
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20005, 'Barnið hevur longu eina familju-røð.');
    WHEN OTHERS THEN
        RAISE;
END barn;
/
