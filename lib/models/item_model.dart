import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  late String id;
  late String category;
  late String pitures;
  late String title;
  late String location;
  late List nameArray;
  late Map itemDetails;
  late String description;
  late dynamic geo;

  ItemModel(
      {required this.id,
      required this.category,
      required this.nameArray,
      required this.pitures,
      required this.title,
      required this.itemDetails,
      required this.location,
      required this.description,
      required this.geo});

  factory ItemModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    var id = doc.id;
    var data = doc.data() as Map;
    return ItemModel(
        id: id,
        category: data['category'] ?? '',
        itemDetails: data['itemDetails'] ?? {},
        nameArray: data['nameArray'] ?? [],
        pitures: data['pitures'],
        title: data['title'] ?? '',
        location: data['location'] ?? '',
        description: data['description'] ?? false,
        geo: doc['geo']['geopoint'] as GeoPoint);
  }
  Map<String, dynamic> toMap() => {
        "category": category,
        "pitures": pitures,
        "nameArray": nameArray,
        "title": title,
        "status": 'available',
        "location": location,
        "description": description,
        "geo": geo,
      };
}

class ItemStatus {
  static String available = 'available';
  static String removed = 'removed';
  static String inUse = 'inUse';
}

class ItemType {
  static String buddy = 'buddy';
  static String job = 'job';
  static String accomodation = 'accomodation';
}
