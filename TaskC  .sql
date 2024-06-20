1.
WITH ProjectGroups AS (
    SELECT
        Task_ID,
        Start_Date,
        End_Date,
        ROW_NUMBER() OVER (ORDER BY Start_Date) - 
        ROW_NUMBER() OVER (ORDER BY Task_ID) AS ProjectID
    FROM Projects
)
, ProjectsAggregated AS (
    SELECT
        MIN(Start_Date) AS Project_Start,
        MAX(End_Date) AS Project_End,
        COUNT(*) AS Duration
    FROM ProjectGroups
    GROUP BY ProjectID
)
SELECT
    Project_Start,
    Project_End
FROM ProjectsAggregated
ORDER BY
    Duration ASC,
    Project_Start ASC;

 2.
 SELECT
    Students.Name
FROM
    Students
JOIN
    Friends ON Students.ID = Friends.ID
JOIN
    Packages AS StudentPackages ON Students.ID = StudentPackages.ID
JOIN
    Packages AS FriendPackages ON Friends.Friend_ID = FriendPackages.ID
WHERE
    FriendPackages.Salary > StudentPackages.Salary
ORDER BY
    FriendPackages.Salary;


3.
SELECT f1.X, f1.Y FROM Functions AS f1 
WHERE f1.X = f1.Y AND
(SELECT COUNT(*) FROM Functions WHERE X = f1.X AND Y = f1.Y) > 1
UNION
SELECT f1.X, f1.Y from Functions AS f1
WHERE EXISTS(SELECT X, Y FROM Functions WHERE f1.X=Y AND f1.Y = X AND f1.X< X)
ORDER BY X;


4.
SELECT con.contest_id, con.hacker_id, con.name, SUM(sg.total_submissions), SUM(sg.total_accepted_submissions),
SUM(vg.total_views), SUM(vg.total_unique_views)
FROM Contests AS con 
JOIN Colleges AS col
ON con.contest_id = col.contest_id
JOIN Challenges AS cha 
ON cha.college_id = col.college_id
LEFT JOIN
(SELECT ss.challenge_id, SUM(ss.total_submissions) AS total_submissions, SUM(ss.total_accepted_submissions) AS total_accepted_submissions FROM 
Submission_Stats AS ss GROUP BY ss.challenge_id) AS sg
ON cha.challenge_id = sg.challenge_id
LEFT JOIN
(SELECT vs.challenge_id, SUM(vs.total_views) AS total_views, SUM(total_unique_views) AS total_unique_views FROM View_Stats AS vs GROUP BY vs.challenge_id) AS vg
ON cha.challenge_id = vg.challenge_id
GROUP BY con.contest_id, con.hacker_id, con.name
HAVING SUM(sg.total_submissions)+
       SUM(sg.total_accepted_submissions)+
       SUM(vg.total_views)+
       SUM(vg.total_unique_views) > 0
ORDER BY con.contest_id;



5.
SELECT SUBMISSION_DATE,
(SELECT COUNT(DISTINCT HACKER_ID)
 FROM SUBMISSIONS S2
 WHERE S2.SUBMISSION_DATE = S1.SUBMISSION_DATE AND
(SELECT COUNT(DISTINCT S3.SUBMISSION_DATE)
 FROM SUBMISSIONS S3 WHERE S3.HACKER_ID = S2.HACKER_ID AND S3.SUBMISSION_DATE < S1.SUBMISSION_DATE) = DATEDIFF(S1.SUBMISSION_DATE , '2016-03-01')),
(SELECT HACKER_ID FROM SUBMISSIONS S2 WHERE S2.SUBMISSION_DATE = S1.SUBMISSION_DATE
GROUP BY HACKER_ID ORDER BY COUNT(SUBMISSION_ID) DESC, HACKER_ID LIMIT 1) AS TMP,
(SELECT NAME FROM HACKERS WHERE HACKER_ID = TMP)
FROM
(SELECT DISTINCT SUBMISSION_DATE FROM SUBMISSIONS) S1
GROUP BY SUBMISSION_DATE;


6.
select ROUND(ABS(MAX(LAT_N) - MIN(LAT_N)) + ABS(MAX(LONG_W) - MIN(LONG_W)),4) FROM STATION;


7.
SELECT LISTAGG(PRIME_NUMBER,'&') WITHIN GROUP (ORDER BY PRIME_NUMBER)
FROM(SELECT L PRIME_NUMBER
FROM(SELECT LEVEL L
FROM DUALCONNECT BY LEVEL <= 1000),
(SELECT LEVEL M FROM DUAL CONNECT BY LEVEL <= 1000)
WHERE M <= L
GROUP BY L
HAVING COUNT(CASE WHEN L/M = TRUNC(L/M) THEN 'Y' END) = 2
ORDER BY L);


8.
SELECT MIN(IF(Occupation = 'Doctor',Name,NULL)),MIN(IF(Occupation = 'Professor',Name,NULL)),MIN(IF(Occupation = 'Singer',Name,NULL)),MIN(IF(Occupation = 'Actor',Name,NULL)) 
FROM(
    SELECT ROW_NUMBER() OVER(PARTITION BY Occupation ORDER BY Name) AS row_num,Name,Occupation
    FROM OCCUPATIONS) AS ord
