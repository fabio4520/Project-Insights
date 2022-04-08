require "colorize"
require "pg"
require "terminal-table"

class Insight

  def initialize
    @db = PG.connect(dbname: "insights")
  end

  def start
    print_welcome
    print_menu

    print ">"
    action , param = gets.chomp.split

    until action == "exit"
      case action
      when "1" then list_restaurants
      when "2" then unique_dishes
      when "3" then distribution
      when "4" then visitors
      when "5" then sum_sales
      when "6" then expense
      when "7" then average
      when "8" then total_sales
      when "9" then list_dishes
      when "10" then fav_dish
      when "menu" then print_menu
        print ">"
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

  def list_restaurants
  end

  def unique_dishes 
  end

  def distribution
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
  end

  def expense
  end

  def average
  end

  def total_sales
  end

  def list_dishes
  end

  def fav_dish
  end

end

app =Insight.new
app.start