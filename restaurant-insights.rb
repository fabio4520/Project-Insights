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
    # puts "Write 'menu'(:orange) at any moment to print the menu again and 'quit'(:orange) to exit."
    puts "Write" + " menu ".red + "at any moment to print the menu again and" + " quit ".red + "to exit."
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
    querie1 = %[SELECT r.restaurant_name, r.category, r.city FROM restaurants AS r;]
    querie2 = %[
      SELECT r.restaurant_name, r.category, r.city FROM restaurants AS r 
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
      SELECT d.dish_name FROM dishes as d group by d.dish_name;
    ])
    title = "List of dishes"
    print_table(title, result.fields, result.values)
  end

  def distribution(param)
    # param: group=value
    # 3. Number and distribution (%) of clients by [group=[age | gender | occupation | nationality]]
    _group, value = validate_input(param, ["age","gender","occupation","nationality"])
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
    result = @db. exec (%[
      SELECT r.restaurant_name, COUNT(client_id) AS Visitors FROM restaurants_clients AS rc
      JOIN restaurants AS r ON r.id = rc.restaurant_id
      GROUP BY r.restaurant_name ORDER BY Visitors DESC LIMIT 10;
      ])
    title = " Top 10 restaurants by visitors"
    print_table(title, result.fields, result.values)
  end

  def validate_input(param, options_arr)
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