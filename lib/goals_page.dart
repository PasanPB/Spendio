import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final List<FinancialGoal> _goals = [];
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  DateTime? _targetDate;
  String _selectedPriority = 'Medium';
  String _selectedCategory = 'General';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Goals'),
        backgroundColor: Color(0xFF526D96), // Matching your theme
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddGoalDialog,
          ),
        ],
      ),
      body: _goals.isEmpty
          ? Center(
              child: Text(
                'No goals set yet!\nTap the + button to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                return _buildGoalCard(goal, index);
              },
            ),
    );
  }

  Widget _buildGoalCard(FinancialGoal goal, int index) {
    final progress = goal.currentAmount / goal.targetAmount;
    final daysRemaining = goal.targetDate.difference(DateTime.now()).inDays;
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  goal.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF526D96),
                  ),
                ),
                Chip(
                  label: Text(goal.priority),
                  backgroundColor: _getPriorityColor(goal.priority),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Target: Rs.${goal.targetAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Target Date: ${DateFormat('MMM dd, yyyy').format(goal.targetDate)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Progress: Rs.${goal.currentAmount.toStringAsFixed(2)} of Rs.${goal.targetAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress > 1 ? 1 : progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getPriorityColor(goal.priority)),
            ),
            SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(1)}% completed • $daysRemaining days remaining',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editGoal(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteGoal(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red[400]!;
      case 'Medium':
        return Colors.orange[400]!;
      case 'Low':
        return Colors.green[400]!;
      default:
        return Colors.blue[400]!;
    }
  }

  void _showAddGoalDialog() {
    _goalNameController.clear();
    _targetAmountController.clear();
    _targetDate = DateTime.now().add(Duration(days: 30)); // Default 30 days from now
    _selectedPriority = 'Medium';
    _selectedCategory = 'General';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Financial Goal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _goalNameController,
                decoration: InputDecoration(
                  labelText: 'Goal Name',
                  hintText: 'e.g. Europe Trip, New Car',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _targetAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target Amount (Rs.)',
                  hintText: 'e.g. 500000',
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categoryOptions.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                items: _priorityOptions.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Priority',
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text(
                  _targetDate == null
                      ? 'Select Target Date'
                      : 'Target Date: ${DateFormat('MMM dd, yyyy').format(_targetDate!)}',
                ),
                trailing: Icon(Icons.arrow_drop_down),
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _targetDate ?? DateTime.now().add(Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365 * 5)), // 5 years in future
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _targetDate = selectedDate;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveGoal,
            child: Text('Save Goal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF526D96),
            ),
          ),
        ],
      ),
    );
  }

  void _saveGoal() {
    if (_goalNameController.text.isEmpty ||
        _targetAmountController.text.isEmpty ||
        _targetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final newGoal = FinancialGoal(
      name: _goalNameController.text,
      targetAmount: double.parse(_targetAmountController.text),
      currentAmount: 0, // Start with 0
      targetDate: _targetDate!,
      priority: _selectedPriority,
      category: _selectedCategory,
    );

    setState(() {
      _goals.add(newGoal);
    });

    Navigator.pop(context);
  }

  void _editGoal(int index) {
    final goal = _goals[index];
    _goalNameController.text = goal.name;
    _targetAmountController.text = goal.targetAmount.toString();
    _targetDate = goal.targetDate;
    _selectedPriority = goal.priority;
    _selectedCategory = goal.category;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Goal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _goalNameController,
                decoration: InputDecoration(labelText: 'Goal Name'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _targetAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Target Amount (Rs.)'),
              ),
              SizedBox(height: 16),
              Text('Current Amount: Rs.${goal.currentAmount.toStringAsFixed(2)}'),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categoryOptions.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Category'),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                items: _priorityOptions.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Priority'),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text(
                  'Target Date: ${DateFormat('MMM dd, yyyy').format(_targetDate!)}',
                ),
                trailing: Icon(Icons.arrow_drop_down),
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _targetDate!,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365 * 5)),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _targetDate = selectedDate;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateGoal(index);
              Navigator.pop(context);
            },
            child: Text('Update'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF526D96),
            ),
          ),
        ],
      ),
    );
  }

  void _updateGoal(int index) {
    setState(() {
      _goals[index] = FinancialGoal(
        name: _goalNameController.text,
        targetAmount: double.parse(_targetAmountController.text),
        currentAmount: _goals[index].currentAmount,
        targetDate: _targetDate!,
        priority: _selectedPriority,
        category: _selectedCategory,
      );
    });
  }

  void _deleteGoal(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Goal'),
        content: Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _goals.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialGoal {
  final String name;
  final double targetAmount;
  double currentAmount;
  final DateTime targetDate;
  final String priority;
  final String category;

  FinancialGoal({
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.priority,
    required this.category,
  });
}