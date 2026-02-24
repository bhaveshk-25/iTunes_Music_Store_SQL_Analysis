--------------- INDEPENDENT TABLES --------------------------------
-- 1. Artist
CREATE TABLE artist (
    artist_id INT PRIMARY KEY,
    name VARCHAR(120)
);

-- 2. Genre
CREATE TABLE genre (
    genre_id INT PRIMARY KEY,
    name VARCHAR(120)
);

-- 3. Media Type
CREATE TABLE media_type (
    media_type_id INT PRIMARY KEY,
    name VARCHAR(120)
);

-- 4. Playlist
CREATE TABLE playlist (
    playlist_id INT PRIMARY KEY,
    name VARCHAR(120)
);

-- 5. Employee
CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(20) NOT NULL,
    title VARCHAR(30),
    reports_to INT REFERENCES employee(employee_id),
	level VARCHAR(4),
    birthdate DATE,
    hire_date DATE,
    address VARCHAR(70),
    city VARCHAR(40),
    state VARCHAR(40),
    country VARCHAR(40),
    postal_code VARCHAR(10),
    phone VARCHAR(24),
    fax VARCHAR(24),
    email VARCHAR(60)
);

------------ TABLES WITH SINGLE DEPENDENCY --------------------------------

-- 6. Album
CREATE TABLE album (
    album_id INT PRIMARY KEY,
    title VARCHAR(160) NOT NULL,
    artist_id INT NOT NULL REFERENCES artist(artist_id)
);

-- 7. Customer
CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    name VARCHAR(40) NOT NULL,
    email VARCHAR(60) NOT NULL,
    company VARCHAR(80),
    address VARCHAR(70),
    city VARCHAR(40),
    state VARCHAR(40),
    country VARCHAR(40),
    postal_code VARCHAR(10),
    phone VARCHAR(24),
    fax VARCHAR(24),
    support_rep_id INT REFERENCES employee(employee_id)
);

------------ TABLES WITH MULTIPLE DEPENDENCIES --------------------------------

-- 8. Track
CREATE TABLE track (
    track_id INT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    album_id INT REFERENCES album(album_id),
    media_type_id INT NOT NULL REFERENCES media_type(media_type_id),
    genre_id INT NOT NULL REFERENCES genre(genre_id),
    composer VARCHAR(220),
    minutes NUMERIC(5,2) NOT NULL,
    file_size_KB NUMERIC(10,2),
    unit_price NUMERIC(10,2) NOT NULL
);

-- 9. Invoice
CREATE TABLE invoice (
    invoice_id INT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer(customer_id),
    invoice_date DATE NOT NULL,
    billing_address VARCHAR(70),
    billing_city VARCHAR(40),
    billing_state VARCHAR(40),
    billing_country VARCHAR(40),
    billing_postal_code VARCHAR(10),
    total NUMERIC(10,2) NOT NULL
);

------------ JUNCTION TABLES --------------------------------

-- 10. Invoice Line
CREATE TABLE invoice_line (
    invoice_line_id INT PRIMARY KEY,
    invoice_id INT NOT NULL REFERENCES invoice(invoice_id),
    track_id INT NOT NULL REFERENCES track(track_id),
    unit_price NUMERIC(10,2) NOT NULL,
    quantity INT NOT NULL
);

-- 11. Playlist Track (Junction table)
CREATE TABLE playlist_track (
    playlist_id INT REFERENCES playlist(playlist_id),
    track_id INT REFERENCES track(track_id),
    PRIMARY KEY (playlist_id, track_id)
);