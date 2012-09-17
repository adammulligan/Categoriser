#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'directory_watcher'
require 'fileutils'

CONFIG = {
  api_key: 'sjdy5n3s8t8g5q877y9dt5ws',

  dirs: {
    watch: "/Users/adam/src/categoriser/_watch/",
    archive: "/Users/adam/src/categoriser/_uncategorised/"
  }
}

module RottenTomatoes
  class Movie
    include HTTParty
    base_uri "http://api.rottentomatoes.com/api/public/v1.0"
    default_params apikey: CONFIG[:api_key]

    def self.search_by_name(name)
      response = get('/movies.json', query: {q: name})
      response = JSON.parse(response.body)

      unless response.has_key?("error") || response["total"] == 0
        movies = response["movies"]
        movie  = movies[0] # For now, we just pick the first result

        return self.info(movie["id"])
      end

      {}
    end

    def self.search_by_id(id)
      self.info(id)
    end

    def self.info(id)
      response = get("/movies/" + id.to_s + ".json")
      info     = JSON.parse(response.body)

      return info  unless info.has_key?("error")

      {}
    end
  end
end

dw = DirectoryWatcher.new CONFIG[:dirs][:watch]
dw.interval = 2.0

Dir.mkdir(CONFIG[:dirs][:archive])  if !File.directory?(CONFIG[:dirs][:archive])

dw.add_observer do |*args|
  args.each do |event|
    movie_file = File.new(event.path)
    movie_name = File.basename(movie_file, File.extname(movie_file))

    movie = RottenTomatoes::Movie.search_by_name(movie_name)

    if movie.length > 0
      archived_movie_location = CONFIG[:dirs][:archive] + File.basename(movie_file)
      puts archived_movie_location

      FileUtils.mv(movie_file, archived_movie_location)

      movie["genres"].each do |genre|
        genre_location = "./" + genre
        Dir.mkdir(genre_location)  if !File.directory?(genre_location)

        `ln -s "#{archived_movie_location}" "#{genre_location}/#{File.basename(movie_file)}"`
      end
    end
  end
end

dw.start
gets
dw.stop
