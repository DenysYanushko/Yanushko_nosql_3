// ============================================================
// PART 2 — MovieLens 1M: indexes and data loading
// ============================================================

// 1. Indexes
CREATE INDEX user_id_index IF NOT EXISTS
FOR (u:User) ON (u.userId);

CREATE INDEX movie_id_index IF NOT EXISTS
FOR (m:Movie) ON (m.movieId);


// 2. Load users
LOAD CSV WITH HEADERS FROM 'file:///users.csv'
AS row
FIELDTERMINATOR ','
CREATE (:User {
    userId: toInteger(row.userId),
    gender: row.gender,
    age: toInteger(row.age),
    occupation: toInteger(row.occupation),
    zipCode: row.zipCode
});


// 3. Load movies
LOAD CSV WITH HEADERS FROM 'file:///movies.csv'
AS row
FIELDTERMINATOR ','
CREATE (:Movie {
    movieId: toInteger(row.movieId),
    title: row.title,
    genres: row.genres
});


// 4. Load ratings
LOAD CSV WITH HEADERS FROM 'file:///ratings.csv'
AS row
FIELDTERMINATOR ','
MATCH (u:User {userId: toInteger(row.userId)})
MATCH (m:Movie {movieId: toInteger(row.movieId)})
CREATE (u)-[:RATED {
    rating: toInteger(row.rating),
    timestamp: toInteger(row.timestamp)
}]->(m);