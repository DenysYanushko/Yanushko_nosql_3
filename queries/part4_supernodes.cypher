// PART 4 — Supernodes analysis

// 1. Movie supernodes
MATCH (m:Movie)<-[:RATED]-(u:User)
RETURN m.movieId AS movie_id,
       m.title AS title,
       count(u) AS ratings_count
ORDER BY ratings_count DESC
LIMIT 10;


// 2. User supernodes
MATCH (u:User)-[:RATED]->(m:Movie)
RETURN u.userId AS user_id,
       count(m) AS ratings_count
ORDER BY ratings_count DESC
LIMIT 10;


// 3. Genre nodes with the highest number of connections
MATCH (g:Genre)<-[:HAS_GENRE]-(m:Movie)
RETURN g.name AS genre,
       count(m) AS movie_count
ORDER BY movie_count DESC;


// 4. Check the highest-degree Movie node
MATCH (m:Movie)<-[:RATED]-(u:User)
WITH m, count(u) AS degree
ORDER BY degree DESC
LIMIT 1
RETURN m.title AS movie,
       degree;


// 5. Check the highest-degree User node
MATCH (u:User)-[:RATED]->(m:Movie)
WITH u, count(m) AS degree
ORDER BY degree DESC
LIMIT 1
RETURN u.userId AS user_id,
       degree;