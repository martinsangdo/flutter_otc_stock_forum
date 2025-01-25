import 'package:flutter/material.dart';

class StockCard extends StatelessWidget {
  final String ticker;
  final String price;
  final String changePercentage;
  final bool isPositive;

  const StockCard({
    super.key,
    required this.ticker,
    required this.price,
    required this.changePercentage,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ticker,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,color: Colors.black
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14, 
              color: Colors.black
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                changePercentage,
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}