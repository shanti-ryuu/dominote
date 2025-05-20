import 'package:hive/hive.dart';

part 'pin.g.dart';

@HiveType(typeId: 2)
class Pin extends HiveObject {
  @HiveField(0)
  String hashedPin;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  DateTime updatedAt;

  Pin({
    required this.hashedPin,
    required this.createdAt,
    required this.updatedAt,
  });
}
