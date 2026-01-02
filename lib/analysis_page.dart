import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  Future<List<String>> checkAllInteractions(List<String> rxcuis) async {
    if (rxcuis.length < 2) return [];
    
    final allIds = rxcuis.join('+');
    final url = Uri.parse('https://rxnav.nlm.nih.gov/REST/interaction/list.json?rxcuis=$allIds');
    
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<String> warnings = [];
      
      var interactionGroups = data['fullInteractionTypeGroup'];
      if (interactionGroups != null) {
        for (var group in interactionGroups) {
          for (var type in group['fullInteractionType']) {
            warnings.add(type['interactionPair'][0]['description']);
          }
        }
      }
      return warnings;
    }
    return [];
  }

  @override 
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(title: const Text('İlaç Etkileşim Analizi')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('medications').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          final rxcuis = docs
              .map((d) => (d.data() as Map<String, dynamic>)['rxcui']?.toString() ?? '')
              .where((id) => id.isNotEmpty && id != 'Bulunamadı')
              .toList();

          return FutureBuilder<List<String>>(
            future: checkAllInteractions(rxcuis),
            builder: (context, interactionSnapshot) {
              if (interactionSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text("Analiz ediliyor..."));
              }

              final warnings = interactionSnapshot.data ?? [];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryCard(docs.length, warnings.length),
                  const SizedBox(height: 20),
                  if (warnings.isEmpty)
                    const Center(child: Text("Güvenli: Mevcut ilaçlarınız arasında etkileşim bulunmadı."))
                  else
                    ...warnings.map((w) => Card(
                      color: Colors.red.shade50,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(Icons.warning, color: Colors.red),
                        title: Text(w, style: const TextStyle(fontSize: 13)),
                      ),
                    )),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(int medCount, int warningCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: warningCount > 0 ? Colors.orange.withOpacity(0.1) : Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text("Toplam İlaç: $medCount", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("Tespit Edilen Risk: $warningCount", style: TextStyle(color: warningCount > 0 ? Colors.red : Colors.teal)),
        ],
      ),
    );
  }
}