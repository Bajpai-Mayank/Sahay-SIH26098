import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

/// Interactive Chat Interface for Participant Check-in and Early-Support.
/// Adheres strictly to AI Safety Boundary: supportive routing, non-clinical, human-in-the-loop escalation.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatMessageItem {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessageItem({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessageItem> _messages = [
    _ChatMessageItem(
      text: 'Namaste. I am your SAHAY support assistant. I am here to listen, offer gentle guidance, and connect you with your support team whenever needed. How are you feeling today?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  final List<String> _quickPrompts = [
    'I feel overwhelmed today',
    'I have questions about my legal rights',
    'I am having trouble sleeping',
    'Connect me to my caseworker',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessageItem(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    if (presetText == null) {
      _textController.clear();
    }

    _scrollToBottom();

    // Simulate calm, supportive Mock AI response adhering to AI Safety Boundary
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        String aiResponse = 'Thank you for sharing that with me. I have noted this in your private timeline. Please remember you are safe and supported. Your assigned caseworker, Pooja Sharma, is notified of any ongoing needs.';
        if (text.toLowerCase().contains('caseworker') || text.toLowerCase().contains('connect')) {
          aiResponse = 'I will help route a direct priority request to Pooja Sharma at the One Stop Centre. You can also tap "Request Human Support" at the top anytime for immediate callback.';
        } else if (text.toLowerCase().contains('sleep')) {
          aiResponse = 'Sleep disruption is very common when experiencing stress. I have logged your sleep difficulty in today\'s well-being check-in so your care team can recommend gentle relaxation strategies.';
        }

        setState(() {
          _messages.add(_ChatMessageItem(
            text: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Support Assistant',
      currentRoute: '/chat',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.s12),
          child: AppSecondaryButton(
            label: 'Request Human Support',
            icon: Icons.support_agent_rounded,
            height: 36,
            onPressed: () => context.push('/victim/request-help'),
          ),
        ),
      ],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Column(
            children: [
              // Reassuring disclaimer banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s10),
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.s10),
                    Expanded(
                      child: Text(
                        'Advisory Support Space: Private & encrypted. AI facilitates routing and does not provide psychiatric diagnoses.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryDark,
                              fontSize: 12,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              // Message conversation list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return Align(
                      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (!msg.isUser)
                              Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.spa_rounded, size: 11, color: Colors.white),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'SAHAY Companion',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s16,
                                vertical: AppSpacing.s12,
                              ),
                              decoration: BoxDecoration(
                                color: msg.isUser ? AppColors.primary : AppColors.card,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(AppRadius.card),
                                  topRight: const Radius.circular(AppRadius.card),
                                  bottomLeft: Radius.circular(msg.isUser ? AppRadius.card : AppRadius.small),
                                  bottomRight: Radius.circular(msg.isUser ? AppRadius.small : AppRadius.card),
                                ),
                                border: Border.all(
                                  color: msg.isUser ? Colors.transparent : AppColors.border,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(6),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                msg.text,
                                style: TextStyle(
                                  color: msg.isUser ? Colors.white : AppColors.textPrimary,
                                  fontSize: 14,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                              child: Text(
                                '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Quick prompts horizontal scroll
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickPrompts.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s8),
                  itemBuilder: (context, index) {
                    final prompt = _quickPrompts[index];
                    return ActionChip(
                      label: Text(prompt),
                      labelStyle: const TextStyle(fontSize: 12, color: AppColors.primaryDark),
                      backgroundColor: AppColors.primarySoft,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                      onPressed: () => _sendMessage(prompt),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.s8),

              // Text entry bar
              Container(
                padding: const EdgeInsets.all(AppSpacing.s12),
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: const TextStyle(color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s16,
                            vertical: AppSpacing.s10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.all(AppSpacing.s12),
                      ),
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
