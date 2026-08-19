# MovieLens 1M — Neo4j Recommendation System

## 1. Project Description

This project implements a movie recommendation system using the MovieLens 1M dataset and Neo4j graph database.

The main goal is to model users, movies and genres as a graph and use Cypher and Neo4j Graph Data Science (GDS) algorithms to analyze the data and generate movie recommendations.

The project demonstrates:

- graph data modeling;
- loading and validating MovieLens data;
- Cypher queries;
- recommendation logic;
- supernode analysis;
- PageRank;
- Louvain community detection;
- Dijkstra shortest path;
- comparison of graph and relational approaches.


## 2. Dataset

The project uses the MovieLens 1M dataset.

The original dataset contains:

- 6040 users;
- 3883 movies;
- 1,000,209 ratings.

The original MovieLens files use the `::` delimiter and Latin-1 encoding. The data was converted to CSV files before loading into Neo4j.

The project contains:

```text
import/
├── movies.csv
├── users.csv
└── ratings.csv
```

## 3. Graph Data Model

The graph contains three types of nodes:

```text
(:User)
(:Movie)
(:Genre)
```

The graph contains two types of relationships:

```text
(:User)-[:RATED {rating, timestamp}]->(:Movie)
(:Movie)-[:HAS_GENRE]->(:Genre)
```

The complete graph schema is:

```text
(:User)
    |
    | RATED
    | rating, timestamp
    v
(:Movie)
    |
    | HAS_GENRE
    v
(:Genre)
```

### User

The `User` node contains:

- `userId`
- `gender`
- `age`
- `occupation`
- `zipCode`

### Movie

The `Movie` node contains:

- `movieId`
- `title`
- `genres`

### Genre

Genres were extracted from the MovieLens movie data and represented as separate `Genre` nodes.

The graph contains 18 genres:

- Action
- Adventure
- Animation
- Children's
- Comedy
- Crime
- Documentary
- Drama
- Fantasy
- Film-Noir
- Horror
- Musical
- Mystery
- Romance
- Sci-Fi
- Thriller
- War
- Western

A total of 6408 `HAS_GENRE` relationships were created between movies and genres.

This graph model allows direct traversal between users, movies and genres and provides the structure required for recommendation queries and graph algorithms.
## 4. Why Rating Is a Relationship

A rating was modeled as a relationship between a user and a movie because it represents an interaction between two entities.

The relationship is:

```text
(:User)-[:RATED]->(:Movie)
```

with the properties:

```text
rating
timestamp
```

This model makes it possible to directly traverse from a user to movies they rated and from a movie to users who rated it.

Using a separate `Rating` node would introduce an additional intermediate node and make common user-movie queries more complex.

## 5. Indexes and Data Loading

Indexes were created for users and movies:

```cypher
CREATE INDEX user_id_index IF NOT EXISTS
FOR (u:User) ON (u.userId);

CREATE INDEX movie_id_index IF NOT EXISTS
FOR (m:Movie) ON (m.movieId);
```

Users were loaded as `User` nodes, movies as `Movie` nodes, and ratings as `RATED` relationships.

The rating relationship contains:

```text
rating
timestamp
```

The project uses the following query files:

```text
queries/part2_load.cypher
queries/part3.cypher
queries/part4_supernodes.cypher
queries/part5_gds.cypher
```

## 6. Data Validation

After loading the dataset, several validation queries were executed.

### Users

```cypher
MATCH (u:User)
RETURN count(u) AS users;
```

Result:

```text
6040
```

### Movies

```cypher
MATCH (m:Movie)
RETURN count(m) AS movies;
```

Result:

```text
3883
```

### Ratings

```cypher
MATCH ()-[r:RATED]->()
RETURN count(r) AS ratings;
```

Result:

```text
1000209
```

### Genres

The graph contains:

```text
18 Genre nodes
6408 HAS_GENRE relationships
```

The genre distribution is:

| Genre | Movies |
|---|---:|
| Drama | 1603 |
| Comedy | 1200 |
| Action | 503 |
| Thriller | 492 |
| Romance | 471 |
| Horror | 343 |
| Adventure | 283 |
| Sci-Fi | 276 |
| Children's | 251 |
| Crime | 211 |
| War | 143 |
| Documentary | 127 |
| Musical | 114 |
| Mystery | 106 |
| Animation | 105 |
| Fantasy | 68 |
| Western | 68 |
| Film-Noir | 44 |

Drama is the most connected genre with 1603 movies.

