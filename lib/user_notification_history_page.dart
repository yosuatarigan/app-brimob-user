// import 'package:app_brimob_user/notification_model.dart';
// import 'package:app_brimob_user/notification_service.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import '../constants/app_constants.dart';

// class UserNotificationHistoryPage extends StatefulWidget {
//   const UserNotificationHistoryPage({super.key});

//   @override
//   State<UserNotificationHistoryPage> createState() => _UserNotificationHistoryPageState();
// }

// class _UserNotificationHistoryPageState extends State<UserNotificationHistoryPage>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
  
//   Stream<List<NotificationModel>>? _notificationsStream;
//   Stream<int>? _unreadCountStream;
  
//   @override
//   void initState() {
//     super.initState();
//     timeago.setLocaleMessages('id', timeago.IdMessages());
//     _initAnimations();
//     _loadNotifications();
//   }

//   void _initAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );

//     _animationController.forward();
//   }

//   void _loadNotifications() {
//     _notificationsStream = NotificationService.getUserNotifications();
//     _unreadCountStream = NotificationService.getUnreadCount();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Color _getTypeColor(NotificationType type) {
//     switch (type) {
//       case NotificationType.general:
//         return AppColors.primaryBlue;
//       case NotificationType.urgent:
//         return AppColors.red;
//       case NotificationType.announcement:
//         return AppColors.purple;
//       case NotificationType.reminder:
//         return AppColors.orange;
//       case NotificationType.event:
//         return AppColors.green;
//     }
//   }

//   IconData _getTypeIcon(NotificationType type) {
//     switch (type) {
//       case NotificationType.general:
//         return Icons.notifications;
//       case NotificationType.urgent:
//         return Icons.priority_high;
//       case NotificationType.announcement:
//         return Icons.campaign;
//       case NotificationType.reminder:
//         return Icons.schedule;
//       case NotificationType.event:
//         return Icons.event;
//     }
//   }

