require "colorize"
require "terminal-table"
module Prompter
  def print_welcome
    puts "Welcome to the Restaurants Insights!"
    puts "Write #{'menu'.red} at any moment to print the menu again and #{'quit'.red} to exit."
  end

  def print_menu
    puts "---"
    puts "#{'1'.green}. List of restaurants included in the research filter by ['' | category=string | city=string]"
    puts "#{'2'.green}. List of unique dishes included in.blue the research"
    puts "#{'3'.green}. Number and distribution (%) of clients by [group=[age | gender | occupation | nationality]]"
    puts "#{'4'.green}. Top 10 restaurants by the number of visitors."
    puts "#{'5'.green}. Top 10 restaurants by the sum of sales."
    puts "#{'6'.green}. Top 10 restaurants by the average expense of their clients."
    puts "#{'7'.green}. The average consumer expense group by [group=[age | gender | occupation | nationality]]"
    puts "#{'8'.green}. The total sales of all the restaurants group by month [order=[asc | desc]]"
    puts "#{'9'.green}. The list of dishes and the restaurant where you can find it at a lower price."
    puts "#{'10'.green}. The favorite dish for [age=number | gender=string | occupation=string | nationality=string]"
    puts "---"
    puts "Pick a number from the list and an [option] #{'if'.blue} necessary"
  end

  def case_options(action, param)
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
    end
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

  def queries(value)
    queries = {
      visitors: %[
        SELECT r.restaurant_name, COUNT(client_id) AS Visitors FROM restaurants_clients AS rc
        JOIN restaurants AS r ON r.id = rc.restaurant_id
        GROUP BY r.restaurant_name ORDER BY Visitors DESC LIMIT 10;
        ],
      sum_sales: %[
        SELECT r.restaurant_name, sum(d.price) FROM restaurants_clients AS rc
        JOIN restaurants AS r ON r.id = rc.restaurant_id
        JOIN dishes AS d ON rc.dish_id = d.id
        GROUP BY r.restaurant_name ORDER BY sum(d.price) DESC;
      ],
      expense: %[
        SELECT r.restaurant_name, ROUND(AVG(price),2) AS avg_expenses
        FROM restaurants AS r
        JOIN restaurants_clients AS rc on r.id = rc.restaurant_id
        JOIN dishes AS d on rc.id = d.id_restaurant
        GROUP BY r.restaurant_name ORDER BY avg_expenses DESC
        LIMIT 10;
      ],
      list_dishes: %[
        SELECT DISTINCT ON (d.dish_name) d.dish_name, r.restaurant_name, min(d.price) as lowest_price
        FROM restaurants_clients AS rc
        JOIN dishes AS d ON d.id = rc.dish_id
        JOIN restaurants AS r ON r.id = rc.restaurant_id
        GROUP BY d.dish_name, r.restaurant_name;
      ]
    }

    queries[value]
  end
end