## 7. Cypher Analysis

Six analytical Cypher queries were implemented.

### 7.1 Movies with the highest number of 5-star ratings

```cypher
MATCH (u:User)-[r:RATED]->(m:Movie)
WHERE r.rating = 5
RETURN m.title, count(r) AS rating_count
ORDER BY rating_count DESC
LIMIT 10;
```

This query identifies movies that received many highly positive ratings.

### 7.2 Most popular movies

```cypher
MATCH (m:Movie)<-[r:RATED]-()
RETURN m.title, count(r) AS ratings
ORDER BY ratings DESC
LIMIT 10;
```

Popularity is measured by the total number of ratings.

### 7.3 Movies with the highest average rating

```cypher
MATCH (m:Movie)<-[r:RATED]-()
WITH m, avg(r.rating) AS avg_rating, count(r) AS rating_count
WHERE rating_count >= 100
RETURN m.title,
       round(avg_rating, 2) AS average_rating,
       rating_count
ORDER BY average_rating DESC
LIMIT 10;
```

A minimum of 100 ratings is used to reduce the influence of movies with very few ratings.

### 7.4 Movies liked by a specific user

```cypher
MATCH (u:User {userId: 1})-[r:RATED]->(m:Movie)
WHERE r.rating >= 4
RETURN m.title, r.rating
ORDER BY r.rating DESC, m.title
LIMIT 20;
```

This query identifies movies that user 1 rated positively.

### 7.5 Recommendation query

The recommendation query uses users with similar preferences.

The logic is:

```text
User 1
   |
   | rated >= 4
   v
Liked movies
   |
   | other users also rated >= 4
   v
Other users
   |
   | their highly rated movies
   v
Recommended movies
```

```cypher
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
```

The recommendation score represents the number of different users who liked the same movies as user 1 and also liked the recommended movie.

This demonstrates a basic graph-based collaborative filtering approach.

### 7.6 Users with common movies

```cypher
MATCH (u1:User {userId: 1})-[:RATED]->(m:Movie)<-[:RATED]-(u2:User)
WHERE u2.userId <> 1
RETURN u2.userId AS other_user,
       count(DISTINCT m) AS common_movies
ORDER BY common_movies DESC
LIMIT 10;
```

This query identifies users with similar rating histories based on common movies.

## 8. Supernode Analysis

A supernode is a node with a very large number of relationships compared with other nodes.

Highly connected nodes are important because traversing them may require processing a large number of relationships.

### 8.1 Movie Supernodes

| Movie | Ratings |
|---|---:|
| American Beauty (1999) | 3428 |
| Star Wars: Episode IV - A New Hope (1977) | 2991 |
| Star Wars: Episode V - The Empire Strikes Back (1980) | 2990 |
| Star Wars: Episode VI - Return of the Jedi (1983) | 2883 |
| Jurassic Park (1993) | 2672 |
| Saving Private Ryan (1998) | 2653 |
| Terminator 2: Judgment Day (1991) | 2649 |
| Matrix, The (1999) | 2590 |
| Back to the Future (1985) | 2583 |
| Silence of the Lambs, The (1991) | 2578 |

`American Beauty (1999)` is the largest Movie supernode with 3428 rating relationships.

### 8.2 User Supernodes

| User ID | Ratings |
|---:|---:|
| 4169 | 2314 |
| 1680 | 1850 |
| 4277 | 1743 |
| 1941 | 1595 |
| 1181 | 1521 |
| 889 | 1518 |
| 3618 | 1344 |
| 2063 | 1323 |
| 1150 | 1302 |
| 1015 | 1286 |

User `4169` is the most connected user with 2314 ratings.

### 8.3 Genre Connectivity

The most connected genre is:

```text
Drama — 1603 movies
```

followed by:

```text
Comedy — 1200 movies
```

These nodes have a high degree within the Movie-Genre part of the graph.

## 9. Neo4j Graph Data Science

Neo4j Graph Data Science version:

```text
2.13.12
```

A GDS graph projection named `movielens` was created using:

- `User` nodes;
- `Movie` nodes;
- `RATED` relationships.

The resulting projection contains:

```text
9923 nodes
2000418 relationships
```

There are 9923 nodes because:

```text
6040 Users + 3883 Movies = 9923 nodes
```

The relationship count is doubled because the GDS projection uses undirected orientation.

## 10. PageRank

PageRank was used to identify important movie nodes based on the structure of the graph.

The top results were:

