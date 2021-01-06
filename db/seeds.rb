# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'open-uri'
url = 'https://raw.githubusercontent.com/maltyeva/iba-cocktails/master/recipes.json'


Cocktail.delete_all if Rails.env.development?

cocktails = JSON.parse(URI.open(url).read)

cocktails.each do |cocktail|
	  Cocktail.create!(name: cocktail["name"], glass: cocktail["glass"], preparation: cocktail["preparation"])
end
