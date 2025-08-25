import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  String selectedSize;
  String selectedFlavor;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.selectedSize,
    required this.selectedFlavor,
  });

  double get totalPrice => product.price * quantity;
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'promo', 'order', 'system'

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
  });
}

class AppState extends ChangeNotifier {
  List<Product> products = dummyProducts;
  List<CartItem> cart = [];
  List<Map<String, dynamic>> orderHistory = [];
  List<NotificationItem> notifications = [];
  double gopayBalance = 150000.0;
  String userName = "User Gojek";
  String userEmail = "user@email.com";
  bool isDarkMode = false;
  String selectedLanguage = "id";

  // Initialize notifications
  AppState() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    notifications = [
      NotificationItem(
        id: "1",
        title: "🎉 Promo Spesial!",
        message: "Diskon hingga 70% untuk semua menu hari ini!",
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: "promo",
      ),
      NotificationItem(
        id: "2",
        title: "📦 Pesanan Dikirim",
        message: "Pesanan #12345 sudah dikirim oleh kurir",
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        type: "order",
      ),
      NotificationItem(
        id: "3",
        title: "💰 Top Up Berhasil",
        message: "Saldo Gopay Anda telah ditambahkan Rp 100.000",
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: "system",
      ),
    ];
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    if (category == "All") return products;
    return products.where((product) => product.category == category).toList();
  }

  // Get unique categories
  List<String> get categories {
    Set<String> categories = {"All"};
    for (var product in products) {
      categories.add(product.category);
    }
    return categories.toList();
  }

  // Cart operations
  void addToCart(Product product, String size, String flavor) {
    final existingIndex = cart.indexWhere((item) => 
      item.product.id == product.id && 
      item.selectedSize == size && 
      item.selectedFlavor == flavor
    );

    if (existingIndex >= 0) {
      cart[existingIndex].quantity++;
    } else {
      cart.add(CartItem(
        product: product,
        selectedSize: size,
        selectedFlavor: flavor,
      ));
    }
    notifyListeners();
    
    // Add notification
    addNotification(
      "🛒 Produk Ditambahkan",
      "${product.name} telah ditambahkan ke keranjang",
      "system",
    );
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < cart.length) {
      cart.removeAt(index);
      notifyListeners();
    }
  }

  void updateCartItemQuantity(int index, int quantity) {
    if (index >= 0 && index < cart.length) {
      if (quantity <= 0) {
        cart.removeAt(index);
      } else {
        cart[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  // Calculate cart total
  double get cartTotal => cart.fold(0, (sum, item) => sum + item.totalPrice);

  int get cartItemCount => cart.fold(0, (sum, item) => sum + item.quantity);

  // Order operations
  void placeOrder() {
    if (cart.isEmpty) return;

    final order = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "items": List<Map<String, dynamic>>.from(cart.map((item) => {
        "name": item.product.name,
        "quantity": item.quantity,
        "size": item.selectedSize,
        "flavor": item.selectedFlavor,
        "price": item.totalPrice,
      })),
      "total": cartTotal,
      "date": DateTime.now().toIso8601String(),
      "status": "Processing",
    };

    orderHistory.add(order);
    
    // Deduct from Gopay balance
    if (gopayBalance >= cartTotal) {
      gopayBalance -= cartTotal;
    }
    
    // Add notification
    addNotification(
      "📦 Pesanan Berhasil",
      "Pesanan sebesar Rp ${cartTotal.toStringAsFixed(0)} telah dibuat",
      "order",
    );
    
    clearCart();
    notifyListeners();
  }

  // Profile operations
  void updateProfile(String name, String email) {
    userName = name;
    userEmail = email;
    notifyListeners();
    
    addNotification(
      "👤 Profile Diupdate",
      "Informasi profile Anda telah berhasil diubah",
      "system",
    );
  }

  void topUpGopay(double amount) {
    gopayBalance += amount;
    notifyListeners();
    
    addNotification(
      "💰 Top Up Berhasil",
      "Saldo Gopay Anda telah ditambahkan Rp ${amount.toStringAsFixed(0)}",
      "system",
    );
  }

  // Notification operations
  void addNotification(String title, String message, String type) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
    );
    
    notifications.insert(0, notification);
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      notifications[index] = NotificationItem(
        id: notifications[index].id,
        title: notifications[index].title,
        message: notifications[index].message,
        timestamp: notifications[index].timestamp,
        isRead: true,
        type: notifications[index].type,
      );
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = NotificationItem(
        id: notifications[i].id,
        title: notifications[i].title,
        message: notifications[i].message,
        timestamp: notifications[i].timestamp,
        isRead: true,
        type: notifications[i].type,
      );
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  int get unreadNotificationCount => notifications.where((n) => !n.isRead).length;

  // Theme operations
  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  // Language operations
  void changeLanguage(String language) {
    selectedLanguage = language;
    notifyListeners();
  }

  // Search products
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return products;
    return products.where((product) => 
      product.name.toLowerCase().contains(query.toLowerCase()) ||
      product.description.toLowerCase().contains(query.toLowerCase()) ||
      product.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Get top rated products
  List<Product> get topRatedProducts {
    List<Product> sorted = List.from(products);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(6).toList();
  }

  // Get best selling products
  List<Product> get bestSellingProducts {
    List<Product> sorted = List.from(products);
    sorted.sort((a, b) => b.soldCount.compareTo(a.soldCount));
    return sorted.take(6).toList();
  }

  // Get trending products (based on recent orders)
  List<Product> get trendingProducts {
    // Simulate trending based on sold count and rating
    List<Product> sorted = List.from(products);
    sorted.sort((a, b) => (b.soldCount * b.rating).compareTo(a.soldCount * a.rating));
    return sorted.take(6).toList();
  }

  // Get products on sale
  List<Product> get productsOnSale {
    return products.where((product) => product.category == "Promo").toList();
  }

  // Add to favorites (placeholder for future implementation)
  List<String> favoriteProductIds = [];

  void toggleFavorite(String productId) {
    if (favoriteProductIds.contains(productId)) {
      favoriteProductIds.remove(productId);
    } else {
      favoriteProductIds.add(productId);
    }
    notifyListeners();
  }

  bool isFavorite(String productId) {
    return favoriteProductIds.contains(productId);
  }

  List<Product> get favoriteProducts {
    return products.where((product) => favoriteProductIds.contains(product.id)).toList();
  }
}
