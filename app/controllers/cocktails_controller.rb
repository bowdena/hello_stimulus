class CocktailsController < ApplicationController
  def index
    if params[:query].present?
      @cocktails = Cocktail.global_search(params[:query])
    else
      @cocktails = Cocktail.all
    end
  end
end
