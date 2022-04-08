require "pg"
require "csv"

# Append to connect to DB
DB = PG.connect(dbname: "insights")

def insert(table, data, unique_column = nil)
  entity = nil

  entity = find(table, unique_column, data[unique_column]) if (unique_column)

  entity ||=  DB.exec(%[INSERT INTO #{table} (#{data.keys.join(', ')})
              VALUES (#{data.values.map { |value| "'#{value.gsub("'","''")}'"}.join(", ")})
              RETURNING *;]).first

  entity
end

def find(table, column, value)
  DB.exec(%[
    SELECT * FROM #{table} 
    WHERE #{column} = '#{value.gsub("'","''")}'; 
    ]).first
end

# for each row to books
CSV.foreach("data.csv", headers: true) do |row|
  client_data = {
    "name" => row["client_name"],
    "age" => row["age"],
    "gender" => row["gender"],
    "occupation" => row["occupation"],
    "nationality" => row["nationality"]
  }
  client = insert("clients", client_data, "name")

  restaurants_data = {
    "name" => row["restaurant_name"],
    "category" => row["category"],
    "city" => row["city"],
    "adress" => row["address"]
  }
  restaurant = insert("restaurants", restaurants_data, "name")

  dishes_data = {
    "name" => row["dish"]
  }
  dishes = insert("dishes", dishes_data)

  prices_data = {
    "price_number" => row["price"],
    "dish_id" => dishes["id"]
  }
  prices = insert("prices", prices_data)

  visit_date = {
    "visit_date" => row["visit_date"],
    "client_id" => client["id"]
  }
  visit = insert("visit_dates", visit_date)

  restaurants_clients_data = {
    "restaurant_id" => restaurant["id"],
    "client_id" => client["id"]
  }
  insert("restaurants_clients", restaurants_clients_data)

  restaurants_clients_data = {
    "restaurant_id" => restaurant["id"],
    "client_id" => client["id"]
  }
  insert("restaurants_clients", restaurants_clients_data)

  restaurants_dishes_data = {
    "restaurant_id" => restaurant["id"],
    "dish_id" => dishes["id"]
  }
  insert("restaurants_dishes", restaurants_dishes_data)
end