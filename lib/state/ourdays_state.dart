import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ourdays_models.dart';

class OurDaysState extends ChangeNotifier {
  static const relationshipStart = '2022-01-14';
  static const _storageKey = 'ourdays_data_v1';
  static const _jetskiChecklist = [
    'Menentukan tanggal kencan',
    'Mencari tempat penyewaan jetski',
    'Mengecek harga sewa',
    'Menyiapkan pakaian ganti',
    'Menyiapkan perlengkapan pribadi',
    'Mengabadikan momen bersama',
  ];

  List<CoupleEvent> events = [];
  List<WishlistItem> wishlist = [];
  List<MemoryItem> memories = [];
  List<SharedNote> notes = [];
  String partnerOne = 'Citra';
  String partnerTwo = 'Iqram';
  String relationshipStartDate = relationshipStart;
  String? loadError;
  String? saveError;
  bool isLoaded = false;
  Future<void> _writeQueue = Future<void>.value();

  int get relationshipDays =>
      DateTime.now().difference(DateTime.parse(relationshipStartDate)).inDays;

  List<CoupleEvent> get upcomingEvents {
    final now = DateTime.now();
    final upcoming = events
        .where(
          (event) =>
              !event.date.isBefore(DateTime(now.year, now.month, now.day)),
        )
        .toList();
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming;
  }

