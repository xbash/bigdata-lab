-- This script finds how many unique movies each pair of actors/actresses has starred in together

-- Input: (actor, title, year, type, char, gender)
raw = LOAD 'hdfs://master:9000/inputs/lab03/imdb-stars.tsv' USING PigStorage('\t') AS (actor, title, year, type, char, gender);
-- Later you can change the above file to 'hdfs://cm:9000/uhadoop/shared/imdb/imdb-stars.tsv' to see the full output
-- but do not run over the full file using pig -x local

-- Line 1: Keep only theatrical movies with the minimum fields needed to identify actor and movie
movies = FILTER raw BY type == 'movie' AND actor IS NOT NULL AND title IS NOT NULL AND year IS NOT NULL;

-- Line 2: Create a unique movie identifier and keep only one row per (movie, actor)
movie_actor = FOREACH movies GENERATE CONCAT(title,'##',year) AS movie_id, actor;
unique_movie_actor = DISTINCT movie_actor;

-- Line 3: Group actors by movie
movie_actor_left = FOREACH unique_movie_actor GENERATE movie_id, actor AS actor_a;
movie_actor_right = FOREACH unique_movie_actor GENERATE movie_id, actor AS actor_b;

-- Line 4: Join the same movie against itself and keep only ordered non-reflexive pairs
movie_pairs_joined = JOIN movie_actor_left BY movie_id, movie_actor_right BY movie_id;
movie_pairs = FILTER movie_pairs_joined BY actor_a < actor_b;
normalized_movie_pairs = FOREACH movie_pairs GENERATE actor_a, actor_b;

-- Line 5: Count how many movies each pair has in common
pair_groups = GROUP normalized_movie_pairs BY (actor_a, actor_b);
pair_movie_count = FOREACH pair_groups GENERATE COUNT(normalized_movie_pairs) AS count, group.actor_a AS actor_a, group.actor_b AS actor_b;

-- Line 6: Order the count in descending order
ordered_pair_count = ORDER pair_movie_count BY count DESC;

-- output the final count
-- TODO: REPLACE suCarpeta WITH YOUR FOLDER
-- TODO2: when running on the full file replace imdb-stars-test with imdb-stars
STORE ordered_pair_count INTO 'hdfs://master:9000/outputs/lab03/costar-count-full-20260802-153853';
