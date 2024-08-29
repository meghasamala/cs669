DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS User_media;
DROP TABLE IF EXISTS Media_vendor;
DROP TABLE IF EXISTS Book;
DROP TABLE IF EXISTS Album;
DROP TABLE IF EXISTS TV_show;
DROP TABLE IF EXISTS Video_game;
DROP TABLE IF EXISTS Movie;
DROP TABLE IF EXISTS Vendor;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Status_history;
DROP TABLE IF EXISTS Status;
DROP TABLE IF EXISTS Media;
DROP TABLE IF EXISTS Genre;
DROP TABLE IF EXISTS Series_anthology_collection;
DROP TABLE IF EXISTS Rating;

DROP SEQUENCE IF EXISTS user_seq;
DROP SEQUENCE IF EXISTS user_media_seq;
DROP SEQUENCE IF EXISTS media_seq;
DROP SEQUENCE IF EXISTS media_vendor_seq;
DROP SEQUENCE IF EXISTS vendor_seq;
DROP SEQUENCE IF EXISTS SAC_seq;
DROP SEQUENCE IF EXISTS review_seq;
DROP SEQUENCE IF EXISTS status_history_seq;
DROP SEQUENCE IF EXISTS status_seq;
DROP SEQUENCE IF EXISTS genre_seq;
DROP SEQUENCE IF EXISTS rating_seq;

CREATE TABLE Users (
	user_id DECIMAL(12) PRIMARY KEY NOT NULL,
	username VARCHAR(64) NOT NULL,
	first_name VARCHAR(64) NOT NULL,
	last_name VARCHAR(64) NOT NULL,
	account_created DATE NOT NULL
);
CREATE TABLE Vendor (
	vendor_id DECIMAL(12) PRIMARY KEY NOT NULL,
	vendor_name VARCHAR(200) NOT NULL,
	vendor_type VARCHAR(64) NOT NULL,
	vendor_link VARCHAR(200)
);
CREATE TABLE Series_anthology_collection (
	SAC_id DECIMAL(12) PRIMARY KEY NOT NULL,
	SAC_name VARCHAR(200) NOT NULL,
	sub_SAC_name VARCHAR(200),
	SAC_part DECIMAL(12)
);
CREATE TABLE Genre (
	genre_id DECIMAL(12) PRIMARY KEY NOT NULL,
	category VARCHAR(64),
	main_genre VARCHAR(64) NOT NULL,
	subgenre VARCHAR(64)
);
CREATE TABLE Rating (
	rating_id DECIMAL(12) PRIMARY KEY NOT NULL,
	rating VARCHAR(64) NOT NULL
);
CREATE TABLE Media (
	media_id DECIMAL(12) PRIMARY KEY NOT NULL,
	genre_id DECIMAL(12) NOT NULL,
	SAC_id DECIMAL(12),
	rating_id DECIMAL(12),
	media_name VARCHAR(200) NOT NULL,
	date_released DATE,
	FOREIGN KEY (genre_id) REFERENCES Genre(genre_id),
	FOREIGN KEY (SAC_id) REFERENCES Series_anthology_collection(SAC_id),
	FOREIGN KEY (rating_id) REFERENCES Rating(rating_id)
);
CREATE TABLE Status (
	status_id DECIMAL(12) PRIMARY KEY NOT NULL,
	media_id DECIMAL(12),
	overall_status VARCHAR(64) NOT NULL,
	media_section VARCHAR(64),
	media_subsection VARCHAR(64),
	date_started DATE,
	date_finished DATE,
	FOREIGN KEY (media_id) REFERENCES Media(media_id)
);
CREATE TABLE User_media (
	user_media_id DECIMAL(12) PRIMARY KEY NOT NULL,
	user_id DECIMAL(12) NOT NULL,
	media_id DECIMAL(12) NOT NULL,
	FOREIGN KEY (user_id) REFERENCES Users(user_id),
	FOREIGN KEY (media_id) REFERENCES Media(media_id)
);
CREATE TABLE Media_vendor (
	media_vendor_id DECIMAL(12) PRIMARY KEY NOT NULL,
	vendor_id DECIMAL(12) NOT NULL,
	media_id DECIMAL(12) NOT NULL,
	media_link VARCHAR(200),
	price DECIMAL(4,2),
	FOREIGN KEY (vendor_id) REFERENCES Vendor(vendor_id),
	FOREIGN KEY (media_id) REFERENCES Media(media_id)
);
CREATE TABLE Review (
	review_id DECIMAL(12) PRIMARY KEY NOT NULL,
	media_id DECIMAL(12) NOT NULL,
	out_of_ten DECIMAL(2) NOT NULL,
	review VARCHAR(65000),
	review_link VARCHAR(200),
	FOREIGN KEY (media_id) REFERENCES Media(media_id)
);
CREATE TABLE Book (
	media_id DECIMAL(12) PRIMARY KEY NOT NULL,
	author VARCHAR(64),
	FOREIGN KEY (media_id) REFERENCES Media(media_id)
);
CREATE TABLE Album (
	media_id DECIMAL(12) PRIMARY KEY NOT NULL,
	artist VARCHAR(64),
	FOREIGN KEY (media_id) REFERENCES Media(media_id)
);
CREATE TABLE TV_show (
	media_id DECIMAL(12) PRIMARY KEY NOT NULL,
	creator VARCHAR(64),
	production_company VARCHAR(64),
	FOREIGN KEY (media_id) REFERENCES Media(media_id)
);
CREATE TABLE Video_game (
	media_id DECIMAL(12) PRIMARY KEY NOT NULL,
	platform VARCHAR(64),
	game_developer VARCHAR(64),
	publisher VARCHAR(64),
	FOREIGN KEY (media_id) REFERENCES Media(media_id)
);
CREATE TABLE Movie (
	media_id DECIMAL(12) PRIMARY KEY NOT NULL,
	director VARCHAR(64),
	production_company VARCHAR(64),
	FOREIGN KEY (media_id) REFERENCES Media(media_id)
);

CREATE SEQUENCE user_seq START WITH 1;
CREATE SEQUENCE user_media_seq START WITH 1;
CREATE SEQUENCE media_seq START WITH 1;
CREATE SEQUENCE media_vendor_seq START WITH 1;
CREATE SEQUENCE vendor_seq START WITH 1;
CREATE SEQUENCE SAC_seq START WITH 1;
CREATE SEQUENCE review_seq START WITH 1;
CREATE SEQUENCE status_seq START WITH 1;
CREATE SEQUENCE genre_seq START WITH 1;
CREATE SEQUENCE rating_seq START WITH 1;

-- adding users
CREATE OR REPLACE PROCEDURE add_user(
	username_arg IN VARCHAR,
	first_name_arg IN VARCHAR,
	last_name_arg IN VARCHAR)
	LANGUAGE plpgsql