GROUP BY row_num


9.
select N,
       case when P is null then 'Root'
            when (select count(*) from BST where P = B.N) > 0 then  
            'Inner'
            else 'Leaf'
       end
from BST as B 
order by N;


10.
select c.company_code, c.founder,
       count(distinct l.lead_manager_code),
       count(distinct s.senior_manager_code),
       count(distinct m.manager_code),
       count(distinct e.employee_code)
from Company as c 
join Lead_Manager as l 
on c.company_code = l.company_code
join Senior_Manager as s
on l.lead_manager_code = s.lead_manager_code
join Manager as m 
on m.senior_manager_code = s.senior_manager_code
join Employee as e
on e.manager_code = m.manager_code
group by c.company_code, c.founder
order by c.company_code


11.
Select S.Name
From ( Students S join Friends F using(ID)
 join Packages P1 on S.ID=P1.ID
 join Packages P2 on F.Friend_ID=P2.ID)
Where P2.Salary > P1.Salary
Order By P2.Salary;

12.
WITH TotalCosts AS (
    SELECT
        JobFamily,
        SUM(Cost) AS TotalCost
    FROM
        JobCosts
    GROUP BY
        JobFamily
),
IndiaCosts AS (
    SELECT JobFamily,SUM(Cost) AS IndiaCost
    FROM
        JobCosts
    WHERE
        Location = 'India'
    GROUP BY
        JobFamily
),
InternationalCosts AS (
    SELECT JobFamily,SUM(Cost) AS InternationalCost
    FROM
        JobCosts
    WHERE
        Location = 'International'
    GROUP BY
        JobFamily
)
SELECT
    TC.JobFamily,
    COALESCE(IC.IndiaCost, 0) * 100.0 / TC.TotalCost AS IndiaCostPercentage,
    COALESCE(IntC.InternationalCost, 0) * 100.0 / TC.TotalCost AS InternationalCostPercentage
FROM
    TotalCosts TC
LEFT JOIN
    IndiaCosts IC ON TC.JobFamily = IC.JobFamily
LEFT JOIN
    InternationalCosts IntC ON TC.JobFamily = IntC.JobFamily;


13.
WITH MonthlyFinancials AS (
    SELECT BU, DATE_TRUNC('month', Date) AS Month,Type,SUM(Amount) AS TotalAmount
    FROM
        Financials
    GROUP BY
        BU,
        DATE_TRUNC('month', Date),
        Type
),
CostRevenueRatio AS (
    SELECT BU,Month,SUM(CASE WHEN Type = 'Cost' THEN TotalAmount ELSE 0 END) AS TotalCost,SUM(CASE WHEN Type = 'Revenue' THEN TotalAmount ELSE 0 END) AS TotalRevenue
    FROM
        MonthlyFinancials
    GROUP BY
        BU,
        Month
)
SELECT BU,Month,TotalCost,TotalRevenue,
    CASE
        WHEN TotalRevenue = 0 THEN NULL
        ELSE TotalCost / TotalRevenue
    END AS CostRevenueRatio
FROM
    CostRevenueRatio
ORDER BY BU,Month;


14.
SELECT
    SubBand,
    COUNT(EmployeeID) AS Headcount,
    ROUND((COUNT(EmployeeID) * 100.0 / SUM(COUNT(EmployeeID)) OVER ()), 2) AS PercentageHeadcount
FROM
    Employees
GROUP BY
    SubBand
ORDER BY
    SubBand;


15.
SELECT *
FROM table
WHERE 
(sal IN 
  (
    SELECT TOP (5) sal
    FROM table as table1
    GROUP BY sal
    ORDER BY sal DESC
  )
)


16.
UPDATE MyTable
SET ColumnA = ColumnA + ColumnB,
    ColumnB = ColumnA - ColumnB,
    ColumnA = ColumnA - ColumnB;


17.
#create a login 
USE master;
CREATE LOGIN YourLoginName WITH PASSWORD = 'YourPassword';
# Create a User in a Database
CREATE USER YourLoginName FOR LOGIN YourLoginName;

# Grant DBO Permissions
ALTER ROLE db_owner ADD MEMBER YourLoginName;


18.
SELECT BU, Month, SUM(EmployeeCost * EmployeeCount) / SUM(EmployeeCount) AS WeightedAverageCost
FROM EmployeeCosts
GROUP BY BU, Month
ORDER BY BU, Month;

19.
WITH ActualAverage AS (
    SELECT AVG(Salary) AS AvgActualSalary
    FROM EMPLOYEES
),
MiscalculatedAverage AS (
    SELECT AVG(CAST(REPLACE(CAST(Salary AS VARCHAR), '0', '') AS FLOAT)) AS AvgMiscalculatedSalary
    FROM EMPLOYEES
)
SELECT CEILING(ABS(AvgActualSalary - AvgMiscalculatedSalary)) AS ErrorAmount
FROM ActualAverage, MiscalculatedAverage;


20.
INSERT INTO DestinationTable (Column1, Column2)
SELECT Column1, Column2
FROM SourceTable
WHERE [Criteria to identify new data];


