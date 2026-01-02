import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Colors.teal, // Uygulama rengi
      ),
      body: ListView(
        children: <Widget>[
          _buildSettingsCategory('Hatırlatma Ayarları', [
            _buildSettingsTile('Varsayılan Alarm Sesi', 'Klasik Zil', Icons.music_note, isSwitch: false),
            _buildSettingsTile('Titreşim Aç/Kapa', null, Icons.vibration, isSwitch: true),
            _buildSettingsTile('Alarm Erteleme Süresi', '10 dakika', Icons.timer, isSwitch: false),
          ]),
          _buildSettingsCategory('Genel Ayarlar', [
            _buildSettingsTile('Dil Seçimi', 'Türkçe', Icons.language, isSwitch: false),
            _buildSettingsTile('Verileri Yedekle', null, Icons.cloud_upload, isSwitch: false),
          ]),
          _buildSettingsCategory('Hakkında', [
            _buildSettingsTile('Gizlilik Politikası', null, Icons.security, isSwitch: false),
            _buildSettingsTile('Uygulama Sürümü', '1.0.0', Icons.info_outline, isSwitch: false),
          ]),
        ],
      ),
    );
  }

  // Ayar başlıklarını oluşturan yardımcı fonksiyon
  Widget _buildSettingsCategory(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }

  // Ayar satırlarını oluşturan yardımcı fonksiyon
  Widget _buildSettingsTile(String title, String? subtitle, IconData icon, {required bool isSwitch}) {
    // Burada Stateful widget kullanarak isSwitch'in değerini yönetmeniz gerekir.
    // Şimdilik varsayılan değerler kullanılmıştır.
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: isSwitch
          ? Switch(value: true, onChanged: (bool value) {/* Durum yönetimi burada yapılır */})
          : const Icon(Icons.chevron_right),
      onTap: () {
        // Tıklama aksiyonu
      },
    );
  }
}