import 'dart:html';
//import 'package:js/js.dart' as js;
import 'package:csv_sheet/csv_sheet.dart';
import 'package:plotly/plotly.dart';

import 'data.dart'; // TODO: To remove when Cross-Scripting limitation solved (chrome permissions)

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
}

/**
 * Retrieve data from the IMDb account using the given userId
 * TODO: Load from Google Chrome Storage if
 * TODO: Cross-Scripting recovery
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
    //nextMovie.directors = row.row[7];
    // 8 "You rated"
    try {
      nextMovie.myRating = double.parse(row.row[8]);
    } catch(exception, stackTrace) {
      print("Pb rating for: ${nextMovie.title} (${nextMovie.listId})");
    }
    // 9 "IMDb Rating"
    nextMovie.imdbRating = double.parse(row.row[9]);
    // 10 "Runtime (mins)"
    try {
      nextMovie.runtime = int.parse(row.row[10]);
    } catch(exception, stackTrace) {
      print("No runtime for: ${nextMovie.title} (${nextMovie.listId})");
    }
    // 11 "Year"
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
