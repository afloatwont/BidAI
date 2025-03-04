import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import '../core/error/error_handler.dart';
import 'auth_viewmodel.dart';

// Product repository provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

// All products stream provider with error handling and caching
final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final productRepository = ref.watch(productRepositoryProvider);

  // Return the stream with transformation for error handling
  return productRepository.getAllProducts().handleError((error, stackTrace) {
    // Log error properly
    ErrorHandler.reportError(error, stackTrace);
    // Rethrow to let Riverpod handle it in the UI
    throw error;
  });
});

// User products stream provider with family parameter
final userProductsStreamProvider =
    StreamProvider.family<List<Product>, String>((ref, userId) {
  final productRepository = ref.watch(productRepositoryProvider);

  // Return the stream with transformation for error handling
  return productRepository
      .getUserProducts(userId)
      .handleError((error, stackTrace) {
    // Log error properly
    ErrorHandler.reportError(error, stackTrace);
    // Rethrow to let Riverpod handle it in the UI
    throw error;
  });
});

// Product categories provider
final productCategoriesProvider = Provider<List<String>>((ref) {
  return [
    'Electronics',
    'Furniture',
    'Clothing',
    'Books',
    'Sports',
    'Others',
  ];
});

// Product view model provider with state
final productViewModelProvider =
    StateNotifierProvider<ProductViewModel, AsyncValue<void>>((ref) {
  final productRepository = ref.watch(productRepositoryProvider);
  return ProductViewModel(productRepository, ref);
});

class ProductViewModel extends StateNotifier<AsyncValue<void>> {
  final ProductRepository _productRepository;
  final Ref _ref;

  ProductViewModel(this._productRepository, this._ref)
      : super(const AsyncValue.data(null));

  // Add a new product with improved error handling
  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required File imageFile,
    required String category,
  }) async {
    try {
      state = const AsyncValue.loading();

      // Get current user with error handling
      final user = _ref.read(authStateProvider).value;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Upload image with timeout
      final imageUrl = await _productRepository
          .uploadProductImage(user.uid, imageFile)
          .timeout(const Duration(seconds: 30));

      // Create product
      final product = Product(
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        category: category,
        userId: user.uid,
      );

      // Save product to Firestore
      await _productRepository.addProduct(product);

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      // Convert the error to a user-friendly message and store it in the state
      final errorMsg = ErrorHandler.getReadableErrorMessage(e);
      state = AsyncValue.error(errorMsg, stackTrace);

      // Rethrow for component level handling
      rethrow;
    }
  }

  // Method to refresh products data
  void refreshProducts() {
    _ref.invalidate(productsStreamProvider);
  }
}
