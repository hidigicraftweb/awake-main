import 'package:equatable/equatable.dart';

class UserStats extends Equatable {
  final int totalTransactions;
  final int totalSpent;
  final String totalSpentFormatted;
  final int totalItems;
  final int transactionsThisMonth;
  final int spentThisMonth;
  final String spentThisMonthFormatted;
  final int averagePerTransaction;
  final String averagePerTransactionFormatted;
  final FavoriteItem? favoriteProduct;
  final FavoriteItem? favoriteCafe;
  final String memberSince;
  final double memberDays;

  const UserStats({
    required this.totalTransactions,
    required this.totalSpent,
    required this.totalSpentFormatted,
    required this.totalItems,
    required this.transactionsThisMonth,
    required this.spentThisMonth,
    required this.spentThisMonthFormatted,
    required this.averagePerTransaction,
    required this.averagePerTransactionFormatted,
    this.favoriteProduct,
    this.favoriteCafe,
    required this.memberSince,
    required this.memberDays,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalTransactions: json['total_transactions'] ?? 0,
      totalSpent: json['total_spent'] ?? 0,
      totalSpentFormatted: json['total_spent_formatted'] ?? 'Rp 0',
      totalItems: json['total_items'] ?? 0,
      transactionsThisMonth: json['transactions_this_month'] ?? 0,
      spentThisMonth: json['spent_this_month'] ?? 0,
      spentThisMonthFormatted: json['spent_this_month_formatted'] ?? 'Rp 0',
      averagePerTransaction: json['average_per_transaction'] ?? 0,
      averagePerTransactionFormatted:
          json['average_per_transaction_formatted'] ?? 'Rp 0',
      favoriteProduct: json['favorite_product'] != null
          ? FavoriteItem.fromJson(json['favorite_product'])
          : null,
      favoriteCafe: json['favorite_cafe'] != null
          ? FavoriteItem.fromJson(json['favorite_cafe'])
          : null,
      memberSince: json['member_since'] ?? '',
      memberDays: (json['member_days'] ?? 0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        totalTransactions,
        totalSpent,
        totalItems,
        transactionsThisMonth,
        spentThisMonth,
        favoriteProduct,
        favoriteCafe,
        memberDays,
      ];
}

class FavoriteItem extends Equatable {
  final int id;
  final String name;
  final int count;

  const FavoriteItem({
    required this.id,
    required this.name,
    required this.count,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      count: json['total_ordered'] ?? json['total_visits'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, count];
}
