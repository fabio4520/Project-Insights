BEGIN;

DROP TABLE IF EXISTS clients;
CREATE TABLE clients (
  id SERIAL PRIMARY KEY,
  client_name VARCHAR,
  age INTEGER,
  gender VARCHAR,
  occupation VARCHAR,
  nationality VARCHAR
);

DROP TABLE IF EXISTS restaurants;
CREATE TABLE restaurants (
  id SERIAL PRIMARY KEY,
  restaurant_name VARCHAR NOT NULL,
  category VARCHAR,
  city VARCHAR,
  address VARCHAR
);

DROP TABLE IF EXISTS dishes;
CREATE TABLE dishes (
  id SERIAL PRIMARY KEY,
  dish_name VARCHAR,
  price INTEGER,
  id_restaurant INTEGER NOT NULL REFERENCES restaurants(id)
);

DROP TABLE IF EXISTS restaurants_clients;
CREATE TABLE restaurants_clients (
  id SERIAL PRIMARY KEY,
  visit_date DATE,
  client_id INTEGER NOT NULL REFERENCES clients(id),
  dish_id INTEGER NOT NULL REFERENCES dishes(id),
  restaurant_id INTEGER NOT NULL REFERENCES restaurants(id)
);

COMMIT;
