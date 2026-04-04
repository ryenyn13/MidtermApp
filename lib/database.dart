import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static const String mongoUrl = "mongodb+srv://nhinty23itb:1234@giuaky.opyprmd.mongodb.net/?appName=GiuaKy";
  static late Db db;

  static Future<void> connect() async {
    db = await Db.create(mongoUrl);
    await db.open();
    print("Connected to MongoDB!");
  }

  static DbCollection getCollection(String collectionName) {
    return db.collection(collectionName);
  }

  static Future<void> close() async {
    await db.close();
  }
}