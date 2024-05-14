import time
import mysql.connector
import ast

# Replace these variables with your actual database connection details
hostname = 'riku.shoshin.uwaterloo.ca'
username = '' #mysql username
password = ''#mysql password
database = 'db356_team31'

start_time = time.time()

class PersonDatabase:
    def __init__(self):
        self.persons = {}

    def add_person(self, person_id, person_data):
        # Adding a person to the hash map
        self.persons[person_id] = person_data

    def search_person(self, person_id):
        # Searching for a person in the hash map
        return self.persons.get(person_id, None)

try:
    # Establish a connection to the MySQL server
    connection = mysql.connector.connect(
        host=hostname, user=username, password=password, database=database
    )

    # Create a cursor object to interact with the database
    cursor = connection.cursor()
    
    # Initialize empty lists for each column
    cast_array = []
    crew_array = []
    id_array = []

    person_db = PersonDatabase()

    cursor.execute(
              """
            SELECT * FROM Credits;
            """
            )
    rows = cursor.fetchall()

    cursor.execute("SELECT movie_id FROM Movies;")
    existing_movies = set(row[0] for row in cursor.fetchall())
    for row in rows:
      # Separate each column into respective variables
      cast, crew, id = row

      # Append values to their respective lists
      cast_array.append(cast)
      crew_array.append(crew)  # Assuming age is an integer
      id_array.append(id)
      movie_id = (id_array[-1])
      try:
        for i in ast.literal_eval(cast_array[-1]):
          cast_id = i["cast_id"]
          character = i["character"]
          credit_id = i["credit_id"]
          gender = i["gender"]
          person_id = i["id"]
          name = i["name"]
          order = i["order"]
          profile_path = i["profile_path"]

          person_exists = person_db.search_person(person_id)
          if not person_exists:
            person_db.add_person(person_id, {"name": name})
            cursor.execute(
              """
            INSERT INTO People (person_id, credit_id, name, gender, profile_path)
            VALUES (%s, %s, %s, %s, %s);
            """,
              (person_id, credit_id, name, gender, profile_path),
            )
          if movie_id in existing_movies:
            cursor.execute(
              """
            INSERT INTO CastMembers (movie_id, person_id, cast_id, character_name, name, order_in_cast)
            VALUES (%s, %s, %s, %s, %s, %s);
            """,
              (movie_id, person_id, cast_id, character, name, order),
            )

        for i in ast.literal_eval(crew_array[-1]):
          credit_id = i["credit_id"]
          department = i["department"]
          gender = i["gender"]
          person_id = i["id"]
          job = i["job"]
          name = i["name"]
          profile_path = i["profile_path"]

          person_exists = person_db.search_person(person_id)

          if not person_exists:
            person_db.add_person(person_id, {"name": name})
            cursor.execute(
                """
              INSERT INTO People (person_id, credit_id, name, gender, profile_path)
              VALUES (%s, %s, %s, %s, %s);
              """,
                (person_id, credit_id, name, gender, profile_path),
              )
          if movie_id in existing_movies:
            cursor.execute(
              """
            INSERT INTO CrewMembers (movie_id, person_id, department, job, name)
            VALUES (%s, %s, %s, %s, %s);
            """,
              (movie_id, person_id, department, job, name),
            )
      except Exception as e:
        pass

    # Commit the changes after all inserts are done
    connection.commit()
    print("Data inserted successfully!")
    elapsed_time = time.time() - start_time
    print("Time taken in seconds")
    print(elapsed_time)

except Exception as e:
    pass
    # print(f"Error: {e}")

finally:
    # Close the cursor and connection
    cursor.close()
    connection.close()