CREATE OR REPLACE PROCEDURE nýggj_hjún (
    p_p1_p_id IN NUMBER,
    p_p2_p_id IN NUMBER
) IS
    v_p1_id        NUMBER;
    v_p2_id        NUMBER;
    v_person_count NUMBER;
    v_active_count NUMBER;
BEGIN
    IF p_p1_p_id IS NULL OR p_p2_p_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'Báðir persónar mugu veljast.');
    END IF;

    IF p_p1_p_id = p_p2_p_id THEN
        RAISE_APPLICATION_ERROR(-20001, 'Ein persónur kann ikki giftast við sær sjálvum.');
    END IF;

    v_p1_id := LEAST(p_p1_p_id, p_p2_p_id);
    v_p2_id := GREATEST(p_p1_p_id, p_p2_p_id);

    SELECT COUNT(*)
      INTO v_person_count
      FROM pers
     WHERE p_id IN (v_p1_id, v_p2_id);

    IF v_person_count <> 2 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Ein av persónunum er ikki til.');
    END IF;

    SELECT COUNT(*)
      INTO v_active_count
      FROM hjúnaband
     WHERE skild_dato IS NULL
       AND (p1_id IN (v_p1_id, v_p2_id) OR p2_id IN (v_p1_id, v_p2_id));

    IF v_active_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Ein av persónunum er longu í virknu hjúnabandi.');
    END IF;

    INSERT INTO hjúnaband (p1_id, p2_id, gift_dato, skild_dato)
    VALUES (v_p1_id, v_p2_id, SYSDATE, NULL);
END nýggj_hjún;
/



CREATE OR REPLACE PROCEDURE end_hjún (
    p_p1_p_id IN NUMBER,
    p_p2_p_id IN NUMBER
) IS
    v_p1_id        NUMBER;
    v_p2_id        NUMBER;
    v_person_count NUMBER;
BEGIN
    IF p_p1_p_id IS NULL OR p_p2_p_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'Báðir persónar mugu veljast.');
    END IF;

    IF p_p1_p_id = p_p2_p_id THEN
        RAISE_APPLICATION_ERROR(-20001, 'Ein persónur kann ikki skiljast frá sær sjálvum.');
    END IF;

    v_p1_id := LEAST(p_p1_p_id, p_p2_p_id);
    v_p2_id := GREATEST(p_p1_p_id, p_p2_p_id);

    SELECT COUNT(*)
      INTO v_person_count
      FROM pers
     WHERE p_id IN (v_p1_id, v_p2_id);

    IF v_person_count <> 2 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Ein av persónunum er ikki til.');
    END IF;

    UPDATE hjúnaband
       SET skild_dato = SYSDATE
     WHERE skild_dato IS NULL
       AND p1_id = v_p1_id
       AND p2_id = v_p2_id;


-- Um einki var updatera, merkir at tey ikki eru til

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Einki virkið hjúnaband funnið hjá hesum báðum.');
    END IF;
END end_hjún;
/
