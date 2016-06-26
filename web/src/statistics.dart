import 'dart:html';
import 'dart:math';
import 'dart:js';
//import 'package:js/js.dart' as js;
import 'package:csv_sheet/csv_sheet.dart';
import 'package:plotly/plotly.dart' as plotly;

import 'data.dart'; // TODO: To remove when Cross-Scripting limitation solved (chrome permissions)
import 'utils.dart';

/**
 * Struct which contains the data associated with a movie
 */
class MovieData
{
  int listId;
  String imdbId;

  String title;
  String titleType;

  String directors; // TODO: Replace by List<String>
  String genres; // TODO: Same

  double myRating;
  double imdbRating;
  int nbVotes;
  int runtime; // In min
  int year;
  DateTime releaseDate;
  DateTime addedDate;

  String url;

  bool hasExternal = false; // We didn't load yet external data

  // Other infos
  String countries;
  String language;
  String writers;
  String actors;
  String plot;
}

/**
 * Main script
 */
void launchStatistics()
{
  // Part 1: Get statistics

  // Define the user ID
  // TODO: Dynamically get the ID
  String userId = "ur42567646"; // Me
  //var userId = "ur42718560"; // Gontran
  //var userId = "ur1000000"; // Fondateur imdb

  List<MovieData> movieData = loadData(userId);
  print("${movieData.length} films extracted");

  // Part 2: Compute statistics
  loadGraphsDuration(movieData);
  loadGraphsMovieType(movieData);
  loadGraphsDirectors(movieData);
  // TODO: Ideas of stats
  // Words cloud of the plots/synopsis
  // Point cloud years vs rating (bubble size nb of movies from this director) ?
  // Favourite actors
  // Difference between my rating and the imdb rating (Top 200, distribution)
  // Map movie origin (log scale)
  // Map movie languages (log scale)
  // Bar diagram of different genres repartition by the year
}

/**
 * Retrieve data from the IMDb account using the given userId
 * TODO: Load from Google Chrome Storage if
 * TODO: Cross-Scripting recovery
 * TODO: Progress bar when loading
 */
List<MovieData> loadData(String userId)
{


  // Get the IMDb statistics

  String csvValues = data;

  /* Code if cross-scripting works (Add permissions with)
  String url = "http://www.imdb.com/list/export?list_id=ratings&author_id=" + userId;
  var request = await HttpRequest.getString(url);
  */

  /* Sample code:
  Go though a server proxy to get the CSV data and convert them to JSONP
  function get_url(remote_url) {
    $.ajax({
      url: "http://query.yahooapis.com/v1/public/yql?"+
          "q=select%20*%20from%20html%20where%20url%3D%22"+
          encodeURIComponent(remote_url)+
          "%22&format=json",
      type: 'get',
      dataType: 'jsonp',
      success: function(data) {
      alert(data.query.results.body.p);
      },
      error: function(jqXHR, textStatus, errorThrow){
      alert(jqXHR['responseText']);
      }
    })
  }

  $('#a').click(function() {
  get_url('http://ichart.finance.yahoo.com/table.csv?format=json&s=GS&amp;a=00&amp;b=1&amp;c=2010&amp;d=08&amp;e=3&amp;f=2012&amp;g=d&amp;ignore=.csv');
  });
  */

  //print(data);

  print("Retrieving data...");

  List<MovieData> movieData = new List();

  var sheet = new CsvSheet(csvValues, headerRow: true); // Parse the file
  sheet.forEachRow((CsvRow row) {
    MovieData nextMovie = new MovieData();

    // Csv header:
    // 0 "position"
    nextMovie.listId = int.parse(row.row[0]);
    // 1 "const"
    nextMovie.imdbId = row.row[1];
    // 2 "created"
    // 3 "modified"
    // 4 "description"
    // 5 "Title"
    nextMovie.title = row.row[5];
    // 6 "Title type"
    nextMovie.titleType = row.row[6];
    // 7 "Directors"
    nextMovie.directors = row.row[7];
    if(nextMovie.directors.isEmpty) {
      print("Pb directors for: ${nextMovie.title} (${nextMovie.listId})");
    }
    // 8 "You rated"
    try {
      nextMovie.myRating = double.parse(row.row[8]);
    } catch(exception) {
      print("Pb rating for: ${nextMovie.title} (${nextMovie.listId})");
    }
    // 9 "IMDb Rating"
    nextMovie.imdbRating = double.parse(row.row[9]);
    // 10 "Runtime (mins)"
    try {
      nextMovie.runtime = int.parse(row.row[10]);
    } catch(exception) {
      print("No runtime for: ${nextMovie.title} (${nextMovie.listId})");
    }
    // 11 "Year"
    try {
      nextMovie.year = int.parse(row.row[11]);
    } catch(exception) {
      print("No year for: ${nextMovie.title} (${nextMovie.listId})");
    }
    // 12 "Genres"
    // 13 "Num. Votes"
    nextMovie.nbVotes = int.parse(row.row[13]);
    // 14 "Release Date (month/day/year)"
    // 15 "URL"
    nextMovie.url = row.row[15];

    // to continue...

    // TODO: Load external data

    movieData.add(nextMovie);
    //print(nextFilm.title);
    //print(nextFilm.myRatting);
    //print(nextFilm.imdbRatting);
    //print(nextFilm.listId);
    //print(nextFilm.title + ": " + nextFilm.myRatting.toString() + "," + nextFilm.imdbRatting.toString());
  });

  return movieData;
}

