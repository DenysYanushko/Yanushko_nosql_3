// 1. Фільми з рейтингом 5
MATCH (u:User)-[r:RATED]->(m:Movie)
WHERE r.rating = 5
RETURN m.title, count(r) AS rating_count
ORDER BY rating_count DESC
LIMIT 10;


// 2. Найпопулярніші фільми за кількістю оцінок
MATCH (m:Movie)<-[r:RATED]-()
RETURN m.title, count(r) AS ratings
ORDER BY ratings DESC
LIMIT 10;


// 3. Найкращі фільми за середнім рейтингом
MATCH (m:Movie)<-[r:RATED]-()
WITH m, avg(r.rating) AS avg_rating, count(r) AS rating_count
WHERE rating_count >= 100
RETURN m.title, round(avg_rating, 2) AS average_rating, rating_count
ORDER BY average_rating DESC
LIMIT 10;


// 4. Фільми, які сподобались конкретному користувачу
MATCH (u:User {userId: 1})-[r:RATED]->(m:Movie)
WHERE r.rating >= 4
RETURN m.title, r.rating
ORDER BY r.rating DESC, m.title
LIMIT 20;


// 5. Рекомендації для користувача
MATCH (u:User {userId: 1})-[r1:RATED]->(liked:Movie)
WHERE r1.rating >= 4

MATCH (other:User)-[r2:RATED]->(liked)
WHERE r2.rating >= 4 AND other <> u

MATCH (other)-[r3:RATED]->(recommended:Movie)
WHERE r3.rating >= 4
  AND NOT (u)-[:RATED]->(recommended)

WITH recommended, count(DISTINCT other) AS recommendation_score
RETURN recommended.title, recommendation_score
ORDER BY recommendation_score DESC
LIMIT 10;


// 6. Пошук зв'язку між двома користувачами через спільні фільми
MATCH p = (u1:User {userId: 1})-[:RATED]->(m:Movie)<-[:RATED]-(u2:User)
WHERE u2.userId <> 1
RETURN u2.userId AS other_user,
       count(DISTINCT m) AS common_movies
ORDER BY common_movies DESC
LIMIT 10;