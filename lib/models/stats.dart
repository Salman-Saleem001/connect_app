class Stats {
  List<Stat>? stats;

  Stats({
    this.stats,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    stats: json["stats"] == null ? [] : List<Stat>.from(json["stats"]!.map((x) => Stat.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "stats": stats == null ? [] : List<dynamic>.from(stats!.map((x) => x.toJson())),
  };
}

class Stat {
  String? country;
  int? totalViews;

  Stat({
    this.country,
    this.totalViews,
  });

  factory Stat.fromJson(Map<String, dynamic> json) => Stat(
    country: json["country"],
    totalViews: json["total_views"],
  );

  Map<String, dynamic> toJson() => {
    "country": country,
    "total_views": totalViews,
  };
}