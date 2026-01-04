import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'new_med_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'İlaç Rehberi: Kontrol & Takip',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hoş Geldiniz Paneli
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hoş Geldiniz 👋',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  'Bugünkü ilaç programınız aşağıdadır.',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(left: 20, top: 20, bottom: 10),
            child: Text(
              "Günlük Doz Takibi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // İlaç Listesi
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('medications')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // 1. Hata Kontrolü
                if (snapshot.hasError) {
                  return const Center(child: Text('Veriler yüklenirken bir hata oluştu.'));
                }

                // 2. Yüklenme Durumu
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 3. Veri Boş mu Kontrolü
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Henüz ilaç eklemediniz.'));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    
                    // Güvenli veri çekme (Null Safety)
                    final bool isTaken = data['isTaken'] ?? false;
                    final String name = data['name'] ?? 'İsimsiz İlaç';
                    final String dosage = data['dosage'] ?? 'Doz belirtilmedi';
                    
                    // KRİTİK DÜZELTME: 'times' alanı null ise boş liste kabul et
                    final List timesList = (data['times'] != null && data['times'] is List) 
                                          ? (data['times'] as List) 
                                          : [];
                    final String timesString = timesList.isNotEmpty ? timesList.join(', ') : 'Saat belirtilmedi';

                    return Card(
                      elevation: isTaken ? 1 : 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: isTaken ? Colors.green.shade50 : Colors.white,
                      child: ListTile(
                        leading: Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            value: isTaken,
                            activeColor: Colors.green,
                            shape: const CircleBorder(),
                            onChanged: (bool? value) {
                              FirebaseFirestore.instance
                                  .collection('medications')
                                  .doc(docId)
                                  .update({'isTaken': value});
                            },
                          ),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: isTaken ? TextDecoration.lineThrough : null,
                            color: isTaken ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          "Doz: $dosage\nSaatler: $timesString",
                          style: TextStyle(color: isTaken ? Colors.grey : Colors.black87),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(context, docId),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewMedPage()),
        ),
        label: const Text('İlaç Ekle'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlacı Sil?'),
        content: const Text('Bu ilacı listeden tamamen kaldırmak istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('medications').doc(id).delete();
              Navigator.pop(context);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
