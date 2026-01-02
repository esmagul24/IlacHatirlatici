import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  // Geçmiş verisi (Örnek veriler)
  final List<Map<String, dynamic>> medicationHistory = const [
    {'name': 'İlaç A', 'time': 'Dün, 22:00', 'status': 'Alındı', 'color': Colors.green},
    {'name': 'İlaç B', 'time': 'Dün, 18:00', 'status': 'Atlandı', 'color': Colors.red},
    {'name': 'İlaç A', 'time': 'Dün, 10:00', 'status': 'Alındı', 'color': Colors.green},
    {'name': 'İlaç C', 'time': 'Önceki Gün, 08:00', 'status': 'Alındı', 'color': Colors.green},
    {'name': 'İlaç D', 'time': 'Önceki Gün, 08:00', 'status': 'Atlandı', 'color': Colors.red},
    {'name': 'İlaç E', 'time': '2 Gün Önce, 23:00', 'status': 'Alındı', 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        itemCount: medicationHistory.length,
        itemBuilder: (context, index) {
          final item = medicationHistory[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: ListTile(
              leading: Icon(
                item['status'] == 'Alındı' ? Icons.check_circle : Icons.close,
                color: item['color'] as Color,
                size: 30,
              ),
              title: Text(
                item['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(item['time'] as String),
              trailing: Text(
                item['status'] as String,
                style: TextStyle(
                  color: item['color'] as Color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}