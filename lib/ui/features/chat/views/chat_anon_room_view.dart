import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/leave_chat_dialog.dart';
import '../widgets/report_chat_dialog.dart';

class ChatAnonRoomView extends StatelessWidget {
  const ChatAnonRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF4), // Light blue-ish background like mockup
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _showLeaveChatDialog(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.twilightDarker,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Mascot Avatar
                  Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.twilightNormal, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/profile.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  
                  // Title
                  Text(
                    'Chat Anon',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.wisteriaNormalHover, // Fixed typo
                      fontSize: 18,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // 3-dots Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.twilightDarker),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'report') {
                        _showReportDialog(context);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            const Icon(Icons.report_problem_outlined, size: 20, color: AppColors.twilightDarker),
                            const SizedBox(width: 8),
                            Text(
                              'Laporkan chat',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.twilightDarker,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Empty Chat Space
            Expanded(
              child: Container(),
            ),
            
            // Input Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.transparent, // Background of the area
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.twilightNormal.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.sentiment_satisfied_alt),
                      color: AppColors.twilightNormal,
                      onPressed: () {},
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: AppColors.twilightNormal.withOpacity(0.3),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.twilightNormal.withOpacity(0.6),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.wisteriaNormal, // Based on mockup blue/purple
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LeaveChatDialog(),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ReportChatDialog(),
    );
  }
}
