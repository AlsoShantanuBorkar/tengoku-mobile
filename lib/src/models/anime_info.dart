import 'anime_result.dart';
import 'anime_episode.dart';
import '../types/genres.dart';
import '../types/seasons.dart';
import '../types/sub_or_dub.dart';

class AnimeInfo extends AnimeResult {
  int? malId;
  List<Genres>? genres;
  String? description;
  int? episodeCount;
  SubOrDub? subOrDub;
  List<String>? synonyms;
  String? originCountry; // 2 character repr.
  bool? isAdult;
  bool? isLicensed;
  Seasons? season;
  List<String>? studios;
  String? color;
  List<AnimeEpisode>? episodes;
  List<AnimeResult>? recommendations;
  List<AnimeResult>? relations;

  AnimeInfo({
    required super.id,
    required super.title,
    super.coverImage,
    super.bannerImage,
    super.status,
    super.rating,
    super.format,
    super.releaseDate,
    this.malId,
    this.genres,
    this.description,
    this.episodeCount,
    this.subOrDub,
    this.synonyms,
    this.originCountry,
    this.isAdult,
    this.isLicensed,
    this.season,
    this.studios,
    this.color,
    this.episodes,
    this.recommendations,
    this.relations,
  });
}
