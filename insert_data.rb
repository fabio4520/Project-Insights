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
  # CLIENT
  client_data = {
    "client_name" => row["client_name"],
    "age" => row["age"],
    "gender" => row["gender"],
    "occupation" => row["occupation"],
    "nationality" => row["nationality"]
  }

  client = insert("clients", client_data, "client_name")
  # RESTAURANT
  restaurants_data = {
    "restaurant_name" => row["restaurant_name"],
    "category" => row["category"],
    "city" => row["city"],
    "address" => row["address"]
  }
  restaurant = insert("restaurants", restaurants_data, "restaurant_name")
  
  # DISH
  dishes_data = {
    "dish_name" => row["dish"],
    "price" => row["price"],
    "id_restaurant" => restaurant["id"]
  }
  dishes = insert("dishes", dishes_data)
  
  # CLIENT_RESTAURANT  
  restaurants_clients_data = {
    "visit_date" => row["visit_date"],
    "client_id" => client["id"],
    "dish_id" => dishes["id"],
    "restaurant_id" => restaurant["id"]
  }
  insert("restaurants_clients", restaurants_clients_data)

end