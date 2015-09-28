class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @sort_by = params[:sort_by]
    @all_ratings = Movie.all_ratings
    @selected_ratings = @all_ratings
    
    if params[:ratings] == nil
      @movies = Movie.all
    else
      @selected_ratings = params[:ratings].keys
      @movies = Movie.where(rating: @selected_ratings)
    end
    
    if @sort_by != nil
      @movies = @movies.sort_by { |movie| movie.send @sort_by }
    end
    # case @sort_by
    # when "title"
    #   @movies = @movies.sort_by { |movie| movie.title }
    # when "release_date"
    #   @movies = @movies.sort_by { |movie| movie.release_date }
    # else
    #   @movies = Movie.all
    # end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
