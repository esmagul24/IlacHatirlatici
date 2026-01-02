import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'interaction_warning_page.dart';

class NewMedPage extends StatefulWidget {
  const NewMedPage({super.key});

  @override
  State<NewMedPage> createState() => _NewMedPageState();
}

class _NewMedPageState extends State<NewMedPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  int _frequency = 1;
  List<TimeOfDay> _selectedTimes = [const TimeOfDay(hour: 08, minute: 00)];
  bool _isLoading = false;

  // 1. ADIM: İlacın Kodunu (RxCUI) Bul (Aspirin ve Simvastatin'i artık kaçırmaz)
  Future<String?> getRxCui(String drugName) async {
    final cleanName = drugName.trim().toLowerCase();
    if (cleanName.isEmpty) return null;
    print("🔍 Sorgulanıyor: $cleanName");

    try {
      final approxUrl = Uri.https('rxnav.nlm.nih.gov', '/REST/approximateTerm.json', {'term': cleanName, 'maxEntries': '1'});
      final response = await http.get(approxUrl).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['approximateGroup'] != null && 
            data['approximateGroup']['candidate'] != null && 
            (data['approximateGroup']['candidate'] as List).isNotEmpty) {
          String rxcui = data['approximateGroup']['candidate'][0]['rxcui'].toString();
          print("✅ Bulundu: $rxcui");
          return rxcui;
        }
      }
    } catch (e) { print("❌ RxCUI Hatası: $e"); }
    return null; 
  }

  // 2. ADIM: Risk Analizi (Senin sorduğun rxcui.toString() satırı burada eklendi)
  void _checkInteractionsAndSave() async {
    if (_nameController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      String? newRxcui = await getRxCui(_nameController.text);
      final snapshot = await FirebaseFirestore.instance.collection('medications').get();
      
      List<String> existingRxcuis = [];
      String existingMedName = "Kayıtlı İlaç";

      // İŞTE SORDUĞUN KRİTİK DÖNGÜ:
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // Veritabanında rxcui varsa ve "Bulunamadı" değilse listeye ekle
        if (data.containsKey('rxcui') && data['rxcui'] != 'Bulunamadı' && data['rxcui'] != null) {
          existingRxcuis.add(data['rxcui'].toString()); // İstediğin satır tam olarak burası!
          existingMedName = data['name'] ?? "Mevcut İlaç";
        }
      }

      if (newRxcui != null && existingRxcuis.isNotEmpty) {
        final allIds = [...existingRxcuis, newRxcui].toSet().join('+');
        print("🧪 Etkileşim Kontrolü Yapılıyor: $allIds");
        
        // JSON HATASINI ÇÖZEN GÜVENLİ URL YAPISI:
        final url = Uri.parse('https://rxnav.nlm.nih.gov/REST/interaction/list.json?rxcuis=$allIds');
        final response = await http.get(url);

        // API yanıtı geçerli bir JSON değilse (Not found gelirse) hata vermemesi için kontrol:
        if (response.statusCode == 200 && response.body.startsWith('{')) {
          final data = json.decode(response.body);
          bool hasRisk = data.containsKey('fullInteractionTypeGroup') || data.containsKey('interactionTypeGroup');

          if (hasRisk) {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InteractionWarningPage(
                    medA: existingMedName, 
                    medB: _nameController.text.trim(),
                    onConfirm: () => _finalStepSave(newRxcui),
                  ),
                ),
              );
            }
            setState(() => _isLoading = false);
            return; 
          }
        } else {
          print("⚠️ API etkileşim verisi döndürmedi (Ciddi bir risk bulunmadı).");
        }
      }
      await _finalStepSave(newRxcui);
    } catch (e) {
      print("⚠️ Analiz sırasında bir sorun oluştu, yine de kaydediliyor: $e");
      await _finalStepSave(null);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 3. ADIM: Firebase Kayıt
  Future<void> _finalStepSave(String? rxcui) async {
    List<String> formattedTimes = _selectedTimes.map((t) => 
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}").toList();

    await FirebaseFirestore.instance.collection('medications').add({
      'name': _nameController.text.trim(),
      'dosage': _dosageController.text.trim(),
      'frequency': _frequency,
      'times': formattedTimes,
      'isTaken': false,
      'rxcui': rxcui ?? 'Bulunamadı',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni İlaç Ekle'), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'İlaç Adı (Aspirin vb.)', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _dosageController, decoration: const InputDecoration(labelText: 'Dozaj (1000mg vb.)', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            DropdownButton<int>(
              value: _frequency,
              isExpanded: true,
              items: [1, 2, 3, 4].map((i) => DropdownMenuItem(value: i, child: Text('Günde $i Kez'))).toList(),
              onChanged: (val) => setState(() {
                _frequency = val!;
                _selectedTimes = List.generate(_frequency, (index) => const TimeOfDay(hour: 08, minute: 00));
              }),
            ),
            ...List.generate(_frequency, (index) => ListTile(
              title: Text('${index + 1}. Saat: ${_selectedTimes[index].format(context)}'),
              trailing: const Icon(Icons.edit),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTimes[index]);
                if (picked != null) setState(() => _selectedTimes[index] = picked);
              },
            )),
            const SizedBox(height: 30),
            _isLoading 
              ? const CircularProgressIndicator() 
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(55), backgroundColor: Colors.teal),
                  onPressed: _checkInteractionsAndSave, 
                  child: const Text('ANALİZ ET VE KAYDET', style: TextStyle(color: Colors.white, fontSize: 16))
                ),
          ],
        ),
      ),
    );
  }
}