CALL gds.graph.project(
    'movielens',
    {
        User: {},
        Movie: {}
    },
    {
        RATED: {
            orientation: 'UNDIRECTED',
            properties: 'rating'
        }
    }
)
YIELD graphName, nodeCount, relationshipCount
RETURN graphName, nodeCount, relationshipCount;

CALL gds.pageRank.stream('movielens')
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS node, score
WHERE node:Movie
RETURN node.title AS movie, score
ORDER BY score DESC
LIMIT 10;

CALL gds.louvain.stream('movielens')
YIELD nodeId, communityId
WITH gds.util.asNode(nodeId) AS node, communityId
WHERE node:Movie
RETURN communityId, count(*) AS movie_count,
       collect(node.title)[0..5] AS example_movies
ORDER BY movie_count DESC
LIMIT 10;

MATCH (m:Movie)
WHERE m.title CONTAINS 'Star Wars: Episode IV'
RETURN m.title;

MATCH (source:User {userId: 1}), (target:Movie)
WHERE target.title = 'Star Wars: Episode IV - A New Hope (1977)'
CALL gds.shortestPath.dijkstra.stream('movielens', {
    sourceNode: source,
    targetNode: target
})
YIELD totalCost, nodeIds
RETURN totalCost,
       [nodeId IN nodeIds | gds.util.asNode(nodeId).title] AS path;
// PART 5 — Graph Data Science analysis

// 1. Create the GDS projection
CALL gds.graph.project(
    'movielens',
    {
        User: {},
        Movie: {}
    },
    {
        RATED: {
            orientation: 'UNDIRECTED',
            properties: 'rating'
        }
    }
)
YIELD graphName, nodeCount, relationshipCount
RETURN graphName, nodeCount, relationshipCount;


// 2. PageRank
CALL gds.pageRank.stream('movielens')
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS node, score
WHERE node:Movie
RETURN node.title AS movie,
       round(score, 4) AS pageRank
ORDER BY pageRank DESC
LIMIT 10;


// 3. Louvain community detection
CALL gds.louvain.stream('movielens')
YIELD nodeId, communityId
WITH gds.util.asNode(nodeId) AS node, communityId
WHERE node:Movie
RETURN communityId,
       count(*) AS movie_count,
       collect(node.title)[0..5] AS example_movies
ORDER BY movie_count DESC
LIMIT 10;


// 4. Dijkstra shortest path
MATCH (source:User {userId: 1}),
      (target:Movie {movieId: 260})
CALL gds.shortestPath.dijkstra.stream('movielens', {
    sourceNode: source,
    targetNode: target
})
YIELD totalCost, nodeIds
RETURN totalCost,
       [nodeId IN nodeIds |
        CASE
            WHEN gds.util.asNode(nodeId):User
            THEN 'User ' + toString(gds.util.asNode(nodeId).userId)
            ELSE gds.util.asNode(nodeId).title
        END
       ] AS path;