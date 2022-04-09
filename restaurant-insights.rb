require "colorize"
require "pg"
require "terminal-table"
require "pg"

# require_relative "insert_data"

class Insight

  def initialize
    @db = PG.connect(dbname: "insights")
  end

  def start
    print_welcome
    
    action = ""
    until action == "exit"
      print_menu
      print "> "
      action , param = gets.chomp.split
      case action
      when "1" then list_restaurants(param)
      when "2" then unique_dishes
      when "3" then distribution(param)
      when "4" then visitors
      when "5" then sum_sales
      when "6" then expense
      when "7" then average(param)
      when "8" then total_sales(param)
      when "9" then list_dishes
      when "10" then fav_dish(param)
      when "menu" then print_menu
        print "> "
        action , param = gets.chomp.split
      end
    end
  end

  private
  def print_welcome
    puts "Welcome to the Restaurants Insights!"
    puts "Write 'menu'(:orange) at any moment to print the menu again and 'quit'(:orange) to exit."
  end

  def print_menu
    puts "---"
    puts "1. List of restaurants included in the research filter by ['' | category=string | city=string]"
    puts "2. List of unique dishes included in the research"
    puts "3. Number and distribution (%) of clients by [group=[age | gender | occupation | nationality]]"
    puts "4. Top 10 restaurants by the number of visitors."
    puts "5. Top 10 restaurants by the sum of sales."
    puts "6. Top 10 restaurants by the average expense of their clients."
    puts "7. The average consumer expense group by [group=[age | gender | occupation | nationality]]"
    puts "8. The total sales of all the restaurants group by month [order=[asc | desc]]"
    puts "9. The list of dishes and the restaurant where you can find it at a lower price."
    puts "10. The favorite dish for [age=number | gender=string | occupation=string | nationality=string]" 
    puts "---"
    puts "Pick a number from the list and an [option] if necessary"
  end

  def list_restaurants(param)
    value = nil
    column, value = param.split("=") unless param.nil?
    querie1 = %[SELECT r.name, r.category, r.city FROM restaurants AS r;]
    querie2 = %[
      SELECT r.name, r.category, r.city FROM restaurants AS r 
      WHERE #{column} = '#{value}';
    ]
    result = @db.exec(
      value.nil? ? querie1 : querie2
    )
    title = "List of restaurants"
    print_table(title, result.fields, result.values)
  end

  def unique_dishes
    result = @db.exec(%[
      SELECT d.name FROM dishes as d group by d.name;
    ])
    title = "List of dishes"
    print_table(title, result.fields, result.values)
  end

  def distribution(param)
    # param: group=value
    _group, value = validate_input(param, ["age","gender","occupation","nationality"])
    result = @db.exec(%[
      SELECT #{value}, 
      COUNT(#{value}), 
      CONCAT( ROUND(( COUNT(#{value}) * 100.0 / (select COUNT(*) from clients)),2), ' % ')
      FROM clients
      GROUP BY #{value} ORDER BY #{value} ASC;
    ])

    title = "Number and distribution of Users by #{value}"
    print_table(title, result.fields, result.values)
  end

  def visitors
    result = @db. exec (%[SELECT r.name, COUNT(client_id) as visitors
      FROM public.restaurants_clients
      JOIN public.restaurants as r ON r.id = restaurant_id
      GROUP BY r.name
      ORDER BY COUNT(client_id) DESC
      LIMIT 10;
    ])

    table = Terminal::Table.new
    table.title = "Top 10 restaurants by visitors"
    table.headings = result.fields
    table.rows = result.values
    puts table
  end
  
  def sum_sales
    result = @db. exec (%[
      SELECT r.name AS restaurant_name, CONCAT('$',SUM(p.price_number)) total_sales 
      FROM restaurants AS r
      JOIN restaurants_dishes AS rd ON r.id = rd.restaurant_id
      JOIN dishes AS d ON d.id = rd.dish_id
      JOIN prices AS p ON d.id = p.dish_id
      GROUP BY r.name ORDER BY total_sales DESC;
    ])

    title = "Top 10 restaurants by sales"
    print_table(title, result.fields, result.values)
  end

  def expense
  end

  def average(param)
    _group, value = validate_input(param, ["age","gender","occupation","nationality"])
    result = @db.exec(%[
      SELECT #{value}, ROUND(AVG(p.price_number),2) FROM clients AS c
      LEFT JOIN restaurants_clients AS rc ON c.id = rc.client_id
      LEFT JOIN restaurants AS r ON rc.restaurant_id = r.id
      LEFT JOIN restaurants_dishes AS rd ON r.id = rd.restaurant_id
      LEFT JOIN dishes AS d ON d.id = rd.dish_id
      LEFT JOIN prices AS p ON d.id = p.dish_id
      GROUP BY #{value} ;
    ])
    title = "Average consumer expenses"
    print_table(title, result.fields, result.values)
  end

  def total_sales(param)
    # param = order=asc
    _column, order = validate_input(param,["asc", "desc"])

    result = @db.exec(%[
      SELECT CONCAT('$',SUM(p.price_number)) total_sales, r.name AS restaurant_name 
      FROM restaurants AS r
      JOIN restaurants_dishes AS rd ON r.id = rd.restaurant_id
      JOIN dishes AS d ON d.id = rd.dish_id
      JOIN prices AS p ON d.id = p.dish_id
      group by r.name order by total_sales #{order};;
    ])
    title = "Total Sales of all restaurants group by month"
    print_table(title, result.fields, result.values)
  end

  def list_dishes
    result = @db.exec(%[
      SELECT d.name, MIN(p.price_number) FROM dishes AS d
      JOIN restaurants_dishes AS rd ON rd.dish_id = d.id
      JOIN restaurants AS r ON r.id = rd.restaurant_id
      JOIN prices AS p ON d.id = p.dish_id
      GROUP BY d.name;
    ])
    title = "Restaurants with the lower price for each dish"
    print_table(title, result.fields, result.values)
  end

  def fav_dish(param)
    column_reference = {
      "age" => "age",
      "gender" => "gender",
      "occupation" => "occupation",
      "nacionality" => "nacionality"
    }
    # column, value = validate_input(param, column_reference.keys)
    column, value = param.split("=")

    result = @db.exec(%[
      SELECT #{column}, d.name AS Dish FROM clients AS c
      LEFT JOIN restaurants_clients AS rc ON rc.client_id = c.id
      LEFT JOIN restaurants AS r ON r.id = rc.restaurant_id
      LEFT JOIN restaurants_dishes AS rd ON r.id = rd.restaurant_id
      join dishes AS d ON d.id = rd.dish_id
      WHERE #{column} = '#{value}'
      GROUP BY #{column}, d.name
      ORDER BY count(d.name) DESC LIMIT 1;
    ])
    title = "Favorite dish for #{column}=#{value}"
    print_table(title, result.fields, result.values)

  end

  def validate_input(param, options_arr)
    # param = order=asc
    column, option = param.split("=")
    until options_arr.include?(option)
      puts "#{column}=#{options_arr.join(" | ")}"
      print "> "
      column, option = gets.chomp.split("=")
    end
    return column, option
  end

  def print_table(title, headings, rows)
    table = Terminal::Table.new
    table.title = title
    table.headings = headings
    table.rows = rows
    puts table
  end

end

app =Insight.new
app.start