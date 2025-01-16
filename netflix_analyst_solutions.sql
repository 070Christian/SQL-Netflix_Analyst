-- Netflix project

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix

(
	show_id	VARCHAR(6),
	type    VARCHAR(10),
	title	VARCHAR(150),
	director VARCHAR(200),
	casts	VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year	INT,
	rating	VARCHAR(10),
	duration	VARCHAR(15),
	listed_in	VARCHAR(100),
	description VARCHAR(250)
);
	SELECT * FROM netflix;
	
	-- 1. Calculate the number of Movies vs TV Shows
	
	SELECT 
		type,
		COUNT(*)
	FROM netflix
	GROUP BY 1
	
	-- 2. Identify the most frequent rating for both movies and TV shows.
	
	WITH RatingCounts AS (
	    SELECT 
	        type,
	        rating,
	        COUNT(*) AS rating_count
	    FROM netflix
	    GROUP BY type, rating
	),
	RankedRatings AS (
	    SELECT 
	        type,
	        rating,
	        rating_count,
	        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
	    FROM RatingCounts
	)
	SELECT 
	    type,
	    rating AS most_frequent_rating
	FROM RankedRatings
	WHERE rank = 1;
	
	-- 3. List all movies released in a specified year (e.g., 2020).
	
	SELECT * 
	FROM netflix
	WHERE release_year = 2020
	
	-- 4. Identify the top 5 countries with the most content available on Netflix.
	
	SELECT * 
	FROM
	(
		SELECT 
			-- country,
			UNNEST(STRING_TO_ARRAY(country, ',')) as country,
			COUNT(*) as total_content
		FROM netflix
		GROUP BY 1
	)as t1
	WHERE country IS NOT NULL
	ORDER BY total_content DESC
	LIMIT 5
	
	-- 5. Find the movie with the longest duration.
	
	SELECT 
		*
	FROM netflix
	WHERE type = 'Movie'
	ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
	
	-- 6. Retrieve all content added to Netflix in the past 5 years.
	
	SELECT
	*
	FROM netflix
	WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'
	
	-- 7. List all movies and TV shows directed by 'Domee Shi'.
	
	SELECT *
	FROM
	(
	
	SELECT 
		*,
		UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
	FROM 
	netflix
	)
	WHERE 
		director_name = 'Domee Shi'
	
	-- 8. Identify all TV shows that have more than 5 seasons.
	
	SELECT *
	FROM netflix
	WHERE 
		TYPE = 'TV Show'
		AND
		SPLIT_PART(duration, ' ', 1)::INT > 5
		
	-- 9. Count the number of content items in each genre.
	
	SELECT 
		UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
		COUNT(*) as total_content
	FROM netflix
	GROUP BY 1
	
	-- 10. Calculate the average number of content releases per year in the United States on Netflix and return the top 5 years with the highest average.
	
	SELECT 
		country,
		release_year,
		COUNT(show_id) as total_release,
		ROUND(
			COUNT(show_id)::numeric/
									(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
			,2
			)
			as avg_release
	FROM netflix
	WHERE country = 'United States' 
	GROUP BY country, 2
	ORDER BY avg_release DESC 
	LIMIT 5
	
	-- 11. List all movies classified as documentaries.
	
	SELECT * FROM netflix
	WHERE listed_in LIKE '%Documentaries'
	
	-- 12. Find all content that has no director listed.
	
	SELECT * FROM netflix
	WHERE director IS NULL
	
	-- 13. Determine how many movies actor 'Adam Sandler' has appeared in during the last 10 years.
	
	SELECT * FROM netflix
	WHERE 
		casts LIKE '%Adam Sandler%'
		AND 
		release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
	-- 14. Identify the top 10 actors who have appeared in the highest number of Indian-produced movies.
	
	SELECT 
		UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
		COUNT(*)
	FROM netflix
	WHERE country = 'United States'
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 10
	
	-- 15. Classify content based on the presence of the words 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good', and count the number of items in each category.
	
	SELECT 
	    category,
		TYPE,
	    COUNT(*) AS content_count
	FROM (
	    SELECT 
			*,
	        CASE 
	            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
	            ELSE 'Good'
	        END AS category
	    FROM netflix
	) AS categorized_content
	GROUP BY 1,2
	ORDER BY 2

