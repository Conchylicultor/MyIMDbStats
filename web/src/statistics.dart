import 'dart:html';
import 'dart:math';
import 'dart:convert';
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
  List<String> countries;
  List<String> languages;
  String writers;
  String actors;
  String plot;
  String pgRating;
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
  loadGraphsCountries(movieData);
  // TODO: Ideas of stats
  // Words cloud of the plots/synopsis
  // Point cloud years vs rating (bubble size nb of movies from this director) ?
  // Favourite actors
  // Difference between my rating and the imdb rating (Top 200, distribution)
  // Map movie origin (log scale)
  // Map movie languages (log scale)
  // Bar diagram of different genres repartition by the year
  // Stats on the PG rating (+18, etc)
  // Oscars nomination and cie
}


/**
 * Decode the information contained in the given string and add them to the
 * given movieData
 */
void extractAdditionalData(MovieData movieData, String encodedData) {
  Map decodedData = JSON.decode(encodedData);

  movieData.languages = decodedData["Language"].split(", ");
  movieData.countries = decodedData["Country"].split(", ");
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


  /*print("Clearing local storage");
  window.localStorage.clear();*/

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
      // print("No runtime for: ${nextMovie.title} (${nextMovie.listId})");
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

    // Load external data

    // Check if already stored
    if(window.localStorage.containsKey(nextMovie.imdbId)) { // If the movie is already in the database, we load it
      // print("Retrieve ${nextMovie.imdbId} (${nextMovie.listId})");
      extractAdditionalData(nextMovie, window.localStorage[nextMovie.imdbId]);
      nextMovie.hasExternal = true;
    } else { // Otherwise we retrieve the data from the webservice
      String url = "http://omdbapi.com/?i=${nextMovie.imdbId}"; // Request webservice
      HttpRequest.getString(url).then((String result) { // After callback:
        print("Getting results for ${nextMovie.imdbId} (${nextMovie.listId})");

        // Extract the data from the request
        extractAdditionalData(nextMovie, result);

        // Save the data
        window.localStorage[nextMovie.imdbId] = result; // Save directly the string
        nextMovie.hasExternal = true;
      });
    }

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
      'title': 'Nb of movies'
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

/**
 * Some container class
 */
class CountryData {
  String name;
  double nbMovies;
  String moviesTitles;
}

class LanguageData {
  String name;
  double nbMovies; // TODO: Make distinction between main language/secondary language (bi-colors bar chart) ; Also separate movie titles
  String moviesTitles; // To recover all movies of a particular language (TODO: Could by optimized by being replaced by a list of listId)
}

/**
 * Some stats about the localisations
 */
void loadGraphsCountries(List<MovieData> movieData) {
  // Compute the data

  Map<String, CountryData> countryData = new Map();
  Map<String, LanguageData> languageData = new Map();
  for (MovieData nextMovie in movieData) {
    // Extract countries
    for (String country in nextMovie.countries) {
      if (!countryData.containsKey(country)) { // If new country, we add it
        countryData[country] = new CountryData();
        countryData[country].name = country;
        countryData[country].nbMovies = 0.0;
        countryData[country].moviesTitles = "";
      }
      countryData[country].nbMovies += 1/nextMovie.countries.length; // We add the participation of the country/language
      countryData[country].moviesTitles += nextMovie.title + "<br />";
    }

    // Extract languages
    for (String language in nextMovie.languages) {
      if (!languageData.containsKey(language)) {
        languageData[language] = new LanguageData();
        languageData[language].name = language;
        languageData[language].nbMovies = 0.0;
        languageData[language].moviesTitles = "";
      }
      languageData[language].nbMovies += 1/nextMovie.languages.length; // We add the participation of the country/language
      languageData[language].moviesTitles += nextMovie.title + "<br />";
    }
  }

  List<String> dataCountriesX = new List();
  List<double> dataCountriesY = new List();
  for(CountryData nextCountry in countryData.values) {
    dataCountriesX.add(nextCountry.name);
    dataCountriesY.add(nextCountry.nbMovies);
  }

  // TODO: Sort languages by nb of movies ???
  List<String> dataLanguagesX = new List();
  List<double> dataLanguagesY = new List();
  for(LanguageData nextLanguage in languageData.values) {
    dataLanguagesX.add(nextLanguage.name);
    dataLanguagesY.add(nextLanguage.nbMovies);
  }

  // Load the graphs

  // Countries
  var countriesTable = [{
    'type': 'choropleth',
    'locationmode': 'country names',
    'locations': dataCountriesX,
    'z': dataCountriesY,
    'text': dataCountriesX,
    'autocolorscale': true
  }];

  var countriesLayout = {
    'title': 'Countries distribution',
    'geo': {
      'projection': {
      'type': 'robinson'
      }
    }
  };

  plotly.Plot countriesPlot = new plotly.Plot.id('graph-countries', countriesTable, countriesLayout);
  countriesPlot.on('plotly_click').listen((JsObject event) {
    int idSelected = event['points']['0']['pointNumber'];
    String countrySelected = dataCountriesX[idSelected];
    querySelector("#graph-languages-details").innerHtml = countryData[countrySelected].moviesTitles;
  });

  // Language
  var languagesTable = [{
    'x': dataLanguagesX,
    'y': dataLanguagesY,
    'type': 'bar'
  }];

  var languagesLayout = {
    'title': 'Movies directors',
    'hovermode':'closest',
    'xaxis': {
      'title': 'Languages'
    },
    'yaxis': {
      'title': 'Nb of movies'
    }
  };

  plotly.Plot languagePlot = new plotly.Plot.id('graph-languages', languagesTable, languagesLayout);
  languagePlot.on('plotly_click').listen((JsObject event) {
    int idSelected = event['points']['0']['pointNumber'];
    String languageSelected = dataLanguagesX[idSelected];
    querySelector("#graph-languages-details").innerHtml = languageData[languageSelected].moviesTitles;
  });
}
