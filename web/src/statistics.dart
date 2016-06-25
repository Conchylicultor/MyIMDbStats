import 'dart:html';
//import 'package:js/js.dart' as js;
//import 'dart:io';
import 'package:csv_sheet/csv_sheet.dart';

import 'data.dart';

class FilmData
{
  int listId;
  String imdbId;

  String title;
  String titleType;

  String directors; // TODO: Replace by List<String>
  String genres; // TODO: Same

  double myRatting;
  double imdbRatting;
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

launchStatistics() async
{
  // Part 1: Get statistics

  // Define the user ID
  // TODO: Dynamically get the ID
  String userId = "ur42567646"; // Me
  //var userId = "ur42718560"; // Gontran
  //var userId = "ur1000000"; // Fondateur imdb

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

  // Parse the file

  print("Begining parsing");

  List<FilmData> filmsData = new List();

  var sheet = new CsvSheet(csvValues, headerRow: true);
  sheet.forEachRow((CsvRow row) {
    FilmData nextFilm = new FilmData();

    // Csv header:
    // 0 "position"
    nextFilm.listId = int.parse(row.row[0]);
    // 1 "const"
    nextFilm.imdbId = row.row[1];
    // 2 "created"
    // 3 "modified"
    // 4 "description"
    // 5 "Title"
    nextFilm.title = row.row[5];
    // 6 "Title type"
    nextFilm.titleType = row.row[6];
    // 7 "Directors"
    // 8 "You rated"
    //nextFilm.myRatting = double.parse(row.row[8]);
    // 9 "IMDb Rating"
    nextFilm.imdbRatting = double.parse(row.row[9]);
    // 10 "Runtime (mins)"
    // 11 "Year"
    // 12 "Genres"
    // 13 "Num. Votes"
    nextFilm.nbVotes = int.parse(row.row[13]);
    // 14 "Release Date (month/day/year)"
    // 15 "URL"
    nextFilm.url = row.row[15];

    // to continue...

    // TODO: Load external data

    filmsData.add(nextFilm);
    //print(nextFilm.title);
    //print(nextFilm.myRatting);
    //print(nextFilm.imdbRatting);
    //print(nextFilm.listId);
    //print(nextFilm.title + ": " + nextFilm.myRatting.toString() + "," + nextFilm.imdbRatting.toString());
  });

  print("${filmsData.length} films extracted");

  // Part 2: Compute statistics
}