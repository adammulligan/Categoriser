# Categoriser

Automatic directory-based film categoriser.

Watches a directory for video file additions, and handles the additions
by:

* Searching for the movie on Rotten Tomatoes and getting its genres.
* Creating directories for those genres, moving the movie file to an
  archive location, and symlinking a file of the same name in all the
  genre directories to the archive location.

This will result in a load of genre categories like "Action" or
"Suspense" with symlinks to all the movies that fall under that genre.

## What's Missing

* Doesn't remove symlinks when a movie is deleted
* Should ideally be a daemon rather than a foreground script
* File names might not be perfect, and Rotten Tomatoes search does not
  account for errors. Using another API might be a good idea?
* Currently it picks the first movie from the search results, assuming
  that is the best result Rotten Tomatoes has for that string. This may
  not always be the case.
