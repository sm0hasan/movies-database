import mysql.connector
import re

# Replace these variables with your actual database connection details
hostname = 'riku.shoshin.uwaterloo.ca'
username = '' #mysql username
password = ''#mysql password
database = 'db356_team31' 

def createuser():
    try:
        connection = mysql.connector.connect(
            host=hostname,
            user=username,
            password=password,
            database=database
        )
        cursor = connection.cursor()

        user = input("create a username: ")
        pw = input("enter a password: ")
        admin = input("Get Admin privileges? You will be able to create and delete movie entries (y/n): ")
        if(admin == 'y'):
            admin = True
        else: admin = False
        cursor.execute('''
            INSERT INTO Users (username, password, admin) VALUES (%s, %s, %s)
        ''', (user, pw, admin))

        connection.commit()
        cursor.close()
        connection.close()
        return admin
    except mysql.connector.Error as err:
        print(f"Error: {err}")

def trylogin(user, passw):
    try:
        connection = mysql.connector.connect(
            host=hostname,
            user=username,
            password=password,
            database=database
        )
        cursor = connection.cursor()

        cursor.execute('''
            SELECT admin FROM Users
            WHERE username = %s
            AND password = %s;
        ''', (user, passw))
        admin = cursor.fetchone()

        connection.commit()
        cursor.close()
        connection.close()
        if (admin):
            print("login successful!")
            return admin[0], True
        else:
            return False, False

    except mysql.connector.Error as err:
        print(f"Error: {err}")
        return False, False

def add_movie(title, imdb_id, overview, tagline, runtime, release_date, genres):
    try:
        connection = mysql.connector.connect(
            host=hostname,
            user=username,
            password=password,
            database=database
        )
        cursor = connection.cursor()

        cursor.execute('''
            INSERT INTO Movies (title, imdb_id, overview, tagline, runtime, release_date)
            VALUES (%s, %s, %s, %s, %s, %s)
        ''', (title, imdb_id, overview, tagline, runtime, release_date))

        cursor.execute('SELECT LAST_INSERT_ID()')
        movie_id = cursor.fetchone()[0]

        cursor.execute('''
            INSERT INTO MovieGenre(movie_id, genre)
            VALUES (%s, %s)
        ''', (movie_id, genres))

        connection.commit()
        cursor.close()
        connection.close()
        print("Movie added successfully!")

    except mysql.connector.Error as err:
        print(f"Error: {err}")

def search_movies(title=None, genre=None, actor=None, director=None):
    try:
        connection = mysql.connector.connect(
            host=hostname,
            user=username,
            password=password,
            database=database
        )
        cursor = connection.cursor(dictionary=True)

        ntitle = None if (title == None) else ("%" + title + "%")
        ngenre = None if (genre == None) else ("%" + genre + "%")
        nactor = None if (actor == None) else ("%" + actor + "%")
        ndirector = None if (director == None) else ("%" + director + "%")
        query_dict = {
                "title": ntitle,
                "genre": ngenre,
                "actor": nactor,
                "director": ndirector
            }

        select_query = """
            SELECT
                Movies.title,
                Movies.overview,
                Movies.tagline,
                Movies.runtime,
                Movies.release_date,
                MovieGenre.genre,
                CrewMembers.name AS director_name,
                CastMembers1.name AS actor_1,
                CastMembers2.name AS actor_2
            FROM Movies 
            LEFT JOIN MovieGenre ON MovieGenre.movie_id = Movies.movie_id
            LEFT JOIN
            CrewMembers ON Movies.movie_id = CrewMembers.movie_id AND CrewMembers.job = 'director'
            LEFT JOIN
                CastMembers AS CastMembers1 ON Movies.movie_id = CastMembers1.movie_id AND CastMembers1.order_in_cast = 1
            LEFT JOIN
                CastMembers AS CastMembers2 ON Movies.movie_id = CastMembers2.movie_id AND CastMembers2.order_in_cast = 2
            WHERE (%(title)s IS NULL OR Movies.title LIKE %(title)s)
                AND (%(genre)s IS NULL OR MovieGenre.genre LIKE %(genre)s)
                AND (%(director)s IS NULL OR CrewMembers.name LIKE %(director)s)
                AND ( %(actor)s IS NULL OR 
                    EXISTS (
                        SELECT 1
                        FROM CastMembers cm
                        WHERE cm.movie_id = Movies.movie_id
                        AND cm.name LIKE %(actor)s
                    )
                );
            """
        cursor.execute(select_query, query_dict)
        movies = cursor.fetchall()
        cursor.close()
        connection.close()
        return movies

    except mysql.connector.Error as err:
        print(f"Error: {err}")
        return []

def add_review(title, new_rating, desc, user):
    try:
        connection = mysql.connector.connect(
            host=hostname,
            user=username,
            password=password,
            database=database
        )
        cursor = connection.cursor()

        cursor.execute('SELECT movie_id from Movies WHERE title = %s', (title,))
        movie_id = cursor.fetchone()
        if not movie_id:
            print("Movie does not exist")
            return
        cursor.execute('''
            REPLACE INTO Reviews (movie_id, new_rating, description, username)
            VALUES (%s, %s, %s, %s)
        ''', (movie_id[0], new_rating, desc, user))

        connection.commit()
        cursor.close()
        connection.close()
        print("Review edited successfully!")

    except mysql.connector.Error as err:
        print(f"Error: {err}")

