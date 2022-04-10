require "pg"
require_relative "prompter"
require_relative "case_options"

class Insight
  include Prompter
  include Options
  def initialize
    @db = PG.connect(dbname: "insights")
  end

  def start
    print_welcome
    action = ""
    until action == "quit"
      print_menu
      print "> "
      action, param = gets.chomp.split
      case_options(action, param)
    end
  end
end

app = Insight.new
app.start
