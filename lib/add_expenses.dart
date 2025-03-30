// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'goals_page.dart'; // Add this import for the GoalsPage

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  File? _billImage;
  final List<String> _defaultCategories = [
    'Food',
    'Transport',
    'Groceries',
    'Clothes',
    'Rent',
    'Other',
  ];
  final Map<String, double> _expenses = {};
  final Map<String, IconData> _categoryIcons = {
    'Food': Icons.fastfood,
    'Transport': Icons.directions_car,
    'Groceries': Icons.local_grocery_store,
    'Clothes': Icons.checkroom,
    'Rent': Icons.house,
    'Other': Icons.account_tree,
  };
  final Map<String, Color> _categoryColors = {
    'Food': Color(0xFF405DE6),
    'Transport': Color(0xFF833AB4),
    'Groceries': Color(0xFFE1306C),
    'Clothes': Color(0xFF5851DB),
    'Rent': Color(0xFFC13584),
    'Other': Color(0xFFFD1D1D),
  };
  int _notificationCount = 3;
  final ImagePicker _picker = ImagePicker();
  String _selectedPlan = 'Monthly';
  final Map<String, double> _plans = {
    'Daily': 0.0,
    'Weekly': 0.0,
    'Monthly': 0.0,
  };
  static const String _baseUrl = "http://10.0.2.2:5000";
  Map<String, String> _userData = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
  };

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users/<user_id>'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _userData = {
            'name': data['name'],
            'email': data['email'],
          };
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user data: $e')),
      );
    }
  }

  Future<void> _fetchExpenses() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/transactions'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Map<String, double> updatedExpenses = {};
        for (var category in _defaultCategories) {
          updatedExpenses[category] = 0.0;
        }

        for (var item in data) {
          final String category = item['category'];
          final double amount = (item['amount'] as num).toDouble();

          if (updatedExpenses.containsKey(category)) {
            updatedExpenses[category] = updatedExpenses[category]! + amount;
          } else {
            updatedExpenses[category] = amount;
          }
        }

        setState(() {
          _expenses.clear();
          _expenses.addAll(updatedExpenses);
        });
      } else {
        throw Exception('Failed to load expenses');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch expenses: $e')),
      );
    }
  }

  Future<void> _addExpenseToAPI(String category, double amount, String note) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'date': DateTime.now().toIso8601String(),
          'userId': 'user123',
          'category': category,
          'subcategory': '',
          'note': note,
          'amount': amount,
          'type': 'Expense',
          'currency': 'LKR',
        }),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Expense added successfully')),
        );
        _fetchExpenses();
      } else {
        throw Exception('Failed to add expense');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add expense: $e')),
      );
    }
  }

  Future<void> _clearTransactions() async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/transactions/<transaction_id>'));
      if (response.statusCode == 200) {
        setState(() {
          _expenses.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('All transactions cleared successfully')),
        );
      } else {
        throw Exception('Failed to clear transactions');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear transactions: $e')),
      );
    }
  }

  void _handleNotificationClick() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You have $_notificationCount new notifications')),
    );
  }

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
                  Navigator.pop(context);
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
                  Navigator.pop(context);
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

  void _showExpenseDialog(String category) {
    TextEditingController _amountController = TextEditingController();
    TextEditingController _noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Expense for $category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: 'Enter note (optional)',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String amount = _amountController.text;
                String note = _noteController.text;
                if (amount.isNotEmpty) {
                  try {
                    double parsedAmount = double.parse(amount);
                    if (parsedAmount > 0) {
                      await _addExpenseToAPI(category, parsedAmount, note);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a positive amount')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid amount entered')),
                    );
                  }
                }
              },
              child: Text('Add Expense'),
            ),
          ],
        );
      },
    );
  }

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
                Navigator.of(context).pop();
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
                    _categoryIcons[category] = Icons.category;
                    _categoryColors[category] = Colors.primaries[_expenses.length % Colors.primaries.length];
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added new category: $category with Rs. $amount')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('Add Category'),
            ),
          ],
        );
      },
    );
  }

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
                Navigator.of(context).pop();
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
                Navigator.of(context).pop();
              },
              child: Text('Set Budget'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPieChart() {
    if (_expenses.isEmpty || _expenses.values.every((value) => value == 0)) {
      return Center(
        child: Text(
          'No expenses added yet!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    double totalExpenses = _expenses.values.reduce((a, b) => a + b);
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Color(0xFFFEFBF3),
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
                color: _categoryColors[entry.key],
                title: '${percentage.toStringAsFixed(1)}%',
                radius: 50,
                titleStyle: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              );
            }).toList(),
            centerSpaceRadius: 40,
            sectionsSpace: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalExpensesCard() {
    double totalExpenses = _expenses.values.reduce((a, b) => a + b);
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF526D96), Color(0xFFEF9587)],
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

  Widget _buildPlanSelection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFFFEFBF3),
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
              color: Color(0xFF526D96),
            ),
          ),
          InkWell(
            onTap: () {
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
                                  Navigator.pop(context);
                                },
                              ))
                          .toList(),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Color(0xFFFEFBF3),
                  );
                },
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFFEEC3B4).withOpacity(0.8),
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
              backgroundColor: Color(0xFFEF9587),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Color(0xFFFEFBF3),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF526D96), Color(0xFFEF9587)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/assets/logo.png'),
                ),
                SizedBox(height: 10),
                Text(
                  _userData['name'] ?? 'John Doe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _userData['email'] ?? 'john.doe@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: Color(0xFF526D96)),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.flag, color: Color(0xFF4CAF50)),
            title: Text('Financial Goals'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GoalsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.analytics, color: Color(0xFF833AB4)),
            title: Text('Analytics'),
            onTap: () {
              Navigator.pop(context);
              print('Navigating to Analytics...');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Color(0xFFE1306C)),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              print('Navigating to Settings...');
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline, color: Color(0xFF5851DB)),
            title: Text('Help'),
            onTap: () {
              Navigator.pop(context);
              print('Navigating to Help...');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Color(0xFFFD1D1D)),
            title: Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              print('Logging out...');
            },
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
        backgroundColor: Color(0xFF526D96),
        foregroundColor: Colors.white,
        actions: [
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
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: _clearTransactions,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Container(
        color: Color(0xFFFEFBF3),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF526D96),
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
                        backgroundColor: Color(0xFFEF9587),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildPlanSelection(),
                SizedBox(height: 16),
                _buildTotalExpensesCard(),
                SizedBox(height: 16),
                Text(
                  'Expense Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF526D96),
                  ),
                ),
                SizedBox(height: 8),
                _buildPieChart(),
                SizedBox(height: 16),
                Text(
                  'Add Expenses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF526D96),
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
                  itemCount: _defaultCategories.length,
                  itemBuilder: (context, index) {
                    String category = _defaultCategories[index];
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
        backgroundColor: Color(0xFF526D96),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}