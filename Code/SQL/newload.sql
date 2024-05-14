DROP TABLE IF EXISTS Metadata;
DROP TABLE IF EXISTS MovieVotes;
DROP TABLE IF EXISTS MovieGenre;
DROP TABLE IF EXISTS MovieProductionCompanies;
DROP TABLE IF EXISTS MovieProductionCountries;
DROP TABLE IF EXISTS AvgTicketPrices;
DROP TABLE IF EXISTS HollywoodStockExchange;
DROP TABLE IF EXISTS BoxOfficeInfo;
DROP TABLE IF EXISTS CrewMembers;
DROP TABLE IF EXISTS CastMembers;
DROP TABLE IF EXISTS People;
DROP TABLE IF EXISTS Movies;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Reviews;

-- Load CSV into temporary Tables --------------------------------------------------------------------

-- The temporary table for links.csv --------------------
DROP TEMPORARY TABLE IF EXISTS TempLinks;
CREATE TEMPORARY TABLE TempLinks (
    movie_id VARCHAR(255) PRIMARY KEY,
    imdb_id VARCHAR(255),
    tmdb_id VARCHAR(255)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/links.csv'
INTO TABLE TempLinks
FIELDS TERMINATED BY ','  -- Adjust the delimiter if needed
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@movieId, @imdbId, @tmdbId)
SET movie_id = @movieId,
imdb_id = @imdbId,
tmdb_id = @tmdbId;

UPDATE TempLinks
SET imdb_id = CONCAT('tt', imdb_id);




-- The temporary table for movies_metadata.csv --------------------


DROP TEMPORARY TABLE IF EXISTS MoviesMetadata;
CREATE TEMPORARY TABLE MoviesMetadata (
    adult BOOLEAN,
    genres VARCHAR(255),
    movie_id INT PRIMARY KEY,
    imdb_id VARCHAR(20),
    original_language VARCHAR(10),
    original_title VARCHAR(255),
    overview VARCHAR(10000),
    popularity FLOAT,
    poster_path VARCHAR(255),
    production_companies VARCHAR(255),
    production_countries VARCHAR(255),
    release_date DATE,
    revenue FLOAT,
    runtime INT,
    spoken_languages VARCHAR(255),
    status VARCHAR(20),
    tagline VARCHAR(255),
    title VARCHAR(255),
    vote_average FLOAT,
    vote_count INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/movies_metadata.csv'
  IGNORE INTO TABLE MoviesMetadata
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@adult, @dummy, @dummy, genres, @dummy, @id, imdb_id, original_language, original_title, overview, popularity, poster_path, @production_companies, @production_countries, @release_date, revenue, @runtime, spoken_languages, status, tagline, title, @dummy, vote_average, vote_count)
SET adult = CASE WHEN @adult = 'true' THEN TRUE ELSE FALSE END,
    movie_id = @id,
    runtime = NULLIF(@runtime, ''),
    production_companies = IFNULL(@production_companies, 'N/A'),
    production_countries = IFNULL(@production_countries, 'N/A'),
    release_date =   IF(
      @release_date <> '' AND STR_TO_DATE(@release_date,  '%Y-%m-%d') IS NOT NULL,
      STR_TO_DATE(@release_date,  '%Y-%m-%d'),
      NULL
  );



-- The temporary table for Mojo_budget_data.csv --------------------
DROP TEMPORARY TABLE IF EXISTS MojoBudgetData;
create temporary table MojoBudgetData (
   imdb_id VARCHAR(10) PRIMARY KEY,
    title VARCHAR(255),
    budget DECIMAL(14,1),
    domestic DECIMAL(14,1),
    international DECIMAL(14,1),
    worldwide DECIMAL(14,1),
    mpaa VARCHAR(10),
    run_time VARCHAR(50)
 );

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Mojo_budget_data.csv' into table MojoBudgetData
 fields terminated by ','
 enclosed by '"'
 lines terminated by '\r\n'
 ignore 1 ROWS
 (@movie_id, @movie_title, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @budget, @domestic, @international, @worldwide, mpaa, @run_time, @dummy, @dummy, @dummy, @dummy, @dummy)
 SET
    title = @movie_title,
    imdb_id = @movie_id,
    budget = NULLIF(@budget, ''),
    domestic = NULLIF(@domestic, ''),
    international = NULLIF(@international, ''),
    worldwide = NULLIF(@worldwide, '');



