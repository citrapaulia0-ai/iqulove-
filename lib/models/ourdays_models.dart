class CoupleEvent {
  CoupleEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.location,
    required this.budget,
    this.activity = '',
    required this.story,
    required this.checklist,
    required this.completedChecklist,
    required this.photos,
    this.status = 'Planned',
  });

  final String id;
  final String title;
  final String category;
  final DateTime date;
  final String location;
  final int budget;
  final String activity;
  final String story;
  final List<String> checklist;
  final List<int> completedChecklist;
  final List<String> photos;
  final String status;

  CoupleEvent copyWith({
    String? title,
    String? category,
    DateTime? date,
    String? location,
    int? budget,
    String? activity,
    String? story,
    List<String>? checklist,
    List<int>? completedChecklist,
    List<String>? photos,
    String? status,
  }) => CoupleEvent(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    date: date ?? this.date,
    location: location ?? this.location,
    budget: budget ?? this.budget,
    activity: activity ?? this.activity,
    story: story ?? this.story,
    checklist: checklist ?? this.checklist,
    completedChecklist: completedChecklist ?? this.completedChecklist,
    photos: photos ?? this.photos,
    status: status ?? this.status,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'date': date.toIso8601String(),
    'location': location,
    'budget': budget,
    'activity': activity,
    'story': story,
    'checklist': checklist,
    'completedChecklist': completedChecklist,
    'photos': photos,
    'status': status,
  };

  factory CoupleEvent.fromJson(Map<String, dynamic> json) => CoupleEvent(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String? ?? 'Date',
    date: DateTime.parse(json['date'] as String),
    location: json['location'] as String? ?? '',
    budget: json['budget'] as int? ?? 0,
    activity: json['activity'] as String? ?? '',
    story: json['story'] as String? ?? '',
    checklist: List<String>.from(json['checklist'] as List? ?? const []),
    completedChecklist: List<int>.from(
      json['completedChecklist'] as List? ?? const [],
    ),
    photos: List<String>.from(json['photos'] as List? ?? const []),
    status: json['status'] as String? ?? 'Planned',
  );
}

class WishlistItem {
  WishlistItem({
    required this.id,
    required this.title,
    required this.category,
    required this.place,
    required this.isDone,
  });

  final String id;
  final String title;
  final String category;
  final String place;
  final bool isDone;

  WishlistItem copyWith({bool? isDone}) => WishlistItem(
    id: id,
    title: title,
    category: category,
    place: place,
    isDone: isDone ?? this.isDone,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'place': place,
    'isDone': isDone,
  };

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String? ?? 'Experience',
    place: json['place'] as String? ?? '',
    isDone: json['isDone'] as bool? ?? false,
  );
}

class MemoryItem {
  MemoryItem({
    required this.id,
    required this.title,
    required this.caption,
    required this.date,
    required this.imageData,
  });

  final String id;
  final String title;
  final String caption;
  final DateTime date;
  final String imageData;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'caption': caption,
    'date': date.toIso8601String(),
    'imageData': imageData,
  };

  factory MemoryItem.fromJson(Map<String, dynamic> json) => MemoryItem(
    id: json['id'] as String,
    title: json['title'] as String,
    caption: json['caption'] as String? ?? '',
    date: DateTime.parse(json['date'] as String),
    imageData: json['imageData'] as String? ?? '',
  );
}

class SharedNote {
  SharedNote({
    required this.id,
    required this.title,
    required this.content,
    required this.isPinned,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final bool isPinned;
  final DateTime updatedAt;

  SharedNote copyWith({
    String? title,
    String? content,
    bool? isPinned,
    DateTime? updatedAt,
  }) => SharedNote(
    id: id,
    title: title ?? this.title,
    content: content ?? this.content,
    isPinned: isPinned ?? this.isPinned,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'isPinned': isPinned,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory SharedNote.fromJson(Map<String, dynamic> json) => SharedNote(
    id: json['id'] as String,
    title: json['title'] as String,
    content: json['content'] as String? ?? '',
    isPinned: json['isPinned'] as bool? ?? false,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}
