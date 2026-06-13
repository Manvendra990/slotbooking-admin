import 'package:flutter/material.dart';
import 'package:slotbookingadmin/Admin/admin_shell.dart';
import 'package:slotbookingadmin/theme/app_colors.dart';

class AdminHeader extends StatelessWidget {
  final String title;
  const AdminHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceBright,
        border: Border(bottom: BorderSide(color: AppColors.primary, width: 2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: AppColors.primaryDark,
              ),
              onPressed: () {
                final shell = AdminShellScope.of(context);
                if (shell != null) {
                  shell.openDrawer();
                } else {
                  Scaffold.of(context).openDrawer();
                }
              },
            ),
          ),

          const Spacer(),

          // Logo
          const Text(
            'KINETIC',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: AppColors.primaryDark,
            ),
          ),
          const Spacer(),

          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primaryDark,
              size: 24,
            ),
          ),

          // Bell
          // Stack(
          //   children: [
          //     IconButton(
          //       icon: const Icon(Icons.notifications_none_rounded),
          //       color: Colors.grey[700],
          //       onPressed: () {},
          //     ),
          //     Positioned(
          //       right: 10,
          //       top: 10,
          //       child: Container(
          //         width: 8,
          //         height: 8,
          //         decoration: const BoxDecoration(
          //           color: Colors.red,
          //           shape: BoxShape.circle,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(width: 30),
        ],
      ),
    );
  }
}
