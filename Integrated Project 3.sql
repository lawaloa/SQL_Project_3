/*Integrating the Auditor's report
To make sure we have the same names, use this query to create the table first, then Import the CSV file:*/

DROP TABLE IF EXISTS md_water_services.auditor_report;
CREATE TABLE md_water_services.auditor_report (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);


/*Wow! First off, it looks like we have 1620 records, or sites that they re-visited. I see a location_id, type of water source at that location, and the
quality score of the water source, that is now independently measured. Our auditor also investigated each site a bit by speaking to a few locals.
Their statements are also captured in his results.

We need to tackle a couple of questions here.
1. Is there a difference in the scores?
2. If so, are there patterns?

For the first question, we will have to compare the quality scores in the water_quality table to the auditor's scores. The auditor_report table
used location_id, but the quality scores table only has a record_id we can use. The visits table links location_id and record_id, so we
can link the auditor_report table and water_quality using the visits table.*/

SELECT 
	v.location_id AS visit_locationid,
    v.record_id AS visit_recordid,
    a.location_id AS auditor_locationid,
    a.true_water_source_score AS auditor_water_score
FROM visits AS v
JOIN auditor_report AS a
ON v.location_id = a.location_id;

/*Now that we have the record_id for each location, our next step is to retrieve the corresponding scores from the water_quality table. We
are particularly interested in the subjective_quality_score. To do this, we'll JOIN the visits table and the water_quality table, using the
record_id as the connecting key.*/

SELECT 
	v.location_id AS visit_locationid,
    v.record_id AS visit_recordid,
    a.location_id AS auditor_locationid,
    a.true_water_source_score AS auditor_water_score,
    w.subjective_quality_score AS surveyor_score
FROM visits AS v
JOIN auditor_report AS a
ON v.location_id = a.location_id
JOIN
	water_quality AS w
ON v.record_id = w.record_id;

/*It doesn't matter if your columns are in a different format, because we are about to clean this up a bit. Since it is a duplicate, we can drop one of
the location_id columns. Let's leave record_id and rename the scores to surveyor_score and auditor_score to make it clear which scores
we're looking at in the results set.*/

SELECT 
    v.record_id AS visit_recordid,
    a.location_id AS auditor_locationid,
    a.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS surveyor_score
FROM visits AS v
JOIN auditor_report AS a
    ON v.location_id = a.location_id
JOIN water_quality AS w
    ON v.record_id = w.record_id;

/*Ok, let's analyse! A good starting point is to check if the auditor's and exployees' scores agree. There are many ways to do it. We can have a
WHERE clause and check if surveyor_score = auditor_score, or we can subtract the two scores and check if the result is 0.*/

SELECT 
    v.record_id AS visit_recordid,
    a.location_id AS auditor_locationid,
    a.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS surveyor_score
FROM visits AS v
JOIN auditor_report AS a
    ON v.location_id = a.location_id
JOIN water_quality AS w
    ON v.record_id = w.record_id
WHERE (a.true_water_source_score - w.subjective_quality_score = 0);

/*You got 2505 rows right? Some of the locations were visited multiple times, so these records are duplicated here. To fix it, we set visits.visit_count
= 1 in the WHERE clause. Make sure you reference the alias you used for visits in the join.*/

SELECT 
    v.record_id AS visit_recordid,
    a.location_id AS auditor_locationid,
    a.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS surveyor_score
FROM visits AS v
JOIN auditor_report AS a
    ON v.location_id = a.location_id
JOIN water_quality AS w
    ON v.record_id = w.record_id
WHERE (a.true_water_source_score - w.subjective_quality_score = 0)
AND  v.visit_count = 1;

/*With the duplicates removed I now get 1518. What does this mean considering the auditor visited 1620 sites?
I think that is an excellent result. 1518/1620 = 94% of the records the auditor checked were correct!!

But that means that 102 records are incorrect. So let's look at those. You can do it by adding one character in the last query!*/

SELECT 
    v.record_id AS visit_recordid,
    a.location_id AS auditor_locationid,
    a.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS surveyor_score
FROM visits AS v
JOIN auditor_report AS a
    ON v.location_id = a.location_id