| Movie | PageRank |
|---|---:|
| American Beauty (1999) | 16.5708 |
| Star Wars: Episode IV - A New Hope (1977) | 13.5004 |
| Star Wars: Episode V - The Empire Strikes Back (1980) | 13.2270 |
| Star Wars: Episode VI - Return of the Jedi (1983) | 13.2111 |
| Saving Private Ryan (1998) | 12.0317 |
| Jurassic Park (1993) | 12.0021 |
| Terminator 2: Judgment Day (1991) | 11.7520 |
| Silence of the Lambs, The (1991) | 11.6574 |
| Back to the Future (1985) | 11.3426 |
| Matrix, The (1999) | 11.1830 |

`American Beauty (1999)` received the highest PageRank score.

The result is consistent with its high number of rating relationships and central position in the graph.

## 11. Louvain Community Detection

The Louvain algorithm was used to identify communities in the MovieLens graph.

The largest detected communities were:

| Community ID | Movie count |
|---:|---:|
| 8044 | 1114 |
| 9844 | 1056 |
| 8144 | 590 |
| 1469 | 415 |
| 4548 | 342 |
| 9581 | 189 |

Examples from the largest communities include:

```text
Persuasion (1995)
Shanghai Triad (Yao a yao yao dao waipo qiao) (1995)
Babe (1995)
Dead Man Walking (1995)
Richard III (1995)
```

and:

```text
Grumpier Old Men (1995)
Waiting to Exhale (1995)
Father of the Bride Part II (1995)
Sabrina (1995)
American President, The (1995)
```

Louvain demonstrates that movies can be grouped according to the structure of their connections with users.

## 12. Dijkstra Shortest Path

Dijkstra shortest path was used to find a path from user 1 to:

```text
Star Wars: Episode IV - A New Hope (1977)
```

The result was:

```text
User 1
   |
   | RATED
   v
Star Wars: Episode IV - A New Hope (1977)
```

The total cost was:

```text
1.0
```

The direct path exists because user 1 has a direct rating relationship with this movie.

## 13. Graph Database vs Relational Database

The same MovieLens dataset could be represented in a relational database using:

```text
Users
Movies
Ratings
Genres
```

with foreign keys connecting the tables.

A relational database is well suited for structured tabular data, transactional operations and traditional aggregation queries.

However, recommendation queries often require several joins between users, ratings and movies.

In Neo4j, the same logic can be represented as graph traversal:

```text
User
  ↓
Liked Movie
  ↑
Other User
  ↓
Recommended Movie
```

This makes relationship-based queries easier to express.

Neo4j also provides graph-specific algorithms such as:

- PageRank;
- Louvain community detection;
- Dijkstra shortest path;
- multi-hop graph traversal.

The graph approach is particularly useful when relationships are central to the application.

A relational database may still be preferable for highly structured tabular workloads, complex transactional systems and cases where graph traversal is not a major part of the application.

## 14. Project Structure

```text
.
├── import/
│   ├── movies.csv
│   ├── ratings.csv
│   └── users.csv
├── queries/
│   ├── part2_load.cypher
│   ├── part3.cypher
│   ├── part4_supernodes.cypher
│   └── part5_gds.cypher
├── convert.py
├── docker-compose.yml
├── .gitignore
└── README.md
```

The original MovieLens archive is excluded from Git using `.gitignore`.

## 15. Running the Project

Start Neo4j:

```bash
docker compose up -d
```

Check the container:

```bash
docker compose ps
```

Neo4j Browser:

```text
http://localhost:7474
```

Bolt connection:

```text
neo4j://localhost:7687
```

The credentials are configured in `docker-compose.yml`.

Convert the dataset:

```bash
python3 convert.py
```

The converted CSV files are placed in:

```text
import/
```

## 16. Conclusion

The project demonstrates a complete graph-based movie recommendation workflow using Neo4j and the MovieLens 1M dataset.

The final graph contains:

- 6040 users;
- 3883 movies;
- 1,000,209 ratings;
- 18 genres;
- 6408 movie-genre relationships.

Cypher was used for data analysis, user preference analysis and recommendations.

Supernode analysis identified highly connected users, movies and genres.

Neo4j Graph Data Science was used to apply PageRank, Louvain and Dijkstra algorithms.

The results demonstrate that graph databases are particularly useful for recommendation systems because users, movies and their interactions can be represented directly as graph structures.

Overall, Neo4j provides a natural and flexible model for recommendation systems where relationships between entities are a central part of the problem.