import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hela/config/api_config.dart';
import 'package:hela/services/live_weather_service.dart';
import 'package:hela/services/localization_service.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/widgets/language_picker_sheet.dart';

/// Bento item representing structured practical tips or cultural rules
class AskHelaBentoItem {
  final IconData icon;
  final String title;
  final String description;

  const AskHelaBentoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// Message model for the Ask HELA AI Chat
class AskHelaMessage {
  final String id;
  final bool isUser;
  final String text;
  final String timeString;
  final String? title; // e.g. "Ayubowan! 🙏"
  final String? badgeText; // e.g. "Verified Lore"
  final String? imageUrl;
  final String? imageCaption;
  final List<AskHelaBentoItem>? bentoItems;

  const AskHelaMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.timeString,
    this.title,
    this.badgeText,
    this.imageUrl,
    this.imageCaption,
    this.bentoItems,
  });
}

/// Dedicated page for Ask HELA 24/7 AI Travel Companion with Google Gemini integration
class AskHelaPage extends StatefulWidget {
  final String? initialPrompt;

  const AskHelaPage({super.key, this.initialPrompt});

  @override
  State<AskHelaPage> createState() => _AskHelaPageState();
}

class _AskHelaPageState extends State<AskHelaPage> with WidgetsBindingObserver {
  static const Duration _weatherRefreshInterval = Duration(minutes: 2);

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final LiveWeatherService _weatherService = LiveWeatherService();

  bool _isAITyping = false;
  final List<Content> _chatHistory = [];

  static final Content _systemInstruction = Content.system(
    'You are HELA, the 24/7 personal Sri Lanka Travel Companion & AI Cultural Guide. '
    'You provide verified practical tips, cultural etiquette, train schedules, pricing in LKR, '
    'historical lore, weather-smart routes, and authentic local recommendations for Sri Lanka. '
    'Keep the tone warm, welcoming, knowledgeable, and concise like a trusted local friend. '
    'Structure your answers clearly with practical advice and local insights. '
    'Do not start your response with "Ayubowan!" because the chat card header already greets the user.',
  );

  final List<AskHelaMessage> _messages = [];

  // Live location & Google weather state
  LiveWeatherData? _liveWeather;
  bool _isWeatherLoading = true;
  Timer? _weatherRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _seedInitialConversation();
    _initLiveWeather();

