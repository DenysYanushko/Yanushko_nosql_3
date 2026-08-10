# MovieLens — Neo4j NoSQL Project

## Description

This project demonstrates working with the MovieLens dataset using Neo4j graph database and Cypher queries.

The project includes:

- loading MovieLens data into Neo4j;
- creating User and Movie nodes;
- creating RATED relationships;
- creating indexes;
- analytical Cypher queries;
- movie recommendations;
- graph algorithms using Neo4j Graph Data Science (GDS).

## Dataset

The project uses the MovieLens 1M dataset.

Main entities:

- `User`
- `Movie`

Relationship:

- `(:User)-[:RATED]->(:Movie)`

Dataset statistics:

- Users: 6040
- Movies: 3883
- Ratings: 1,000,209

## Project Structure

```text
.
├── import/
│   ├── movies.csv
│   ├── users.csv
│   └── ratings.csv
├── queries/
│   ├── part2_load.cypher
│   └── part3.cypher
├── convert.py
├── docker-compose.yml
└── README.md
## Conclusion

The project showed that Neo4j is well suited for recommendation systems based on relationships between users and movies. Cypher queries made it possible to analyze ratings, find popular movies and generate recommendations.

The GDS algorithms provided additional insights into the graph structure. PageRank helped identify important movies, Louvain detected communities, and Dijkstra was used to find a shortest path in the graph.

Compared with a relational approach, a graph database makes relationship-based queries and recommendations more direct and easier to express.