def delete_review(title, user):
    try:
        connection = mysql.connector.connect(
            host=hostname,
            user=username,
            password=password,
            database=database
        )
        cursor = connection.cursor()

        cursor.execute('SELECT movie_id from Movies WHERE title = %s', (title,))
        movie_id = cursor.fetchone()
        if not movie_id:
            print("Movie does not exist")
            return
        
        cursor.execute('''
            DELETE FROM Reviews WHERE movie_id = %s AND username = %s
        ''', (movie_id[0], user))

        connection.commit()
        cursor.close()
        connection.close()
        print("Review deleted successfully!")

    except mysql.connector.Error as err:
        print(f"Error: {err}")

def search_reviews(title=None):
    try:
        connection = mysql.connector.connect(
            host=hostname,
            user=username,
            password=password,
            database=database
        )
        cursor = connection.cursor(dictionary=True)

        cursor.execute('SELECT movie_id from Movies WHERE title = %s', (title,))
        movie_id = cursor.fetchone()
        if not movie_id:
            print("Movie does not exist")
            return
        
        cursor.execute('''SELECT Movies.title, 
                       Reviews.new_rating as Rating, 
                       Reviews.description, 
                       Reviews.username 
                       FROM Reviews 
                       LEFT JOIN Movies ON Movies.movie_id = Reviews.movie_id
                       WHERE Reviews.movie_id = %(movie_id)s
                       ''', (movie_id))
        reviews = cursor.fetchall()

        cursor.close()
        connection.close()
        return reviews

    except mysql.connector.Error as err:
        print(f"Error: {err}")
        return []

def delete_movie(title=None):
    try:
        connection = mysql.connector.connect(
            host=hostname,
            user=username,
            password=password,
            database=database
        )
        cursor = connection.cursor()

        cursor.execute('SELECT movie_id from Movies WHERE title = %s', (title,))
        movie_id = cursor.fetchone()

        cursor.execute('DELETE FROM movies WHERE movie_id = %s', (movie_id[0],))

        connection.commit()
        cursor.close()
        connection.close()
        print("Removed Movie Successfully!")

    except mysql.connector.Error as err:
        print(f"Error: {err}")

def printgenres(values):
    if values[0] != '[':
        print(values, end=' | ')
        return
    newstr = ''.join(values)
    newstr = newstr.replace("{'id': ", "")
    newstr = newstr.replace("'}", "")
    newstr = newstr.replace("'name': '", "")
    newstr = newstr.replace("]", "")
    newstr = re.sub(r'[0-9]', '', newstr)
    newstr = newstr.replace(newstr[:3], '')
    newstr = ', '.join([x.strip() for x in newstr.split(',') if not x.isspace() and x != ''])
    print(newstr, end=' | ')

def main():

    login = False
    admin = False
    user = ''

    create_login = input("Create user? If n, will go to login user (y/n): ")
    if(create_login == 'y'):
        createuser()

    while not login:
        print("\nLogin:")
        user = input("Enter username: ")
        passw = input("Enter password: ")
        admin, login = trylogin(user, passw)

    while True:
        print("\nMovie Database CLI")
        print("1. Add a new movie")
        print("2. Search for movies")
        print("3. Edit or create movie review")
        print("4. Remove a movie from the database")
        print("5. Delete review")
        print("6. Search for reviews")
        print("7. Exit")

        choice = input("\nEnter your choice (1-7): ")

        if choice == '1':
            if admin:
                title = input("Enter movie title (required): ")
                imdb_id = input("Enter movie imdb id: ") or None
                overview = input("Enter movie overview: ") or None
                tagline = input("Enter movie tagline: ") or None
                runtime = input("Enter movie runtime(in minutes): ") or None
                genres = input("Enter genres,comma separated (required): ") or None
                release_date = input("Enter release_date in YYYY-MM-DD (required): ")
                if not title and not release_date:
                    print("release date and title are required fields!")
                else:  
                    add_movie(title, imdb_id, overview, tagline, runtime, release_date, genres)
            else:
                print("you do not have permission to add movies")

        elif choice == '2':
            print("\nSearch filters:")
            title = input("Enter movie title: ") or None
            genre = input("Enter movie genre: ") or None
            actors = input("Enter movie actor: ") or None
            director = input("Enter movie director: ") or None

            result = search_movies(title, genre, actors, director)
            if result:
                print("\n\n")
                for review in result[0]:
                    print(review, end=' | ')
                print("\n------------------------------------------------------------------------------------------------------")
                for reviews in result:
                    counter = 0
                    for values in reviews.values():
                        if counter == 5:
                            counter = 0
                            if values is not None:
                                printgenres(values)
                        else:
                            counter += 1
                            print(values, end=' | ')
                    print("\n------------------------------------------------------------------------------------------------------")
            else:
                print("No matching movies found.")

        elif choice == '3':
            title = input("Enter the movie title: ")
            new_rating = input("Enter the new rating: ")
            desc = input("Enter the review description: ")
            add_review(title, new_rating, desc, user)

        elif choice == '4':
            if admin:
                title = input("Enter movie title (required): ")
                delete_movie(title)
            else:
                print("you do not have permission to remove movies")

        elif choice == '5':
            title = input("Enter the movie title: ")
            delete_review(title, user)

        elif choice == '6':
            title = input("Enter the movie title: ")
            result = search_reviews(title)
            if result:
                print("\n\n")
                for review in result[0]:
                        print(review, end=' | ')
                print()
                for reviews in result:
                    for values in reviews.values():
                        print(values, end=' | ')
                    print()
                print()
            else:
                print("No reviews published for this movie")


        elif choice == '7':
            print("Exiting the program. Goodbye!")
            break

        else:
            print("Invalid choice. Please enter a number between 1 and 7.")

if __name__ == "__main__":
    main()