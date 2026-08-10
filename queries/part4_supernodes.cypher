MATCH (u:User)-[r:RATED]->(m:Movie)
WITH m, count(r) AS rating_count
RETURN m.title, rating_count
ORDER BY rating_count DESC
LIMIT 10;
