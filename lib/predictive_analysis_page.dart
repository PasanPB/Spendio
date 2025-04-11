import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart'; // For animations

class PredictiveAnalysisPage extends StatefulWidget {
  const PredictiveAnalysisPage({super.key});

  @override
  State<PredictiveAnalysisPage> createState() => _PredictiveAnalysisPageState();
}

class _PredictiveAnalysisPageState extends State<PredictiveAnalysisPage> {
  static const String _baseUrl = "http://10.0.2.2:5000"; // Consistent with DashboardPage
  final String _userId = "user123"; // Replace with actual user ID from auth
  Map<String, Map<String, double>> _predictions = {};
  Map<String, String> _suggestions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPredictiveAnalysis();
  }

  Future<void> _fetchPredictiveAnalysis() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/predictive-analysis?user_id=$_userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _predictions = Map<String, Map<String, double>>.from(
            data['predictions'].map((k, v) => MapEntry(k, Map<String, double>.from(v))),
          );
          _suggestions = Map<String, String>.from(data['suggestions']);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load predictive analysis: ${response.body}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predictive Analysis', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF526D96),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF526D96), Color(0xFFEF9587)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F6F6), Color(0xFFEFEFEF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFEF9587)))
            : _predictions.isEmpty
                ? Center(
                    child: FadeIn(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.analytics, size: 50, color: Color(0xFF526D96)),
                          const SizedBox(height: 20),
                          Text(
                            'No spending data available!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Add transactions to see predictions',
                            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInDown(
                          child: const Text(
                            'Spending Predictions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF526D96),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._predictions.entries.map((entry) => _buildPredictionCard(entry.key, entry.value)).toList(),
                        const SizedBox(height: 20),
                        FadeInDown(
                          child: const Text(
                            'Savings Suggestions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF526D96),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._suggestions.entries.map((entry) => _buildSuggestionCard(entry.key, entry.value)).toList(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildPredictionCard(String category, Map<String, double> predictions) {
    return FadeInUp(
      delay: Duration(milliseconds: _predictions.keys.toList().indexOf(category) * 100),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF6F6F6), Color(0xFFEFEFEF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getCategoryIcon(category), color: const Color(0xFF526D96), size: 24),
                const SizedBox(width: 12),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF526D96),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPredictionRow('Next Week', predictions['next_week']!),
            _buildPredictionRow('Next Month', predictions['next_month']!),
            _buildPredictionRow('Next Year', predictions['next_year']!),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionRow(String period, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(period, style: const TextStyle(fontSize: 16, color: Color(0xFF526D96))),
          Text(
            'Rs. ${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEF9587),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String category, String suggestion) {
    return FadeInUp(
      delay: Duration(milliseconds: (_suggestions.keys.toList().indexOf(category) + _predictions.length) * 100),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF6F6F6), Color(0xFFEFEFEF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: ListTile(
          leading: Icon(_getCategoryIcon(category), color: const Color(0xFF526D96)),
          title: Text(
            category,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF526D96),
            ),
          ),
          subtitle: Text(
            suggestion,
            style: const TextStyle(color: Color(0xFF526D96)),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.fastfood;
      case 'transport':
        return Icons.directions_car;
      case 'groceries':
        return Icons.local_grocery_store;
      case 'clothes':
        return Icons.checkroom;
      case 'rent':
        return Icons.house;
      case 'other':
        return Icons.account_tree;
      default:
        return Icons.category;
    }
  }
}