    if (widget.initialPrompt != null &&
        widget.initialPrompt!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSendMessage(widget.initialPrompt!);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshLiveWeather(requestPermissionIfNeeded: false);
    }
  }

  Future<void> _initLiveWeather() async {
    final cached = await _weatherService.loadCachedWeather();
    if (cached != null && mounted) {
      setState(() {
        _liveWeather = cached;
      });
    }

    await _refreshLiveWeather(requestPermissionIfNeeded: true);

    _weatherRefreshTimer?.cancel();
    _weatherRefreshTimer = Timer.periodic(_weatherRefreshInterval, (_) {
      _refreshLiveWeather(requestPermissionIfNeeded: false);
    });
  }

  Future<void> _refreshLiveWeather({
    bool requestPermissionIfNeeded = false,
  }) async {
    if (!mounted) return;
    setState(() => _isWeatherLoading = true);

    final appState = HelaAppStateProvider.of(context);
    final fallbackCity = appState.userLocation.split(',').first.trim();
    final updated = await _weatherService.fetchLiveWeather(
      fallbackLocationName: fallbackCity.isNotEmpty ? fallbackCity : 'Kandy',
      requestPermissionIfNeeded: requestPermissionIfNeeded,
    );

    if (!mounted) return;
    setState(() {
      if (updated != null) {
        _liveWeather = updated;
      }
      _isWeatherLoading = false;
    });
  }

  void _seedInitialConversation() {
    // Initial conversation exactly matching user's design reference
    _messages.addAll([
      const AskHelaMessage(
        id: 'user_init_1',
        isUser: true,
        text:
            'What should I know before visiting a Buddhist temple like Kandy\'s Temple of the Tooth?',
        timeString: '09:41 AM',
      ),
      const AskHelaMessage(
        id: 'ai_init_1',
        isUser: false,
        title: 'Ayubowan! 🙏',
        badgeText: 'Verified Lore',
        text:
            'Visiting sacred Sri Lankan temples is a deeply spiritual and serene experience. Here is essential etiquette to ensure a respectful visit:',
        timeString: '09:41 AM',
        imageUrl:
            'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80',
        imageCaption: 'Sri Dalada Maligawa • Kandy',
        bentoItems: [
          AskHelaBentoItem(
            icon: Icons.checkroom_rounded,
            title: 'Modest Attire (White Preferred)',
            description:
                'Shoulders and knees must be fully covered. Light-colored or white garments express cultural reverence and keep you cool.',
          ),
          AskHelaBentoItem(
            icon: Icons.do_not_step_rounded,
            title: 'Footwear & Headwear',
            description:
                'Remove shoes, hats, and sunglasses at the guarded footwear counters (free or small discretionary tip) before crossing inner gates.',
          ),
        ],
      ),
    ]);
  }

  @override
  void dispose() {
    _weatherRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
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

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $ampm';
  }

  Future<void> _handleSendMessage(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || _isAITyping) return;

    final userTime = _formatCurrentTime();
    _textController.clear();

    setState(() {
      _messages.add(
        AskHelaMessage(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          isUser: true,
          text: trimmed,
          timeString: userTime,
        ),
      );
      _isAITyping = true;
    });

    _scrollToBottom();

    // Query Gemini AI with multi-model fallback
    final appState = HelaAppStateProvider.of(context);
    final currentLang = appState.selectedLanguage;

    // Build language & live weather/location context hints
    final langNote = currentLang != 'EN'
        ? ' (Reply in the user\'s preferred language: $currentLang where natural)'
        : '';
    final weatherNote = _liveWeather != null
        ? ' [User live location: ${_liveWeather!.locationName}, live temp: ${_liveWeather!.temperatureC.round()}°C'
              '${_liveWeather!.condition != null ? ', ${_liveWeather!.condition}' : ''}]'
        : '';
    final prompt = '$trimmed$langNote$weatherNote';

    final replyText = await _sendToGeminiWithFallback(prompt);
    final aiResponse = (replyText != null && replyText.isNotEmpty)
        ? _buildRichAiMessageFromText(trimmed, replyText)
        : _getSmartFallbackResponse(trimmed);

    if (!mounted) return;

    setState(() {
      _messages.add(aiResponse);
      _isAITyping = false;
    });

    _scrollToBottom();
  }

  /// Sends [prompt] using multi-turn [_chatHistory], falling back across
  /// free Gemini Flash tiers if the primary model experiences transient load.
  Future<String?> _sendToGeminiWithFallback(String prompt) async {
    final models = [
      ApiConfig.geminiModel,
      ApiConfig.geminiFallbackModel,
      ApiConfig.geminiLiteFallbackModel,
    ];
    for (final modelName in models) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: ApiConfig.geminiApiKey,
          systemInstruction: _systemInstruction,
        );
        final chat = model.startChat(history: _chatHistory);
        final response = await chat
            .sendMessage(Content.text(prompt))
            .timeout(const Duration(seconds: 20));
        final text = response.text?.trim();
        if (text != null && text.isNotEmpty) {
          _chatHistory
            ..clear()
            ..addAll(chat.history);
          return text;
        }
      } catch (e) {
        debugPrint('[AskHELA] Model $modelName error: $e');
      }
    }
    return null;
  }

  AskHelaMessage _buildRichAiMessageFromText(
    String userQuery,
    String geminiText,
  ) {
    final lower = userQuery.toLowerCase();
    String? imageUrl;
    String? imageCaption;
    List<AskHelaBentoItem>? bentoItems;

    if (lower.contains('sigiriya') ||
        lower.contains('rock') ||
        lower.contains('lion')) {
      imageUrl =
          'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80';
      imageCaption = 'Sigiriya Rock Fortress • Cultural Triangle';
      bentoItems = const [
        AskHelaBentoItem(
          icon: Icons.wb_sunny_rounded,
          title: 'Optimal Sunrise Ascent',
          description:
              'Arrive at gates by 06:30 AM to beat the tropical heat and high winds at the summit terrace.',
        ),
        AskHelaBentoItem(
          icon: Icons.shield_outlined,
          title: 'Sacred Mirror Wall Rules',
          description:
              'Flash photography and touching ancient graffiti is strictly prohibited to preserve delicate plaster.',
        ),
      ];
    } else if (lower.contains('train') ||
        lower.contains('ella') ||
        lower.contains('bridge')) {
      imageUrl =
          'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=1200&auto=format&fit=crop&q=85';
      imageCaption = 'Nine Arch Bridge • Ella Highlands';
      bentoItems = const [
        AskHelaBentoItem(
          icon: Icons.train_rounded,
          title: 'Train Departures & Timing',
          description:
              'The blue passenger trains rumble across the viaduct daily at 09:30 AM, 11:30 AM, 03:30 PM, and 05:30 PM.',
        ),
        AskHelaBentoItem(
          icon: Icons.confirmation_number_outlined,
          title: 'Ticket Reservations',
          description:
              'Reserve 1st or 2nd class observation carriage seats 30 days ahead online via Sri Lanka Railways portal.',
        ),
      ];
    } else if (lower.contains('tuk') ||
        lower.contains('fare') ||
        lower.contains('meter') ||
        lower.contains('taxi')) {
      bentoItems = const [
        AskHelaBentoItem(
          icon: Icons.speed_rounded,
          title: 'Official Meter Pricing',
          description:
              'LKR 100-120 for the first kilometer, and LKR 80-90 per subsequent km. Ensure the roof meter is reset.',
        ),
        AskHelaBentoItem(
          icon: Icons.verified_user_outlined,
          title: 'HELA Fair-Fare Guarantee',
          description:
              'Use our in-app Fair Ride calculator before departing to verify fair local market rates.',
        ),
      ];
    } else if (lower.contains('temple') ||
        lower.contains('tooth') ||
        lower.contains('kandy')) {
      imageUrl =
          'https://images.unsplash.com/photo-1588598198321-9735fd52455b?w=800&auto=format&fit=crop&q=80';
      imageCaption = 'Sri Dalada Maligawa • Kandy';
      bentoItems = const [
        AskHelaBentoItem(
          icon: Icons.checkroom_rounded,
          title: 'Modest Attire (White Preferred)',
          description:
              'Shoulders and knees must be fully covered. Light-colored or white garments express cultural reverence.',
        ),
        AskHelaBentoItem(
          icon: Icons.do_not_step_rounded,
          title: 'Footwear & Headwear',
          description:
              'Remove shoes, hats, and sunglasses at the guarded footwear counters before crossing inner gates.',
        ),
      ];
    }

    return AskHelaMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      isUser: false,
      title: 'Ayubowan! 🙏',
      badgeText: 'Verified Lore',
      text: geminiText,
      timeString: _formatCurrentTime(),
      imageUrl: imageUrl,
      imageCaption: imageCaption,
      bentoItems: bentoItems,
    );
  }

  AskHelaMessage _getSmartFallbackResponse(String userQuery) {
    final lower = userQuery.toLowerCase();
    if (lower.contains('sigiriya') || lower.contains('rock')) {
      return AskHelaMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        title: 'Ayubowan! 🙏',
        badgeText: 'Verified Lore',
        text:
            'Sigiriya is an extraordinary 5th-century ancient citadel constructed by King Kashyapa. Rising 200 meters above the jungle canopy, it features vibrant frescoes, mirror walls, and advanced hydraulic water gardens.',
        timeString: _formatCurrentTime(),
        imageUrl:
            'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=800&auto=format&fit=crop&q=80',
        imageCaption: 'Sigiriya Rock Fortress • Cultural Triangle',
        bentoItems: const [
          AskHelaBentoItem(
            icon: Icons.wb_sunny_rounded,
            title: 'Optimal Sunrise Ascent',
            description:
                'Arrive at gates by 06:30 AM to beat the tropical heat and high winds at the summit terrace.',
          ),
          AskHelaBentoItem(
            icon: Icons.shield_outlined,
            title: 'Sacred Mirror Wall Rules',
            description:
                'Flash photography and touching ancient graffiti is strictly prohibited to preserve delicate plaster.',
          ),
        ],
      );
    } else if (lower.contains('train') ||
        lower.contains('ella') ||
        lower.contains('bridge')) {
      return AskHelaMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        title: 'Ayubowan! 🙏',
        badgeText: 'Scenic Rail Lore',
        text:
            'The Main Line railway journey through Nuwara Eliya and Ella is widely praised as one of the world\'s most breathtaking train journeys, winding through emerald tea valleys, eucalyptus forests, and misty waterfalls.',
        timeString: _formatCurrentTime(),
        imageUrl:
            'https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?w=1200&auto=format&fit=crop&q=85',
        imageCaption: 'Nine Arch Bridge • Ella Highlands',
        bentoItems: const [
          AskHelaBentoItem(
            icon: Icons.train_rounded,
            title: 'Train Departures & Timing',
            description:
                'The blue passenger trains rumble across the viaduct daily at 09:30 AM, 11:30 AM, 03:30 PM, and 05:30 PM.',
          ),
          AskHelaBentoItem(
            icon: Icons.confirmation_number_outlined,
            title: 'Ticket Reservations',
            description:
                'Reserve 1st or 2nd class observation carriage seats 30 days ahead online via Sri Lanka Railways portal.',
          ),
        ],
      );
    } else if (lower.contains('tuk') ||
        lower.contains('fare') ||
        lower.contains('meter')) {
      return AskHelaMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        title: 'Ayubowan! 🙏',
        badgeText: 'Fair Transit Guide',
        text:
            'Sri Lankan three-wheelers (tuk-tuks) are the heartbeat of local island transit. Understanding fair pricing ensures a pleasant and stress-free ride.',
        timeString: _formatCurrentTime(),
        bentoItems: const [
          AskHelaBentoItem(
            icon: Icons.speed_rounded,
            title: 'Official Meter Pricing',
            description:
                'LKR 100-120 for the first kilometer, and LKR 80-90 per subsequent km. Ensure the driver turns on the meter.',
          ),
          AskHelaBentoItem(
            icon: Icons.verified_user_outlined,
            title: 'HELA Fair-Fare Guarantee',
            description:
                'Use HELA Fair Ride before departing to verify fair local market rates and avoid airport markups.',
          ),
        ],
      );
    } else {
      return AskHelaMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        title: 'Ayubowan! 🙏',
        badgeText: 'Island Intelligence',
        text:
            'Sri Lanka is ready to welcome you! Whether you are exploring ancient royal kingdoms, seeking surf in Weligama, or savoring hot kottu roti in Colombo, I am right here with verified local guidance.',
        timeString: _formatCurrentTime(),
        bentoItems: const [
          AskHelaBentoItem(
            icon: Icons.explore_rounded,
            title: 'Personalized Routing',
            description:
                'Ask about weather-smart timings, authentic street food, or hidden mountain waterfalls.',
          ),
          AskHelaBentoItem(
            icon: Icons.handshake_outlined,
            title: 'Cultural Courtesy',
            description:
                'Greet locals with "Ayubowan" and both palms joined at chest height for a warm island welcome.',
          ),
        ],
      );
    }
  }

  void _showLanguageSelector() {
    showHelaLanguagePickerSheet(
      context,
      onLanguageSelected: (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = HelaAppStateProvider.of(context);
    final activeLanguageName = LocalizationService.getLanguage(
      appState.selectedLanguage,
    ).nativeName;

    return Scaffold(
      backgroundColor: const Color(
        0xFFEAF8F4,
      ), // Mint page background matching reference
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Top App Bar
            _buildTopBar(activeLanguageName),

            // Status Bar & Weather Info
            _buildStatusAndWeatherBar(),

            // Chat Scrollable View
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  // Welcome Introduction Card
                  _buildWelcomeIntroCard(),

                  const SizedBox(height: 18),

                  // Messages list
                  ..._messages.map((msg) {
                    if (msg.isUser) {
                      return _buildUserMessageBubble(msg);
                    } else {
                      return _buildAiMessageCard(msg);
                    }
                  }),

                  // Typing indicator
                  if (_isAITyping) _buildTypingIndicator(),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Bottom Input Bar
            _buildBottomInputBar(),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TOP APP BAR
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTopBar(String languageName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.transparent,
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF0B2D25),
              size: 24,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),

          // HELA Avatar with green online dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFF0B3328),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.filter_vintage_rounded, // Gold lotus / seal icon
                    color: Color(0xFFDFAC6C),
                    size: 20,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 10),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      HelaAppStateProvider.of(context).tr('ask_hela'),
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B2D25),
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 15,
                      color: Color(0xFF296759),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  HelaAppStateProvider.of(context).tr('ask_hela_subtitle'),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4C756A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Language Dropdown Pill
          InkWell(
            onTap: _showLanguageSelector,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFC6EAE0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.translate_rounded,
                    size: 14,
                    color: Color(0xFF105B4B),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    languageName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B2D25),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: Color(0xFF4C756A),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // STATUS & WEATHER BAR
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildStatusAndWeatherBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left pill: Online • Island Intelligence Active
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFD4F3EA),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 7, color: Color(0xFF10B981)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    HelaAppStateProvider.of(
                      context,
                    ).tr('online_intelligence_active'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F5444),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right text: Live Weather & Location info (tap to refresh)
          Tooltip(
            message: _liveWeather != null
                ? 'Live via ${_liveWeather!.source} • Tap to refresh'
                : 'Fetching live temperature & location',
            child: InkWell(
              onTap: () => _refreshLiveWeather(requestPermissionIfNeeded: true),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.thermostat_rounded,
                      size: 15,
                      color: Color(0xFF38685C),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _liveWeather?.formattedLabel ??
                          (_isWeatherLoading ? 'Locating...' : '--°C'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF38685C),
                      ),
                    ),
                    if (_isWeatherLoading) ...[
                      const SizedBox(width: 5),
                      const SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Color(0xFF38685C),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // WELCOME INTRO CARD
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildWelcomeIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with leaf icon and headers
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF0B3328),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.eco_rounded,
                    color: Color(0xFF22C55E),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HelaAppStateProvider.of(context).tr('ask_hela_welcome_title'),
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0C2B23),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      HelaAppStateProvider.of(context).tr('ask_hela_welcome_sub'),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF426C60),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Description Paragraph
          const Text(
            'I provide real-time travel tips, cultural etiquette, verified historical lore, train schedules, and weather-smart routes tailored to your journey.',
            style: TextStyle(
              fontSize: 13,
              height: 1.42,
              color: Color(0xFF2C564B),
            ),
          ),

          const SizedBox(height: 16),

          // Suggested Inquiries Section
          const Text(
            'SUGGESTED INQUIRIES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Color(0xFF487366),
            ),
          ),

          const SizedBox(height: 10),

          // Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip(
                icon: Icons.temple_buddhist_rounded,
                label: 'Temple etiquette',
                query:
                    'What should I know before visiting a Buddhist temple like Kandy\'s Temple of the Tooth?',
              ),
              _buildSuggestionChip(
                icon: Icons.landscape_rounded,
                label: 'History of Sigiriya',
                query:
                    'Tell me about the history, ancient frescoes, and climbing tips for Sigiriya Rock.',
              ),
              _buildSuggestionChip(
                icon: Icons.train_rounded,
                label: 'Scenic train tips',
                query:
                    'What are the departure times and tips for the Kandy to Ella scenic train?',
              ),
              _buildSuggestionChip(
                icon: Icons.electric_rickshaw_rounded,
                label: 'Tuk-tuk fair rates',
                query:
                    'What are the official meter tuk-tuk rates and travel advice in Sri Lanka?',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip({
    required IconData icon,
    required String label,
    required String query,
  }) {
    return InkWell(
      onTap: () => _handleSendMessage(query),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFE2F6EE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBDEADA)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF105B4B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F4D3F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // USER MESSAGE BUBBLE
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildUserMessageBubble(AskHelaMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFFD2F4EB), // User mint bubble color
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msg.text,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0D3128),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg.timeString,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B796D),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: Color(0xFF4B796D),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // AI RICH MESSAGE CARD
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildAiMessageCard(AskHelaMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HELA avatar
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2, right: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF0B3328),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.filter_vintage_rounded,
                color: Color(0xFFDFAC6C),
                size: 17,
              ),
            ),
          ),

          // Message Card Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Ayubowan! 🙏 and Verified Lore
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        msg.title ?? 'Ayubowan! 🙏',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0B2C24),
                        ),
                      ),
                      if (msg.badgeText != null)
                        Text(
                          msg.badgeText!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF467468),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Main Text Content
                  Text(
                    msg.text,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.42,
                      color: Color(0xFF29554A),
                    ),
                  ),

                  // Embedded Landmark Image
                  if (msg.imageUrl != null) ...[
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Image.network(
                            msg.imageUrl!,
                            height: 155,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 155,
                                  color: const Color(0xFF0B3328),
                                  child: const Center(
                                    child: Icon(
                                      Icons.temple_buddhist_rounded,
                                      color: Colors.white54,
                                      size: 40,
                                    ),
                                  ),
                                ),
                          ),
                          if (msg.imageCaption != null)
                            Positioned(
                              left: 10,
                              bottom: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 12,
                                      color: Color(0xFF9AE5D3),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      msg.imageCaption!,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],

                  // Bento Items
                  if (msg.bentoItems != null && msg.bentoItems!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...msg.bentoItems!.map(_buildBentoItem),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoItem(AskHelaBentoItem item) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFC2EBE0),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 16, color: const Color(0xFF0F5B4B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0B2D25),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: Color(0xFF356256),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF0B3328),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.filter_vintage_rounded,
                color: Color(0xFFDFAC6C),
                size: 16,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF105B4B),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Island Intelligence thinking...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF356256),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BOTTOM INPUT BAR
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildBottomInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8F4),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFCCE8DF).withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Row(
        children: [
          // Text Input Field
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFC6EAE0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: Color(0xFF105B4B),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _handleSendMessage,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF0B2D25),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Ask about temples, trains, food...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7FA89C),
                          fontWeight: FontWeight.w400,
                        ),
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Send Button
          GestureDetector(
            onTap: () => _handleSendMessage(_textController.text),
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFF0B3328),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x330B3328),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
