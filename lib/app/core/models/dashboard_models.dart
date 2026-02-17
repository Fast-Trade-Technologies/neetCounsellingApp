/// Nullable model classes for Dashboard API response parsing.

class NewsUpdateItem {
  NewsUpdateItem({
    this.id,
    this.heading,
    this.link,
    this.isNew,
    this.isLocked,
    this.createdAt,
  });

  final String? id;
  final String? heading;
  final String? link;
  final bool? isNew;
  final bool? isLocked;
  final String? createdAt;

  factory NewsUpdateItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return NewsUpdateItem();
    return NewsUpdateItem(
      id: json['id']?.toString(),
      heading: json['heading']?.toString(),
      link: json['link']?.toString(),
      isNew: json['is_new'] as bool?,
      isLocked: json['is_locked'] as bool?,
      createdAt: json['created_at']?.toString(),
    );
  }
}

class CounsellingLinkItem {
  CounsellingLinkItem({
    this.id,
    this.heading,
    this.link,
    this.isNew,
    this.createdAt,
  });

  final String? id;
  final String? heading;
  final String? link;
  final bool? isNew;
  final String? createdAt;

  factory CounsellingLinkItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CounsellingLinkItem();
    return CounsellingLinkItem(
      id: json['id']?.toString(),
      heading: json['heading']?.toString(),
      link: json['link']?.toString(),
      isNew: json['is_new'] as bool?,
      createdAt: json['created_at']?.toString(),
    );
  }
}

class ImportantLinkItem {
  ImportantLinkItem({
    this.id,
    this.heading,
    this.link,
    this.isNew,
    this.isLocked,
    this.createdAt,
  });

  final String? id;
  final String? heading;
  final String? link;
  final bool? isNew;
  final bool? isLocked;
  final String? createdAt;

  factory ImportantLinkItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ImportantLinkItem();
    return ImportantLinkItem(
      id: json['id']?.toString(),
      heading: json['heading']?.toString(),
      link: json['link']?.toString(),
      isNew: json['is_new'] as bool?,
      isLocked: json['is_locked'] as bool?,
      createdAt: json['created_at']?.toString(),
    );
  }
}

class WebinarItem {
  WebinarItem({
    this.id,
    this.name,
    this.description,
    this.date,
    this.time,
    this.image,
  });

  final String? id;
  final String? name;
  final String? description;
  final String? date;
  final String? time;
  final String? image;

  factory WebinarItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WebinarItem();
    return WebinarItem(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      date: json['date']?.toString(),
      time: json['time']?.toString(),
      image: json['image']?.toString(),
    );
  }
}

class CounsellingTypeItem {
  CounsellingTypeItem({this.id, this.name});

  final String? id;
  final String? name;

  factory CounsellingTypeItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CounsellingTypeItem();
    return CounsellingTypeItem(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
    );
  }
}

class MapSummary {
  MapSummary({this.totalSeats, this.totalColleges});

  final int? totalSeats;
  final int? totalColleges;

  factory MapSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MapSummary();
    return MapSummary(
      totalSeats: json['total_seats'] is int
          ? json['total_seats'] as int
          : int.tryParse(json['total_seats']?.toString() ?? ''),
      totalColleges: json['total_colleges'] is int
          ? json['total_colleges'] as int
          : int.tryParse(json['total_colleges']?.toString() ?? ''),
    );
  }
}

class DashboardData {
  DashboardData({
    this.newsUpdates,
    this.counsellingLinks,
    this.importantLinks,
    this.webinars,
    this.counsellingTypes,
    this.mapSummary,
    this.stream,
    this.streamName,
    this.paidStatus,
  });

  final List<NewsUpdateItem>? newsUpdates;
  final List<CounsellingLinkItem>? counsellingLinks;
  final List<ImportantLinkItem>? importantLinks;
  final List<WebinarItem>? webinars;
  final List<CounsellingTypeItem>? counsellingTypes;
  final MapSummary? mapSummary;
  final String? stream;
  final String? streamName;
  final String? paidStatus;

  factory DashboardData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DashboardData();
    return DashboardData(
      newsUpdates: _parseList<NewsUpdateItem>(
        json['news_updates'],
        (e) => NewsUpdateItem.fromJson(e as Map<String, dynamic>?),
      ),
      counsellingLinks: _parseList<CounsellingLinkItem>(
        json['counselling_links'],
        (e) => CounsellingLinkItem.fromJson(e as Map<String, dynamic>?),
      ),
      importantLinks: _parseList<ImportantLinkItem>(
        json['important_links'],
        (e) => ImportantLinkItem.fromJson(e as Map<String, dynamic>?),
      ),
      webinars: _parseList<WebinarItem>(
        json['webinars'],
        (e) => WebinarItem.fromJson(e as Map<String, dynamic>?),
      ),
      counsellingTypes: _parseList<CounsellingTypeItem>(
        json['counselling_types'],
        (e) => CounsellingTypeItem.fromJson(e as Map<String, dynamic>?),
      ),
      mapSummary: json['map_summary'] is Map
          ? MapSummary.fromJson(Map<String, dynamic>.from(json['map_summary'] as Map))
          : null,
      stream: json['stream']?.toString(),
      streamName: json['stream_name']?.toString(),
      paidStatus: json['paid_status']?.toString(),
    );
  }

  static List<T>? _parseList<T>(dynamic raw, T Function(dynamic) fromJson) {
    if (raw is! List) return null;
    final list = <T>[];
    for (final e in raw) {
      try {
        list.add(fromJson(e));
      } catch (_) {}
    }
    return list;
  }
}
