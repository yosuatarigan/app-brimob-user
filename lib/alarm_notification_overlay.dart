// // lib/widgets/alarm_notification_overlay.dart
// import 'package:flutter/material.dart';
// import 'dart:math' as math;

// class AlarmNotificationOverlay extends StatefulWidget {
//   final String title;
//   final String message;
//   final VoidCallback? onDismiss;
//   final Duration autoCloseDuration;

//   const AlarmNotificationOverlay({
//     super.key,
//     required this.title,
//     required this.message,
//     this.onDismiss,
//     this.autoCloseDuration = const Duration(seconds: 10),
//   });

//   @override
//   State<AlarmNotificationOverlay> createState() => _AlarmNotificationOverlayState();

//   static OverlayEntry? _currentOverlay;
  
//   static void show(
//     BuildContext context, {
//     required String title,
//     required String message,
//     Duration autoCloseDuration = const Duration(seconds: 10),
//   }) {
//     dismiss();

//     final overlay = Overlay.of(context);
//     _currentOverlay = OverlayEntry(
//       builder: (context) => AlarmNotificationOverlay(
//         title: title,
//         message: message,
//         autoCloseDuration: autoCloseDuration,
//         onDismiss: () => dismiss(),
//       ),
//     );

//     overlay.insert(_currentOverlay!);
//   }

//   static void dismiss() {
//     _currentOverlay?.remove();
//     _currentOverlay = null;
//   }
// }

// class _AlarmNotificationOverlayState extends State<AlarmNotificationOverlay>
//     with TickerProviderStateMixin {
//   late AnimationController _slideController;
//   late AnimationController _bellController;
//   late AnimationController _pulseController;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _bellAnimation;
//   late Animation<double> _pulseAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, -1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _slideController,
//       curve: Curves.elasticOut,
//     ));

//     _bellController = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );

//     _bellAnimation = Tween<double>(
//       begin: -0.1,
//       end: 0.1,
//     ).animate(CurvedAnimation(
//       parent: _bellController,
//       curve: Curves.easeInOut,
//     ));

//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     _pulseAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.05,
//     ).animate(CurvedAnimation(
//       parent: _pulseController,
//       curve: Curves.easeInOut,
//     ));

//     _slideController.forward();
//     _repeatBellAnimation();
//     _pulseController.repeat(reverse: true);

//     Future.delayed(widget.autoCloseDuration, () {
//       if (mounted) {
//         _dismiss();
//       }
//     });
//   }

//   void _repeatBellAnimation() async {
//     while (mounted) {
//       await _bellController.forward();
//       await _bellController.reverse();
//       await _bellController.forward();
//       await _bellController.reverse();
//       await Future.delayed(const Duration(milliseconds: 500));
//     }
//   }

//   void _dismiss() async {
//     await _slideController.reverse();
//     if (mounted) {
//       widget.onDismiss?.call();
//     }
//   }

//   @override
//   void dispose() {
//     _slideController.dispose();
//     _bellController.dispose();
//     _pulseController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.black.withOpacity(0.3),
//       child: SafeArea(
//         child: SlideTransition(
//           position: _slideAnimation,
//           child: GestureDetector(
//             onTap: _dismiss,
//             child: AnimatedBuilder(
//               animation: _pulseAnimation,
//               builder: (context, child) {
//                 return Transform.scale(
//                   scale: _pulseAnimation.value,
//                   child: Container(
//                     margin: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           Color(0xFFFF0000), // Merah mencolok
//                           Color(0xFFFF6B00), // Orange
//                           Color(0xFFFFD700), // Kuning emas
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.red.withOpacity(0.5),
//                           blurRadius: 20,
//                           spreadRadius: 5,
//                         ),
//                       ],
//                     ),
//                     child: child,
//                   ),
//                 );
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Lonceng bergoyang
//                     AnimatedBuilder(
//                       animation: _bellAnimation,
//                       builder: (context, child) {
//                         return Transform.rotate(
//                           angle: _bellAnimation.value * math.pi,
//                           child: child,
//                         );
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.3),
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.notifications_active,
//                           size: 60,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     // Title
//                     Text(
//                       widget.title,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         shadows: [
//                           Shadow(
//                             color: Colors.black45,
//                             offset: Offset(2, 2),
//                             blurRadius: 4,
//                           ),
//                         ],
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 12),

//                     // Message
//                     Text(
//                       widget.message,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w500,
//                         shadows: [
//                           Shadow(
//                             color: Colors.black45,
//                             offset: Offset(1, 1),
//                             blurRadius: 2,
//                           ),
//                         ],
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 20),

//                     // Close button
//                     ElevatedButton(
//                       onPressed: _dismiss,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: Colors.red,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 32,
//                           vertical: 12,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25),
//                         ),
//                       ),
//                       child: const Text(
//                         'TUTUP',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }