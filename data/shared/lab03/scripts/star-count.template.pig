-- This script finds how many unique movies each actors/actress has starred in

-- Input: (actor, title, year, num, type, episode, char, gender)
raw = LOAD 'hdfs://cm:9000/uhadoop/shared/imdb/imdb-stars-test.tsv' USING PigStorage('\t') AS (actor, title, year, type, char, gender);
-- Later you can change the above file to 'hdfs://cm:9000/uhadoop/shared/imdb/imdb-stars.tsv' to see the full output
-- but do not run over the full file using pig -x local

-- Line 1: Filter raw to make sure type equals 'movie' 
movies = FILTER raw BY type == 'movie';

-- Line 2: Generate new relation with full movie name (concatenating title+##+year) and actor
full_movies = FOREACH movies GENERATE CONCAT(title,'##',year), actor;

-- Line 3: Group the relation by actor
actor_movies = GROUP full_movies BY actor;

-- Line 4: Count how many movies there are for each actor
actor_movie_count = FOREACH actor_movies GENERATE COUNT($1) AS count, group AS actor; 

-- Line 5: order the count in descending order
ordered_actor_count = ORDER actor_movie_count BY count DESC;

-- output the final count
-- TODO: REPLACE suCarpeta WITH YOUR FOLDER
-- TODO2: when running on the full file replace imdb-stars-test with imdb-stars
STORE ordered_actor_count INTO 'hdfs://cm:9000/uhadoop2026/cc66i/<suCarpeta>/imdb-stars-test/';
