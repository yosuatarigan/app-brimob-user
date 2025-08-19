import 'package:app_brimob_user/libadmin/admin_constant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminLoadingWidget extends StatelessWidget {
  final String? message;
  
  const AdminLoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AdminColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AdminColors.primaryBlue),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AdminSizes.paddingM),
            Text(
              message!,
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: AdminColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AdminErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  
  const AdminErrorWidget({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdminSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AdminColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: AdminColors.error,
              ),
            ),
            const SizedBox(height: AdminSizes.paddingL),
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AdminColors.adminDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AdminSizes.paddingS),
            Text(
              message,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: AdminColors.darkGray,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AdminSizes.paddingL),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AdminSizes.paddingL,
                    vertical: AdminSizes.paddingM,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AdminStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? change;
  
  const AdminStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AdminSizes.radiusM),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AdminSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AdminSizes.paddingS),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AdminSizes.radiusS),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: AdminSizes.iconM,
                    ),
                  ),
                  if (change != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AdminSizes.paddingS,
                        vertical: AdminSizes.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AdminColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AdminSizes.radiusS),
                      ),
                      child: Text(
                        change!,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.success,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AdminSizes.paddingM),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.adminDark,
                ),
              ),
              const SizedBox(height: AdminSizes.paddingXS),
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: AdminColors.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? imageUrl;
  final VoidCallback onTap;
  
  const AdminMenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AdminSizes.radiusM),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AdminSizes.radiusM),
                      topRight: Radius.circular(AdminSizes.radiusM),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.8),
                        color.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background image
                      if (imageUrl != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AdminSizes.radiusM),
                            topRight: Radius.circular(AdminSizes.radiusM),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: color.withOpacity(0.3),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: color.withOpacity(0.3),
                            ),
                          ),
                        ),
                      
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(AdminSizes.radiusM),
                            topRight: Radius.circular(AdminSizes.radiusM),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              color.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      
                      // Icon
                      Positioned(
                        bottom: AdminSizes.paddingS,
                        right: AdminSizes.paddingS,
                        child: Container(
                          padding: const EdgeInsets.all(AdminSizes.paddingS),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(AdminSizes.radiusS),
                          ),
                          child: Icon(
                            icon,
                            size: AdminSizes.iconM,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Content section
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(AdminSizes.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.adminDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AdminSizes.paddingXS),
                      Text(
                        subtitle,
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: AdminColors.darkGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  
  const AdminActionButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AdminSizes.paddingM),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AdminSizes.paddingS),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AdminSizes.radiusS),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: AdminSizes.iconM,
                ),
              ),
              const SizedBox(width: AdminSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.adminDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: AdminColors.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AdminColors.lightGray,
                size: AdminSizes.iconS,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  
  const AdminSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AdminSizes.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.adminDark,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AdminSizes.paddingXS),
                  Text(
                    subtitle!,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: AdminColors.darkGray,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null)
            action!,
        ],
      ),
    );
  }
}

class AdminStatusChip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final bool isActive;
  
  const AdminStatusChip({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminSizes.paddingS,
        vertical: AdminSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : AdminColors.lightGray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AdminSizes.radiusS),
        border: Border.all(
          color: isActive ? color.withOpacity(0.3) : AdminColors.lightGray.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: isActive ? color : AdminColors.lightGray,
            ),
            const SizedBox(width: AdminSizes.paddingXS),
          ],
          Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? color : AdminColors.lightGray,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  
  const AdminFloatingActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AdminColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 8,
      icon: Icon(icon),
      label: Text(
        label,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class AdminEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  
  const AdminEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdminSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AdminColors.lightGray.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AdminColors.lightGray,
              ),
            ),
            const SizedBox(height: AdminSizes.paddingL),
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AdminColors.adminDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AdminSizes.paddingS),
            Text(
              message,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: AdminColors.darkGray,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AdminSizes.paddingL),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AdminSizes.paddingL,
                    vertical: AdminSizes.paddingM,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}