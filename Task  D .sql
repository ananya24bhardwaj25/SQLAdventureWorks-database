1. 
CREATE PROCEDURE AllocateSubjects()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE currentStudentId INT;
    DECLARE currentGPA DECIMAL(3, 2);
    DECLARE currentPreference INT;
    DECLARE currentSubjectId VARCHAR(20);
    DECLARE availableSeats INT;

    DECLARE studentCursor CURSOR FOR
        SELECT StudentId, GPA
        FROM StudentDetails
        ORDER BY GPA DESC;

    DECLARE preferenceCursor CURSOR FOR
        SELECT SubjectId
        FROM StudentPreference
        WHERE StudentId = currentStudentId
        ORDER BY Preference ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Open the cursor to process students
    OPEN studentCursor;
    
    -- Loop through each student based on GPA
    read_students: LOOP
        FETCH studentCursor INTO currentStudentId, currentGPA;
        IF done THEN
            LEAVE read_students;
        END IF;
        
        -- Open the cursor to process preferences for the current student
        SET done = 0;
        OPEN preferenceCursor;
        
        read_preferences: LOOP
            FETCH preferenceCursor INTO currentSubjectId;
            IF done THEN
                LEAVE read_preferences;
            END IF;
            
            -- Check the availability of the subject
            SELECT RemainingSeats INTO availableSeats
            FROM SubjectDetails
            WHERE SubjectId = currentSubjectId;

            -- If there are available seats, allocate the subject to the student
            IF availableSeats > 0 THEN
                INSERT INTO Allotments (SubjectId, StudentId)
                VALUES (currentSubjectId, currentStudentId);

                -- Update the remaining seats for the subject
                UPDATE SubjectDetails
                SET RemainingSeats = RemainingSeats - 1
                WHERE SubjectId = currentSubjectId;
                
                -- Close the preference cursor and move to the next student
                CLOSE preferenceCursor;
                LEAVE read_preferences;
            END IF;
        END LOOP read_preferences;
        
        -- If no subject was allocated, mark the student as unallotted
        IF done THEN
            INSERT INTO UnallotedStudents (StudentId)
            VALUES (currentStudentId);
        END IF;
        
        CLOSE preferenceCursor;
    END LOOP read_students;

    CLOSE studentCursor;
END