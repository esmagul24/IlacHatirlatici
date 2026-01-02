import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyMedsPage extends StatelessWidget {
  const MyMedsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıtlı İlaçlarım')),
      // StreamBuilder: Veritabanında bir değişiklik olduğunda sayfayı otomatik yeniler
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('medications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu!'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final meds = snapshot.data!.docs;

          if (meds.isEmpty) {
            return const Center(child: Text('Henüz ilaç eklenmemiş.'));
          }

          return ListView.builder(
            itemCount: meds.length,
            itemBuilder: (context, index) {
              final med = meds[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const Icon(Icons.medication, color: Colors.teal),
                  title: Text(med['name']),
                  subtitle: Text('Eklenme: ${med['createdAt']?.toDate().toString().substring(0, 16) ?? "Az önce"}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      // Silme işlemi
                      FirebaseFirestore.instance.collection('medications').doc(med.id).delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}