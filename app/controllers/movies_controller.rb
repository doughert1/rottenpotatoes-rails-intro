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
    @all_ratings = Movie.all_ratings
    session[:ratings] ||= @all_ratings
    session[:sort_by] ||= :none
    should_redirect = false
    
    # See if params are different from those we've stored
    
    if params.include?(:ratings)
      if params_has_new_ratings?(params, session)
        session[:ratings] = params[:ratings].keys
      end
    else
      should_redirect = true
    end
    
    if params.include?(:sort_by)
      if params_has_new_sort_by?(params, session)
        session[:sort_by] = params[:sort_by].to_sym
      end
    else
      should_redirect = true
    end

    
    # Session has been set with most current params
    
    if should_redirect
      flash.keep()
      redirect_to(controller: "movies", action: "index", 
                  ratings: to_ratings_hash(session[:ratings]), 
                  sort_by: session[:sort_by])
    end
    
    @selected_ratings = session[:ratings]
    @sort_by = session[:sort_by]
    
    @movies = Movie.where(rating: @selected_ratings)
    
    if @sort_by != :none && @sort_by != 'none'
      @movies = @movies.sort_by { |movie| movie.send @sort_by }
    end
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

  private

  def params_has_new_ratings?(params_dict, session_dict)
    params_dict[:ratings].keys.sort != session_dict[:ratings].sort
  end
  
  def params_has_new_sort_by?(params_dict, session_dict)
    params_dict[:sort_by] != session_dict[:sort_by].to_sym
  end
  
  def to_ratings_hash(ratings_arr)
    Hash[ratings_arr.map {|rating| [rating, 1]}]
  end

end
