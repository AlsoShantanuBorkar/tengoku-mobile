import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:tengoku/src/types/genres.dart';
import 'package:tengoku/src/types/item_title.dart';
import 'package:tengoku/src/models/anime_info.dart';
import 'package:tengoku/src/models/anime_result.dart';
import 'package:tengoku/src/models/anime_episode.dart';
import 'package:tengoku/src/utils/global.dart' as utils;

class ConsumetService {
  final Client _client = Client();

  // Endpoints
  static const String baseUrl = 'https://api.consumet.org';
  static const String anilistUrl = '$baseUrl/meta/anilist';

  /* Perform Basic Anime Search (https://api.consumet.org/meta/anilist/{query}) */
  Future<List<AnimeResult>?> basicAnimeSearch(
      String query, int? page, int? resultsPerPage) async {
    final Uri url =
        Uri.parse('$anilistUrl/$query?page=$page&perPage=$resultsPerPage');

    final List<dynamic> results = await _makeGetRequest(() async {
      Response response = await _client.get(url);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['results'];
    });

    final List<AnimeResult>? animeList = _processResults(results);

    return animeList;
  }

  /* Get Trending Anime (https://api.consumet.org/meta/anilist/trending) */
  Future<List<AnimeResult>?> getTrendingAnime(
      int? page, int? resultsPerPage) async {
    final Uri url =
        Uri.parse('$anilistUrl/trending?page=$page&perPage=$resultsPerPage');

    final List<dynamic> results = await _makeGetRequest(() async {
      Response response = await _client.get(url);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['results'];
    });

    final List<AnimeResult>? animeList = _processResults(results);

    return animeList;
  }

  /* Get Anime Info (incl. Episodes) (https://api.consumet.org/meta/anilist/info/{id}) */
  Future<AnimeInfo> getAnimeInfoWithEpisodes(int id, String? provider) async {
    final Uri url = Uri.parse('$anilistUrl/info/$id?provider=$provider');

    final Map<String, dynamic> data = await _makeGetRequest(() async {
      Response response = await _client.get(url);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    });

    // TODO: Implement 'characters' into the model.
    final AnimeInfo animeInfo = AnimeInfo(
      id: id,
      title: ItemTitle(
        english: data['title']['english'],
        romaji: data['title']['romaji'],
        native: data['title']['native'],
      ),
      coverImage: data['image'],
      bannerImage: data['cover'],
      status: utils.evaluateMediaStatus(data['status']),
      rating: data['rating'],
      format: utils.evaluateMediaFormat(data['type']),
      releaseDate: data['releaseDate'],
      malId: data['malId'],
      genres: _processGenres(data['genres']),
      description: data['description'],
      episodeCount: data['totalEpisodes'],
      subOrDub: utils.evaluateSubOrDub(data['subOrDub']),
      synonyms: _dynamicListToStringList(data['synonyms']),
      originCountry: data['countryOfOrigin'],
      isAdult: data['isAdult'],
      isLicensed: data['isLicensed'],
      season: utils.evaluateSeason(data['season']),
      studios: _dynamicListToStringList(data['studios']),
      color: data['color'],
      recommendations: _processResults(data['recommendations']),
      relations: _processResults(data['relations']),
      episodes: _processEpisodes(data['episodes']),
    );

    return animeInfo;
  }

  // Network: Re-useable try-catch block for get requests.
  Future _makeGetRequest(Function request) async {
    try {
      return await request();
    } on SocketException catch (_) {
      throw 'Error whilst getting the data: no internet connection.';
    } on HttpException catch (_) {
      throw 'Error whilst getting the data: requested data could not be found.';
    } on FormatException catch (_) {
      throw 'Error whilst getting the data: bad format.';
    } on TimeoutException catch (_) {
      throw 'Error whilst getting the data: connection timed out.';
    } catch (err) {
      throw 'An error occurred whilst fetching the requested data: $err';
    }
  }

  List<AnimeResult>? _processResults(List<dynamic> results) {
    List<AnimeResult> animeList = [];
    for (int i = 0; i < results.length; i++) {
      final item = results[i];
      final AnimeResult anime = AnimeResult(
        id: item['id'] is int ? item['id'] : int.parse(item['id']),
        title: ItemTitle(
          romaji: item['title']['romaji'],
          english: item['title']['english'],
          native: item['title']['native'],
          userPreferred: item['title']['userPreferred'],
        ),
        coverImage: item['image'],
        bannerImage: item['cover'],
        status: utils.evaluateMediaStatus(item['status']),
        rating: item['rating'],
        format: utils.evaluateMediaFormat(item['type']),
        releaseDate: item['releaseDate'] is String
            ? int.parse(item['releaseDate'])
            : item['releaseDate'],
      );

      animeList.add(anime);
    }

    return animeList;
  }

  List<String>? _dynamicListToStringList(List<dynamic> dynamicList) {
    List<String>? stringList = [];

    for (int i = 0; i < dynamicList.length; i++) {
      final item = dynamicList[i];
      item is String ? stringList.add(item) : stringList.add(item.toString());
    }

    return stringList;
  }

  List<Genres>? _processGenres(List<dynamic> genres) {
    List<Genres> genreList = [];

    for (int i = 0; i < genres.length; i++) {
      final item = genres[i];
      if (item is String) genreList.add(utils.evaluateGenre(genres[i]));
    }

    return genreList;
  }

  List<AnimeEpisode>? _processEpisodes(List<dynamic> episodes) {
    List<AnimeEpisode> episodeList = [];
    for (int i = 0; i < episodes.length; i++) {
      final item = episodes[i];
      final AnimeEpisode episode = AnimeEpisode(
        id: item['id'],
        number: item['number'],
        title: item['title'],
        description: item['description'],
        isFiller: item['isFiller'],
        url: item['url'],
        image: item['image'],
        releaseDate: item['releaseDate'],
      );

      episodeList.add(episode);
    }

    return episodeList;
  }
}
