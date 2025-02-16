import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // For pie chart

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2), // Light gray background for contrast
      appBar: AppBar(
        title: Text('Dashboard'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF405DE6),
                Color(0xFF5851DB),
                Color(0xFF833AB4),
                Color(0xFFC13584),
                Color(0xFFE1306C),
                Color(0xFFFD1D1D),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0, // Flat design
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333), // Dark text for contrast
              ),
            ),
            SizedBox(height: 16),

            // Pie Chart for Expense Visualization
            _buildPieChart(),
            SizedBox(height: 16),

            // GridView for Expense Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildExpenseCard('Food', 'Rs. 5,000', Icons.fastfood),
                  _buildExpenseCard('Transport', 'Rs. 3,000', Icons.directions_car),
                  _buildExpenseCard('Groceries', 'Rs. 7,500', Icons.shopping_cart),
                  _buildExpenseCard('Clothes', 'Rs. 2,000', Icons.checkroom),
                  _buildExpenseCard('Rent', 'Rs. 15,000', Icons.home),
                  _buildExpenseCard('Other', 'Rs. 4,500', Icons.more_horiz),
                ],
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button for Adding Expenses
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Expense Page
        },
        backgroundColor: Color(0xFF405DE6),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Pie Chart Widget
  Widget _buildPieChart() {
    return Container(
      height: 200, // Adjusted height for better visibility
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: 25, // Food
              color: Color(0xFF405DE6),
              title: '25%', // Percentage for Food
              radius: 60, // Adjusted radius
              titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: 15, // Transport
              color: Color(0xFF833AB4),
              title: '15%', // Percentage for Transport
              radius: 60, // Adjusted radius
              titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: 35, // Groceries
              color: Color(0xFFE1306C),
              title: '35%', // Percentage for Groceries
              radius: 60, // Adjusted radius
              titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: 25, // Other
              color: Color(0xFFFD1D1D),
              title: '25%', // Percentage for Other
              radius: 60, // Adjusted radius
              titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          centerSpaceRadius: 40, // Space in the center
          sectionsSpace: 2, // Space between sections
        ),
      ),
    );
  }

  // Expense Card Widget
  Widget _buildExpenseCard(String category, String amount, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF405DE6),
              Color(0xFF5851DB),
              Color(0xFF833AB4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              SizedBox(height: 8),
              Text(
                category,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 4),
              Text(
                amount,
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}