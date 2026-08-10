import csv
from pathlib import Path

DATA_DIR = Path("ml-1m")
OUTPUT_DIR = Path("import")

OUTPUT_DIR.mkdir(exist_ok=True)


def convert_file(input_file, output_file, headers):
    with open(input_file, "r", encoding="latin-1") as infile:
        reader = csv.reader(infile, delimiter=":")

        with open(output_file, "w", encoding="utf-8", newline="") as outfile:
            writer = csv.writer(outfile)

            writer.writerow(headers)

            for line in infile:
                parts = line.strip().split("::")
                writer.writerow(parts)


# Movies
convert_file(
    DATA_DIR / "movies.dat",
    OUTPUT_DIR / "movies.csv",
    ["movieId", "title", "genres"],
)

# Users
convert_file(
    DATA_DIR / "users.dat",
    OUTPUT_DIR / "users.csv",
    ["userId", "gender", "age", "occupation", "zip"],
)

# Ratings
convert_file(
    DATA_DIR / "ratings.dat",
    OUTPUT_DIR / "ratings.csv",
    ["userId", "movieId", "rating", "timestamp"],
)

print("SUCCESS")
print("CSV files created in ./import/")