import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import '../views/home/home_screen.dart';
import '../routs/app_routs.dart';
import '../utils/app_color.dart';

class AuthProvider with ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;


  // Add to Cart
  Future<void> addToCart(String image, String name, String price, String des,List<Map<String, dynamic>> relatedProducts, BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('addcart').add({
          'image': image,
          'name': name,
          'price': price,
          'description': des,
          'relatedProducts': relatedProducts,
          'userId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your cart has been added'), backgroundColor: orangeButtonColor),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Failed to add product to cart: $e');
    }
  }

  // Favorite Add
  Future<void> favoriteAdd(String image, String name, String price, String description, BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('favoriteAdd').add({
          'image': image,
          'name': name,
          'description': description,
          'price': price,
          'userId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your favorite has been added'), backgroundColor: orangeButtonColor),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Failed to add product to favorites: $e');
    }
  }

  // Favorite Remove
  Future<void> favoriteRemove(String image, String name, BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await _firestore.collection('favoriteAdd')
            .where('userId', isEqualTo: user.uid)
            .where('image', isEqualTo: image)
            .where('name', isEqualTo: name)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          await querySnapshot.docs.first.reference.delete();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The item has been removed from your favorites'), backgroundColor: orangeButtonColor),
          );
          notifyListeners();
        }
      }
    } catch (e) {
      print('Failed to remove product from favorites: $e');
    }
  }

  // Save User Details
  Future<void> saveDetails(BuildContext context, String name, String age, String gender, String address, File? image) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      String userId = user.uid;
      String phoneNumber = user.phoneNumber ?? '';
      String email = user.email ?? '';

      String? imageUrl;
      if (image != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profileImages/$userId.jpg');
        await storageRef.putFile(image);
        imageUrl = await storageRef.getDownloadURL();
      }

      await _firestore.collection('usersDetails').doc(userId).set({
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
        'age': age,
        'gender': gender,
        'address': address,
        'imageUrl': imageUrl,
        'firstLogin': false,
      });

      sendToPageReplacement(context: context, page: const HomeScreen());
      notifyListeners();
    } catch (e) {
      print('Error saving details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving details: $e')),
      );
    }
  }

  // Fetch User Data
  Future<Map<String, String?>> fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User is not logged in');
      }

      String userId = user.uid;
      DocumentSnapshot userDoc = await _firestore.collection('usersDetails').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      Map<String, String?> userData = {
        'name': userDoc.get('name') as String?,
        'email': userDoc.get('email') as String?,
        'phoneNumber': userDoc.get('phoneNumber') as String?,
        'age': userDoc.get('age') as String?,
        'address': userDoc.get('address') as String?,
        'gender': userDoc.get('gender') as String?,
        'profileImage': userDoc.get('imageUrl') as String?,
      };

      return userData;
    } catch (e) {
      print('Error fetching user data: $e');
      return {
        'name': null,
        'email': null,
        'phoneNumber': null,
        'age': null,
        'address': null,
        'gender': null,
        'profileImage': null,
      };
    }
  }

  // Update User Profile
  Future<void> updateDetails(BuildContext context, String name, String age, String gender, String address, File? image) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      String userId = user.uid;
      String phoneNumber = user.phoneNumber ?? '';
      String email = user.email ?? '';

      Map<String, dynamic> updatedData = {
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
        'age': age,
        'gender': gender,
        'address': address,
      };

      if (image != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profileImages/$userId.jpg');
        await storageRef.putFile(image);
        String imageUrl = await storageRef.getDownloadURL();
        updatedData['imageUrl'] = imageUrl;
      }

      await _firestore.collection('usersDetails').doc(userId).update(updatedData);
      notifyListeners();
      sendToPageReplacement(context: context, page: const HomeScreen());
      notifyListeners();
    } catch (e) {
      print('Error updating details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating details: $e')),
      );
    }
  }

  // Sign In with Google
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Google authentication tokens are null.');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        return user;
      } else {
        throw Exception('User is null after signing in.');
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // User Logout
  Future<void> userLogout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
      throw e; // Rethrow the error to handle it in the calling method
    }
  }
  // Fetch Products Data from Firebase
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('products').get();
      List<Map<String, dynamic>> products = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        String price;
        final priceValue = data['price'];
        if (priceValue is String) {
          price = priceValue;
        } else if (priceValue is double) {
          price = priceValue.toStringAsFixed(2);
        } else {
          price = 'N/A';
        }

        return {
          'image': data['image'],
          'name': data['name'],
          'price': price,
          'description': data['description'],  // Fetching the description
        };
      }).toList();

      notifyListeners();
      return products;

    } catch (e) {
      print('Error fetching products data: $e');
      return [];
    }
  }

  // Fetch Cart Items
  Stream<List<Map<String, dynamic>>> getCartItemsStream() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('addcart')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList());
    } else {
      return Stream.value([]);
    }
  }
  // Remove Item from Cart
  Future<void> removeItemFromCart(String id) async {
    try {
      await _firestore.collection('addcart').doc(id).delete();
      await getCartItemsStream();  // Refresh the cart items
      notifyListeners();       // Notify listeners to rebuild UI
    } catch (e) {
      print('Failed to remove item from cart: $e');
    }
  }

// Update Cart Item Quantity
  Future<void> updateCartItemQuantity(String id, int quantity) async {
    try {
      await _firestore.collection('addcart').doc(id).update({
        'quantity': quantity,
      });
      await getCartItemsStream();  // Refresh the cart items
      notifyListeners();       // Notify listeners to rebuild UI
    } catch (e) {
      print('Failed to update cart item quantity: $e');
    }
  }

  // user product order

  Future<void> productOrder(String image, String name, String price, String description, BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('orders').add({
          'image': image,
          'name': name,
          'description': description,
          'price': price,
          'userId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'pending',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your order has been added'), backgroundColor: orangeButtonColor),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Failed to add product to order: $e');
    }
  }

  // Fetch Orders
  Future<List<Map<String, dynamic>>> fetchOrders() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot snapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .get();
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Store document ID for later use
          return data;
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Failed to fetch orders: $e');
      return [];
    }
    }


}
