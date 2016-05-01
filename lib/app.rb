require 'date'
require 'json'

# while i could take advantage of the objects i used to implement ToyCity1
# i decided in this project to stick closer to Udacity expectations regarding
# implementation techniques, in this case procedural-style methods and global variables.
# rubocop does not like globals, though :)
#
# some thoughts: if i stuck to original design all i'd have to do is substitute wline
# into my ToyCity1 implementation for puts. better yet it would also be easy to
# use inversion of control to print to console or file or write to a DB or API
# without having to structurally alter the ToyCity1 code:
#
# https://github.com/skiprhudy/ToyCity
#
# but here is a proceedure version
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

def file_close
  $report_file.close
end

def wline(line)
  $report_file.puts line
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
  wline '   _____       __             ____                        __'
  wline '  / ___/____ _/ /__  _____   / __ \___  ____  ____  _____/ /_'
  wline '  \__ \/ __ `/ / _ \/ ___/  / /_/ / _ \/ __ \/ __ \/ ___/ __/'
  wline ' ___/ / /_/ / /  __(__  )  / _, _/  __/ /_/ / /_/ / /  / /_'
  wline '/____/\__,_/_/\___/____/  /_/ |_|\___/ .___/\____/_/   \__/'
  wline '                                    /_/'

  # Print today's date
  wline DateTime.now.strftime('%Y-%m-%d-%H:%M')
  wline ''
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
  wline '    ____                 __           __'
  wline '   / __ \_________  ____/ /_  _______/ /______'
  wline '  / /_/ / ___/ __ \/ __  / / / / ___/ __/ ___/'
  wline ' / ____/ /  / /_/ / /_/ / /_/ / /__/ /_(__  )'
  wline '/_/   /_/   \____/\__,_/\__,_/\___/\__/____/'
  wline ''
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
    wline "Toy Name: #{product['title']}"
    wline "Toy Retail: #{product['full-price']}"
    wline "Total Purchases: #{product['purchases'].length}"
    wline "Total Sales: $#{formatter(get_total_toy_sales(product))}"
    wline "Avg Sales Price: $#{formatter(get_avg_sales_price(product))}"
    wline "Avg Discount: $#{formatter(get_avg_discount(product))}"
    wline ''
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
  wline '    ____                       __'
  wline '   / __ )_________ _____  ____/ /____'
  wline '  / __  / ___/ __ `/ __ \/ __  / ___/'
  wline ' / /_/ / /  / /_/ / / / / /_/ (__  )'
  wline '/_____/_/   \__,_/_/ /_/\__,_/____/'
  wline ''
end


def print_brands_data
  # For each brand in the data set:
  # Print the name of the brand
  # Count and print the number of the brand's toys we stock
  # Calculate and print the average price of the brand's toys
  # Calculate and print the total sales volume of all the brand's toys combined
  #
  # Question: why is stock toy "blind"? we don't know how many of the in-stock
  # items are one toy or another toy. the boss won't like that. should be a hash
  brands = build_brands_hash
  brands.each do |brand,data|
    wline "Brand: #{brand}"
    wline "Num Toys in Stock: #{data[:num_toys_in_stock]}"
    wline "Avg Toy Price: $#{formatter brand_avg_toy_price data}"
    wline "Total Sales: $#{formatter brand_total_sales data}"
    wline ""
  end
end
#broken but need to upload so i don't lose data in tstorms
def brand_avg_toy_price(data)
  res = brand_total_sales(data)
  res = res / data[:sales_prices].length
end

def brand_total_sales(data)
  res = 0.0
  if !data[:sales_prices].empty?
    res = data[:sales_prices].inject { |result,element| result + element }
  end
  res
end

# a corny formula 1 pun. this will allow simpler calculation of report
# data; i'm not seeing a good way to index into products to solve the brand
# report without going spaghetti. so i'll be interested to see the official solution
def build_brands_hash
  # brands = {
  #   name: str,
  #   num_toys_in_stock: int,
  #   sales_prices: [float]
  # }
  brands = {}
  $products_hash['items'].each do |product|
    name = product['brand'].delete(" .").to_sym
    stock = product['stock']
    purchases = get_prod_purchases(product)
    if brands.has_key?(name)
      #here we just want to add more data to existing brand hash
      #just add the toy sales prices in
      #only just adding stock and price
      brands[name][:num_toys_in_stock] += stock
      brands[name][:sales_prices].concat(purchases)
    else
        toy_info = {
          :num_toys_in_stock => stock,
          :sales_prices => purchases
        }
      brands[name] = toy_info
    end
  end
  brands
end

def get_prod_purchases(prod)
  ary = []
  prod['purchases'].each do |purchase|
    ary << purchase['price']
  end
  ary
end

start