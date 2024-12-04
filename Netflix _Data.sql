--Netflix Project

create table netflix(show_id varchar(10)	,type varchar(10)	,title varchar(150)	,director varchar(250)	,casts varchar(1000),	
country varchar(150),	date_added varchar(50),	release_year integer, rating varchar(10),	duration varchar(50),
listed_in varchar(150), description varchar(250));

select * from netflix;
select count(*) as total_count from netflix

Business Problems 

--1-Count the number of movies vs TV Shows

select type, count(type) as count from netflix group by type;

--2-Find the most common ratings for movies and TV shows

--select type, rating, count(rating) as rating_count from netflix group by rating, type order by rating_count desc;

select type, rating from(select type, rating, count(rating), rank() over(partition by type order by count(rating) desc) as ranking from netflix
group by type, rating) as t1 where ranking = 1;



--3-List all movies released in a specific year (e.g.,2020)

select * from netflix where type = 'Movie' and release_year = '2020';


---4-Find the top 5 countrires with the most content on Netflix

select unnest(string_to_array(country, ',')) as country, count(*) as total_content from netflix group by 1 order by 2 desc limit 5;


--5-Indentify the longest movie duration?

select * from netflix where type = 'Movie' order by duration desc;

OR

select * from netflix where type = 'Movie' and duration = (select max(duration) from netflix) limit 1;

select * from netflix where type = 'TV Show' order by duration desc limit 1;



---6-Find content addes the last 5 years

select * from netflix where to_date(date_added, 'Month DD, YYY') >= current_date - interval '5 years';


---7-Find all the movies/TV shows by director 'Rajiv Chilaka'

select * from netflix where director ilike '%Rajiv Chilaka%';



---8-List all TV shows with more than 5 seasons
select * from netflix where type = 'TV Show' and duration > '5 Seasons';

OR

select * from netflix where type = 'TV Show' and split_part(duration, ' ', 1)::numeric > 5; 

--9-Count the number of content items in each genre

select unnest(string_to_array(listed_in, ',')) as genre, count(show_id) as total_count from netflix 
group by 1 order by 2 desc;


---10- retrieve each year and the number of contents released by the United States on Netflix.
select release_year, country, count(*)/count(distinct release_year) as avg_contents_per_year
from netflix where country ilike '%United States' group by release_year, country
order by release_year desc;

select release_year, count(*) as total from netflix where country ilike 'United States' group by release_year
order by 1 desc;


OR

select extract(year from to_date(date_added, 'Month DD, YYY')) as year_of_release, count(*) as total_released, count(*)/count(distinct release_year)
as avg_released from netflix where country ilike '%United States%' group by 1 order by total_released desc;

select extract(year from to_date(date_added, 'Month DD, YYY')) as year_of_release, count(*) as total_released,
count(*)::numeric/(select count(*) from netflix where country = 'India')::numeric*100 as avg_yearly_contents from netflix where country = 'India' 
group by 1;

---11-List all movies that are documentaries
select * from netflix where listed_in ilike '%documentaries%';


--12-Find all content without a director
select * from netflix where director is null;

--13-Find how many movies actor 'Salman Khan' appeared in the last 10 years;
select * from netflix where casts ilike '%Salman Khan%' and release_year > extract(year from current_date) - 10;


--14-Find the top 10 actors who have appeared in the highest number of movies produced in India

select actor, count(*) as movie_count
from(select unnest(string_to_array(casts, ',')) as actor from netflix where type = 'Movie' and country ilike '%United States%') as actor_movies
group by actor order by movie_count desc limit 10;


--15- Cetegorize the content based on the presence of the keywords 'kill' and 'violence' in the description column. Label contnet containig
--these words as 'Bad' and all other as 'Good'. Count how many items fall into each category.
select 
    case
        when description ilike '%kill%' or description ilike '%violence%' then 'Bad'
        else 'Good'
    end as category, 
    count(*) as total_content
from netflix
group by category
order by total_content desc;



 
select * from netflix