# Following along 
https://medium.com/swlh/build-a-dynamic-search-with-stimulus-js-and-rails-6-56b537a44579

bowdena:~/environment/rails_apps $ rails new hello_stimulus-search --database=postgresql

# Add an appropriate database user and connection
bowdena:~/environment/rails_apps $ cd hello_stimulus-search/
bowdena:~/environment/rails_apps/hello_stimulus-search (master) $ vi config/database.yml 

bowdena:~/environment/rails_apps/hello_stimulus-search (master) $ rails db:create
Created database 'hello_stimulus_search_development'
Created database 'hello_stimulus_search_test'

bowdena:~/environment/rails_apps/hello_stimulus-search (master) $ rails g model cocktail name glass preparation:text
Running via Spring preloader in process 20803
      invoke  active_record
      create    db/migrate/20210106035407_create_cocktails.rb
      create    app/models/cocktail.rb
      invoke    test_unit
      create      test/models/cocktail_test.rb
      create      test/fixtures/cocktails.yml
bowdena:~/environment/rails_apps/hello_stimulus-search (master) $ rails db:migrate
== 20210106035407 CreateCocktails: migrating ==================================
-- create_table(:cocktails)
   -> 0.0133s
== 20210106035407 CreateCocktails: migrated (0.0143s) =========================

bowdena:~/environment/rails_apps/hello_stimulus-search (master) $ vi db/seeds.rb 

#db/seeds.rbrequire 'open-uri'
url = "https://raw.githubusercontent.com/maltyeva/iba-cocktails/master/recipes.json"
Cocktail.delete_all if Rails.env.development?

cocktails = JSON.parse(open(url).read)
cocktails.each do |cocktail|
  Cocktail.create!(name: cocktail["name"], glass: cocktail["glass"], preparation: cocktail["preparation"])
end


bowdena:~/environment/rails_apps/hello_stimulus-search (master) $ rails g controller cocktails index --skip-routes
Running via Spring preloader in process 21083
      create  app/controllers/cocktails_controller.rb
      invoke  erb
      create    app/views/cocktails
      create    app/views/cocktails/index.html.erb
      invoke  test_unit
      create    test/controllers/cocktails_controller_test.rb
      invoke  helper
      create    app/helpers/cocktails_helper.rb
      invoke    test_unit
      invoke  assets
      invoke    scss
      create      app/assets/stylesheets/cocktails.scss
bowdena:~/environment/rails_apps/hello_stimulus-search (master) $ 

#config/routes.rb
root "cocktails#index"

#app/controllers/cocktails_controller.rb
def index
  @cocktails = Cocktail.all
end

#app/views/cocktails/index.html.erb
<div class="container">
  <h1 class="text-center">Cocktails</h1>
  <div class="row justify-content-center">
    <div class="col-xs-12 col-sm-6">
      <%= render @cocktails %>
    </div>
  </div>
</div>

#app/views/cocktails/_cocktail.html.erb
<h4>
  <%= cocktail.name %><small><%= cocktail.glass %> glass</small></h4>
<p><%= cocktail.preparation %></p>

bowdena:~/environment/rails_apps/hello_stimulus-search (master) $ rake db:seed

##Step 2.  Add the search

#Gemfile 
gem 'pg_search'

#shell 
bundle install

#app/models/cocktail.rb

include PgSearch::Model

pg_search_scope :global_search,
    against: [:name, :glass, :preparation],
  using: {
    tsearch: { prefix: true }
}

#app/controllers/cocktails_controller.rb

def index
  if params[:query].present?
    @cocktails = Cocktail.global_search(params[:query])
  else
    @cocktails = Cocktail.all
  end
end

#app/views/cocktails/index.html.erb
....
 <%= form_with(url: "/", method: :get) do |f| %>
   <%= label_tag(:query, "Search for") %>
   <%= text_field_tag(:query) %>
   <%= submit_tag("Search", class: "btn btn-primary") %>
<% end %>
....