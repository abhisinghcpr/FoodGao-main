import 'package:flutter/material.dart';
import 'package:food_gao/routs/app_routs.dart';
import 'package:food_gao/utils/app_color.dart';
import 'package:food_gao/views/home/favoriteScreen.dart';
import 'package:food_gao/views/profile/edit_profile.dart';
import 'package:food_gao/views/widgets/widget_app.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firebase_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool switchValue = true;
  Map<String, String?>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      userData = await AuthProvider().fetchUserData();
    } catch (e) {
      print('Error fetching user data: $e');
      userData = {
        'name': null,
        'email': null,
        'phoneNumber': null,
        'age': null,
        'address': null,
        'gender': null,
        'profileImage': null,
      };
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: orangeBorderColor))
          : userData == null
          ? const Center(child: Text('No user data available'))
          : Container(
        color: Colors.white,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Picture and Name
            Container(
              width: double.infinity,
              height: 270,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFA726), Color(0xFFFFA726)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(85)),
              ),
              padding: const EdgeInsets.only(top: 70.0),
              child: Column(
                children: [
                  // Profile Image with Border
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: whiteTextColor, width: 4),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: userData?['profileImage'] != null && userData!['profileImage']!.isNotEmpty
                          ? NetworkImage(userData!['profileImage']!)
                          : null,
                      child: userData!['profileImage'] == null || userData!['profileImage']!.isEmpty
                          ? Text(
                        userData!['name']?[0]?.toUpperCase() ?? 'N', // First letter of the user's name
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          color: whiteTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          : null,
                      backgroundColor: userData!['profileImage'] == null || userData!['profileImage']!.isEmpty
                          ? orangeButtonColor
                          : Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userData!['name'] ?? 'No Name',
                    style: GoogleFonts.poppins(
                      color: whiteTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Menu Items
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(Icons.person_outline, 'My Profile', () {
                    sendToPagePush(
                        context: context,
                        page: EditProfileScreen(
                          name: userData!['name'] ?? 'No Name',
                          email: userData!['email'] ?? 'No Email',
                          phone: userData!['phoneNumber'] ?? 'No Phone',
                          age: userData!['age'] ?? 'No Age',
                          address: userData!['address'] ?? 'No Address',
                          gender: userData!['gender'] ?? 'No Gender',
                          image: userData!['profileImage'] ?? 'No Image',
                        ));
                  }),
                  _buildMenuItem(Icons.mail_outline, 'Messages'),
                  _buildMenuItem(Icons.favorite_border, 'Favourites', () {
                    sendToPagePush(context: context, page: const FavoritesScreen());
                  }),
                  _buildMenuItemWithSwitch(Icons.notifications_outlined, 'Notification'),
                  _buildMenuItem(Icons.logout, 'Log Out', () {
                    WidgetApp(context: context).showLogoutDialog(context);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, [VoidCallback? onTap]) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 18, color: Colors.black87),
      ),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildMenuItemWithSwitch(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 18, color: Colors.black87),
      ),
      trailing: Switch(
        value: switchValue,
        onChanged: (bool newValue) {
          setState(() {
            switchValue = newValue;
          });
        },
        activeColor: whiteTextColor,
        activeTrackColor: orangeButtonColor,
      ),
    );
  }
}