JOIN water_quality AS w
    ON v.record_id = w.record_id
WHERE (a.true_water_source_score - w.subjective_quality_score != 0)
AND  v.visit_count = 1;

/*Since we used some of this data in our previous analyses, we need to make sure those results are still valid, now we know some of them are
incorrect. We didn't use the scores that much, but we relied a lot on the type_of_water_source, so let's check if there are any errors there.

So, to do this, we need to grab the type_of_water_source column from the water_source table and call it survey_source, using the
source_id column to JOIN. Also select the type_of_water_source from the auditor_report table, and call it auditor_source.*/

SELECT 
    v.record_id AS visit_recordid,
    a.location_id AS auditor_locationid,
    a.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS surveyor_score,
    a.type_of_water_source AS auditor_source,
    s.type_of_water_source AS survey_source
FROM visits AS v
JOIN auditor_report AS a
    ON v.location_id = a.location_id
JOIN water_quality AS w
    ON v.record_id = w.record_id
JOIN water_source AS s
ON v.source_id = s.source_id
WHERE (a.true_water_source_score - w.subjective_quality_score != 0)
AND  v.visit_count = 1;

/*So what I can see is that the types of sources look the same! So even though the scores are wrong, the integrity of the type_of_water_source
data we analysed last time is not affected.
Once you're done, remove the columns and JOIN statement for water_sources again.*/

SELECT 
    v.record_id AS visit_recordid,
    a.location_id AS auditor_locationid,
    a.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS surveyor_score
FROM visits AS v
JOIN auditor_report AS a
    ON v.location_id = a.location_id
JOIN water_quality AS w
    ON v.record_id = w.record_id
WHERE (a.true_water_source_score - w.subjective_quality_score != 0)
AND  v.visit_count = 1;

/*Linking records to employees
Next up, let's look at where these errors may have come from. At some of the locations, employees assigned scores incorrectly, and those records
ended up in this results set.
I think there are two reasons this can happen.
1. These workers are all humans and make mistakes so this is expected.
2. Unfortunately, the alternative is that someone assigned scores incorrectly on purpose!
In either case, the employees are the source of the errors, so let's JOIN the assigned_employee_id for all the people on our list from the visits
table to our query. Remember, our query shows the shows the 102 incorrect records, so when we join the employee data, we can see which
employees made these incorrect records.*/

SELECT 
    v.record_id AS visit_recordid,
    a.location_id AS auditor_locationid,
    a.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS surveyor_score,
    e.assigned_employee_id AS assigned_employee_id
FROM visits AS v
JOIN auditor_report AS a
    ON v.location_id = a.location_id
JOIN water_quality AS w
    ON v.record_id = w.record_id
JOIN employee AS e
	ON v.assigned_employee_id = e.assigned_employee_id
WHERE (a.true_water_source_score - w.subjective_quality_score != 0)
AND  v.visit_count = 1;

/*So now we can link the incorrect records to the employees who recorded them. The ID's don't help us to identify them. We have employees' names
stored along with their IDs, so let's fetch their names from the employees table instead of the ID's.*/

SELECT 
    v.record_id AS visit_recordid,
    a.location_id AS auditor_locationid,
    a.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS surveyor_score,
    e.employee_name AS employee_name
FROM visits AS v
JOIN auditor_report AS a
    ON v.location_id = a.location_id
JOIN water_quality AS w
    ON v.record_id = w.record_id
JOIN employee AS e
	ON v.assigned_employee_id = e.assigned_employee_id
WHERE (a.true_water_source_score - w.subjective_quality_score != 0)
AND  v.visit_count = 1;

/*Well this query is massive and complex, so maybe it is a good idea to save this as a CTE, so when we do more analysis, we can just call that CTE
like it was a table. Call it something like Incorrect_records. Once you are done, check if this query SELECT * FROM Incorrect_records, gets
the same table back.*/

WITH Incorrect_records AS (
SELECT 
    v.record_id AS visit_recordid,
    a.location_id AS auditor_locationid,
    a.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS surveyor_score,
    e.employee_name AS employee_name
FROM visits AS v
JOIN auditor_report AS a
    ON v.location_id = a.location_id
JOIN water_quality AS w
    ON v.record_id = w.record_id
JOIN employee AS e
	ON v.assigned_employee_id = e.assigned_employee_id
WHERE (a.true_water_source_score - w.subjective_quality_score != 0)
AND  v.visit_count = 1
)

