require_relative "prompter"

module Options
  include Prompter
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
    result = @db.exec(queries(:visitors))
    title = " Top 10 restaurants by visitors"
    print_table(title, result.fields, result.values)
  end

  def sum_sales
    result = @db.exec(queries(:sum_sales))

    title = "Top 10 restaurants by sales"
    print_table(title, result.fields, result.values)
  end

  def expense
    result = @db.exec(queries(:expense))
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
    result = @db.exec(queries(:list_dishes))
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
end
