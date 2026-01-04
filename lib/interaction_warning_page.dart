import 'package:flutter/material.dart';

class InteractionWarningPage extends StatelessWidget {
  final String medA;
  final String medB;
  final VoidCallback onConfirm;

  const InteractionWarningPage({
    super.key, 
    required this.medA, 
    required this.medB, 
    required this.onConfirm
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('⚠️ Kritik Risk'), backgroundColor: Colors.red),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_outlined, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            const Text('Dikkat: Etkileşim Tespit Edildi!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Text('"$medA" ve "$medB" birlikte kullanımı sağlığınız için riskli olabilir.', style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç'))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () { 
                    onConfirm(); // Firebase'e kaydı yapar
                    Navigator.pop(context); // Uyarı ekranını kapatır
                  }, 
                  child: const Text('Yine de Ekle', style: TextStyle(color: Colors.white)))
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
