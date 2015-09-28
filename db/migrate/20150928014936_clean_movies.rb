class CleanMovies < ActiveRecord::Migration
  def change
    Movie.delete_all
  end
end
