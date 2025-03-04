import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/error/error_handler.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload product image to Firebase Storage with better error handling
  Future<String> uploadProductImage(String userId, File image) async {
    try {
      // Create unique filename with timestamp and random component
      String fileName =
          'products/${userId}_${DateTime.now().millisecondsSinceEpoch}';

      // Configure metadata for better caching
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=86400',
      );

      // Upload image with progress monitoring
      final ref = _storage.ref().child(fileName);
      final uploadTask = ref.putFile(image, metadata);

      // Monitor upload progress (could be used for a progress indicator)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      // Wait for upload to complete
      await uploadTask;

      // Get download URL
      return await ref.getDownloadURL();
    } catch (e) {
      // Throw a more descriptive error
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  // Add a new product to Firestore with server timestamp
  Future<String> addProduct(Product product) async {
    try {
      final productMap = product.toMap();
      // Use server timestamp for better consistency
      productMap['createdAt'] = FieldValue.serverTimestamp();

      DocumentReference docRef =
          await _firestore.collection('products').add(productMap);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add product: ${e.toString()}');
    }
  }

  // Get all products with realtime updates and error handling
  Stream<List<Product>> getAllProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .limit(50) // Limit for performance
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) => Product.fromMap(doc.id, doc.data()))
            .toList();
      } catch (e, stackTrace) {
        ErrorHandler.reportError(e, stackTrace);
        throw Exception('Error parsing products: ${e.toString()}');
      }
    });
  }

  // Modify the getUserProducts method to handle the index error better
  Stream<List<Product>> getUserProducts(String userId) {
    return _firestore
        .collection('products')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) => Product.fromMap(doc.id, doc.data()))
            .toList();
      } catch (e, stackTrace) {
        // Check for specific Firebase index error
        if (e.toString().contains('The query requires an index')) {
          ErrorHandler.reportError(e, stackTrace);
          throw Exception(
              'Database index being created. Please wait a moment and try again later.');
        }
        ErrorHandler.reportError(e, stackTrace);
        throw Exception('Error loading your products: ${e.toString()}');
      }
    }).handleError((error, stackTrace) {
      // This catches stream errors that occur before the map operation
      if (error.toString().contains('requires an index')) {
        return []; // Return empty list while index is building
      }
      // rethrow;
    });
  }

  // Add method to get products by category
  Stream<List<Product>> getProductsByCategory(String category) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.id, doc.data()))
            .toList());
  }
}
