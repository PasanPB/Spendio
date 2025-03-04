import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart'; // Add image_picker package
import 'dart:io';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  File? _billImage;
  final Map<String, double> _expenses = {
    'Food': 0.0,
    'Transport': 0.0,
    'Groceries': 0.0,
    'Clothes': 0.0,
    'Rent': 0.0,
    'Other': 0.0,
  };

  // Default icon map for predefined categories
  final Map<String, IconData> _categoryIcons = {
    'Food': Icons.fastfood,
    'Transport': Icons.directions_car,
    'Groceries': Icons.local_grocery_store,
    'Clothes': Icons.checkroom,
    'Rent': Icons.house,
    'Other': Icons.account_tree,
  };

  // Color map for each category
  final Map<String, Color> _categoryColors = {
    'Food': Color(0xFF405DE6), // Blue
    'Transport': Color(0xFF833AB4), // Purple
    'Groceries': Color(0xFFE1306C), // Pink
    'Clothes': Color(0xFF5851DB), // Indigo
    'Rent': Color(0xFFC13584), // Magenta
    'Other': Color(0xFFFD1D1D), // Red
  };

  // Image Picker instance
  final ImagePicker _picker = ImagePicker();

  // Notification counter (optional)
  int _notificationCount = 3; // Example: 3 unread notifications

  // Handle notification button click
  void _handleNotificationClick() {
    // Navigate to a notifications page or show a dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You have $_notificationCount new notifications')),
    );
  }

  // Scan bill logic
  Future<void> _scanBill() async {
    // Show a dialog to choose between camera and gallery
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Capture Photo'),
                onTap: () async {
                  Navigator.pop(context); // Close the dialog
                  final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      _billImage = File(image.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context); // Close the dialog
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _billImage = File(image.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show dialog to enter expense amount
  void _showExpenseDialog(String category) {
    TextEditingController _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Expense for $category'),
          content: TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter amount',
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String amount = _amountController.text;
                if (amount.isNotEmpty) {
                  setState(() {
                    _expenses[category] = double.parse(amount);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Expense for $category: Rs. $amount added')),
                  );
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Add Expense'),
            ),
          ],
        );
      },
    );
  }

  // Show dialog to add new expense category
  void _showAddCategoryDialog() {
    TextEditingController _categoryController = TextEditingController();
    TextEditingController _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Expense Category'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  hintText: 'Enter category name',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter initial amount',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String category = _categoryController.text;
                String amount = _amountController.text;
                if (category.isNotEmpty && amount.isNotEmpty) {
                  setState(() {
                    _expenses[category] = double.parse(amount);
                    _categoryIcons[category] = Icons.category; // Default icon for new categories
                    _categoryColors[category] = Colors.primaries[_expenses.length % Colors.primaries.length]; // Assign a random color
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added new category: $category with Rs. $amount')),
                  );
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Add Category'),
            ),
          ],
        );
      },
    );
  }

  // Expense Button Widget with Animation
  Widget _buildExpenseButton(String category) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: ElevatedButton(
        onPressed: () {
          _showExpenseDialog(category);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _categoryColors[category]!.withOpacity(0.8),
          padding: EdgeInsets.all(8), // Reduced padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Smaller border radius
          ),
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_categoryIcons[category], size: 24, color: Colors.white), // Smaller icon
            SizedBox(height: 4),
            Text(
              category,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), // Smaller text
            ),
          ],
        ),
      ),
    );
  }

  // Pie Chart Widget
  Widget _buildPieChart() {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: value,
            child: child,
          ),
        );
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: PieChart(
          PieChartData(
            sections: _expenses.entries.map((entry) {
              return PieChartSectionData(
                value: entry.value,
                color: _categoryColors[entry.key], // Use category-specific color
                title: '${entry.value}',
                radius: 50,
                titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              );
            }).toList(),
            centerSpaceRadius: 40,
            sectionsSpace: 3,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Color(0xFF405DE6).withOpacity(0.8),
        actions: [
          // Notification Icon with Badge
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.white),
                onPressed: _handleNotificationClick,
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '$_notificationCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Menu Bar (PopupMenuButton)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String value) {
              // Handle menu item selection
              switch (value) {
                case 'profile':
                  print('Profile selected');
                  break;
                case 'predictive_analysis':
                  print('Predictive Analysis selected');
                  break;
                case 'offers':
                  print('Offers selected');
                  break;
                case 'contact_info':
                  print('Contact Information selected');
                  break;
                case 'achievements':
                  print('My Achievements selected');
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'profile',
                  child: Text('Profile'),
                ),
                PopupMenuItem(
                  value: 'predictive_analysis',
                  child: Text('Predictive Analysis'),
                ),
                PopupMenuItem(
                  value: 'offers',
                  child: Text('Offers'),
                ),
                PopupMenuItem(
                  value: 'contact_info',
                  child: Text('Contact Information'),
                ),
                PopupMenuItem(
                  value: 'achievements',
                  child: Text('My Achievements'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF405DE6),
              Color(0xFF833AB4),
              Color(0xFFE1306C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Logo
                Center(
                  child: Image.asset(
                    'assets/assets/logo.png', // Replace with your logo path
                    width: 100, // Adjust size as needed
                    height: 100,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error, size: 100, color: Colors.white); // Fallback if image fails to load
                    },
                  ),
                ),
                SizedBox(height: 16),

                Text(
                  'Expense Overview',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),

                // Pie Chart Section
                _buildPieChart(),
                SizedBox(height: 16),

                // Scan Bill Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _scanBill,
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                    label: Text('Scan Bill', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF405DE6).withOpacity(0.8),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Display the scanned bill image (if available)
                if (_billImage != null)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Scanned Bill:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(_billImage!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Expense Category Buttons
                Text(
                  'Add Expenses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),

                GridView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // More columns for smaller buttons
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1, // Adjust height of buttons
                  ),
                  children: _expenses.keys.map((category) {
                    return _buildExpenseButton(category);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),

      // Floating Action Button for Adding New Expense Category
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: Color(0xFF405DE6).withOpacity(0.8),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}