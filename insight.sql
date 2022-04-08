BEGIN;

DROP TABLE IF EXISTS clients;
CREATE TABLE clients (
  id SERIAL PRIMARY KEY,
  name VARCHAR,
  age INTEGER,
  gender VARCHAR,
  occupation VARCHAR,
  nationality VARCHAR
);

DROP TABLE IF EXISTS visit_dates;
CREATE TABLE visit_dates (
  id SERIAL PRIMARY KEY,
  visit_date DATE,
  client_id INTEGER NOT NULL REFERENCES clients(id)
);

DROP TABLE IF EXISTS dishes;
CREATE TABLE dishes(
  id SERIAL PRIMARY KEY,
  name VARCHAR
);

DROP TABLE IF EXISTS restaurants;
CREATE TABLE restaurants(
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  category VARCHAR,
  city VARCHAR,
  adress VARCHAR
);

DROP TABLE IF EXISTS prices;
CREATE TABLE prices(
  id SERIAL PRIMARY KEY,
  price_number INTEGER NOT NULL,
  dish_id INTEGER NOT NULL REFERENCES dishes(id)
);

DROP TABLE IF EXISTS restaurants_dishes;
CREATE TABLE restaurants_dishes(
  id SERIAL PRIMARY KEY,
  restaurant_id INTEGER NOT NULL REFERENCES restaurants(id),
  dish_id INTEGER NOT NULL REFERENCES dishes(id)
);

DROP TABLE IF EXISTS restaurants_clients;
CREATE TABLE restaurants_clients (
  id SERIAL PRIMARY KEY,
  restaurant_id INTEGER NOT NULL REFERENCES restaurants(id),
  client_id INTEGER NOT NULL REFERENCES clients(id)
);

COMMIT;
