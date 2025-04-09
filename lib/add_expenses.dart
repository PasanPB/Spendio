// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'goals_page.dart';
import 'package:animate_do/animate_do.dart'; // For animations

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  File? _billImage;
  final List<String> _defaultCategories = ['Food', 'Transport', 'Groceries', 'Clothes', 'Rent', 'Other'];
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
    'Food': const Color(0xFF405DE6),
    'Transport': const Color(0xFF833AB4),
    'Groceries': const Color(0xFFE1306C),
    'Clothes': const Color(0xFF5851DB),
    'Rent': const Color(0xFFC13584),
    'Other': const Color(0xFFFD1D1D),
  };
  int _notificationCount = 3;
  final ImagePicker _picker = ImagePicker();
  String _selectedPlan = 'Monthly';
  final Map<String, double> _plans = {'Daily': 0.0, 'Weekly': 0.0, 'Monthly': 0.0};
  static const String _baseUrl = "http://10.0.2.2:5000";
  Map<String, String> _userData = {'name': 'John Doe', 'email': 'john.doe@example.com'};
  Map<String, List<double>> _expenseTrends = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchExpenses();
    _fetchExpenseTrends();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users/<user_id>'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() => _userData = {'name': data['name'], 'email': data['email']});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch user data: $e')));
    }
  }

  Future<void> _fetchExpenses() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/transactions'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Map<String, double> updatedExpenses = {for (var cat in _defaultCategories) cat: 0.0};
        for (var item in data) {
          final String category = item['category'];
          final double amount = (item['amount'] as num).toDouble();
          updatedExpenses[category] = (updatedExpenses[category] ?? 0.0) + amount;
        }
        setState(() {
          _expenses.clear();
          _expenses.addAll(updatedExpenses);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch expenses: $e')));
    }
  }

  Future<void> _fetchExpenseTrends() async {
    setState(() {
      _expenseTrends = {
        for (var category in _defaultCategories)
          category: List.generate(5, (index) => (_expenses[category] ?? 0.0) * (0.8 + index * 0.05)),
      };
    });
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense added')));
        _fetchExpenses();
        _fetchExpenseTrends();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add expense: $e')));
    }
  }

  Future<void> _clearTransactions() async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/transactions/<transaction_id>'));
      if (response.statusCode == 200) {
        setState(() {
          _expenses.clear();
          _expenseTrends.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transactions cleared')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to clear transactions: $e')));
    }
  }

  void _handleNotificationClick() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You have $_notificationCount new notifications')));
  }

  Future<void> _scanBill() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan Bill', style: TextStyle(color: Color(0xFF526D96))),
        backgroundColor: const Color(0xFFF6F6F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption(Icons.camera_alt, 'Capture Photo', 'camera'),
            _buildDialogOption(Icons.photo_library, 'Choose from Gallery', 'gallery'),
          ],
        ),
      ),
    );

    if (choice != null) {
      final source = choice == 'camera' ? ImageSource.camera : ImageSource.gallery;
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() => _billImage = File(image.path));
        _processBillImage();
      }
    }
  }

  Widget _buildDialogOption(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFEF9587)),
      title: Text(title, style: const TextStyle(color: Color(0xFF526D96))),
      onTap: () => Navigator.pop(context, value),
    );
  }

  void _processBillImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bill Details', style: TextStyle(color: Color(0xFF526D96))),
        backgroundColor: const Color(0xFFF6F6F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_billImage != null) FadeIn(child: Image.file(_billImage!, height: 100)),
            const SizedBox(height: 10),
            _buildBillDetail(Icons.attach_money, 'Amount', 'Rs. 1500.00'),
            _buildBillDetail(Icons.category, 'Category', 'Groceries'),
            _buildBillDetail(Icons.note, 'Note', 'Supermarket Receipt'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              _addExpenseToAPI('Groceries', 1500.00, 'Supermarket Receipt');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF9587), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBillDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF526D96), size: 20),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF526D96))),
          Text(value, style: const TextStyle(color: Color(0xFF526D96))),
        ],
      ),
    );
  }

  void _showExpenseDialog(String category) {
    final TextEditingController _amountController = TextEditingController();
    final TextEditingController _noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Expense - $category', style: const TextStyle(color: Color(0xFF526D96))),
        backgroundColor: const Color(0xFFF6F6F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: FadeInUp(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_amountController, 'Enter amount', Icons.attach_money, TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(_noteController, 'Enter note (optional)', Icons.note),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(_amountController.text) ?? 0;
              if (amount > 0) {
                await _addExpenseToAPI(category, amount, _noteController.text);
                Navigator.pop(context);
                _checkBudget(category, amount);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF9587), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, [TextInputType? keyboardType]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF526D96)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController _categoryController = TextEditingController();
    final TextEditingController _amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category', style: TextStyle(color: Color(0xFF526D96))),
        backgroundColor: const Color(0xFFF6F6F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: FadeInUp(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_categoryController, 'Enter category name', Icons.category),
              const SizedBox(height: 12),
              _buildTextField(_amountController, 'Enter initial amount', Icons.attach_money, TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              final category = _categoryController.text;
              final amount = double.tryParse(_amountController.text) ?? 0;
              if (category.isNotEmpty && amount > 0) {
                setState(() {
                  _expenses[category] = amount;
                  _categoryIcons[category] = Icons.category;
                  _categoryColors[category] = Colors.primaries[_expenses.length % Colors.primaries.length];
                  _expenseTrends[category] = List.filled(5, amount / 5);
                });
                _addExpenseToAPI(category, amount, 'Initial amount');
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF9587), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPlanDialog() {
    final TextEditingController _budgetController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Budget for $_selectedPlan', style: const TextStyle(color: Color(0xFF526D96))),
        backgroundColor: const Color(0xFFF6F6F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: FadeInUp(
          child: _buildTextField(_budgetController, 'Enter budget amount', Icons.attach_money, TextInputType.number),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              final budget = double.tryParse(_budgetController.text) ?? 0;
              if (budget > 0) {
                setState(() => _plans[_selectedPlan] = budget);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Budget set to Rs. $budget')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF9587), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Set', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _checkBudget(String category, double amount) {
    final totalExpenses = _expenses.values.reduce((a, b) => a + b);
    final budget = _plans[_selectedPlan] ?? 0;
    if (budget > 0 && totalExpenses + amount > budget) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Warning: Budget exceeded!'), backgroundColor: Colors.orange),
      );
    }
  }

  Widget _buildPieChart() {
    if (_expenses.isEmpty || _expenses.values.every((value) => value == 0)) {
      return const Center(child: Text('No expenses yet!', style: TextStyle(fontSize: 16, color: Colors.grey)));
    }
    final totalExpenses = _expenses.values.reduce((a, b) => a + b);
    return FadeIn(
      child: Container(
        height: 260,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFF6F6F6), Color(0xFFEFEFEF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: PieChart(
          PieChartData(
            sections: _expenses.entries.map((entry) {
              final percentage = (entry.value / totalExpenses) * 100;
              return PieChartSectionData(
                value: entry.value,
                color: _categoryColors[entry.key]!,
                title: '${percentage.toStringAsFixed(1)}%',
                radius: 70,
                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              );
            }).toList(),
            centerSpaceRadius: 50,
            sectionsSpace: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalExpensesCard() {
    final totalExpenses = _expenses.values.reduce((a, b) => a + b);
    final budget = _plans[_selectedPlan] ?? 0;
    return FadeInDown(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF526D96), Color(0xFFEF9587)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            const Icon(Icons.account_balance_wallet, size: 50, color: Colors.white),
            const SizedBox(height: 16),
            const Text('Total Expenses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white70)),
            const SizedBox(height: 10),
            Text('Rs. ${totalExpenses.toStringAsFixed(2)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
            if (budget > 0) ...[
              const SizedBox(height: 12),
              Text('Budget: Rs. $budget', style: const TextStyle(fontSize: 16, color: Colors.white70)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: totalExpenses / budget,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTrends() {
    if (_expenseTrends.isEmpty) return const SizedBox.shrink();
    return FadeInUp(
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFF6F6F6), Color(0xFFEFEFEF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(drawHorizontalLine: true, drawVerticalLine: false, horizontalInterval: 500),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text('Rs. ${value.toInt()}'))),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text('P${value.toInt() + 1}', style: const TextStyle(fontSize: 12)))),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: _expenseTrends.entries.map((entry) {
              return LineChartBarData(
                spots: entry.value.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                isCurved: true,
                color: _categoryColors[entry.key]!,
                barWidth: 3,
                belowBarData: BarAreaData(show: true, color: _categoryColors[entry.key]!.withOpacity(0.2)),
                dotData: const FlDotData(show: true),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanSelection() {
    return FadeInLeft(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(4, 4)),
            BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 10, offset: const Offset(-4, -4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF526D96)),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedPlan,
                  items: _plans.keys.map((plan) => DropdownMenuItem(value: plan, child: Text(plan, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                  onChanged: (value) => setState(() => _selectedPlan = value!),
                  style: const TextStyle(fontSize: 18, color: Color(0xFF526D96)),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFEF9587)),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _showPlanDialog,
              icon: const Icon(Icons.edit, size: 18, color: Colors.white),
              label: const Text('Set Budget', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF9587),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseButton(String category) {
    return FadeInUp(
      delay: Duration(milliseconds: _expenses.keys.toList().indexOf(category) * 100),
      child: GestureDetector(
        onTap: () => _showExpenseDialog(category),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_categoryColors[category]!, _categoryColors[category]!.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: _categoryColors[category]!.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_categoryIcons[category], size: 28, color: Colors.white),
              const SizedBox(height: 8),
              Text(category, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text('Rs. ${_expenses[category]?.toStringAsFixed(2) ?? "0.00"}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFFF6F6F6),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF526D96), Color(0xFFEF9587)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(radius: 35, backgroundImage: AssetImage('assets/assets/logo.png')),
                const SizedBox(height: 12),
                Text(_userData['name'] ?? 'John Doe', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(_userData['email'] ?? 'john.doe@example.com', style: const TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', () => Navigator.pop(context)),
          _buildDrawerItem(Icons.flag, 'Financial Goals', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GoalsPage()))),
          _buildDrawerItem(Icons.analytics, 'Analytics', () => Navigator.pop(context)),
          _buildDrawerItem(Icons.settings, 'Settings', () => Navigator.pop(context)),
          _buildDrawerItem(Icons.help_outline, 'Help', () => Navigator.pop(context)),
          _buildDrawerItem(Icons.logout, 'Logout', () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF526D96)),
      title: Text(title, style: const TextStyle(fontSize: 16, color: Color(0xFF526D96))),
      onTap: onTap,
      tileColor: const Color(0xFFF6F6F6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF526D96),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF526D96), Color(0xFFEF9587)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications), onPressed: _handleNotificationClick),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    child: Text('$_notificationCount', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
            ],
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: _clearTransactions),
        ],
      ),
      drawer: _buildDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFF6F6F6), Color(0xFFEFEFEF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF526D96))),
                  ElevatedButton.icon(
                    onPressed: _scanBill,
                    icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    label: const Text('Scan Bill', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF9587),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildPlanSelection(),
              const SizedBox(height: 20),
              _buildTotalExpensesCard(),
              const SizedBox(height: 20),
              const Text('Expense Breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF526D96))),
              const SizedBox(height: 12),
              _buildPieChart(),
              const SizedBox(height: 20),
              const Text('Expense Trends', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF526D96))),
              const SizedBox(height: 12),
              _buildExpenseTrends(),
              const SizedBox(height: 20),
              const Text('Add Expenses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF526D96))),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _expenses.keys.length,
                itemBuilder: (context, index) => _buildExpenseButton(_expenses.keys.elementAt(index)),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: const Color(0xFF526D96),
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}