-- The temporary table for Mojo_budget_update.csv --------------------
DROP TEMPORARY TABLE IF EXISTS MojoBudgetUpdate;
CREATE TEMPORARY TABLE MojoBudgetUpdate (
    imdb_id VARCHAR(10) PRIMARY KEY,
    title VARCHAR(255),
    year INT,
    overview VARCHAR(10000),
    mpaa VARCHAR(10),
    release_date VARCHAR(50),
    run_time VARCHAR(50),
    distributor VARCHAR(255),
    budget DECIMAL(14,1),
    domestic DECIMAL(14,1),
    international DECIMAL(14,1),
    worldwide DECIMAL(14,1)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Mojo_budget_update.csv'
INTO TABLE MojoBudgetUpdate
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@movie_id, title, @dummy, @trivia, mpaa, @release_date, run_time, distributor,  @dummy,  @dummy,  @dummy,  @dummy,  @dummy,  @dummy,  @dummy,  @dummy,  @dummy, @budget, @domestic, @international, @worldwide,  @dummy,  @dummy,  @dummy,  @dummy,  @dummy)
  SET 
    overview = @trivia,
    imdb_id = @movie_id,
    budget = NULLIF(@budget, ''),
    domestic = NULLIF(@domestic, ''),
    international = NULLIF(@international, ''),
    worldwide = NULLIF(@worldwide, '');
--   SET release_date =  IF(
--     @release_date <> '' AND STR_TO_DATE(@release_date, '%M %d') IS NOT NULL,
--     STR_TO_DATE(@release_date, '%M %d'),
--     NULL
-- );


-- The temporary table for ratings_small.csv --------------------
DROP TEMPORARY TABLE IF EXISTS TempRatings;
CREATE TEMPORARY TABLE TempRatings (
    userId INT ,
    movie_id INT,
    rating FLOAT,
    PRIMARY KEY (userId,movie_id)
);

-- Load data from a file into the temporary table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ratings_small.csv'
INTO TABLE TempRatings
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(userId, @movieId, rating, @dummy)
SET movie_id = @movieId;


-- The table for credits.csv --------------------
DROP TABLE IF EXISTS Credits;
CREATE TABLE Credits (
    cast TEXT,
    crew TEXT,
    id INT PRIMARY KEY
);

-- Load data from a file into the temporary table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credits.csv'
IGNORE INTO TABLE Credits
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- The temporary table for boxofficemojo_daily_boxoffice.csv --------------------
DROP TEMPORARY TABLE IF EXISTS TempBoxOfficeDaily;
CREATE TEMPORARY TABLE TempBoxOfficeDaily (
    bo_date dateTime ,
    identifier VARCHAR(255),
    daily_domestic_gross INT,
    daily_theater_count INT
);

-- Load data from a file into the temporary table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/hsx_bomojo_data/boxofficemojo_daily_boxoffice.csv'
INTO TABLE TempBoxOfficeDaily
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(bo_date, identifier, daily_domestic_gross, @daily_theater_count, @dummy, @dummy)
SET daily_theater_count = NULLIF(@daily_theater_count, '');



