select distinct(subject) from TuteroStudentFeedbackData

select session_type, count(student_id) as jumlah_null
from TuteroStudentFeedbackData
where comments is null and rating is null
group by session_type

select session_type, count(student_id) as jumlah_null
from TuteroStudentFeedbackData
where comments is not null and rating is not null
group by session_type

-- Mengisi missing value pada rating 
--1. mengubah rentang rating
UPDATE TuteroStudentFeedbackData
SET rating = 
    CASE 
        WHEN rating = 10 THEN 1
        WHEN rating = 20 THEN 2
        WHEN rating = 30 THEN 3
        WHEN rating = 40 THEN 4
        WHEN rating = 50 THEN 5
        ELSE rating  -- Biarkan tetap sama kalau ada nilai lain
    END;

--cek modus
select rating, count(*) as jumlah
from TuteroStudentFeedbackData
group by rating
order by rating

--cek rata-rata
select AVG(rating) as avg_rating
from TuteroStudentFeedbackData

--cek median
SELECT rating AS median_rating
FROM (
    SELECT rating, 
           ROW_NUMBER() OVER (ORDER BY rating) AS row_num,
           COUNT(*) OVER () AS total_count
    FROM TuteroStudentFeedbackData
) subquery
WHERE row_num = (total_count / 2) OR row_num = ((total_count / 2) + 1);


-- karena sudah cek mean=2,9 ~ 3. median=2, modus=3. maka missing value akan diisi dengan nilai 3
select tutor_name, avg(rating) as rate, count(case when rating is null then 1 END) as jumlah_null
from TuteroStudentFeedbackData
group by tutor_name


--mengisi nilai null dengan nilai rata-rata rating per tutor
with cte as(
select tutor_name, round(avg(rating),0) as avg_rating
from TuteroStudentFeedbackData
group by tutor_name
)

update TuteroStudentFeedbackData
set rating = avg_rating
from TuteroStudentFeedbackData r
join cte a
on r.tutor_name = a.tutor_name
where r.rating is null

select * from TuteroStudentFeedbackData

--mengisi null pada comments dengan "no comments"
update TuteroStudentFeedbackData
set comments = 'No Feedback'
where comments is null


--Bagaimana distribusi durasi sesi (berapa rata-rata lama sesi, dan apakah ada sesi yang sangat panjang atau pendek)?
select avg(duration_minutes) as avg_session
from TuteroStudentFeedbackData

select min(duration_minutes) as minimum_duration, 
max(duration_minutes) as maximum_duration, 
avg(duration_minutes) as avg_session
from TuteroStudentFeedbackData

select subject, min(duration_minutes) as minimum_duration, 
max(duration_minutes) as maximum_duration, 
avg(duration_minutes) as avg_session
from TuteroStudentFeedbackData
group by subject

select session_type, avg(duration_minutes) as duration_minutes
from TuteroStudentFeedbackData
group by session_type


--melihat subject dengan durasinya
select subject, avg(duration_minutes) as avg_duration, round(avg(rating), 2) as avg_rate
from TuteroStudentFeedbackData
group by subject
order by avg_duration desc



--Berapa banyak sesi yang dilakukan per jenis sesi (one-on-one vs group)?
select session_type, count(session_id) as banyak_sesi
from TuteroStudentFeedbackData
group by session_type


--Bagaimana tren jumlah sesi per bulan? Apakah ada pola musiman dalam penggunaan layanan Tutero?
select 
year(session_date) as tahun,
month(session_date) as bulan,
count(session_id) as jumlah_session
from TuteroStudentFeedbackData
group by year(session_date), month(session_date)
order by jumlah_session

select 
year(session_date) as tahun,
month(session_date) as bulan,
count(session_id) as jumlah_session
from TuteroStudentFeedbackData
where session_type = 'group'
group by year(session_date), month(session_date)
order by bulan







--PERFORMA TUTOR DAN MATA PELAJARAN
--Tutor mana yang memiliki rating tertinggi dan terendah?
select TOP 1 tutor_name, avg(rating) as avg_rate
from TuteroStudentFeedbackData
group by tutor_name
order by avg_rate DESC

select TOP 1 tutor_name, round(avg(rating),2) as avg_rate
from TuteroStudentFeedbackData
group by tutor_name
order by avg_rate ASC

select avg(rating) as avg_rate
from TuteroStudentFeedbackData

select tutor_id, round(avg(rating),2) as rate_tutor
from TuteroStudentFeedbackData
group by tutor_id
having avg(rating)<2.962





