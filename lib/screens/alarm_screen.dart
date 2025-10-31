// // lib/screens/alarm_screen.dart
// import 'package:flutter/material.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class AlarmScreen extends StatefulWidget {
//   final String title;
//   final String body;
//   final int notificationId;

//   const AlarmScreen({
//     Key? key,
//     required this.title,
//     required this.body,
//     required this.notificationId,
//   }) : super(key: key);

//   @override
//   State<AlarmScreen> createState() => _AlarmScreenState();
// }

// class _AlarmScreenState extends State<AlarmScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _pulseAnimation;

//   @override
//   void initState() {
//     super.initState();
    
//     // AKTIFKAN WAKELOCK - Layar tetap nyala
//     WakelockPlus.enable();
    
//     // Animasi pulse untuk tombol
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 1),
//     )..repeat(reverse: true);
    
//     _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     // MATIKAN WAKELOCK
//     WakelockPlus.disable();
//     super.dispose();
//   }

//   Future<void> _dismissAlarm() async {
//     // Cancel notifikasi
//     final FlutterLocalNotificationsPlugin notificationsPlugin =
//         FlutterLocalNotificationsPlugin();
//     await notificationsPlugin.cancel(widget.notificationId);
    
//     // Tutup halaman
//     if (mounted) {
//       Navigator.of(context).pop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       // Cegah back button
//       onWillPop: () async => false,
//       child: Scaffold(
//         backgroundColor: Colors.red.shade900,
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Icon Alarm
//                 ScaleTransition(
//                   scale: _pulseAnimation,
//                   child: Container(
//                     width: 120,
//                     height: 120,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.notifications_active,
//                       size: 80,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 40),
                
//                 // Title
//                 Text(
//                   widget.title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
                
//                 const SizedBox(height: 16),
                
//                 // Body Message
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(0.3),
//                       width: 2,
//                     ),
//                   ),
//                   child: Text(
//                     widget.body,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       height: 1.5,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
                
//                 const SizedBox(height: 60),
                
//                 // Tombol Matikan Alarm
//                 ScaleTransition(
//                   scale: _pulseAnimation,
//                   child: ElevatedButton(
//                     onPressed: _dismissAlarm,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.red.shade900,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 48,
//                         vertical: 20,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       elevation: 8,
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: const [
//                         Icon(Icons.alarm_off, size: 28),
//                         SizedBox(width: 12),
//                         Text(
//                           'MATIKAN ALARM',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 24),
                
//                 // Info text
//                 Text(
//                   'Tekan tombol di atas untuk mematikan alarm',
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.7),
//                     fontSize: 14,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }