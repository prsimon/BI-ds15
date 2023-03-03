
USE BoxOffice

--1. Get the top ten popular movies where the original language was English.
SELECT TOP (10) [movie_id], [original_title], [popularity]
FROM [dbo].[movies]
WHERE [original_language] = 'en'
ORDER BY [popularity] DESC

--2. Calculate the number of movies that were released by year.
SELECT YEAR(release_date) as release_year, COUNT(movie_id) as N_of_movies
FROM dbo.movies
GROUP BY YEAR(release_date) 

--3. Calculate the number of movies that were released by month.
SELECT MONTH(release_date) as release_month, COUNT(movie_id) as N_of_movies
FROM dbo.movies
GROUP BY MONTH(release_date)
ORDER BY release_month

-- 4. Create a new variable based on runtime, where the movies are categorized into the following categories: 0 = Unknown, 1-50 = Short, 51-120 Average, >120 Long.
SELECT runtime,
CASE
    WHEN runtime = 0 THEN 'Unknown'
    WHEN runtime BETWEEN 1 AND 50 THEN 'Short'
    WHEN runtime BETWEEN 51 AND 120 THEN 'Average'
    WHEN runtime > 120 THEN 'Long'
END AS runtime_txtual
FROM dbo.movies

-- 5. For each year, calculate :
        -- a.The dense rank, based on the revenue (descending order)
        SELECT YEAR(release_date) AS release_year, revenue,
        DENSE_RANK() OVER (PARTITION BY YEAR(release_date) ORDER BY revenue DESC) AS dr_revenue
        FROM dbo.movies
        order by revenue DESC

        --b. The yearly revenue's sum of the movies
        SELECT YEAR(release_date) AS release_year,
        SUM (CONVERT (BIGINT, revenue)) AS revenue_sum
        FROM dbo.movies
        GROUP BY YEAR(release_date)

        --c. The percent of the revenue with respect to the yearly annual revenue (b).
        SELECT movie_id, original_title,YEAR(release_date) as release_year, revenue, revenue/
        SUM(CONVERT(float,revenue)) OVER (PARTITION BY YEAR(release_date))*100 as prc_of_year
        FROM dbo.movies
        ORDER by release_year

--6. For each movie, create a table that contains the following features:
        --a. Count the number of female actors in the movie.
        --b. Count the number of male actors in the movie. 
        --c. Calculate the ratio of male vs women (female count / male count)
              
        SELECT t4.*,
            CASE WHEN t4.nMen != 0 THEN (t4.nWomen / convert(float,t4.nMen))
            END AS gender_ratio
        FROM (SELECT 
            t1.movie_id, t1.original_title,
            SUM(CASE WHEN t3.gender = 1 THEN 1 ELSE 0 END) AS nWomen,
            SUM(CASE WHEN t3.gender = 2 THEN 1 ELSE 0 END) AS nMen
            FROM dbo.movies as t1
        INNER JOIN dbo.movies_crew as t2
            ON t1.movie_id = t2.movie_id
        INNER JOIN dbo.crew_dim as t3
            ON t3.crew_id = t2.crew_id
        GROUP BY t1.movie_id, t1.original_title
        ) AS t4
        GROUP BY t4.movie_id, t4.original_title, t4.nMen, t4.nWomen
        ORDER by movie_id
      
        
                
-- 7. For each of the following languages: [en, fr, es, de, ru, it, ja]: Create a column and set it to 1 if the movie has a translation** to the language and zero if not. 

    SELECT movie_id, t4.en, t4.fr, t4.es, t4.de, t4.ru, t4.it, t4.ja 
    FROM (SELECT * 
    FROM dbo.movie_languages WHERE sw_original_lang = 0 ) as t5
    PIVOT (  
    count(sw_original_lang) 
    FOR   
    iso_639_1 IN ( [en], [fr],[es],[de], [ru], [it], [ja])  
    ) AS t4
    

--8. For each of the crew departments, create a column and count the total number of individuals for each movie. Create a view with this query

CREATE VIEW dsuser29.crew_dep_V AS (
    SELECT movie_id, sum(t3.Actors) as Actors, sum(t3.Art) as ART, sum(t3.Camera) as Camera, sum(t3.[Costume & Make-Up]) as costum_and_makeup,
    sum(t3.Crew) as Crew, sum(t3.Directing) as Directing, sum(t3.Editing) as Editing, sum(t3.Lighting) as Lighting, sum(t3.Production) as Production,
    sum(t3.Sound) as Sound, sum (t3.[Visual Effects]) as Visual_Effects, sum(t3.Writing) as Writing
    FROM(
    SELECT movie_id , t2.[Costume & Make-Up], t2.Crew, t2.Sound, t2.Actors, t2.Art, t2.Production, t2.[Visual Effects],
    t2.Lighting, t2.Camera, t2.Writing, t2.Editing, t2.Directing
    FROM movies_crew as t1
    PIVOT (
        COUNT(crew_id)
        FOR 
        [department] IN ([Costume & Make-Up], [Crew], [Sound], [Actors], [Art], [Production],  [Visual Effects],
        [Lighting], [Camera], [Writing], [Editing], [Directing])
    ) as t2) as t3
    GROUP by movie_id)

SELECT * FROM dsuser29.crew_dep_V