import 'package:flutter/material.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/models/tour_plan.dart';
import 'package:hela/models/tour_preferences.dart';
import 'package:hela/services/tour_api_service.dart';
import 'package:hela/widgets/hela_logo.dart';

/// Interactive AI chat screen allowing users to customize their tour plan using Gemini.
class AiChatCustomizationPage extends StatefulWidget {
  final TourPlan currentPlan;
  final TourPreferences preferences;

  const AiChatCustomizationPage({
    super.key,
    required this.currentPlan,
    required this.preferences,
  });

  @override
  State<AiChatCustomizationPage> createState() =>
      _AiChatCustomizationPageState();
}

class _ChatBubble {
  final String text;
  final bool isUser;
  final TourPlan? updatedPlan;

  _ChatBubble({
    required this.text,
    required this.isUser,
    this.updatedPlan,
  });
}

class _AiChatCustomizationPageState extends State<AiChatCustomizationPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatBubble> _messages = [];
  bool _isSending = false;
  late TourPlan _activePlan;

  final List<String> _quickSuggestions = [
    'Add more relaxation time',
    'Include authentic street food stops',
    'Make budget friendlier',
    'Add an ocean sunset or beach swim',
    'Include a scenic tea plantation train ride',
  ];

  @override
  void initState() {
    super.initState();
    _activePlan = widget.currentPlan;

    // Welcome message from HELA AI
    _messages.add(
      _ChatBubble(
        text:
            'Ayubowan! I am your HELA AI travel specialist. I can customize "${widget.currentPlan.title}" to suit your pace, budget, or preferred activities. What would you like to adjust?',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? presetText]) async {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    _textController.clear();
    setState(() {
      _messages.add(_ChatBubble(text: text, isUser: true));
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final updated = await TourApiService().customizeItinerary(
        currentPlan: _activePlan,
        userPrompt: text,
      );

      if (!mounted) return;

      setState(() {
        _activePlan = updated;
        _messages.add(
          _ChatBubble(
            text: updated.customizationSummary ??
                'I have updated your itinerary according to your request!',
            isUser: false,
            updatedPlan: updated,
          ),
        );
        _isSending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatBubble(
            text: 'I could not process the update right now: $e. Please try again.',
            isUser: false,
          ),
        );
        _isSending = false;
      });
      _scrollToBottom();
    }
  }

  void _applyAndExit(TourPlan plan) {
    Navigator.pop(context, plan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelaColors.surface,
      appBar: AppBar(
        backgroundColor: HelaColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: HelaColors.primary),
          onPressed: () => Navigator.pop(context, _activePlan),
        ),
        title: Row(
          children: [
            const HelaLogo(
              size: 34,
              framed: true,
              isCircle: true,
              padding: 4,
              borderColor: HelaColors.outlineVariant,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HELA AI Assistant',
                  style: TextStyle(
                    color: HelaColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Customizing v${_activePlan.version}',
                  style: const TextStyle(
                    color: HelaColors.onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _applyAndExit(_activePlan),
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Done'),
            style: TextButton.styleFrom(
              foregroundColor: HelaColors.primary,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Quick Suggestion Chips
          if (!_isSending) ...[
            Container(
              height: 36,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: _quickSuggestions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final suggestion = _quickSuggestions[index];
                  return ActionChip(
                    label: Text(
                      suggestion,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: HelaColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: HelaColors.surfaceContainerLowest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: HelaColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    onPressed: () => _sendMessage(suggestion),
                  );
                },
              ),
            ),
          ],

          // Loading Indicator
          if (_isSending)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(HelaColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Gemini is updating your tour...',
                    style: TextStyle(
                      fontSize: 12,
                      color: HelaColors.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

          // Bottom Chat Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: HelaColors.surfaceContainerLowest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: HelaColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _textController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Add an evening street food walk...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: HelaColors.outline,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: HelaColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded,
                          size: 18, color: Colors.white),
                      onPressed: _isSending ? null : () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatBubble msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: HelaColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              height: 1.35,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 32),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: HelaColors.surfaceContainerLowest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: HelaColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: const TextStyle(
                color: HelaColors.onSurface,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            if (msg.updatedPlan != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: HelaColors.primaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 16, color: HelaColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Itinerary v${msg.updatedPlan!.version} ready to view',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: HelaColors.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _applyAndExit(msg.updatedPlan!),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: HelaColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