--Mata pelajaran mana yang mendapatkan rating tertinggi dan terendah?
select top 1 subject, round(avg(rating),2) as avg_rate
from TuteroStudentFeedbackData
group by subject
order by avg_rate desc

select top 1 subject, round(avg(rating),2) as avg_rate
from TuteroStudentFeedbackData
group by subject
order by avg_rate

--rata-rata rating per subject
select subject, round(avg(rating),2) as avg_rate
from TuteroStudentFeedbackData
group by subject
order by avg_rate


--Apakah ada tutor tertentu yang lebih sering mengajar sesi **group** dibanding **one-on-one**?
with cte as (
select distinct(tutor_name), sum(case when session_type='group' then 1 else 0 end) as grup, 
sum(case when session_type='one-on-one' then 1 else 0 end) as one_on_one
from TuteroStudentFeedbackData
group by tutor_name
)
select distinct(t.tutor_name), c.grup, c.one_on_one
from TuteroStudentFeedbackData t
join cte c
on t.tutor_name = c.tutor_name
where grup < one_on_one


--Bagaimana sebaran durasi sesi per mata pelajaran? Apakah mata pelajaran tertentu memiliki sesi yang lebih lama?
select subject, avg(duration_minutes) as durasi
from TuteroStudentFeedbackData
group by subject
order by durasi desc








--HUBUNGAN ANTAR VARIABEL
--Apakah sesi **one-on-one** mendapatkan rating lebih tinggi dibanding sesi **group**?
select session_type, round(avg(rating),2) as avg_rate
from TuteroStudentFeedbackData
group by session_type

--Apakah tutor dengan rating rendah memiliki pola tertentu, seperti durasi sesi yang lebih pendek atau lebih banyak sesi grup?
select TOP 1 tutor_name, avg(rating) as avg_rate, avg(duration_minutes) as durasi
from TuteroStudentFeedbackData
group by tutor_name
order by avg_rate DESC

select tutor_name, subject, duration_minutes, rating
from TuteroStudentFeedbackData
where tutor_name = 'Kathleen Todd'

select tutor_name, subject, duration_minutes, rating
from TuteroStudentFeedbackData
where tutor_name = 'Carlos Sims'


--apakah durasi mempenagruhi rating?
SELECT 
    duration_range,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(*) AS session_count
FROM (
    SELECT 
        CASE 
            WHEN duration_minutes BETWEEN 0 AND 30 THEN '0-30 min'
            WHEN duration_minutes BETWEEN 31 AND 45 THEN '31-45 min'
            WHEN duration_minutes BETWEEN 46 AND 60 THEN '46-60 min'
            WHEN duration_minutes BETWEEN 61 AND 75 THEN '61-75 min'
            WHEN duration_minutes > 75 THEN '76+ min'
        END AS duration_range,
        rating
    FROM TuteroStudentFeedbackData
    WHERE rating IS NOT NULL  -- Menghindari nilai NULL agar perhitungan lebih akurat
) AS subquery
GROUP BY duration_range
ORDER BY duration_range;


-- apakah ada korelasi antara session_type, subject, rating?
SELECT 
    subject, 
    session_type, 
    round(AVG(rating),2) AS rate
FROM TuteroStudentFeedbackData
WHERE rating IS NOT NULL  -- Hindari nilai NULL agar hasil lebih akurat
GROUP BY subject, session_type
ORDER BY subject, rate DESC;


SELECT 
    session_type,
    CASE 
        WHEN duration_minutes BETWEEN 0 AND 30 THEN '0-30 min'
        WHEN duration_minutes BETWEEN 31 AND 45 THEN '31-45 min'
        WHEN duration_minutes BETWEEN 46 AND 60 THEN '46-60 min'
        WHEN duration_minutes BETWEEN 61 AND 75 THEN '61-75 min'
        ELSE '76+ min'
    END AS duration_range,
    COUNT(*) AS session_count
FROM TuteroStudentFeedbackData
GROUP BY 
    session_type,
    CASE 
        WHEN duration_minutes BETWEEN 0 AND 30 THEN '0-30 min'
        WHEN duration_minutes BETWEEN 31 AND 45 THEN '31-45 min'
        WHEN duration_minutes BETWEEN 46 AND 60 THEN '46-60 min'
        WHEN duration_minutes BETWEEN 61 AND 75 THEN '61-75 min'
        ELSE '76+ min'
    END
ORDER BY session_type, duration_range;