AS
$$
BEGIN
	INSERT INTO Users(user_id, username, first_name, last_name, account_created)
	VALUES(nextval('user_seq'), username_arg, first_name_arg, last_name_arg, CURRENT_DATE);
END;
$$;

START TRANSACTION;
DO
$$ BEGIN
	CALL add_user('msamala', 'Megha', 'Samala');
	CALL add_user('nbardhan', 'Neha', 'Bardhan');
	CALL add_user('aismail', 'Afra', 'Ismail');
	CALL add_user('sanand', 'Soummitra', 'Anand');
	CALL add_user('mkoleti', 'Manish', 'Koleti');
	CALL add_user('tnguyen', 'Tim', 'Nguyen');
END $$;
COMMIT TRANSACTION;

-- throw error if username is already taken when creating new user account
CREATE OR REPLACE FUNCTION user_username_func()
	RETURNS TRIGGER LANGUAGE plpgsql
	AS $$
	BEGIN
		IF EXISTS(
			SELECT username FROM Users WHERE username = NEW.username
		) THEN
			RAISE EXCEPTION USING MESSAGE = 'Username is already taken',
			ERRCODE = 23000;
		END IF;
		RETURN NEW;
	END;
	$$;
CREATE TRIGGER user_username_trg
BEFORE UPDATE OR INSERT ON Users
FOR EACH ROW 
EXECUTE PROCEDURE user_username_func();

-- INSERT INTO Users(user_id, username, first_name, last_name, account_created)
-- VALUES(nextval('user_seq'), 'msamala', 'Sdnfsdf', 'Hjsdfjb', CURRENT_DATE);

-- adding rating
CREATE OR REPLACE PROCEDURE add_rating(
	rating_arg IN VARCHAR)
	LANGUAGE plpgsql
AS
$$
BEGIN
	INSERT INTO Rating(rating_id, rating)
	VALUES(nextval('rating_seq'), rating_arg);
END;
$$;

START TRANSACTION;
DO
$$ BEGIN
	CALL add_rating('TV-Y');
	CALL add_rating('TV-Y7');
	CALL add_rating('TV-G');
	CALL add_rating('TV-PG');
	CALL add_rating('TV-14');
	CALL add_rating('TV-MA');
	CALL add_rating('G');
	CALL add_rating('PG');
	CALL add_rating('PG-13');
	CALL add_rating('R');
	CALL add_rating('NC-17');
	CALL add_rating('E');
	CALL add_rating('E10+');
	CALL add_rating('T');
	CALL add_rating('M');
	CALL add_rating('NR');
	CALL add_rating('Explicit');
END $$;
COMMIT TRANSACTION;

-- adding genres
CREATE OR REPLACE PROCEDURE add_genre(
	category_arg IN VARCHAR,
	main_genre_arg IN VARCHAR,
	subgenre_arg IN VARCHAR
	) LANGUAGE plpgsql
AS
$$
BEGIN
	INSERT INTO Genre(genre_id, category, main_genre, subgenre)
	VALUES(nextval('genre_seq'), category_arg, main_genre_arg, subgenre_arg);
END;
$$;

START TRANSACTION;
DO
$$ BEGIN
	CALL add_genre('Fiction', 'Mystery', 'Historical');
	CALL add_genre('Full album', 'Pop', 'Hyperpop');
	CALL add_genre('Full album', 'Rap', 'R&B');
	CALL add_genre('Fiction', 'Fantasy', 'High fantasy');
	CALL add_genre('Manga', 'Shounen', 'Action');
	CALL add_genre('Full album', 'Korean', 'Rap');
	CALL add_genre('Full album', 'Pop', 'Alternative');
	CALL add_genre('Series', 'Drama', 'Romance');
	CALL add_genre('Series', 'Comedy', 'Drama');
	CALL add_genre('Series', 'Romance', 'Historical');
	CALL add_genre('Anime', 'Shounen', 'Action');
	CALL add_genre('Anime', 'Seinen', 'Fantasy');
	CALL add_genre('JRPG', 'Fantasy', 'High fantasy');
	CALL add_genre('JRPG', 'Fantasy', 'Sci-fi');
	CALL add_genre('Third-person shooter', 'Horror', 'Action');
	CALL add_genre('Feature film', 'Action', 'Comedy');
	CALL add_genre('Feature film', 'Horror', 'Mystery');
	CALL add_genre('Short film', 'Comedy', 'Adventure');
	CALL add_genre('Anime', 'Shoujo', 'Fantasy');
	
END $$;
COMMIT TRANSACTION;

-- adding series, anthology, collection
CREATE OR REPLACE PROCEDURE add_SAC(
	SAC_name_arg IN VARCHAR,
	sub_SAC_name_arg IN VARCHAR,
	SAC_part_arg IN DECIMAL
	) LANGUAGE plpgsql
AS
$$
BEGIN
	INSERT INTO Series_anthology_collection(SAC_id, SAC_name, sub_SAC_name, SAC_part)
	VALUES(nextval('SAC_seq'), SAC_name_arg, sub_SAC_name_arg, SAC_part_arg);
END;
$$;

START TRANSACTION;
DO
$$ BEGIN
	CALL add_SAC('Detective Kindaichi Mysteries', NULL, 1);
	CALL add_SAC('Detective Kindaichi Mysteries', NULL, 2);
	CALL add_SAC('Mistborn', 'Mistborn Trilogy 1', 1);
	CALL add_SAC('Jujutsu Kaisen', NULL, NULL);
	CALL add_SAC('Bleach', NULL, NULL);
	CALL add_SAC('Epik High Is Here', NULL, 1);
	CALL add_SAC('Epik High Is Here', NULL, 2);
	CALL add_SAC('Bridgerton', NULL, NULL);
	CALL add_SAC('Sousou no Frieren', NULL, NULL);
	CALL add_SAC('Final Fantasy', NULL, 16);
	CALL add_SAC('Final Fantasy', 'Compilation of Final Fantasy VII', 7);
	CALL add_SAC('Resident Evil', 'Resident Evil Remakes', 3);
	CALL add_SAC('Resident Evil', 'Resident Evil Remakes', 4);
	CALL add_SAC('Fire Emblem', 'Fodlan Games', 16);
	CALL add_SAC('Kingsman', 'Kingsman Movies', 1);
	CALL add_SAC('Kingsman', 'Kingsman Movies', 2);
	CALL add_SAC('Howl''s Moving Castle', NULL, NULL);
END $$;
COMMIT TRANSACTION;