-- The temporary table for boxofficemojo_releases.csv --------------------
DROP TEMPORARY TABLE IF EXISTS TempBoxOfficeRelease;
CREATE TEMPORARY TABLE TempBoxOfficeRelease (
    identifier VARCHAR(255),
    imdb_id VARCHAR(255),
    budget INT,
    domestic_gross INT,
    international_gross INT,
    worldwide_gross INT,
    widest_release INT
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/hsx_bomojo_data/boxofficemojo_releases.csv'
IGNORE INTO TABLE TempBoxOfficeRelease
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(identifier, @dummy, @dummy, @imdb_title_identifier, @dummy, @budget, @dummy, domestic_gross, international_gross, worldwide_gross, @dummy, @dummy, @widest_release, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy)
SET imdb_id = @imdb_title_identifier,
budget = NULLIF(@budget, ''),
widest_release = CAST(SUBSTRING_INDEX(REPLACE(@widest_release, ',', ''), ' ', 1) AS UNSIGNED);

-- The temporary table for hsx_movie_master.csv --------------------
DROP TEMPORARY TABLE IF EXISTS TempHSXMaster;
CREATE TEMPORARY TABLE TempHSXMaster (
    identifier VARCHAR(255),
    title VARCHAR(255),
    status VARCHAR(255),
    ipo_date DATE,
    delist_date DATE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/hsx_bomojo_data/hsx_movie_master.csv'
INTO TABLE TempHSXMaster
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(identifier, title, @dummy, status, @dummy, @dummy, @dummy, @ipo_date, @dummy, @delist_date, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy)
SET
    ipo_date = NULLIF(@ipo_date, '')
    -- delist_date = STR_TO_DATE(@delist_date, '%m/%d/%Y')
;

-- The temporary table for hsx_movie_prices.csv --------------------
DROP TEMPORARY TABLE IF EXISTS TempHSXPrices;
CREATE TEMPORARY TABLE TempHSXPrices (
    identifier INT,
    price DECIMAL(6,2),
    shares_long INT,
    shares_short INT,
    trading_vol INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/hsx_bomojo_data/hsx_movie_prices.csv'
IGNORE INTO TABLE TempHSXPrices
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(identifier, price, shares_long, shares_short, trading_vol, @dummy, @dummy);

-- The temporary table for domestic_avg_movie_ticket_prices.csv --------------------
DROP TEMPORARY TABLE IF EXISTS TempTicketPrice;
CREATE TEMPORARY TABLE TempTicketPrice (
    year INT,
    avg_movie_ticket_price_usd DECIMAL(6,2),
    source VARCHAR(255)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/domestic_avg_movie_ticket_prices.csv'
INTO TABLE TempTicketPrice
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Create Tables in reference to ER model --------------------------------------------------------------------

CREATE TABLE Movies (
    -- Consider AUTO_INCREMENT on movie_id
    movie_id INT PRIMARY KEY AUTO_INCREMENT,
    imdb_id Varchar(255) UNIQUE,
    tmdb_id INT,
    title varchar(255),
    overview varchar(10000),
    tagline varchar(255),
    runtime INT,
    release_date datetime
);

CREATE TABLE Metadata (
    movie_id INT PRIMARY KEY,
    keywords TEXT DEFAULT NULL,
    adult BOOLEAN, 
    original_language varchar(10),
    spoken_languages VARCHAR(255),
    original_title varchar(255),
    poster_path varchar(255),
    movie_status varchar(255),
    foreign key (movie_id) references Movies(movie_id) on delete cascade 
);

CREATE TABLE MovieVotes(
    movie_id INT NOT NULL PRIMARY KEY,
    popularity FLOAT,
    vote_average FLOAT,
    vote_count INT,
    rating FLOAT,
    foreign key (movie_id) references Movies(movie_id) on delete cascade 
);

CREATE TABLE MovieGenre (
    movie_id int,
    genre varchar(255),
    primary key (movie_id, genre),
    foreign key (movie_id) references Movies(movie_id)  on delete cascade
);

CREATE TABLE MovieProductionCompanies (
    imdb_id Varchar(255),
    production_company varchar(255),
    primary key (imdb_id, production_company),
    foreign key (imdb_id) references Movies (imdb_id) on delete cascade
);

CREATE TABLE MovieProductionCountries (
    imdb_id Varchar(255),
    production_country varchar(255),
    primary key (imdb_id, production_country),
    foreign key (imdb_id) references Movies (imdb_id) on delete cascade
);

CREATE TABLE AvgTicketPrices(
    year INT,
    avg_movie_ticket_price_usd DECIMAL(6,2),
    source varchar(255)
);

CREATE TABLE HollywoodStockExchange(
    title varchar(255) PRIMARY KEY,
    ipo_date DATE,
    delist_date DATE,
    price DECIMAL(6,2),
    shares_long INT,
    shares_short INT,
    trading_vol INT,
    movie_status varchar(255)
);

CREATE TABLE BoxOfficeInfo (
    movie_id INT NOT NULL PRIMARY KEY,
    budget INT,
    domestic_gross INT,
    international_gross INT,
    worldwide_gross INT,
    revenue INT,
    widest_release INT,
    bo_date DATE, 
    daily_domestic_gross INT,
    daily_theater_count INT,
    foreign key (movie_id) references Movies(movie_id)  on delete cascade
);

CREATE TABLE People (
    person_id INT PRIMARY KEY,
    credit_id Varchar(255) NOT NULL,
    name varchar(255) NOT NULL,
    gender INT NOT NULL,
    profile_path varchar(255)
);

  CREATE TABLE CrewMembers(
    movie_id INT,
    person_id INT,
    department varchar(255),
    job varchar(255),
    name varchar(255),
    foreign key (person_id) references People(person_id) on delete cascade,
    foreign key (movie_id) references Movies(movie_id) on delete cascade
);

CREATE TABLE CastMembers(
    movie_id INT,
    person_id INT,
    cast_id INT,
    character_name varchar(2000),
    name varchar(255),
    order_in_cast INT,
    foreign key (person_id) references People(person_id) on delete cascade,
    foreign key (movie_id) references Movies(movie_id) on delete cascade  
);

CREATE TABLE Users(
  username varchar(255) UNIQUE NOT NULL,
  password varchar(255) NOT NULL,
  admin BOOLEAN DEFAULT FALSE
);

CREATE TABLE Reviews(
  movie_id INT NOT NULL,
  new_rating INT NOT NULL,
  description TEXT,
  username varchar(255),
  PRIMARY KEY (movie_id, username)
);


INSERT INTO Movies (movie_id, imdb_id, tmdb_id, title, overview, tagline, runtime, release_date)
SELECT m.movie_id, m.imdb_id, l.tmdb_id, m.title, m.overview, m.tagline, m.runtime, m.release_date
FROM TempLinks l
JOIN MoviesMetadata m ON m.imdb_id = l.imdb_id;


INSERT INTO Metadata (
    movie_id,
    adult,
    original_language,
    spoken_languages,
    original_title,
    poster_path,
    movie_status
)
SELECT
    Movies.movie_id,
    MoviesMetadata.adult,
    MoviesMetadata.original_language,
    MoviesMetadata.spoken_languages,
    MoviesMetadata.original_title,
    MoviesMetadata.poster_path,
    MoviesMetadata.status
FROM
    Movies
JOIN MoviesMetadata ON Movies.imdb_id = MoviesMetadata.imdb_id;

INSERT IGNORE INTO MovieVotes (
    movie_id,
    popularity,
    vote_average,
    vote_count,
    rating
)
SELECT
    Movies.movie_id,
    MoviesMetadata.popularity,
    MoviesMetadata.vote_average,
    MoviesMetadata.vote_count,
    TempRatings.rating
FROM
    Movies
JOIN MoviesMetadata ON Movies.imdb_id = MoviesMetadata.imdb_id
JOIN TempRatings ON Movies.movie_id = TempRatings.movie_id;

INSERT INTO MovieGenre (movie_id, genre)
SELECT
    Movies.movie_id,
    MoviesMetadata.genres
FROM
    Movies
JOIN MoviesMetadata ON Movies.imdb_id = MoviesMetadata.imdb_id;


INSERT INTO MovieProductionCompanies (imdb_id, production_company)
SELECT
    Movies.imdb_id,
    MoviesMetadata.production_companies
FROM
Movies
JOIN MoviesMetadata ON Movies.imdb_id = MoviesMetadata.imdb_id;

INSERT INTO MovieProductionCountries (imdb_id, production_country)
SELECT
    Movies.imdb_id,
    MoviesMetadata.production_countries
FROM
Movies
JOIN MoviesMetadata ON Movies.imdb_id = MoviesMetadata.imdb_id;

INSERT INTO AvgTicketPrices (year, avg_movie_ticket_price_usd, source)
SELECT
    year,
    avg_movie_ticket_price_usd,
    source
FROM
    TempTicketPrice;


INSERT IGNORE INTO BoxOfficeInfo (
    movie_id,
    budget,
    domestic_gross,
    international_gross,
    worldwide_gross,
    revenue,
    widest_release,
    bo_date,
    daily_domestic_gross,
    daily_theater_count
)
SELECT
    MoviesMetadata.movie_id,
    TempBoxOfficeRelease.budget,
    TempBoxOfficeRelease.domestic_gross,
    TempBoxOfficeRelease.international_gross,
    TempBoxOfficeRelease.worldwide_gross,
    MoviesMetadata.revenue,
    TempBoxOfficeRelease.widest_release,
    TempBoxOfficeDaily.bo_date,
    TempBoxOfficeDaily.daily_domestic_gross,
    TempBoxOfficeDaily.daily_theater_count
FROM
    TempBoxOfficeRelease
JOIN MoviesMetadata ON MoviesMetadata.imdb_id = TempBoxOfficeRelease.imdb_id
JOIN TempBoxOfficeDaily ON TempBoxOfficeRelease.identifier = TempBoxOfficeDaily.identifier;
