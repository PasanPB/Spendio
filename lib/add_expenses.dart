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

  // Notification counter (optional)
  int _notificationCount = 3; // Example: 3 unread notifications

  // Image Picker instance
  final ImagePicker _picker = ImagePicker();

  // Plan selection
  String _selectedPlan = 'Monthly'; // Default plan
  final Map<String, double> _plans = {
    'Daily': 0.0,
    'Weekly': 0.0,
    'Monthly': 0.0,
  };

  // Handle notification button click
  void _handleNotificationClick() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You have $_notificationCount new notifications')),
    );
  }

  // Scan bill logic
  Future<void> _scanBill() async {
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
                    _expenses[category] = (_expenses[category] ?? 0) + double.parse(amount);
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

  // Show dialog to set budget plan
  void _showPlanDialog() {
    TextEditingController _budgetController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Budget for $_selectedPlan Plan'),
          content: TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter budget amount',
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
                String budget = _budgetController.text;
                if (budget.isNotEmpty) {
                  setState(() {
                    _plans[_selectedPlan] = double.parse(budget);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Budget for $_selectedPlan set to Rs. $budget')),
                  );
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Set Budget'),
            ),
          ],
        );
      },
    );
  }

  // Pie Chart Widget
  Widget _buildPieChart() {
    double totalExpenses = _expenses.values.reduce((a, b) => a + b);

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Color(0xFFFEFBF3), // Background color
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PieChart(
          PieChartData(
            sections: _expenses.entries.map((entry) {
              double percentage = (entry.value / totalExpenses) * 100;
              return PieChartSectionData(
                value: entry.value,
                color: _categoryColors[entry.key], // Use category-specific color
                title: '${percentage.toStringAsFixed(1)}%', // Display percentage
                radius: 50,
                titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              );
            }).toList(),
            centerSpaceRadius: 40,
            sectionsSpace: 3,
          ),
        ),
      ),
    );
  }

  // Total Expenses Card
  Widget _buildTotalExpensesCard() {
    double totalExpenses = _expenses.values.reduce((a, b) => a + b);

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF526D96), Color(0xFFEF9587)], // Gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_money, size: 48, color: Colors.white),
            SizedBox(height: 12),
            Text(
              'Total Expenses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Rs. ${totalExpenses.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Plan Selection Dropdown with Enhanced Design
  Widget _buildPlanSelection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFFFEFBF3), // Background color
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Plan:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF526D96), // Primary color
            ),
          ),
          InkWell(
            onTap: () {
              // Show a custom dialog for plan selection
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'Select Plan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF526D96),
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: ['Daily', 'Weekly', 'Monthly']
                          .map((String plan) => ListTile(
                                leading: Icon(
                                  plan == 'Daily'
                                      ? Icons.calendar_today
                                      : plan == 'Weekly'
                                          ? Icons.calendar_view_week
                                          : Icons.calendar_month,
                                  color: Color(0xFFEF9587),
                                ),
                                title: Text(
                                  plan,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF526D96),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedPlan = plan;
                                  });
                                  Navigator.pop(context); // Close the dialog
                                },
                              ))
                          .toList(),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Color(0xFFFEFBF3), // Background color
                  );
                },
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFFEEC3B4).withOpacity(0.8), // Accent color
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedPlan,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showPlanDialog,
            icon: Icon(Icons.edit, color: Colors.white),
            label: Text(
              'Set Budget',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEF9587), // Secondary color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Expense Button Widget
  Widget _buildExpenseButton(String category) {
    return ElevatedButton(
      onPressed: () {
        _showExpenseDialog(category);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _categoryColors[category]!.withOpacity(0.8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_categoryIcons[category], size: 20, color: Colors.white),
          SizedBox(width: 8),
          Text(
            category,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Menu Bar (Modern PopupMenuButton)
  Widget _buildMenuBar() {
    return PopupMenuButton<String>(
      // Custom icon with animation
      icon: TweenAnimationBuilder(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
            ),
          );
        },
      ),
      onSelected: (String value) {
        // Handle menu item selection
        switch (value) {
          case 'profile':
            print('Profile selected');
            break;
          case 'analytics':
            print('Analytics selected');
            break;
          case 'settings':
            print('Settings selected');
            break;
          case 'help':
            print('Help selected');
            break;
          case 'logout':
            print('Logout selected');
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          // Profile
          PopupMenuItem(
            value: 'profile',
            child: _buildMenuItem(
              icon: Icons.person,
              text: 'Profile',
              color: Color(0xFF405DE6), // Blue
            ),
          ),
          // Analytics
          PopupMenuItem(
            value: 'analytics',
            child: _buildMenuItem(
              icon: Icons.analytics,
              text: 'Analytics',
              color: Color(0xFF833AB4), // Purple
            ),
          ),
          // Settings
          PopupMenuItem(
            value: 'settings',
            child: _buildMenuItem(
              icon: Icons.settings,
              text: 'Settings',
              color: Color(0xFFE1306C), // Pink
            ),
          ),
          // Help
          PopupMenuItem(
            value: 'help',
            child: _buildMenuItem(
              icon: Icons.help_outline,
              text: 'Help',
              color: Color(0xFF5851DB), // Indigo
            ),
          ),
          // Logout
          PopupMenuItem(
            value: 'logout',
            child: _buildMenuItem(
              icon: Icons.logout,
              text: 'Logout',
              color: Color(0xFFFD1D1D), // Red
            ),
          ),
        ];
      },
      offset: Offset(0, 40), // Adjust dropdown position
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      color: Color(0xFFFEFBF3), // Background color for dropdown
    );
  }

  // Custom Menu Item Widget
  Widget _buildMenuItem({required IconData icon, required String text, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Tracker'),
        backgroundColor: Color(0xFF526D96), // Primary color
        foregroundColor: Colors.white,
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
          // Modern Menu Bar
          _buildMenuBar(),
        ],
      ),
      body: Container(
        color: Color(0xFFFEFBF3), // Background color
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF526D96), // Primary color
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _scanBill,
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      label: Text(
                        'Scan Bill',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEF9587), // Secondary color
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Plan Selection Section
                _buildPlanSelection(),
                SizedBox(height: 16),
                // Total Expenses Card
                _buildTotalExpensesCard(),
                SizedBox(height: 16),
                // Pie Chart Section
                Text(
                  'Expense Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF526D96), // Primary color
                  ),
                ),
                SizedBox(height: 8),
                _buildPieChart(),
                SizedBox(height: 16),
                // Expense Buttons Grid
                Text(
                  'Add Expenses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF526D96), // Primary color
                  ),
                ),
                SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _expenses.length,
                  itemBuilder: (context, index) {
                    String category = _expenses.keys.elementAt(index);
                    return _buildExpenseButton(category);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: Color(0xFF526D96), // Primary color
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}