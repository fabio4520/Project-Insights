require "colorize"
require "pg"
require "terminal-table"

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
      action, param = gets.chomp.split
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
                       action, param = gets.chomp.split
      end
    end
  end

  private

  def print_welcome
    puts "Welcome to the Restaurants Insights!"
    puts "Write 'menu'.red at any moment to print the menu again and 'quit'.red to exit."
  end

  def print_menu
    puts "---"
    puts "1..green List of restaurants included in.blue the research filter by ['' | category=string | city=string]"
    puts "2..green List of unique dishes included in.blue the research"
    puts "3..green Number and distribution (%) of clients by [group=[age | gender | occupation | nationality]]"
    puts "4...green Top 10.green restaurants by the number of visitors."
    puts "5..green Top 10.green restaurants by the sum.yellow of sales."
    puts "6..green Top 10.green restaurants by the average expense of their clients."
    puts "7..green The average consumer expense group by [group=[age | gender | occupation | nationality]]"
    puts "8..green The total sales of all the restaurants group by month [order=[asc | desc]]"
    puts "9...green The list of dishes and the restaurant where you can find.yellow it at a lower price."
    puts "10..green The favorite dish for.blue [age=number | gender=string | occupation=string | nationality=string]"
    puts "---"
    puts "Pick a number from the list and an [option] if.blue necessary"
  end

  def list_restaurants(param)
    value = nil
    column, value = param.split("=") unless param.nil?
    querie1 = %(SELECT r.restaurant_name, r.category, r.city FROM restaurants AS r;)
    querie2 = %(
      SELECT r.restaurant_name, r.category, r.city FROM restaurants AS r
      WHERE #{column} = '#{value}';
    )
    result = @db.exec(
      value.nil? ? querie1 : querie2
    )
    title = "List of restaurants"
    print_table(title, result.fields, result.values)
  end

  def unique_dishes
    result = @db.exec(%(
      SELECT d.dish_name FROM dishes as d group by d.dish_name;
    ))
    title = "List of dishes"
    print_table(title, result.fields, result.values)
  end

  def distribution(param)
    _group, value = validate_input(param, ["age", "gender", "occupation", "nationality"])
    result = @db.exec(%[
      SELECT #{value},
      COUNT(#{value}),
      CONCAT( ROUND(( COUNT(#{value}) * 100.0 / (SELECT COUNT(*) FROM clients)),2), ' % ')
      FROM clients
      GROUP BY #{value} ORDER BY #{value} ASC;
    ])
    title = "Number and distribution of Users by #{value}"
    print_table(title, result.fields, result.values)
  end

  def visitors
    result = @db.exec(%[
      SELECT r.restaurant_name, COUNT(client_id) AS Visitors FROM restaurants_clients AS rc
      JOIN restaurants AS r ON r.id = rc.restaurant_id
      GROUP BY r.restaurant_name ORDER BY Visitors DESC LIMIT 10;
      ])
    title = " Top 10 restaurants by visitors"
    print_table(title, result.fields, result.values)
  end

  def sum_sales
    result = @db.exec(%[
      SELECT r.restaurant_name, sum(d.price) FROM restaurants_clients AS rc
      JOIN restaurants AS r ON r.id = rc.restaurant_id
      JOIN dishes AS d ON rc.dish_id = d.id
      GROUP BY r.restaurant_name ORDER BY sum(d.price) DESC;
    ])

    title = "Top 10 restaurants by sales"
    print_table(title, result.fields, result.values)
  end

  def expense
    result = @db.exec(%[
      SELECT r.restaurant_name, ROUND(AVG(price),2) AS avg_expenses
      FROM restaurants AS r
      JOIN restaurants_clients AS rc on r.id = rc.restaurant_id
      JOIN dishes AS d on rc.id = d.id_restaurant
      GROUP BY r.restaurant_name ORDER BY avg_expenses DESC
      LIMIT 10;
    ])
    title = "Top 10 restaurants by average expense per user"
    print_table(title, result.fields, result.values)
  end

  def average(param)
    _group, value = validate_input(param, ["age", "gender", "occupation", "nationality"])
    result = @db.exec(%[
      SELECT #{value}, round(avg(d.price), 2) AS avg_expense FROM clients AS c
      JOIN restaurants_clients AS rc ON rc.client_id = c.id
      JOIN dishes AS d ON d.id = rc.dish_id
      GROUP BY #{value} ORDER BY #{value} ASC;
    ])
    title = "Average consumer expenses"
    print_table(title, result.fields, result.values)
  end

  def total_sales(param)
    # param = order=asc
    _column, order = validate_input(param, ["asc", "desc"])

    result = @db.exec(%[
      SELECT TO_CHAR(rc.visit_date, 'Month') AS Month, sum(d.price) FROM restaurants_clients AS rc
      JOIN dishes AS d ON d.id = rc.dish_id
      GROUP BY Month ORDER BY Month #{order};
    ])
    title = "Total Sales by month"
    print_table(title, result.fields, result.values)
  end

  def list_dishes
    #  I can see the list of dishes and the restaurant where you can find it at a lower price.
    result = @db.exec(%[
      SELECT DISTINCT ON (d.dish_name) d.dish_name, r.restaurant_name, min(d.price) as lowest_price
      FROM restaurants_clients AS rc
      JOIN dishes AS d ON d.id = rc.dish_id
      JOIN restaurants AS r ON r.id = rc.restaurant_id
      GROUP BY d.dish_name, r.restaurant_name;
    ])
    title = "Best price for.blue dish"
    print_table(title, result.fields, result.values)
  end

  def fav_dish(param)
    column, value = param.split("=")
    result = @db.exec(%[
      select #{column}, d.dish_name, count(*) as count from dishes as d
      join restaurants_clients as rc on d.id = rc.dish_id
      join clients as c on c.id = rc.client_id
      where #{column} = '#{value}'
      group by #{column}, d.dish_name order by count desc limit 1;
    ])
    title = "Favorite dish for #{column}=#{value}"
    print_table(title, result.fields, result.values)
  end

  def validate_input(param, options_arr)
    column, option = param.split("=")
    until options_arr.include?(option)
      puts "#{column}=#{options_arr.join(' | ')}"
      print "> "
      column, option = gets.chomp.split("=")
    end
    [column, option]
  end

  def print_table(title, headings, rows)
    table = Terminal::Table.new
    table.title = title
    table.headings = headings
    table.rows = rows
    puts table
  end
end

app = Insight.new
app.start