SELECT * FROM Incorrect_records;

/*Let's first get a unique list of employees from this table. 
Think back to the start of your SQL journey to answer this one. I got 17 employees.*/

WITH Incorrect_records AS (
SELECT 
    v.record_id AS visit_recordid,
    a.location_id AS auditor_locationid,
    a.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS surveyor_score,
    e.employee_name AS employee_name
FROM visits AS v
JOIN auditor_report AS a
    ON v.location_id = a.location_id
JOIN water_quality AS w
    ON v.record_id = w.record_id
JOIN employee AS e
	ON v.assigned_employee_id = e.assigned_employee_id
WHERE (a.true_water_source_score - w.subjective_quality_score != 0)
AND  v.visit_count = 1
)
SELECT DISTINCT employee_name
FROM Incorrect_records;

/*Next, let's try to calculate how many mistakes each employee made. So basically we want to count how many times their name is in
Incorrect_records list, and then group them by name, right?*/

WITH Incorrect_records AS (
SELECT 
    v.record_id AS visit_recordid,
    a.location_id AS auditor_locationid,
    a.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS surveyor_score,
    e.employee_name AS employee_name
FROM visits AS v
JOIN auditor_report AS a
    ON v.location_id = a.location_id
JOIN water_quality AS w
    ON v.record_id = w.record_id
JOIN employee AS e
	ON v.assigned_employee_id = e.assigned_employee_id
WHERE (a.true_water_source_score - w.subjective_quality_score != 0)
AND  v.visit_count = 1
)
SELECT 
	employee_name,
    COUNT(employee_name) AS number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name;

/*So let's try to find all of the employees who have an above-average number of mistakes. Let's break it down into steps first:
1. We have to first calculate the number of times someone's name comes up. (we just did that in the previous query). Let's call it error_count.*/

WITH error_count AS(
WITH Incorrect_records AS (
SELECT 
    v.record_id AS visit_recordid,
    a.location_id AS auditor_locationid,
    a.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS surveyor_score,
    e.employee_name AS employee_name
FROM visits AS v
JOIN auditor_report AS a
    ON v.location_id = a.location_id
JOIN water_quality AS w
    ON v.record_id = w.record_id
JOIN employee AS e
	ON v.assigned_employee_id = e.assigned_employee_id
WHERE (a.true_water_source_score - w.subjective_quality_score != 0)
AND  v.visit_count = 1
)
SELECT 
	employee_name,
    COUNT(employee_name) AS number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name
)
SELECT
AVG(number_of_mistakes) AS avg_error_count_per_empl
FROM
error_count;

/*Finaly we have to compare each employee's error_count with avg_error_count_per_empl. We will call this results set our suspect_list.
Remember that we can't use an aggregate result in WHERE, so we have to use avg_error_count_per_empl as a subquery.*/

WITH error_count AS(
WITH Incorrect_records AS (
SELECT 
    v.record_id AS visit_recordid,
    a.location_id AS auditor_locationid,
    a.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS surveyor_score,
    e.employee_name AS employee_name
FROM visits AS v
JOIN auditor_report AS a
    ON v.location_id = a.location_id
JOIN water_quality AS w
    ON v.record_id = w.record_id
JOIN employee AS e
	ON v.assigned_employee_id = e.assigned_employee_id
WHERE (a.true_water_source_score - w.subjective_quality_score != 0)
AND  v.visit_count = 1
)
SELECT 
	employee_name,
    COUNT(employee_name) AS number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name
)
SELECT
employee_name,
number_of_mistakes
FROM
error_count
WHERE
number_of_mistakes > (SELECT
AVG(number_of_mistakes)
FROM
error_count);

-- So, replace WITH with CREATE VIEW like this, and note that I added the statements column to this table in line 8 too:

