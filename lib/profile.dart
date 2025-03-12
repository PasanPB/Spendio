import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy user data (replace with actual user data from your backend or state management)
    final String userName = "John Doe";
    final String userEmail = "johndoe@example.com";
    final String userPhone = "+1 234 567 890";
    final String userAddress = "123 Main Street, City, Country";

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF526D96), // Primary color
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFFEFBF3), // Background color
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Section
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/profile.png'), // Replace with user's image
                    ),
                    SizedBox(height: 12),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF526D96),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Profile Details Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      _buildProfileDetailRow(Icons.person, 'Name', userName),
                      Divider(),
                      // Email
                      _buildProfileDetailRow(Icons.email, 'Email', userEmail),
                      Divider(),
                      // Phone
                      _buildProfileDetailRow(Icons.phone, 'Phone', userPhone),
                      Divider(),
                      // Address
                      _buildProfileDetailRow(Icons.location_on, 'Address', userAddress),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Edit Profile Button
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to edit profile page or show a dialog
                  print('Edit Profile clicked');
                },
                icon: Icon(Icons.edit, color: Colors.white),
                label: Text(
                  'Edit Profile',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFEF9587), // Secondary color
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Logout Button
              OutlinedButton.icon(
                onPressed: () {
                  // Perform logout action
                  print('Logout clicked');
                  // Example: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
                icon: Icon(Icons.logout, color: Color(0xFFFD1D1D)),
                label: Text(
                  'Logout',
                  style: TextStyle(color: Color(0xFFFD1D1D)),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFFFD1D1D)),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build profile detail rows
  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF526D96), size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF526D96),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}