require 'date'
require 'json'

# while i could take advantage of the objects i used to implement ToyCity1
# i decided in this project to stick closer to Udacity expectations regarding
# implementation techniques, in this case procedural with global variables.
# rubocop does not like globals :)
def start
  setup_files
  create_report
end

def setup_files
  path           = File.join(File.dirname(__FILE__), '../data/products.json')
  file           = File.read(path)
  $products_hash = JSON.parse(file)
  $report_file   = File.new('report.txt', 'w+')
end

def formatter(amount)
  amt = format("%.2f", amount)
  amt
end

def create_report
  print_heading
  print_data
end

# thanks to:
# http://patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something%20
def print_heading
  # Print "Sales Report" in ascii art
  puts '   _____       __             ____                        __'
  puts '  / ___/____ _/ /__  _____   / __ \___  ____  ____  _____/ /_'
  puts '  \__ \/ __ `/ / _ \/ ___/  / /_/ / _ \/ __ \/ __ \/ ___/ __/'
  puts ' ___/ / /_/ / /  __(__  )  / _, _/  __/ /_/ / /_/ / /  / /_'
  puts '/____/\__,_/_/\___/____/  /_/ |_|\___/ .___/\____/_/   \__/'
  puts '                                    /_/'

  # Print today's date
  puts DateTime.now.strftime('%Y-%m-%d-%H:%M')
  puts ''
end

def print_data
  make_products_section
  make_brands_section
end

def make_products_section
  print_products_header
  print_product_data
end

# thanks to:
# http://patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something%20
def print_products_header
  puts '    ____                 __           __'
  puts '   / __ \_________  ____/ /_  _______/ /______'
  puts '  / /_/ / ___/ __ \/ __  / / / / ___/ __/ ___/'
  puts ' / ____/ /  / /_/ / /_/ / /_/ / /__/ /_(__  )'
  puts '/_/   /_/   \____/\__,_/\__,_/\___/\__/____/'
  puts ''
end

def print_product_data
  # For each product in the data set:
  # Print the name of the toy
  # Print the retail price of the toy
  # Calculate and print the total number of purchases
  # Calculate and print the total amount of sales
  # Calculate and print the average price the toy sold for
  # Calculate and print the average discount (% or $) based off the average sales price
  $products_hash['items'].each do |product|
    puts "Toy Name: #{product['title']}"
    puts "Toy Retail: #{product['full-price']}"
    puts "Total Purchases: #{product['purchases'].length}"
    puts "Total Sales: $#{formatter(get_total_toy_sales(product))}"
    puts "Avg Sales Price: $#{formatter(get_avg_sales_price(product))}"
    puts "Avg Discount: $#{formatter(get_avg_discount(product))}"
    puts ''
  end
end

def get_total_toy_sales(prod)
  res = sum_sales(prod)
end

def get_avg_sales_price(prod)
  res = sum_sales(prod)
  final = res / prod['purchases'].length
end

def get_avg_discount(prod)
  res = get_avg_sales_price(prod)
  res = prod['full-price'].to_f - res
end

# as per feedback on ToyCity1 i'm trying out inject. but it seems to
# me that creating an array and then running inject to sum the elements is not
# optimal time-wise. is there a different way to use inject here? is it
# better than writing amt += purchase['price']? is it faster or considered
# more elegant? it's good to learn about regardless. could have used reduce too.
def sum_sales(prod)
  amt = []
  if prod['purchases'].empty?
    return 0.00
  else
    prod['purchases'].each do |purchase|
      amt << purchase['price']
    end
    res = amt.inject { |result, element| result + element }
  end
end

def make_brands_section
  print_brands_header
  print_brands_data
end

# thanks to:
# http://patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something%20
def print_brands_header
  puts '    ____                       __'
  puts '   / __ )_________ _____  ____/ /____'
  puts '  / __  / ___/ __ `/ __ \/ __  / ___/'
  puts ' / /_/ / /  / /_/ / / / / /_/ (__  )'
  puts '/_____/_/   \__,_/_/ /_/\__,_/____/'
  puts ''
end

def print_brands_data
  # comment
end

# Print "Brands" in ascii art

# For each brand in the data set:
# Print the name of the brand
# Count and print the number of the brand's toys we stock
# Calculate and print the average price of the brand's toys
# Calculate and print the total sales volume of all the brand's toys combined
start