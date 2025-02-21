import 'package:isar/isar.dart';

part 'transaction_model.g.dart';

@Collection()
class TransactionModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String transactionId;

  late String userId;
  late String userName;
  late double totalAmount;
  late DateTime timestamp;
  late String status;
  late String paymentId;

  final List<TransactionItem> items = [];
}

@Embedded()
class TransactionItem {
  late String name;
  late int quantity;
  late double price;
  late double discountedPrice;
  late double total;
}
