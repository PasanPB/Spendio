import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  File? _billImage;
  Map<String, double> _expenses = {
    'Food': 0.0,
    'Transport': 0.0,
    'Groceries': 0.0,
    'Clothes': 0.0,
    'Rent': 0.0,
    'Other': 0.0,
  };

  // Default icon map for predefined categories
  Map<String, IconData> _categoryIcons = {
    'Food': Icons.fastfood,
    'Transport': Icons.directions_car,
    'Groceries': Icons.local_grocery_store,
    'Clothes': Icons.checkroom,
    'Rent': Icons.house,
    'Other': Icons.account_tree,
  };

  Future<void> _scanBill() async {
    // Scan bill logic
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

  // Expense Button Widget
  Widget _buildExpenseButton(String category) {
    return ElevatedButton(
      onPressed: () {
        // Show a dialog to enter the expense amount
        _showExpenseDialog(category);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF405DE6), // Background color
        padding: EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_categoryIcons[category], size: 38, color: Colors.white),
          SizedBox(height: 6),
          Text(
            category,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Pie Chart Widget
  Widget _buildPieChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: Color(0xFF405DE6),
              title: '${entry.value}%',
              radius: 50,
              titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
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
        ),
        elevation: 3,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expense Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
                    backgroundColor: Color(0xFF405DE6),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Expense Category Buttons
              Text(
                'Add Expenses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),

              GridView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                children: _expenses.keys.map((category) {
                  return _buildExpenseButton(category);
                }).toList(),
              ),
            ],
          ),
        ),
      ),

      // Floating Action Button for Adding New Expense Category
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: Color(0xFF405DE6),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
