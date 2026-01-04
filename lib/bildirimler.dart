import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  // Basit bildirimler listesi (Örnek veriler)
  final List<Map<String, dynamic>> recentNotifications = const [ 
    {'title': 'İlaç A alım saati yaklaşıyor.', 'time': '2 dakika önce', 'icon': Icons.alarm_on},
    {'title': 'İlaç B dozu kaçırıldı.', 'time': '1 saat önce', 'icon': Icons.warning_amber, 'color': Colors.red},
    {'title': 'Yeni ilaç başarıyla eklendi.', 'time': 'Bugün, 14:30', 'icon': Icons.check_circle_outline},
    {'title': 'Etkileşim Riski: İlaç C ve D', 'time': 'Dün', 'icon': Icons.dangerous, 'color': Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        itemCount: recentNotifications.length,
        itemBuilder: (context, index) {
          final item = recentNotifications[index];
          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              leading: Icon(
                item['icon'] as IconData,
                color: (item['color'] as Color?) ?? Colors.teal,
              ),
              title: Text(item['title'] as String),
              subtitle: Text(item['time'] as String),
              onTap: () {
                // Bildirim detaylarına gitme aksiyonu
              },
            ),
          );
        },
      ),
    );
  }
}