  Future<void> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final stored = preferences.getString(_storageKey);
      if (stored == null) {
        _seedData();
        await _persist();
      } else {
        final data = jsonDecode(stored) as Map<String, dynamic>;
        events = _decodeList(data['events'], CoupleEvent.fromJson);
        wishlist = _decodeList(data['wishlist'], WishlistItem.fromJson);
        memories = _decodeList(data['memories'], MemoryItem.fromJson);
        notes = _decodeList(data['notes'], SharedNote.fromJson);
        partnerOne = data['partnerOne'] as String? ?? partnerOne;
        partnerTwo = data['partnerTwo'] as String? ?? partnerTwo;
        relationshipStartDate =
            data['relationshipStartDate'] as String? ?? relationshipStartDate;
        if (_migrateLegacyDemoData()) await _persist();
      }
    } on Exception catch (error) {
      loadError = 'We could not load your saved days: $error';
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  bool _migrateLegacyDemoData() {
    var changed = false;
    if (partnerOne == 'Sofia') {
      partnerOne = 'Citra';
      changed = true;
    }
    if (partnerTwo == 'Raka') {
      partnerTwo = 'Iqram';
      changed = true;
    }
    notes = notes.map((note) {
      if (note.id == 'note-little-things' &&
          note.content == 'Sofia likes tulips. Raka likes extra chili.') {
        changed = true;
        return note.copyWith(
          content: 'Citra likes tulips. Iqram likes extra chili.',
        );
      }
      return note;
    }).toList();
    events = events.map((event) {
      final isLegacyJetskiPlan =
          event.id == 'event-sunday-market' &&
          (event.title == 'Sunday flower market' ||
              event.title == 'Naik jetski di Barelang');
      if (!isLegacyJetskiPlan) return event;
      changed = true;
      return event.copyWith(
        title: 'Jetski Date at Barelang',
        category: 'Adventure Date',
        location: 'Barelang, Batam, Kepulauan Riau, Indonesia',
        activity: 'Bermain jetski bersama menikmati pemandangan laut Barelang.',
        story: 'A fun adventure together, riding a jetski and enjoying the beautiful sea view of Barelang.',
        checklist: _jetskiChecklist,
        completedChecklist: [],
      );
    }).toList();
    return changed;
  }

  List<T> _decodeList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) decode,
  ) {
    if (value is! List) return [];
    return value.whereType<Map<String, dynamic>>().map(decode).toList();
  }

  void _seedData() {
    final now = DateTime.now();
    final nextDate = DateTime(now.year, now.month, now.day + 3, 18);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    events = [
      CoupleEvent(
        id: 'event-first-coffee',
        title: 'Coffee & slow morning',
        category: 'Date',
        date: nextDate,
        location: 'Kopi Nako, Jakarta',
        budget: 180000,
        story: 'A little coffee date, a lot of catching up.',
        checklist: ['Book a table', 'Bring the film camera', 'Pick up flowers'],
        completedChecklist: [0],
        photos: [],
      ),
      CoupleEvent(
        id: 'event-sunday-market',
        title: 'Jetski Date at Barelang',
        category: 'Adventure Date',
        date: DateTime(now.year, now.month, now.day + 8, 10),
        location: 'Barelang, Batam, Kepulauan Riau, Indonesia',
        budget: 0,
        activity: 'Bermain jetski bersama menikmati pemandangan laut Barelang.',
        story: 'A fun adventure together, riding a jetski and enjoying the beautiful sea view of Barelang.',
        checklist: _jetskiChecklist,
        completedChecklist: [],
        photos: [],
      ),
    ];
    wishlist = [
      WishlistItem(
        id: 'wish-camping',
        title: 'Watch the sunrise by the sea',
        category: 'Experience',
        place: 'Any quiet beach',
        isDone: false,
      ),
      WishlistItem(
        id: 'wish-ramen',
        title: 'Try the little ramen place',
        category: 'Food',
        place: 'Blok M',
        isDone: false,
      ),
      WishlistItem(
        id: 'wish-vinyl',
        title: 'Find a record for our home',
        category: 'Little things',
        place: 'Djungkir Balik Records',
        isDone: true,
      ),
    ];
    memories = [
      MemoryItem(
        id: 'memory-rainy-day',
        title: 'Rainy day in Bandung',
        caption: 'Got lost, found the best little bakery.',
        date: yesterday,
        imageData: '',
      ),
      MemoryItem(
        id: 'memory-coffee',
        title: 'Our usual coffee stop',
        caption: 'Same table, new stories.',
        date: DateTime(now.year, now.month - 1, 12),
        imageData: '',
      ),
    ];
    notes = [
      SharedNote(
        id: 'note-anniversary',
        title: 'Anniversary ideas',
        content: 'A picnic somewhere green, then dinner at home.',
        isPinned: true,
        updatedAt: now,
      ),
      SharedNote(
        id: 'note-little-things',
        title: 'Little things to remember',
        content: 'Citra likes tulips. Iqram likes extra chili.',
        isPinned: false,
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  Future<void> addEvent(CoupleEvent event) async {
    events = [...events, event];
    notifyListeners();
    await _persist();
  }

  Future<void> updateEvent(CoupleEvent event) async {
    events = events.map((item) => item.id == event.id ? event : item).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> deleteEvent(String id) async {
    events = events.where((event) => event.id != id).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> toggleChecklist(CoupleEvent event, int index) async {
    final checked = [...event.completedChecklist];
    if (checked.contains(index)) {
      checked.remove(index);
    } else {
      checked.add(index);
    }
    await updateEvent(event.copyWith(completedChecklist: checked));
  }

  Future<void> addEventPhoto(
    CoupleEvent event, {
    required String imageData,
    required String caption,
  }) async {
    if (!events.any((item) => item.id == event.id)) {
      saveError = 'This event is no longer available.';
      notifyListeners();
      return;
    }
    events = events
        .map(
          (item) => item.id == event.id
              ? item.copyWith(photos: [...item.photos, imageData])
              : item,
        )
        .toList();
    memories = [
      MemoryItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: event.title,
        caption: caption,
        date: event.date,
        imageData: imageData,
      ),
      ...memories,
    ];
    notifyListeners();
    await _persist();
  }

  Future<void> addWishlist(WishlistItem item) async {
    wishlist = [...wishlist, item];
    notifyListeners();
    await _persist();
  }

  Future<void> updateWishlist(WishlistItem item) async {
    wishlist = wishlist
        .map((wish) => wish.id == item.id ? item : wish)
        .toList();
    notifyListeners();
    await _persist();
  }

  Future<void> deleteWishlist(String id) async {
    wishlist = wishlist.where((item) => item.id != id).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> addMemory(MemoryItem memory) async {
    memories = [memory, ...memories];
    notifyListeners();
    await _persist();
  }

  Future<void> addNote(SharedNote note) async {
    notes = [note, ...notes];
    notifyListeners();
    await _persist();
  }

  Future<void> updateNote(SharedNote note) async {
    notes = notes.map((item) => item.id == note.id ? note : item).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> deleteNote(String id) async {
    notes = notes.where((note) => note.id != id).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> updatePartners(String first, String second) async {
    partnerOne = first;
    partnerTwo = second;
    notifyListeners();
    await _persist();
  }

  Future<void> updateRelationshipStart(DateTime date) async {
    relationshipStartDate =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final snapshot = jsonEncode({
      'events': events.map((item) => item.toJson()).toList(),
      'wishlist': wishlist.map((item) => item.toJson()).toList(),
      'memories': memories.map((item) => item.toJson()).toList(),
      'notes': notes.map((item) => item.toJson()).toList(),
      'partnerOne': partnerOne,
      'partnerTwo': partnerTwo,
      'relationshipStartDate': relationshipStartDate,
    });
    _writeQueue = _writeQueue.catchError((Object _) {}).then((_) async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_storageKey, snapshot);
    });
    try {
      await _writeQueue;
      saveError = null;
    } on Exception catch (error) {
      saveError = 'Your changes could not be saved: $error';
      notifyListeners();
    }
  }
}