/**
 *
 */
void loadGraphsMovieType(List<MovieData> movieData) {
}

/**
 * Compute the total duration
 */
void loadGraphsDuration(List<MovieData> movieData) {
  Duration totalDuration = new Duration();

  int nbExcluded = 0;
  movieData.forEach((nextMovie) {
    if(nextMovie.runtime != null) {
      totalDuration += new Duration(minutes: nextMovie.runtime);
    }
    else {
      nbExcluded++;
    }
  });
  print("$nbExcluded movie exluded from the duration statistics");

  int nbMonths = totalDuration.inDays ~/ 30;
  int nbWeeks = totalDuration.inDays ~/ 7;
  totalDuration -= new Duration(days: nbWeeks*7);
  int nbDays = totalDuration.inDays;
  totalDuration -= new Duration(days: nbDays);
  int nbHours = totalDuration.inHours;
  totalDuration -= new Duration(hours: nbHours);
  int nbMinutes = totalDuration.inMinutes;


  querySelector('#duration-text').text = "$nbWeeks weeks (about $nbMonths months), $nbDays days, $nbHours hours, $nbMinutes minutes";
}

/**
 * Helper class for the director graphs
 */
class DirectorsData {
  String name;

  double avgMyRating;
  double avgImdbRating;
  int avgYear;
  int nbMovies;
}

/**
 * Compute the point-cloud of the directors
 */
void loadGraphsDirectors(List<MovieData> movieData) {
  // Computing the data
  var rng = new Random();

  Map<String, DirectorsData> directorsData = new Map();
  for (MovieData nextMovie in movieData) {
      directorsData.containsKey(nextMovie.directors);
    if (directorsData.containsKey(nextMovie.directors)) {
      directorsData[nextMovie.directors].avgMyRating += nextMovie.myRating;
      directorsData[nextMovie.directors].avgImdbRating += nextMovie.imdbRating;
      directorsData[nextMovie.directors].avgYear += nextMovie.year;
      directorsData[nextMovie.directors].nbMovies++;
    } else if (!nextMovie.directors.isEmpty) { // We exclude the TV series (no directors)
      DirectorsData newDirector = new DirectorsData();
      newDirector.name = nextMovie.directors;
      newDirector.avgMyRating = nextMovie.myRating;
      newDirector.avgImdbRating = nextMovie.imdbRating;
      newDirector.avgYear = nextMovie.year;
      newDirector.nbMovies = 1;
      directorsData[newDirector.name] = newDirector;
    } else {
      // print("Exlude: ${nextMovie.title}");
    }
  }

  List<double> dataX = new List();
  List<double> dataY = new List();
  List<String> dataText = new List();
  for(DirectorsData nextDirector in directorsData.values) {
    double noiseX = genNormDist(rng, dilatation: 25.0);
    double noiseY = genNormDist(rng);
    dataX.add(nextDirector.avgMyRating / nextDirector.nbMovies + noiseX);
    dataY.add(nextDirector.nbMovies.toDouble() + noiseY);
    dataText.add(nextDirector.name);
  }

  // Creating the graph

  var trace = {
    'x': dataX,
    'y': dataY,
    'text': dataText,
    'mode': 'markers'
  };

  var layout = {
    'title': 'Movies directors',
    'hovermode':'closest',
    'xaxis': {
      'title': 'My rating'
    },
    'yaxis': {
      'title': 'Nb of movie'
    }
  };

  plotly.Plot directorPlot = new plotly.Plot.id('graph-directors', [trace], layout, scrollZoom: true);
  directorPlot.on('plotly_click').listen((JsObject event) {
    print(dataText[event['points']['0']['pointNumber']]);
    String directorName = dataText[event['points']['0']['pointNumber']];
    directorName.replaceAll(" ", "+"); // TODO: Case of special characters
    window.open("https://google.com/search?q=$directorName", ""); // Open the selected director in a new tab
  });
}