-- manual media inserts here
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Fiction' AND main_genre='Mystery' AND subgenre='Historical'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Detective Kindaichi Mysteries' AND SAC_part=1),
	  (SELECT rating_id FROM Rating WHERE rating='NR'),
	  'The Honjin Murders',
	  CAST('04-AUG-2020' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Fiction' AND main_genre='Mystery' AND subgenre='Historical'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Detective Kindaichi Mysteries' AND SAC_part=2),
	  (SELECT rating_id FROM Rating WHERE rating='NR'),
	  'Death on Gokumon Island',
	  CAST('05-JUL-2022' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Full album' AND main_genre='Pop' AND subgenre='Hyperpop'),
	  NULL,
	  (SELECT rating_id FROM Rating WHERE rating='Explicit'),
	  'BRAT',
	  CAST('07-JUN-2024' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Full album' AND main_genre='Rap' AND subgenre='R&B'),
	  NULL,
	  (SELECT rating_id FROM Rating WHERE rating='Explicit'),
	  'HARDSTONE PSYCHO',
	  CAST('14-JUN-2024' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Fiction' AND main_genre='Fantasy' AND subgenre='High fantasy'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Mistborn' AND SAC_part=1),
	  (SELECT rating_id FROM Rating WHERE rating='NR'),
	  'Mistborn: The Final Empire',
	  CAST('17-JUL-2006' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Manga' AND main_genre='Shounen' AND subgenre='Action'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Jujutsu Kaisen' AND SAC_part=NULL),
	  (SELECT rating_id FROM Rating WHERE rating='NR'),
	  'Jujutsu Kaisen',
	  CAST('05-MAR-2018' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Manga' AND main_genre='Shounen' AND subgenre='Action'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Bleach' AND SAC_part=NULL),
	  (SELECT rating_id FROM Rating WHERE rating='NR'),
	  'Bleach',
	  CAST('07-AUG-2001' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Full album' AND main_genre='Korean' AND subgenre='Rap'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Epik High Is Here' AND SAC_part=1),
	  (SELECT rating_id FROM Rating WHERE rating='Explicit'),
	  'Epik High Is Here (Part 1)',
	  CAST('18-JAN-2021' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Full album' AND main_genre='Korean' AND subgenre='Rap'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Epik High Is Here' AND SAC_part=2),
	  (SELECT rating_id FROM Rating WHERE rating='NR'),
	  'Epik High Is Here (Part 2)',
	  CAST('14-FEB-2022' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Full album' AND main_genre='Pop' AND subgenre='Alternative'),
	  NULL,
	  (SELECT rating_id FROM Rating WHERE rating='Explicit'),
	  'Heaven Knows',
	  CAST('10-NOV-2023' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Series' AND main_genre='Drama' AND subgenre='Romance'),
	  NULL,
	  (SELECT rating_id FROM Rating WHERE rating='TV-MA'),
	  'Euphoria',
	  CAST('16-JUN-2019' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Series' AND main_genre='Comedy' AND subgenre='Drama'),
	  NULL,
	  (SELECT rating_id FROM Rating WHERE rating='TV-MA'),
	  'Derry Girls',
	  CAST('04-JAN-2018' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Series' AND main_genre='Romance' AND subgenre='Historical'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Bridgerton' AND SAC_part=NULL),
	  (SELECT rating_id FROM Rating WHERE rating='TV-MA'),
	  'Bridgerton',
	  CAST('25-DEC-2020' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Anime' AND main_genre='Shounen' AND subgenre='Action'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Jujutsu Kaisen' AND SAC_part=NULL),
	  (SELECT rating_id FROM Rating WHERE rating='NR'),
	  'Jujutsu Kaisen',
	  CAST('03-OCT-2020' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Anime' AND main_genre='Seinen' AND subgenre='Fantasy'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Sousou no Frieren' AND SAC_part=NULL),
	  (SELECT rating_id FROM Rating WHERE rating='NR'),
	  'Sousou no Frieren',
	  CAST('29-SEP-2023' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='JRPG' AND main_genre='Fantasy' AND subgenre='High fantasy'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Final Fantasy' AND SAC_part=16),
	  (SELECT rating_id FROM Rating WHERE rating='M'),
	  'Final Fantasy XVI',
	  CAST('22-JUN-2023' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='JRPG' AND main_genre='Fantasy' AND subgenre='Sci-fi'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Final Fantasy' AND SAC_part=7),
	  (SELECT rating_id FROM Rating WHERE rating='T'),
	  'Final Fantasy VII Remake',
	  CAST('10-APR-2020' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='JRPG' AND main_genre='Fantasy' AND subgenre='Sci-fi'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Final Fantasy' AND SAC_part=7),
	  (SELECT rating_id FROM Rating WHERE rating='T'),
	  'Crisis Core: Final Fantasy VII Reunion',
	  CAST('13-DEC-2022' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Third-person shooter' AND main_genre='Horror' AND subgenre='Action'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Resident Evil' AND SAC_part=4),
	  (SELECT rating_id FROM Rating WHERE rating='M'),
	  'Resident Evil 4 Remake',
	  CAST('24-MAR-2023' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Third-person shooter' AND main_genre='Horror' AND subgenre='Action'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Resident Evil' AND SAC_part=3),
	  (SELECT rating_id FROM Rating WHERE rating='M'),
	  'Resident Evil 3 Remake',
	  CAST('03-APR-2020' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='JRPG' AND main_genre='Fantasy' AND subgenre='High fantasy'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Fire Emblem' AND SAC_part=16),
	  (SELECT rating_id FROM Rating WHERE rating='T'),
	  'Fire Emblem: Three Houses',
	  CAST('26-JUL-2019' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Feature film' AND main_genre='Action' AND subgenre='Comedy'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Kingsman' AND SAC_part=1),
	  (SELECT rating_id FROM Rating WHERE rating='R'),
	  'Kingsman: The Secret Service',
	  CAST('12-FEB-2015' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Feature film' AND main_genre='Action' AND subgenre='Comedy'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Kingsman' AND SAC_part=2),
	  (SELECT rating_id FROM Rating WHERE rating='R'),
	  'Kingsman: The Golden Circle',
	  CAST('22-SEP-2017' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Feature film' AND main_genre='Horror' AND subgenre='Mystery'),
	  NULL,
	  (SELECT rating_id FROM Rating WHERE rating='R'),
	  'Midsommar',
	  CAST('03-JUL-2019' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Short film' AND main_genre='Comedy' AND subgenre='Adventure'),
	  NULL,
	  (SELECT rating_id FROM Rating WHERE rating='PG'),
	  'The Wonderful Story of Henry Sugar',
	  CAST('01-SEP-2023' AS DATE));
INSERT INTO Media(media_id, genre_id, SAC_id, rating_id, media_name, date_released)
VALUES(nextval('media_seq'), 
	  (SELECT genre_id FROM Genre WHERE category='Anime' AND main_genre='Shoujo' AND subgenre='Fantasy'),
	  (SELECT SAC_id FROM Series_anthology_collection WHERE SAC_name='Howl''s Moving Castle' AND SAC_part=NULL),
	  (SELECT rating_id FROM Rating WHERE rating='PG'),
	  'Howl''s Moving Castle',
	  CAST('12-JUL-2012' AS DATE));
	  
-- throw error if date started is earlier than media release date	  
CREATE OR REPLACE FUNCTION status_date_func()
	RETURNS TRIGGER LANGUAGE plpgsql
	AS $$
	DECLARE
		v_date_released DATE;
	BEGIN
		SELECT date_released
		INTO v_date_released
		FROM Media
		WHERE Media.media_id = NEW.media_id;
		
		IF NEW.date_started < v_date_released THEN
			RAISE EXCEPTION USING MESSAGE = 'Invalid started on date',
			ERRCODE = 22000;
		END IF;
		RETURN NEW;
	END;
	$$;
CREATE TRIGGER status_date_trg
BEFORE UPDATE OR INSERT ON Status
FOR EACH ROW
EXECUTE PROCEDURE status_date_func();

-- adding a media as a book
CREATE OR REPLACE PROCEDURE add_book(
	media_name_arg IN VARCHAR,
	date_released_arg IN DATE,
	author_arg IN VARCHAR) LANGUAGE plpgsql
AS
$$
DECLARE
	v_media_id DECIMAL(12);
BEGIN
	SELECT media_id
	INTO v_media_id
	FROM Media
	WHERE media_name = media_name_arg AND date_released = date_released_arg;
	
	INSERT INTO Book(media_id, author)
	VALUES(v_media_id, author_arg);
END;
$$;

START TRANSACTION;
DO
$$ BEGIN
	CALL add_book('The Honjin Murders', CAST('04-AUG-2020' AS DATE), 'Seishi Yokomizo');
	CALL add_book('Death on Gokumon Island', CAST('05-JUL-2022' AS DATE), 'Seishi Yokomizo');
	CALL add_book('Mistborn: The Final Empire', CAST('17-JUL-2006' AS DATE), 'Brandon Sanderson');
	CALL add_book('Jujutsu Kaisen', CAST('05-MAR-2018' AS DATE), 'Gege Akutami');
	CALL add_book('Bleach', CAST('07-AUG-2001' AS DATE), 'Tite Kubo');
END $$;
COMMIT TRANSACTION;

-- adding media as an album
CREATE OR REPLACE PROCEDURE add_album(
	media_name_arg IN VARCHAR,
	date_released_arg IN DATE,
	artist_arg IN VARCHAR) LANGUAGE plpgsql
AS
$$
DECLARE
	v_media_id DECIMAL(12);
BEGIN
	SELECT media_id
	INTO v_media_id
	FROM Media
	WHERE media_name = media_name_arg AND date_released = date_released_arg;
	
	INSERT INTO Album(media_id, artist)
	VALUES(v_media_id, artist_arg);
END;
$$;

START TRANSACTION;
DO
$$ BEGIN
	CALL add_album('BRAT', CAST('07-JUN-2024' AS DATE), 'Charli xcx');
	CALL add_album('HARDSTONE PSYCHO', CAST('14-JUN-2024' AS DATE), 'Don Toliver');
	CALL add_album('Epik High Is Here (Part 1)', CAST('18-JAN-2021' AS DATE), 'Epik High');
	CALL add_album('Epik High Is Here (Part 2)', CAST('14-FEB-2022' AS DATE), 'Epik High');
	CALL add_album('Heaven Knows', CAST('10-NOV-2023' AS DATE), 'Pinkpantheress');
END $$;
COMMIT TRANSACTION;

-- adding media as a TV show
CREATE OR REPLACE PROCEDURE add_TV_show(
	media_name_arg IN VARCHAR,
	date_released_arg IN DATE,
	creator_arg IN VARCHAR,
	production_company_arg IN VARCHAR) LANGUAGE plpgsql
AS
$$
DECLARE
	v_media_id DECIMAL(12);
BEGIN
	SELECT media_id
	INTO v_media_id
	FROM Media
	WHERE media_name = media_name_arg AND date_released = date_released_arg;
	
	INSERT INTO TV_show(media_id, creator, production_company)
	VALUES(v_media_id, creator_arg, production_company_arg);
END;
$$;

START TRANSACTION;
DO
$$ BEGIN
	CALL add_TV_show('Euphoria', CAST('16-JUN-2019' AS DATE), 'Sam Levinson', 'A24');
	CALL add_TV_show('Derry Girls', CAST('04-JAN-2018' AS DATE), 'Lisa McGee', 'Hat Trick Productions');
	CALL add_TV_show('Bridgerton', CAST('25-DEC-2020' AS DATE), 'Chris Van Dusen', 'Shondaland');
	CALL add_TV_show('Jujutsu Kaisen', CAST('03-OCT-2020' AS DATE), 'Sunghoo Park', 'MAPPA');
	CALL add_TV_show('Sousou no Frieren', CAST('29-SEP-2023' AS DATE), 'Keiichiro Saito', 'Madhouse');
END $$;
COMMIT TRANSACTION;

-- adding media as a video game
CREATE OR REPLACE PROCEDURE add_video_game(
	media_name_arg IN VARCHAR,
	date_released_arg IN DATE,
	platform_arg IN VARCHAR,
	game_developer_arg IN VARCHAR,
	publisher_arg IN VARCHAR) LANGUAGE plpgsql
AS
$$
DECLARE
	v_media_id DECIMAL(12);
BEGIN
	SELECT media_id
	INTO v_media_id
	FROM Media
	WHERE media_name = media_name_arg AND date_released = date_released_arg;
	
	INSERT INTO Video_game(media_id, platform, game_developer, publisher)
	VALUES(v_media_id, platform_arg, game_developer_arg, publisher_arg);
END;
$$;

START TRANSACTION;
DO
$$ BEGIN
	CALL add_video_game('Final Fantasy XVI', CAST('22-JUN-2023' AS DATE), 'PS5', 'Square Enix', 'Square Enix');
	CALL add_video_game('Final Fantasy VII Remake', CAST('10-APR-2020' AS DATE), 'PS5', 'Square Enix', 'Square Enix');
	CALL add_video_game('Crisis Core: Final Fantasy VII Reunion', CAST('13-DEC-2022' AS DATE), 'PS5', 'Square Enix', 'Square Enix');
	CALL add_video_game('Resident Evil 4 Remake', CAST('24-MAR-2023' AS DATE), 'PS5', 'Capcom', 'Capcom');
	CALL add_video_game('Resident Evil 3 Remake', CAST('03-APR-2020' AS DATE), 'PS5', 'Capcom', 'Capcom');
	CALL add_video_game('Fire Emblem: Three Houses', CAST('26-JUL-2019' AS DATE), 'Nintendo Switch', 'Intelligent Systems', 'Nintendo');
END $$;
COMMIT TRANSACTION;

-- adding media as a movie
CREATE OR REPLACE PROCEDURE add_movie(
	media_name_arg IN VARCHAR,
	date_released_arg IN DATE,
	director_arg IN VARCHAR,
	production_company_arg IN VARCHAR) LANGUAGE plpgsql
AS
$$
DECLARE
	v_media_id DECIMAL(12);
BEGIN
	SELECT media_id
	INTO v_media_id
	FROM Media
	WHERE media_name = media_name_arg AND date_released = date_released_arg;
	
	INSERT INTO Movie(media_id, director, production_company)
	VALUES(v_media_id, director_arg, production_company_arg);
END;
$$;

START TRANSACTION;
DO
$$ BEGIN
	CALL add_movie('Kingsman: The Secret Service', CAST('12-FEB-2015' AS DATE), 'Matthew Vaughn', 'Marv Studios');
	CALL add_movie('Kingsman: The Golden Circle', CAST('22-SEP-2017' AS DATE), 'Matthew Vaughn', '20th Century Studios');
	CALL add_movie('Midsommar', CAST('03-JUL-2019' AS DATE), 'Ari Aster', 'A24');
	CALL add_movie('The Wonderful Story of Henry Sugar', CAST('01-SEP-2023' AS DATE), 'Wes Anderson', 'Netflix Studios');
	CALL add_movie('Howl''s Moving Castle', CAST('12-JUL-2012' AS DATE), 'Hayao Miyazaki', 'Studio Ghibli');
END $$;
COMMIT TRANSACTION;

-- adding status
CREATE OR REPLACE PROCEDURE add_status(
	media_name_arg IN VARCHAR,
	date_released_arg IN DATE,
	overall_status_arg IN VARCHAR,
	media_section_arg IN VARCHAR,
	media_subsection_arg IN VARCHAR,
	date_started_arg IN DATE,
	date_finished_arg IN DATE
	) LANGUAGE plpgsql
AS
$$
DECLARE
	v_media_id DECIMAL(12);
BEGIN
	SELECT media_id
	INTO v_media_id
	FROM Media
	WHERE media_name = media_name_arg AND date_released = date_released_arg;
	
	INSERT INTO Status(status_id, media_id, overall_status, media_section, media_subsection, date_started, date_finished)
	VALUES(nextval('status_seq'), v_media_id, overall_status_arg, media_section_arg, media_subsection_arg, date_started_arg, date_finished_arg);
END;
$$;

START TRANSACTION;
DO
$$ BEGIN
	CALL add_status('The Honjin Murders', CAST('04-AUG-2020' AS DATE), 'Completed', NULL, NULL, CAST('04-MAR-2023' AS DATE), CAST('27-MAR-2023' AS DATE));
	CALL add_status('Death on Gokumon Island', CAST('05-JUL-2022' AS DATE), 'Planned', NULL, NULL, NULL, NULL);
	CALL add_status('BRAT', CAST('07-JUN-2024' AS DATE), 'Completed', NULL, NULL, CAST('07-JUN-2024' AS DATE), CAST('08-JUN-2024' AS DATE));
	CALL add_status('HARDSTONE PSYCHO', CAST('14-JUN-2024' AS DATE), 'Completed', NULL, NULL, CAST('15-JUN-2024' AS DATE), CAST('16-JUN-2024' AS DATE));
	CALL add_status('Mistborn: The Final Empire', CAST('17-JUL-2006' AS DATE), 'In Progress', 'Chapter 5', 'Page 94', CAST('02-JUN-2024' AS DATE), NULL);
	CALL add_status('Jujutsu Kaisen', CAST('05-MAR-2018' AS DATE), 'In Progress', 'Volume 25', 'Chapter 218', NULL, NULL);
	CALL add_status('Bleach', CAST('07-AUG-2001' AS DATE), 'Completed', 'Volume 74', 'Chapter 705', CAST('27-OCT-2022' AS DATE), CAST('18-NOV-2022' AS DATE));
	CALL add_status('Epik High Is Here (Part 1)', CAST('18-JAN-2021' AS DATE), 'Completed', NULL, NULL, CAST('18-JAN-2021' AS DATE), CAST('18-JAN-2021' AS DATE));
	CALL add_status('Epik High Is Here (Part 2)', CAST('14-FEB-2022' AS DATE), 'Planned', NULL, NULL, NULL, NULL);
	CALL add_status('Heaven Knows', CAST('10-NOV-2023' AS DATE), 'Completed', NULL, NULL, CAST('11-NOV-2023' AS DATE), CAST('11-NOV-2023' AS DATE));
	CALL add_status('Euphoria', CAST('16-JUN-2019' AS DATE), 'In Progress', 'Season 2', 'Episode 8', CAST('20-JUN-2020' AS DATE), NULL);
	CALL add_status('Derry Girls', CAST('04-JAN-2018' AS DATE), 'Completed', NULL, NULL, CAST('15-FEB-2023' AS DATE), CAST('18-FEB-2023' AS DATE));
	CALL add_status('Bridgerton', CAST('25-DEC-2020' AS DATE), 'In Progress', 'Season 3', 'Episode 4', CAST('27-DEC-2020' AS DATE), NULL);
	CALL add_status('Jujutsu Kaisen', CAST('03-OCT-2020' AS DATE), 'In Progress', 'Season 2', 'Episode 15', CAST('06-OCT-2020' AS DATE), NULL);
	CALL add_status('Sousou no Frieren', CAST('29-SEP-2023' AS DATE), 'Planned', NULL, NULL, NULL, NULL);
	CALL add_status('Final Fantasy XVI', CAST('22-JUN-2023' AS DATE), 'In Progress', 'Chapter 34', NULL, CAST('27-JUN-2023' AS DATE), NULL);
	CALL add_status('Final Fantasy VII Remake', CAST('10-APR-2020' AS DATE), 'Completed', NULL, NULL, CAST('26-DEC-2021' AS DATE), CAST('14-NOV-2023' AS DATE));
	CALL add_status('Crisis Core: Final Fantasy VII Reunion', CAST('13-DEC-2022' AS DATE), 'Planned', NULL, NULL, NULL, NULL);
	CALL add_status('Resident Evil 4 Remake', CAST('24-MAR-2023' AS DATE), 'Planned', NULL, NULL, NULL, NULL);
	CALL add_status('Resident Evil 3 Remake', CAST('03-APR-2020' AS DATE), 'Completed', NULL, NULL, CAST('06-APR-2020' AS DATE), CAST('11-MAY-2020' AS DATE));
	CALL add_status('Fire Emblem: Three Houses', CAST('26-JUL-2019' AS DATE), 'Completed', NULL, NULL, CAST('27-JUL-2019' AS DATE), CAST('04-SEP-2019' AS DATE));
	CALL add_status('Kingsman: The Secret Service', CAST('12-FEB-2015' AS DATE), 'Completed', NULL, NULL, CAST('13-SEP-2019' AS DATE), CAST('13-SEP-2019' AS DATE));
	CALL add_status('Kingsman: The Golden Circle', CAST('22-SEP-2017' AS DATE), 'Completed', NULL, NULL, CAST('14-SEP-2019' AS DATE), CAST('14-SEP-2019' AS DATE));
	CALL add_status('Midsommar', CAST('03-JUL-2019' AS DATE), 'Completed', NULL, NULL, CAST('07-JUL-2019' AS DATE), CAST('07-JUL-2019' AS DATE));
	CALL add_status('The Wonderful Story of Henry Sugar', CAST('01-SEP-2023' AS DATE), 'Planned', NULL, NULL, NULL, NULL);
	CALL add_status('Howl''s Moving Castle', CAST('12-JUL-2012' AS DATE), 'Completed', NULL, NULL, CAST('03-MAY-2017' AS DATE), CAST('03-MAY-2017' AS DATE));
	
END $$;
COMMIT TRANSACTION;


-- adding user media connection
CREATE OR REPLACE PROCEDURE add_user_media(
	username_arg IN VARCHAR,
	media_name_arg IN VARCHAR,
	date_released_arg IN DATE) LANGUAGE plpgsql
AS
$$
DECLARE
	v_media_id DECIMAL(12);
	v_user_id DECIMAL(12);
BEGIN
	SELECT media_id
	INTO v_media_id
	FROM Media
	WHERE media_name = media_name_arg AND date_released = date_released_arg;
	
	SELECT user_id
	INTO v_user_id
	FROM Users
	WHERE username = username_arg;
	
	INSERT INTO User_media(user_media_id, user_id, media_id)
	VALUES(nextval('user_media_seq'), v_user_id, v_media_id);
END;
$$;

START TRANSACTION;
DO
$$ BEGIN
	CALL add_user_media('msamala', 'The Honjin Murders', CAST('04-AUG-2020' AS DATE));
	CALL add_user_media('msamala', 'Death on Gokumon Island', CAST('05-JUL-2022' AS DATE));
	CALL add_user_media('msamala', 'Heaven Knows', CAST('10-NOV-2023' AS DATE));
	CALL add_user_media('msamala', 'Derry Girls', CAST('04-JAN-2018' AS DATE));
	CALL add_user_media('msamala', 'Kingsman: The Secret Service', CAST('12-FEB-2015' AS DATE));
	CALL add_user_media('msamala', 'Kingsman: The Golden Circle', CAST('22-SEP-2017' AS DATE));
	CALL add_user_media('nbardhan', 'Mistborn: The Final Empire', CAST('17-JUL-2006' AS DATE));
	CALL add_user_media('nbardhan', 'Epik High Is Here (Part 1)', CAST('18-JAN-2021' AS DATE));
	CALL add_user_media('nbardhan', 'Epik High Is Here (Part 2)', CAST('14-FEB-2022' AS DATE));
	CALL add_user_media('nbardhan', 'Howl''s Moving Castle', CAST('12-JUL-2012' AS DATE));
	CALL add_user_media('aismail', 'BRAT', CAST('07-JUN-2024' AS DATE));
	CALL add_user_media('aismail', 'Bridgerton', CAST('25-DEC-2020' AS DATE));
	CALL add_user_media('aismail', 'Midsommar', CAST('03-JUL-2019' AS DATE));
	CALL add_user_media('aismail', 'Final Fantasy XVI', CAST('22-JUN-2023' AS DATE));
	CALL add_user_media('sanand', 'Final Fantasy VII Remake', CAST('10-APR-2020' AS DATE));
	CALL add_user_media('sanand', 'Crisis Core: Final Fantasy VII Reunion', CAST('13-DEC-2022' AS DATE));
	CALL add_user_media('sanand', 'The Wonderful Story of Henry Sugar', CAST('01-SEP-2023' AS DATE));
	CALL add_user_media('sanand', 'Euphoria', CAST('16-JUN-2019' AS DATE));
	CALL add_user_media('sanand', 'HARDSTONE PSYCHO', CAST('14-JUN-2024' AS DATE));
	CALL add_user_media('mkoleti', 'Jujutsu Kaisen', CAST('05-MAR-2018' AS DATE));
	CALL add_user_media('mkoleti', 'Jujutsu Kaisen', CAST('03-OCT-2020' AS DATE));
	CALL add_user_media('mkoleti', 'Sousou no Frieren', CAST('29-SEP-2023' AS DATE));
	CALL add_user_media('tnguyen', 'Resident Evil 4 Remake', CAST('24-MAR-2023' AS DATE));
	CALL add_user_media('tnguyen', 'Resident Evil 3 Remake', CAST('03-APR-2020' AS DATE));
	CALL add_user_media('tnguyen', 'Fire Emblem: Three Houses', CAST('26-JUL-2019' AS DATE));
	CALL add_user_media('tnguyen', 'Bleach', CAST('07-AUG-2001' AS DATE));
END $$;
COMMIT TRANSACTION;	

-- adding vendor
CREATE OR REPLACE PROCEDURE add_vendor(
	vendor_name_arg IN VARCHAR,
	vendor_type_arg IN VARCHAR,
	vendor_link_arg IN VARCHAR) LANGUAGE plpgsql
AS
$$
BEGIN
	INSERT INTO Vendor(vendor_id, vendor_name, vendor_type, vendor_link)
	VALUES(nextval('vendor_seq'), vendor_name_arg, vendor_type_arg, vendor_link_arg);
END;
$$;

START TRANSACTION;
DO
$$ BEGIN
	CALL add_vendor('Barnes & Noble', 'Physical storefront', 'barnesandnoble.com');
	CALL add_vendor('Spotify', 'Subscription service', 'spotify.com');
	CALL add_vendor('Amazon', 'Website', 'amazon.com');
	CALL add_vendor('Amazon Prime Video', 'Website', 'primevideo.com');
	CALL add_vendor('Netflix', 'Subscription service', 'netflix.com');
	CALL add_vendor('HBO Max', 'Subscription service', 'hbo.com');
	CALL add_vendor('Gamestop', 'Physical storefront', 'gamestop.com');
	CALL add_vendor('AMC Theatres', 'Physical storefront', 'amctheatres.com');
	CALL add_vendor('Cinemark Theatres', 'Physical storefront', 'cinemark.com');
	CALL add_vendor('Viz Media', 'Subscription service', 'viz.com');
END $$;
COMMIT TRANSACTION;

-- adding media vendor connection (media purchase)
CREATE OR REPLACE PROCEDURE add_media_vendor(
	vendor_name_arg IN VARCHAR,
	media_name_arg IN VARCHAR,
	date_released_arg IN DATE,
	media_link_arg IN VARCHAR,
	price_arg IN DECIMAL) LANGUAGE plpgsql
AS
$$
DECLARE
	v_vendor_id DECIMAL(12);
	v_media_id DECIMAL(12);
BEGIN
	SELECT media_id
	INTO v_media_id
	FROM Media
	WHERE media_name = media_name_arg AND date_released = date_released_arg;
	
	SELECT vendor_id
	INTO v_vendor_id
	FROM Vendor
	WHERE vendor_name = vendor_name_arg;
	
	INSERT INTO Media_vendor(media_vendor_id, vendor_id, media_id, media_link, price)
	VALUES(nextval('media_vendor_seq'), v_vendor_id, v_media_id, media_link_arg, price_arg);
END;
$$;

START TRANSACTION;
DO
$$ BEGIN
	CALL add_media_vendor('Barnes & Noble', 'The Honjin Murders', CAST('04-AUG-2020' AS DATE), NULL, 14.95);
	CALL add_media_vendor('Spotify', 'BRAT', CAST('07-JUN-2024' AS DATE), NULL, NULL);
	CALL add_media_vendor('Spotify', 'HARDSTONE PSYCHO', CAST('14-JUN-2024' AS DATE), NULL, NULL);
	CALL add_media_vendor('Amazon', 'Mistborn: The Final Empire', CAST('17-JUL-2006' AS DATE), 'https://www.amazon.com/s?k=mistborn+book+1&crid=3RLAH1KLVQNCI&sprefix=mistborn+book+1%2Caps%2C121&ref=nb_sb_noss_1', 16.75);
	CALL add_media_vendor('Viz Media', 'Jujutsu Kaisen', CAST('05-MAR-2018' AS DATE), 'https://www.viz.com/shonenjump/chapters/jujutsu-kaisen', NULL);
	CALL add_media_vendor('Viz Media', 'Bleach', CAST('07-AUG-2001' AS DATE), 'https://www.viz.com/shonenjump/chapters/bleach', NULL);
	CALL add_media_vendor('Spotify', 'Epik High Is Here (Part 1)', CAST('18-JAN-2021' AS DATE), NULL, NULL);
	CALL add_media_vendor('Spotify', 'Heaven Knows', CAST('10-NOV-2023' AS DATE), NULL, NULL);
	CALL add_media_vendor('HBO Max', 'Euphoria', CAST('16-JUN-2019' AS DATE), NULL, NULL);
	CALL add_media_vendor('Netflix', 'Derry Girls', CAST('04-JAN-2018' AS DATE), NULL, NULL);
	CALL add_media_vendor('Netflix', 'Bridgerton', CAST('25-DEC-2020' AS DATE), NULL, NULL);
	CALL add_media_vendor('Netflix', 'Jujutsu Kaisen', CAST('03-OCT-2020' AS DATE), NULL, NULL);
	CALL add_media_vendor('Gamestop', 'Final Fantasy XVI', CAST('22-JUN-2023' AS DATE), NULL, 69.99);
	CALL add_media_vendor('Gamestop', 'Resident Evil 3 Remake', CAST('03-APR-2020' AS DATE), NULL, 59.99);
	CALL add_media_vendor('Gamestop', 'Final Fantasy VII Remake', CAST('10-APR-2020' AS DATE), NULL, 59.99);
	CALL add_media_vendor('Gamestop', 'Fire Emblem: Three Houses', CAST('26-JUL-2019' AS DATE), NULL, 59.99);
	CALL add_media_vendor('Amazon Prime Video', 'Kingsman: The Secret Service', CAST('12-FEB-2015' AS DATE), 'https://www.amazon.com/Kingsman-Secret-Service-Colin-Firth/dp/B00TJYY1HQ', 3.79);
	CALL add_media_vendor('Amazon Prime Video', 'Kingsman: The Golden Circle', CAST('22-SEP-2017' AS DATE), 'https://www.amazon.com/Kingsman-Golden-Circle-Colin-Firth/dp/B075SM8KDQ', 3.79);
	CALL add_media_vendor('Cinemark Theatres', 'Howl''s Moving Castle', CAST('12-JUL-2012' AS DATE), NULL, 11.99);
	CALL add_media_vendor('AMC Theatres', 'Midsommar', CAST('03-JUL-2019' AS DATE), NULL, 13.99);
END $$;
COMMIT TRANSACTION;

-- adding review 
CREATE OR REPLACE PROCEDURE add_review(
	media_name_arg IN VARCHAR,
	date_released_arg IN DATE,
	out_of_ten_arg IN DECIMAL,
	review_arg IN VARCHAR,
	review_link_arg IN VARCHAR) LANGUAGE plpgsql
AS
$$
DECLARE
	v_media_id DECIMAL(12);
BEGIN
	SELECT media_id
	INTO v_media_id
	FROM Media
	WHERE media_name = media_name_arg AND date_released = date_released_arg;
	
	INSERT INTO Review(review_id, media_id, out_of_ten, review, review_link)
	VALUES(nextval('review_seq'), v_media_id, out_of_ten_arg, review_arg, review_link_arg);
END;
$$;

START TRANSACTION;
DO
$$ BEGIN
	CALL add_review('The Honjin Murders', CAST('04-AUG-2020' AS DATE), 8, 'a good short locked-room mystery', NULL);
	CALL add_review('BRAT', CAST('07-JUN-2024' AS DATE), 9, 'one of the best albums of 2024 so far', 'myblog.com/brat-review');
	CALL add_review('HARDSTONE PSYCHO', CAST('14-JUN-2024' AS DATE), 7, 'his other albums are better', NULL);
	CALL add_review('Bleach', CAST('07-AUG-2001' AS DATE), 7, NULL, 'mymangablog.com/bleach-review');
	CALL add_review('Heaven Knows', CAST('10-NOV-2023' AS DATE), 9, 'an awesome debut album', NULL);
	CALL add_review('Derry Girls', CAST('04-JAN-2018' AS DATE), 10, 'one of the best shows ever made, an excellent mix of comedy and emotion', NULL);
	CALL add_review('Bridgerton', CAST('25-DEC-2020' AS DATE), 6, 'writing leaves much to be desired', 'myshowblog.com/bridgerton-review');
	CALL add_review('Final Fantasy VII Remake', CAST('10-APR-2020' AS DATE), 9, NULL, NULL);
	CALL add_review('Resident Evil 3 Remake', CAST('03-APR-2020' AS DATE), 6, 'not enough content to justify the price', NULL);
	CALL add_review('Final Fantasy XVI', CAST('22-JUN-2023' AS DATE), 9, 'compelling story that is different from normal final fantasy games', NULL);
	CALL add_review('Fire Emblem: Three Houses', CAST('26-JUL-2019' AS DATE), 8, 'loved the characters, story was messy', 'mygameblog.com/fe3h-review');
	CALL add_review('Kingsman: The Secret Service', CAST('12-FEB-2015' AS DATE), 10, 'super fun spy comedy', NULL);
	CALL add_review('Kingsman: The Golden Circle', CAST('22-SEP-2017' AS DATE), 5, 'incredibly lacking compared to the first movie', NULL);
	CALL add_review('Howl''s Moving Castle', CAST('12-JUL-2012' AS DATE), 9, 'a classic', NULL);
	CALL add_review('Euphoria', CAST('16-JUN-2019' AS DATE), 8, 'aside from the plot and characters, the mood created by the lighting, makeup, and costumes is great', NULL);
	CALL add_review('Midsommar', CAST('03-JUL-2019' AS DATE), 9, 'a movie you think about for years afterwards', NULL);
END $$;
COMMIT TRANSACTION;

-- queries

-- first query: Which subscription service is the most used for watching TV shows?
SELECT vendor_name, COUNT(*) AS use_count
FROM Vendor
JOIN Media_vendor ON Media_vendor.vendor_id = Vendor.vendor_id
JOIN Media ON Media.media_id = Media_vendor.media_id
JOIN TV_show ON TV_show.media_id = Media.media_id
GROUP BY vendor_name;

-- second query: What is the best reviewed video game that falls under the “fantasy” genre?
SELECT media_name, out_of_ten
FROM Review
JOIN Media ON Media.media_id = Review.media_id
JOIN Genre ON Genre.genre_id = Media.genre_id
JOIN Video_game on Video_game.media_id = Media.media_id
WHERE main_genre = 'Fantasy' OR subgenre = 'Fantasy'
ORDER BY out_of_ten DESC;

-- third query: What is the average rating given to a piece of media by each user?
CREATE OR REPLACE VIEW User_ratings AS
SELECT username, media_name, out_of_ten
	FROM Review
	JOIN Media ON Media.media_id = Review.media_id
	JOIN User_media ON User_media.media_id = Media.media_id
	RIGHT JOIN Users ON Users.user_id = User_media.user_id
	ORDER BY username, out_of_ten DESC;

SELECT user_ratings.username, ROUND(AVG(out_of_ten), 2) AS avg_rating
FROM User_ratings
GROUP BY user_ratings.username;

-- index creation
-- foreign key indexes
CREATE INDEX IF NOT EXISTS media_genre_idx
ON Media(genre_id);
CREATE INDEX IF NOT EXISTS media_SAC_idx
ON Media(SAC_id);
CREATE INDEX IF NOT EXISTS media_rating_idx
ON Media(rating_id);
CREATE INDEX IF NOT EXISTS user_media_user_idx
ON User_media(user_id);
CREATE INDEX IF NOT EXISTS user_media_idx
ON User_media(media_id);
CREATE INDEX IF NOT EXISTS media_vendor_media_idx
ON Media_vendor(media_id);
CREATE INDEX IF NOT EXISTS media_vendor_vendor_idx
ON Media_vendor(vendor_id);
CREATE INDEX IF NOT EXISTS review_media_idx
ON Review(media_id);
CREATE UNIQUE INDEX IF NOT EXISTS status_media_idx
ON Status(media_id);
CREATE INDEX IF NOT EXISTS book_media_idx
ON Book(media_id);
CREATE INDEX IF NOT EXISTS album_media_idx
ON Album(media_id);
CREATE INDEX IF NOT EXISTS tv_show_media_idx
ON TV_show(media_id);
CREATE INDEX IF NOT EXISTS video_game_media_idx
ON Video_game(media_id);
CREATE INDEX IF NOT EXISTS movie_media_idx
ON Movie(media_id);
-- query-driven indexes
CREATE INDEX IF NOT EXISTS main_genre_idx
ON Genre(main_genre);
CREATE INDEX IF NOT EXISTS main_subgenre_idx
ON Genre(subgenre);

-- history table
CREATE TABLE Status_history (
	status_change_id DECIMAL(12) PRIMARY KEY NOT NULL,
	status_id DECIMAL(12) NOT NULL,
	new_overall_status VARCHAR(64),
	old_overall_status VARCHAR(64),
	new_media_section VARCHAR(64),
	old_media_section VARCHAR(64),
	new_media_subsection VARCHAR(64),
	old_media_subsection VARCHAR(64),
	new_date_started DATE,
	old_date_started DATE,
	new_date_finished DATE,
	old_date_finished DATE,
	FOREIGN KEY (status_id) REFERENCES Status (status_id)
	);
	
CREATE SEQUENCE status_history_seq START WITH 1;
	
CREATE OR REPLACE FUNCTION Status_history_func()
RETURNS TRIGGER LANGUAGE plpgsql
AS $trigfunc$
	BEGIN
		INSERT INTO Status_history(
		status_change_id,
		status_id,
		new_overall_status,
		old_overall_status,
		new_media_section,
		old_media_section,
		new_media_subsection,
		old_media_subsection,
		new_date_started,
		old_date_started,
		new_date_finished,
		old_date_finished)
		VALUES(
		nextval('status_history_seq'),
		NEW.status_id,
		NEW.overall_status,
		OLD.overall_status,
		NEW.media_section,
		OLD.media_section,
		NEW.media_subsection,
		OLD.media_subsection,
		NEW.date_started,
		OLD.date_started,
		NEW.date_finished,
		OLD.date_finished);
	RETURN NEW;
	END;
$trigfunc$;

CREATE TRIGGER Status_history_trg
BEFORE UPDATE OF overall_status, media_section, media_subsection, date_started, date_finished ON Status
FOR EACH ROW
EXECUTE PROCEDURE Status_history_func();
	
UPDATE Status
SET overall_status = 'In Progress', media_section = 'Chapter 6', date_started = CURRENT_DATE
WHERE status_id = 
	(SELECT status_id 
	 FROM Status 
	 WHERE media_id = 
	 (SELECT media_id 
	 FROM Media
	 WHERE media_name = 'Resident Evil 4 Remake' 
	  AND date_released = CAST('24-MAR-2023' AS DATE)));

UPDATE Status
SET media_section = 'Chapter 14'
WHERE status_id = 
	(SELECT status_id 
	 FROM Status 
	 WHERE media_id = 
	 (SELECT media_id 
	 FROM Media
	 WHERE media_name = 'Resident Evil 4 Remake' 
	  AND date_released = CAST('24-MAR-2023' AS DATE)));
	  
UPDATE Status
SET overall_status = 'Completed', media_section = 'Chapter 16', date_finished = CAST('30-JUN-2024' AS DATE)
WHERE status_id = 
	(SELECT status_id 
	 FROM Status 
	 WHERE media_id = 
	 (SELECT media_id 
	 FROM Media
	 WHERE media_name = 'Resident Evil 4 Remake' 
	  AND date_released = CAST('24-MAR-2023' AS DATE)));

SELECT * FROM Status_history;

-- visualization queries
-- question 1
SELECT date_part('year', date_released)::DECIMAL AS release_year, COUNT(*) as media_count
FROM Media 
GROUP BY date_part('year', date_released)
ORDER BY release_year;

-- question 2
SELECT username, overall_status, COUNT(*) as status_count
FROM Users
JOIN User_media ON User_media.user_id = Users.user_id
JOIN Media ON Media.media_id = User_media.media_id
JOIN Status ON Status.media_id = Media.media_id
GROUP BY username, overall_status
ORDER BY username;

