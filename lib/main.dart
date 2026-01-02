import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'notification_service.dart';
import 'home_page.dart';        
import 'analysis_page.dart';    
import 'my_meds_page.dart';     
import 'calendar_page.dart';    
import 'history_page.dart';


// ----------------------------------------------------------------------
// UYGULAMA BAŞLANGIÇ NOKTASI
// ---------------------------------------------------------------------- 
// Soft Turkuaz Rengi (0xFF4DB6AC)
const Color primaryAppColor = Color(0xFF4DB6AC);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Firebase ve Saat Dilimi Başlatma
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();

  // 2. Bildirim Ayarları
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // 3. Android 13+ için Bildirim İzni İste
  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'İlaç Rehberim',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      
      // Uygulamanın başlangıç ekranı (Daha önce oluşturduğumuz navigasyonlu ekran)
      home: AppScreen(), 
    );
  }
}

// ----------------------------------------------------------------------
// ANA NAVİGASYON EKRANI (APP SCREEN) 
// ----------------------------------------------------------------------

class AppScreen extends StatefulWidget {
  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  int _selectedIndex = 0;

  // Hata veren kısım: Şimdi yukarıda veya aşağıda tanımlandıkları için
  // artık uyarı vermeyecekler.
  final List<Widget> _widgetOptions = <Widget>[
    HomePage(),     // 1. Ana Sayfa/Rehber
    AnalysisPage(), // 2. Analiz
    MyMedsPage(),   // 3. İlaçlarım
    CalendarPage(), // 4. Takvim
    HistoryPage(),  // 5. Geçmiş
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analiz'),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'İlaçlarım'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Takvim'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Geçmiş'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ----------------------------------------------------------------------
// BURAYA TÜM SAYFA SINIFLARININ TANIMLARI GELECEK
// ----------------------------------------------------------------------
// HomePage, AnalysisPage, MyMedsPage, CalendarPage, HistoryPage sınıflarının
// yukarıdaki veya ayrı dosyalardaki (import edilerek) tanımları burada olmalıdır.