//   String _getTypeLabel(NotificationType type) {
//     switch (type) {
//       case NotificationType.general:
//         return 'Umum';
//       case NotificationType.urgent:
//         return 'Urgent';
//       case NotificationType.announcement:
//         return 'Pengumuman';
//       case NotificationType.reminder:
//         return 'Pengingat';
//       case NotificationType.event:
//         return 'Event';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.lightGray.withOpacity(0.5),
//       appBar: _buildAppBar(),
//       body: SafeArea(
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: StreamBuilder<List<NotificationModel>>(
//             stream: _notificationsStream,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return _buildLoadingState();
//               }

//               if (snapshot.hasError) {
//                 return _buildErrorState(snapshot.error.toString());
//               }

//               final notifications = snapshot.data ?? [];

//               if (notifications.isEmpty) {
//                 return _buildEmptyState();
//               }

//               return _buildNotificationList(notifications);
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: AppColors.primaryBlue,
//       foregroundColor: Colors.white,
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Notifikasi',
//             style: GoogleFonts.roboto(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           StreamBuilder<int>(
//             stream: _unreadCountStream,
//             builder: (context, snapshot) {
//               final unreadCount = snapshot.data ?? 0;
//               if (unreadCount > 0) {
//                 return Text(
//                   '$unreadCount pesan belum dibaca',
//                   style: GoogleFonts.roboto(
//                     fontSize: 12,
//                     color: Colors.white.withOpacity(0.9),
//                   ),
//                 );
//               }
//               return Text(
//                 'Semua pesan sudah dibaca',
//                 style: GoogleFonts.roboto(
//                   fontSize: 12,
//                   color: Colors.white.withOpacity(0.9),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       elevation: 0,
//       actions: [
//         PopupMenuButton<String>(
//           onSelected: _handleMenuAction,
//           itemBuilder: (context) => [
//             const PopupMenuItem(
//               value: 'mark_all_read',
//               child: Row(
//                 children: [
//                   Icon(Icons.done_all, size: 20),
//                   SizedBox(width: 8),
//                   Text('Tandai Semua Dibaca'),
//                 ],
//               ),
//             ),
//             const PopupMenuItem(
//               value: 'clear_all',
//               child: Row(
//                 children: [
//                   Icon(Icons.clear_all, size: 20),
//                   SizedBox(width: 8),
//                   Text('Hapus Semua'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Memuat notifikasi...',
//             style: GoogleFonts.roboto(
//               fontSize: 14,
//               color: AppColors.darkGray,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState(String error) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.red.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(50),
//               ),
//               child: Icon(
//                 Icons.error_outline,
//                 size: 48,
//                 color: AppColors.red,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Terjadi Kesalahan',
//               style: GoogleFonts.roboto(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.darkNavy,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               error,
//               style: GoogleFonts.roboto(
//                 fontSize: 14,
//                 color: AppColors.darkGray,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: () {
//                 setState(() {
//                   _loadNotifications();
//                 });
//               },
//               icon: const Icon(Icons.refresh),
//               label: const Text('Coba Lagi'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryBlue,
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: AppColors.primaryBlue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(50),
//               ),
//               child: Icon(
//                 Icons.notifications_none,
//                 size: 64,
//                 color: AppColors.primaryBlue,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'Belum Ada Notifikasi',
//               style: GoogleFonts.roboto(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.darkNavy,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Notifikasi dari admin akan muncul di sini',
//               style: GoogleFonts.roboto(
//                 fontSize: 14,
//                 color: AppColors.darkGray,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             TextButton.icon(
//               onPressed: () => Navigator.pop(context),
//               icon: const Icon(Icons.arrow_back),
//               label: const Text('Kembali ke Dashboard'),
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.primaryBlue,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNotificationList(List<NotificationModel> notifications) {
//     return RefreshIndicator(
//       onRefresh: () async {
//         _loadNotifications();
//       },
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: notifications.length,
//         itemBuilder: (context, index) {
//           final notification = notifications[index];
//           return _buildNotificationCard(notification, index);
//         },
//       ),
//     );
//   }

//   Widget _buildNotificationCard(NotificationModel notification, int index) {
//     return FutureBuilder<bool>(
//       future: NotificationService.isNotificationRead(notification.id),
//       builder: (context, snapshot) {
//         final isRead = snapshot.data ?? false;
        
//         return AnimatedContainer(
//           duration: Duration(milliseconds: 300 + (index * 50)),
//           curve: Curves.easeOut,
//           margin: const EdgeInsets.only(bottom: 12),
//           child: Card(
//             elevation: isRead ? 1 : 3,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//               side: isRead 
//                 ? BorderSide.none 
//                 : BorderSide(
//                     color: _getTypeColor(notification.type).withOpacity(0.3),
//                     width: 1,
//                   ),
//             ),
//             child: InkWell(
//               borderRadius: BorderRadius.circular(12),
//               onTap: () => _handleNotificationTap(notification),
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   color: isRead ? null : _getTypeColor(notification.type).withOpacity(0.02),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildNotificationHeader(notification, isRead),
//                     const SizedBox(height: 12),
//                     _buildNotificationContent(notification),
//                     if (notification.imageUrl != null) ...[
//                       const SizedBox(height: 12),
//                       _buildNotificationImage(notification.imageUrl!),
//                     ],
//                     const SizedBox(height: 12),
//                     _buildNotificationFooter(notification),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildNotificationHeader(NotificationModel notification, bool isRead) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: _getTypeColor(notification.type).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             _getTypeIcon(notification.type),
//             size: 18,
//             color: _getTypeColor(notification.type),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       notification.title,
//                       style: GoogleFonts.roboto(
//                         fontSize: 16,
//                         fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
//                         color: AppColors.darkNavy,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   if (!isRead) ...[
//                     const SizedBox(width: 8),
//                     Container(
//                       width: 8,
//                       height: 8,
//                       decoration: BoxDecoration(
//                         color: _getTypeColor(notification.type),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//               const SizedBox(height: 2),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: _getTypeColor(notification.type).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   _getTypeLabel(notification.type),
//                   style: GoogleFonts.roboto(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     color: _getTypeColor(notification.type),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildNotificationContent(NotificationModel notification) {
//     return Text(
//       notification.message,
//       style: GoogleFonts.roboto(
//         fontSize: 14,
//         color: AppColors.darkGray,
//         height: 1.4,
//       ),
//       maxLines: 4,
//       overflow: TextOverflow.ellipsis,
//     );
//   }

//   Widget _buildNotificationImage(String imageUrl) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(8),
//       child: CachedNetworkImage(
//         imageUrl: imageUrl,
//         height: 120,
//         width: double.infinity,
//         fit: BoxFit.cover,
//         placeholder: (context, url) => Container(
//           height: 120,
//           color: AppColors.lightGray,
//           child: const Center(
//             child: CircularProgressIndicator(),
//           ),
//         ),
//         errorWidget: (context, url, error) => Container(
//           height: 120,
//           color: AppColors.lightGray,
//           child: const Center(
//             child: Icon(Icons.broken_image, color: AppColors.darkGray),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNotificationFooter(NotificationModel notification) {
//     return Row(
//       children: [
//         Icon(
//           Icons.person_outline,
//           size: 14,
//           color: AppColors.darkGray,
//         ),
//         const SizedBox(width: 4),
//         Text(
//           notification.senderName,
//           style: GoogleFonts.roboto(
//             fontSize: 12,
//             color: AppColors.darkGray,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Icon(
//           Icons.access_time,
//           size: 14,
//           color: AppColors.darkGray,
//         ),
//         const SizedBox(width: 4),
//         Text(
//           timeago.format(notification.createdAt, locale: 'id'),
//           style: GoogleFonts.roboto(
//             fontSize: 12,
//             color: AppColors.darkGray,
//           ),
//         ),
//       ],
//     );
//   }

//   Future<void> _handleNotificationTap(NotificationModel notification) async {
//     // Mark as read
//     await NotificationService.markAsRead(notification.id);
    
//     // Show detailed notification dialog
//     _showNotificationDetail(notification);
//   }

//   void _showNotificationDetail(NotificationModel notification) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Container(
//           constraints: const BoxConstraints(maxWidth: 400),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: _getTypeColor(notification.type),
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(16),
//                     topRight: Radius.circular(16),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       _getTypeIcon(notification.type),
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         notification.title,
//                         style: GoogleFonts.roboto(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: const Icon(Icons.close, color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ),
              
//               // Content
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       notification.message,
//                       style: GoogleFonts.roboto(
//                         fontSize: 14,
//                         color: AppColors.darkNavy,
//                         height: 1.5,
//                       ),
//                     ),
                    
//                     if (notification.imageUrl != null) ...[
//                       const SizedBox(height: 16),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: CachedNetworkImage(
//                           imageUrl: notification.imageUrl!,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ],
                    
//                     const SizedBox(height: 16),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: AppColors.lightGray.withOpacity(0.5),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.info_outline,
//                             size: 16,
//                             color: AppColors.darkGray,
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Dari: ${notification.senderName}',
//                                   style: GoogleFonts.roboto(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w500,
//                                     color: AppColors.darkGray,
//                                   ),
//                                 ),
//                                 Text(
//                                   'Waktu: ${timeago.format(notification.createdAt, locale: 'id')}',
//                                   style: GoogleFonts.roboto(
//                                     fontSize: 12,
//                                     color: AppColors.darkGray,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleMenuAction(String action) {
//     switch (action) {
//       case 'mark_all_read':
//         _markAllAsRead();
//         break;
//       case 'clear_all':
//         _showClearAllDialog();
//         break;
//     }
//   }

//   Future<void> _markAllAsRead() async {
//     try {
//       // This would need to be implemented in the NotificationService
//       // await NotificationService.markAllAsRead();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Semua notifikasi ditandai sebagai dibaca'),
//           backgroundColor: AppColors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Gagal menandai semua sebagai dibaca: $e'),
//           backgroundColor: AppColors.red,
//         ),
//       );
//     }
//   }

//   void _showClearAllDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text('Hapus Semua Notifikasi'),
//         content: const Text('Apakah Anda yakin ingin menghapus semua riwayat notifikasi?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Batal'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _clearAllNotifications();
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
//             child: const Text('Hapus', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _clearAllNotifications() async {
//     try {
//       await NotificationService.clearAllNotifications();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Semua notifikasi berhasil dihapus'),
//           backgroundColor: AppColors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Gagal menghapus notifikasi: $e'),
//           backgroundColor: AppColors.red,
//         ),
//       );
//     }
//   }
// }