CREATE VIEW Incorrect_records AS (
SELECT 
    v.record_id AS visit_recordid,
    a.location_id AS auditor_locationid,
    a.true_water_source_score AS auditor_score,
    w.subjective_quality_score AS surveyor_score,
    e.employee_name AS employee_name,
    a.statements AS statements
FROM visits AS v
JOIN auditor_report AS a
    ON v.location_id = a.location_id
JOIN water_quality AS w
    ON v.record_id = w.record_id
JOIN employee AS e
	ON v.assigned_employee_id = e.assigned_employee_id
WHERE (a.true_water_source_score - w.subjective_quality_score != 0)
AND  v.visit_count = 1
);

-- This gives us the same result as the CTE did.
SELECT * FROM Incorrect_records

/*Next, we convert the query error_count, we made earlier, into a CTE. Test it to make sure it gives the same result again, using SELECT * FROM
Incorrect_records. On large queries like this, it is better to build the query, and test each step, because fixing errors becomes harder as the
query grows.*/

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
	employee_name,
	COUNT(employee_name) AS number_of_mistakes
FROM
	Incorrect_records
    /*Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different*/
GROUP BY
	employee_name)
-- Query
SELECT * FROM error_count;

/*3. To find the employees who made more mistakes than the average person, we need the employee's names, the number of mistakes each one
made, and filter the employees with an above-average number of mistakes.*/

WITH error_count AS(
SELECT
	employee_name,
	COUNT(employee_name) AS number_of_mistakes
FROM
	Incorrect_records
GROUP BY
	employee_name)
-- Query
SELECT
employee_name,
number_of_mistakes
FROM
error_count
WHERE
number_of_mistakes > (SELECT
AVG(number_of_mistakes)
FROM
error_count);

/*First, convert the suspect_list to a CTE, so we can use it to filter the records from these four employees. Make sure you get the names of the
four "suspects", and their mistake count as a result, using SELECT employee_name FROM suspect_list.

You should get a column of names back. So let's just recap here...
1. We use Incorrect_records to find all of the records where the auditor and employee scores don't match.
2. We then used error_count to aggregate the data, and got the number of mistakes each employee made.
3. Finally, suspect_list retrieves the data of employees who make an above-average number of mistakes.
Now we can filter that Incorrect_records view to identify all of the records associated with the four employees we identified.

Firstly, let's add the statements column to the Incorrect_records view. Then pull up all of the records where the employee_name is in the
suspect list. HINT: Use SELECT employee_name FROM suspect_list as a subquery in WHERE.*/

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/*Incorrect_records is a view that joins the audit report to the database
for records where the auditor and employees scores are different*/

GROUP BY
employee_name),
suspect_list AS (-- This CTE SELECTS the employees with above−average mistakes
SELECT
employee_name,
number_of_mistakes
FROM
error_count
WHERE
number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))
-- This query filters all of the records where the "corrupt" employees gathered data.
SELECT
employee_name,
auditor_locationid,
statements
FROM
Incorrect_records
WHERE
employee_name in (SELECT employee_name FROM suspect_list);

/*If you have a look, you will notice some alarming statements about these four officials (look at these records: AkRu04508, AkRu07310,
KiRu29639, AmAm09607, for example. See how the word "cash" is used a lot in these statements.
Filter the records that refer to "cash".*/

-- For those with error less than the average
WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/*Incorrect_records is a view that joins the audit report to the database
for records where the auditor and employees scores are different*/
GROUP BY
employee_name)
SELECT
    ir.employee_name,
    ir.statements
FROM Incorrect_records AS ir
JOIN error_count AS ec
    ON ir.employee_name = ec.employee_name
WHERE
    ir.statements LIKE '%cash%'
    AND ec.number_of_mistakes < (SELECT AVG(number_of_mistakes) FROM error_count);

-- For those with error more than the average

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/*Incorrect_records is a view that joins the audit report to the database
for records where the auditor and employees scores are different*/
GROUP BY
employee_name)
SELECT
    ir.employee_name,
    ir.statements
FROM Incorrect_records AS ir
JOIN error_count AS ec
    ON ir.employee_name = ec.employee_name
WHERE
    ir.statements LIKE '%cash%'
    AND ec.number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count);
    
-- I get an empty result, so no one, except the four suspects, has these allegations of bribery.