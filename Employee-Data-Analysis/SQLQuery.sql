use Data;

SELECT * FROM Employee_Data;
select termdate from Employee_Data 
order by termdate desc;

/* convert data type of termdate to date and 
   remove extra info time and UTC by doing format only yyyymmdd */

update Employee_Data
set termdate=  FORMAT(CONVERT(datetime, LEFT(termdate,19),120 ), 'yyyy-MM-dd'); 

alter table Employee_Data
add new_termdate Date;

--copy converted time values to new_termdate

update Employee_Data
set new_termdate= CASE 
	when termdate is not null and isdate(termdate)=1	then cast (termdate as datetime)  else Null end;

--create new column age

alter table Employee_Data
add age nvarchar(50);

--populate new column with age

update  Employee_Data
set age= DATEDIFF(year,birthdate,getdate());


-- QUESTIONS TO ANSWER FROM THE DATA

-- 1) What's the age distribution in the company?

select 
min(age) as Youngest,
max(age) as Oldest
from Employee_Data;

--age group by gender

select age
from Employee_Data
order by age;


select age_group, count(*) as count
from
(select
case when age>=21 and age<=30 then '21 to 30'
	 when age>=31 and age<=40 then '31 to 40'
     when age>=41 and age<=50 then '41 to 50'
else '50+'
END as age_group
from Employee_Data
where new_termdate is NULL) as subquery
group by age_group
order by age_group;

--Age group by gender

select age_group, gender, count(*) as count
from
(select
case when age>=21 and age<=30 then '21 to 30'
	 when age>=31 and age<=40 then '31 to 40'
     when age>=41 and age<=50 then '41 to 50'
else '50+'
END as age_group, gender
from Employee_Data
where new_termdate is NULL) as subquery
group by age_group, gender
order by age_group, gender;

-- 2) What's the gender breakdown in the company?

select gender, count(*) as count
from  Employee_Data
where new_termdate is  null
group by gender
order by gender;

-- 3) How does gender vary across departments and job titles?

--gender vary across departments

select department,gender, count(*) as count
from Employee_Data
where new_termdate is  null
group  by department,gender
order by department,gender;

--gender vary across job titles

select department,jobtitle,gender, count(*) as count
from Employee_Data
where new_termdate is  null
group  by department,jobtitle,gender
order by department,jobtitle,gender;

--4) What's the race distribution in the company?

SELECT race, count(*) AS count
FROM Employee_Data
WHERE new_termdate IS NULL 
GROUP BY race
ORDER BY count(race) DESC;

-- 5) What's the average length of employment in the company?

SELECT AVG(DATEDIFF(year, hire_date, new_termdate)) AS tenure
 FROM Employee_Data
 WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE();

 -- 6) Which department has the highest turnover rate?

 -- get total count
-- get terminated count
-- terminated count/total count

-- department wise terminated count
SELECT department, count(*) AS total_count,
   SUM(CASE
        WHEN new_termdate IS NOT NULL AND new_termdate <= getdate()
		THEN 1 ELSE 0
		END
   ) AS terminated_count
   FROM Employee_Data
   group by department;

SELECT department, total_count, terminated_count,
 round(CAST(terminated_count AS FLOAT)/total_count, 2) * 100 AS turnover_rate
FROM 
   (SELECT department, count(*) AS total_count,
   SUM(CASE
        WHEN new_termdate IS NOT NULL AND new_termdate <= getdate()
		THEN 1 ELSE 0
		END
   ) AS terminated_count
  FROM Employee_Data
  GROUP BY department
  ) AS Subquery
ORDER BY turnover_rate DESC;

--turnover rate dept wise only
SELECT department,
 round(CAST(terminated_count AS FLOAT)/total_count, 2) * 100 AS turnover_rate
FROM 
   (SELECT department, count(*) AS total_count,
   SUM(CASE
        WHEN new_termdate IS NOT NULL AND new_termdate <= getdate()
		THEN 1 ELSE 0
		END
   ) AS terminated_count
  FROM Employee_Data
  GROUP BY department
  ) AS Subquery
ORDER BY turnover_rate DESC;

-- 7) What is the tenure distribution for each department?

SELECT department, AVG(DATEDIFF(year, hire_date, new_termdate)) AS tenure
FROM Employee_Data
WHERE 
    new_termdate IS NOT NULL 
    AND new_termdate <= GETDATE()
GROUP BY department
ORDER BY tenure DESC;

--8) How many employees work remotely for each department?

select department,location, count(*) as count
from Employee_Data
where location='Remote' and new_termdate IS NULL
group by department,location;

SELECT location, count(*) AS count
FROM Employee_Data
WHERE new_termdate IS NULL
GROUP BY location;

-- 9) What's the distribution of employees across different states?

SELECT location_state, count(*) AS count
FROM Employee_Data
WHERE new_termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;

-- 10) How are job titles distributed in the company?

SELECT jobtitle, count(*) AS count
FROM Employee_Data
WHERE new_termdate IS NULL
GROUP BY jobtitle
ORDER BY count DESC;

--11) How have employee hire counts varied over time?

--calculate hires
--calculate terminations
--(hires-terminations)/hires percent hire change


select year(hire_date) as year ,count(*) as hires,
sum(case
	when new_termdate is not null and new_termdate<=getdate() then 1 else 0
	end) as terminations
from Employee_Data
group by year(hire_date)
order by year(hire_date);


select hires, terminations, (hires-terminations) as net_change,
	round(cast(hires-terminations as float)/hires,2)*100 as percent_hire_change
from
	(select year(hire_date) as year,count(*) as hires,
	sum(case
	when new_termdate is not null and new_termdate<=getdate() then 1 else 0
	end) as terminations
	from Employee_Data
	group by year(hire_date) ) as subquery
order by percent_hire_change;







