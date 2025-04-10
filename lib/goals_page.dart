import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final List<FinancialGoal> _goals = [];
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _currentAmountController = TextEditingController();
  DateTime? _targetDate;
  String _selectedPriority = 'Medium';
  String _selectedCategory = 'General';
  bool _notifyOnProgress = false;

  final List<String> _priorityOptions = ['Low', 'Medium', 'High'];
  final List<String> _categoryOptions = [
    'General',
    'Travel',
    'Education',
    'Home',
    'Vehicle',
    'Emergency Fund',
    'Retirement'
  ];

  static const String _baseUrl = "http://10.0.2.2:5000"; // Adjust based on your Flask server
  final String _userId = "user123"; // Replace with actual user ID after login

  @override
  void initState() {
    super.initState();
    _fetchGoals(); // Fetch goals when the page loads
  }

  Future<void> _fetchGoals() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/goals?user_id=$_userId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _goals.clear();
          _goals.addAll(data.map((goal) => FinancialGoal.fromJson(goal)).toList());
          _goals.sort((a, b) => a.targetDate.compareTo(b.targetDate));
        });
      } else {
        throw Exception('Failed to load goals: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch goals: $e')));
    }
  }

  Future<void> _addGoal(FinancialGoal goal) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/goals'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "userId": _userId,
          "title": goal.name,
          "targetAmount": goal.targetAmount,
          "currentAmount": goal.currentAmount,
          "deadline": goal.targetDate.toIso8601String(),
          "priority": goal.priority,
          "category": goal.category,
          "notifyOnProgress": goal.notifyOnProgress,
          "currency": "LKR",
        }),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        goal.id = data['goal_id']; // Set the ID from the server response
        setState(() {
          _goals.add(goal);
          _goals.sort((a, b) => a.targetDate.compareTo(b.targetDate));
        });
        _checkProgressNotification(goal);
      } else {
        throw Exception('Failed to add goal: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add goal: $e')));
    }
  }

  Future<void> _updateGoal(FinancialGoal goal) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/goals/${goal.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "title": goal.name,
          "targetAmount": goal.targetAmount,
          "currentAmount": goal.currentAmount,
          "deadline": goal.targetDate.toIso8601String(),
          "priority": goal.priority,
          "category": goal.category,
          "notifyOnProgress": goal.notifyOnProgress,
        }),
      );
      if (response.statusCode == 200) {
        setState(() {
          _goals.sort((a, b) => a.targetDate.compareTo(b.targetDate));
        });
        _checkProgressNotification(goal);
      } else {
        throw Exception('Failed to update goal: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update goal: $e')));
    }
  }

  Future<void> _deleteGoal(String goalId) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/goals/$goalId'));
      if (response.statusCode == 200) {
        setState(() {
          _goals.removeWhere((goal) => goal.id == goalId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal deleted successfully'), backgroundColor: Colors.red),
        );
      } else {
        throw Exception('Failed to delete goal: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete goal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Financial Goals', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4E7AC7),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddGoalDialog,
          ),
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: _sortGoals,
          ),
        ],
      ),
      body: _goals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/assets/goals.png', height: 50, width: 50),
                  const SizedBox(height: 20),
                  Text(
                    'No goals set yet!',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap the + button to add your first goal',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(top: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildGoalCard(_goals[index], index),
                      childCount: _goals.length,
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: _goals.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showSavingsSuggestion,
              backgroundColor: const Color(0xFF4E7AC7),
              child: const Icon(Icons.calculate),
            )
          : null,
    );
  }

  Widget _buildGoalCard(FinancialGoal goal, int index) {
    final progress = goal.currentAmount / goal.targetAmount;
    final daysRemaining = goal.targetDate.difference(DateTime.now()).inDays;
    final isCompleted = progress >= 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _viewGoalDetails(index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(_getCategoryIcon(goal.category), color: Colors.blueGrey, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              goal.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(goal.priority).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        goal.priority,
                        style: TextStyle(color: _getPriorityColor(goal.priority), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text(goal.category, style: TextStyle(color: Colors.blueGrey[600], fontSize: 14))),
                    if (isCompleted) const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Saved', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          Text('Rs.${goal.currentAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4E7AC7))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Target', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          Text('Rs.${goal.targetAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                    ),
                    Container(
                      height: 8,
                      width: MediaQuery.of(context).size.width * (progress > 1 ? 1 : progress),
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green : _getPriorityColor(goal.priority),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${(progress * 100).toStringAsFixed(1)}% completed', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('$daysRemaining days left',
                        style: TextStyle(
                            fontSize: 12,
                            color: daysRemaining < 30 ? Colors.red : Colors.grey,
                            fontWeight: daysRemaining < 30 ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _addToGoal(index),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[100],
                        foregroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey),
                          onPressed: () => _editGoal(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, size: 20, color: Colors.red[300]),
                          onPressed: () => _removeGoal(goal.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _viewGoalDetails(int index) {
    final goal = _goals[index];
    final progress = goal.currentAmount / goal.targetAmount;
    final daysRemaining = goal.targetDate.difference(DateTime.now()).inDays;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(_getCategoryIcon(goal.category), size: 28, color: Colors.blueGrey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(goal.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(goal.category, style: TextStyle(color: Colors.blueGrey[600], fontSize: 16)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress', style: TextStyle(color: Colors.blueGrey[600], fontSize: 16)),
                      Text('${(progress * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4E7AC7))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress > 1 ? 1 : progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(progress >= 1 ? Colors.green : _getPriorityColor(goal.priority)),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Saved', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                            Text('Rs.${goal.currentAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4E7AC7))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Target', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                            Text('Rs.${goal.targetAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Column(
                    children: [
                      const Icon(Icons.start, color: Colors.blueGrey, size: 20),
                      Text('Start', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                  Expanded(
                    child: Divider(color: Colors.blueGrey[200], thickness: 2),
                  ),
                  Column(
                    children: [
                      Icon(Icons.flag, color: _getPriorityColor(goal.priority), size: 20),
                      Text('Target', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildDetailItem(Icons.calendar_today, 'Target Date', DateFormat('MMM dd, yyyy').format(goal.targetDate)),
                _buildDetailItem(Icons.priority_high, 'Priority', goal.priority),
                _buildDetailItem(Icons.timelapse, 'Days Remaining', '$daysRemaining days'),
                _buildDetailItem(Icons.savings, 'Amount Left', 'Rs.${(goal.targetAmount - goal.currentAmount).toStringAsFixed(2)}'),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _editGoal(index),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF4E7AC7)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Edit Goal', style: TextStyle(color: Color(0xFF4E7AC7))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _addToGoal(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E7AC7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Add Money'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey[600]),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFE53E3E);
      case 'Medium':
        return const Color(0xFFDD6B20);
      case 'Low':
        return const Color(0xFF38A169);
      default:
        return const Color(0xFF4E7AC7);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Travel':
        return Icons.flight;
      case 'Education':
        return Icons.school;
      case 'Home':
        return Icons.home;
      case 'Vehicle':
        return Icons.directions_car;
      case 'Emergency Fund':
        return Icons.local_hospital;
      case 'Retirement':
        return Icons.hourglass_bottom;
      default:
        return Icons.savings;
    }
  }

  void _showAddGoalDialog() {
    _goalNameController.clear();
    _targetAmountController.clear();
    _currentAmountController.clear();
    _targetDate = DateTime.now().add(const Duration(days: 30));
    _selectedPriority = 'Medium';
    _selectedCategory = 'General';
    _notifyOnProgress = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Add New Goal',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
              const SizedBox(height: 20),
              TextField(
                controller: _goalNameController,
                decoration: InputDecoration(
                  labelText: 'Goal Name',
                  hintText: 'e.g. Europe Trip, New Car',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _targetAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target Amount (Rs.)',
                  hintText: 'e.g. 500000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixText: 'Rs. ',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _currentAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Current Amount (Rs.)',
                  hintText: 'e.g. 10000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixText: 'Rs. ',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categoryOptions.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                items: _priorityOptions.map((priority) {
                  return DropdownMenuItem(value: priority, child: Text(priority));
                }).toList(),
                onChanged: (value) => setState(() => _selectedPriority = value!),
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (selectedDate != null) setState(() => _targetDate = selectedDate);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blueGrey),
                      const SizedBox(width: 16),
                      Text(
                        _targetDate == null
                            ? 'Select Target Date'
                            : 'Target Date: ${DateFormat('MMM dd, yyyy').format(_targetDate!)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Notify on Progress', style: TextStyle(fontSize: 16)),
                subtitle: const Text('Get notified at 25%, 50%, 75%, and 100%'),
                value: _notifyOnProgress,
                onChanged: (value) => setState(() => _notifyOnProgress = value),
                activeColor: const Color(0xFF4E7AC7),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E7AC7),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Goal', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
              Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
            ],
          ),
        ),
      ),
    );
  }

  void _saveGoal() async {
    if (_goalNameController.text.isEmpty || _targetAmountController.text.isEmpty || _targetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: Colors.red),
      );
      return;
    }

    final currentAmount = _currentAmountController.text.isEmpty ? 0 : double.parse(_currentAmountController.text);

    final newGoal = FinancialGoal(
      id: '', // ID will be set by the server
      name: _goalNameController.text,
      targetAmount: double.parse(_targetAmountController.text),
      currentAmount: currentAmount.toDouble(),
      targetDate: _targetDate!,
      priority: _selectedPriority,
      category: _selectedCategory,
      notifyOnProgress: _notifyOnProgress,
    );

    await _addGoal(newGoal);
    Navigator.pop(context);
  }

  void _editGoal(int index) {
    final goal = _goals[index];
    _goalNameController.text = goal.name;
    _targetAmountController.text = goal.targetAmount.toString();
    _currentAmountController.text = goal.currentAmount.toString();
    _targetDate = goal.targetDate;
    _selectedPriority = goal.priority;
    _selectedCategory = goal.category;
    _notifyOnProgress = goal.notifyOnProgress;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Edit Goal',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
              const SizedBox(height: 20),
              TextField(
                controller: _goalNameController,
                decoration: InputDecoration(
                  labelText: 'Goal Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _targetAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target Amount (Rs.)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixText: 'Rs. ',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _currentAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Current Amount (Rs.)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixText: 'Rs. ',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categoryOptions.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                items: _priorityOptions.map((priority) => DropdownMenuItem(value: priority, child: Text(priority))).toList(),
                onChanged: (value) => setState(() => _selectedPriority = value!),
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _targetDate!,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (selectedDate != null) setState(() => _targetDate = selectedDate);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blueGrey),
                      const SizedBox(width: 16),
                      Text('Target Date: ${DateFormat('MMM dd, yyyy').format(_targetDate!)}',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Notify on Progress', style: TextStyle(fontSize: 16)),
                subtitle: const Text('Get notified at 25%, 50%, 75%, and 100%'),
                value: _notifyOnProgress,
                onChanged: (value) => setState(() => _notifyOnProgress = value),
                activeColor: const Color(0xFF4E7AC7),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        _updateGoalAtIndex(index);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4E7AC7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Update'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToGoal(int index) async {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add to "${_goals[index].name}"'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount to Add (Rs.)',
                border: OutlineInputBorder(),
                prefixText: 'Rs. ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amountToAdd = double.tryParse(amountController.text) ?? 0;
              if (amountToAdd > 0) {
                setState(() {
                  _goals[index].currentAmount += amountToAdd;
                });
                await _updateGoal(_goals[index]);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added Rs.${amountToAdd.toStringAsFixed(2)} to your goal'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4E7AC7)),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _updateGoalAtIndex(int index) async {
    final currentAmount = _currentAmountController.text.isEmpty
        ? _goals[index].currentAmount
        : double.parse(_currentAmountController.text);

    _goals[index] = FinancialGoal(
      id: _goals[index].id,
      name: _goalNameController.text,
      targetAmount: double.parse(_targetAmountController.text),
      currentAmount: currentAmount,
      targetDate: _targetDate!,
      priority: _selectedPriority,
      category: _selectedCategory,
      notifyOnProgress: _notifyOnProgress,
    );

    await _updateGoal(_goals[index]);
  }

  void _removeGoal(String goalId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${_goals.firstWhere((g) => g.id == goalId).name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.grey[700]))),
          ElevatedButton(
            onPressed: () async {
              await _deleteGoal(goalId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _sortGoals() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Sort by Target Date'),
              onTap: () {
                setState(() => _goals.sort((a, b) => a.targetDate.compareTo(b.targetDate)));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.priority_high),
              title: const Text('Sort by Priority'),
              onTap: () {
                setState(() => _goals.sort((a, b) => _priorityOptions.indexOf(b.priority).compareTo(_priorityOptions.indexOf(a.priority))));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Sort by Progress'),
              onTap: () {
                setState(() => _goals.sort((a, b) => (b.currentAmount / b.targetAmount).compareTo(a.currentAmount / a.targetAmount)));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSavingsSuggestion() {
    final totalRemaining = _goals.fold(0.0, (sum, goal) => sum + (goal.targetAmount - goal.currentAmount));
    final daysLeft = _goals.map((goal) => goal.targetDate.difference(DateTime.now()).inDays).reduce((a, b) => a > b ? a : b);
    final monthlySavings = totalRemaining / (daysLeft / 30);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Savings Suggestion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To achieve all your goals:'),
            const SizedBox(height: 16),
            Text('Total Remaining: Rs.${totalRemaining.toStringAsFixed(2)}'),
            Text('Max Days Left: $daysLeft days'),
            const SizedBox(height: 8),
            Text('Suggested Monthly Savings:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Rs.${monthlySavings.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Color(0xFF4E7AC7))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _checkProgressNotification(FinancialGoal goal) {
    if (!goal.notifyOnProgress) return;
    final progress = goal.currentAmount / goal.targetAmount * 100;
    final milestones = [25.0, 50.0, 75.0, 100.0];
    for (var milestone in milestones) {
      if (progress >= milestone && progress < milestone + 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Congratulations! "${goal.name}" has reached ${milestone.toStringAsFixed(0)}%'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

class FinancialGoal {
  String id; // Added to match MongoDB _id
  String name;
  double targetAmount;
  double currentAmount;
  DateTime targetDate;
  String priority;
  String category;
  bool notifyOnProgress;

  FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.priority,
    required this.category,
    this.notifyOnProgress = false,
  });

  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id: json['_id'],
      name: json['title'],
      targetAmount: json['targetAmount'].toDouble(),
      currentAmount: json['currentAmount'].toDouble(),
      targetDate: DateTime.parse(json['deadline']),
      priority: json['priority'] ?? 'Medium',
      category: json['category'] ?? 'General',
      notifyOnProgress: json['notifyOnProgress'] ?? false,
    );
  }
}