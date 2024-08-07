CREATE PROCEDURE UpdateSubjectAllotments()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_StudentId VARCHAR(255);
    DECLARE v_SubjectId VARCHAR(255);
    DECLARE cur CURSOR FOR SELECT StudentId, SubjectId FROM SubjectRequest;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Open the cursor
    OPEN cur;

    -- Fetch rows from SubjectRequest one by one
    read_loop: LOOP
        FETCH cur INTO v_StudentId, v_SubjectId;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Check if the student exists in SubjectAllotments
        IF EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentId = v_StudentId) THEN
            -- Update the current subject to be invalid
            UPDATE SubjectAllotments 
            SET Is_valid = 0 
            WHERE StudentId = v_StudentId AND Is_valid = 1;

            -- Insert the new subject as valid
            INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_valid) 
            VALUES (v_StudentId, v_SubjectId, 1);
        ELSE
            -- Insert the new subject as valid directly
            INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_valid) 
            VALUES (v_StudentId, v_SubjectId, 1);
        END IF;
    END LOOP;

    -- Close the cursor
    CLOSE cur;
END 
