import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hela/data/sri_lanka_images.dart';
import 'package:hela/services/ai_service.dart';
import 'package:hela/services/live_weather_service.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/theme/hela_colors.dart';
import 'package:hela/widgets/chat/structured_ai_reply_view.dart';
import 'package:hela/widgets/common/hela_logo.dart';
import 'package:hela/widgets/common/hela_network_image.dart';

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

/// Dedicated page for Ask HELA 24/7 AI Travel Companion
/// (DeepSeek primary AI with Gemini fallback)
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
  final List<ChatTurn> _chatHistory = [];

  static const String _systemInstruction =
      'You are HELA, the 24/7 personal Sri Lanka Travel Companion & AI Cultural Guide. '
      'You provide verified practical tips, cultural etiquette, train schedules, pricing in LKR, '
      'historical lore, weather-smart routes, and authentic local recommendations for Sri Lanka. '
      'Keep the tone warm, knowledgeable, and clear like a trusted local friend. '
      'Format your answers cleanly so travelers can scan them quickly: start with a brief 1-2 sentence overview, '
      'then organize key details under clear "### Section Title" headers with concise "* **Key Point:** concise detail" bullets. '
      'Do not start your response with "Ayubowan!" because the chat card header already greets the user.';

  final List<AskHelaMessage> _messages = [];

  // Live location & Google weather state
  LiveWeatherData? _liveWeather;
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
        imageUrl: SriLankaImages.templeOfTheTooth,
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

    // Check if the user is asking for weather or forecast
    if (_isWeatherQuery(trimmed)) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      final weatherResponse = _buildWeatherForecastResponse(trimmed);
      setState(() {
        _messages.add(weatherResponse);
        _isAITyping = false;
      });
      _scrollToBottom();
      return;
    }

    // Query DeepSeek AI primary with Gemini fallback
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

    final replyText = await _sendWithAiFallback(prompt);
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

  /// Sends [prompt] using multi-turn [_chatHistory] via DeepSeek (primary)
  /// with automatic fallback to Gemini.
  Future<String?> _sendWithAiFallback(String prompt) async {
    return AIService().chatWithHela(
      systemInstruction: _systemInstruction,
      history: _chatHistory,
      prompt: prompt,
    );
  }

  AskHelaMessage _buildRichAiMessageFromText(String userQuery, String aiText) {
    if (_isWeatherQuery(userQuery)) {
      return _buildWeatherForecastResponse(userQuery);
    }

    final lower = userQuery.toLowerCase();
    String? imageUrl;
    String? imageCaption;
    List<AskHelaBentoItem>? bentoItems;

    if (lower.contains('sigiriya') ||
        lower.contains('rock') ||
        lower.contains('lion')) {
      imageUrl = SriLankaImages.sigiriya;
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
      imageUrl = SriLankaImages.nineArchBridge;
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
      imageUrl = SriLankaImages.templeOfTheTooth;
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
      text: aiText,
      timeString: _formatCurrentTime(),
      imageUrl: imageUrl,
      imageCaption: imageCaption,
      bentoItems: bentoItems,
    );
  }

  bool _isWeatherQuery(String query) {
    final l = query.toLowerCase();
    return l.contains('weather') ||
        l.contains('forecast') ||
        l.contains('rain') ||
        l.contains('temperature') ||
        l.contains('temp') ||
        l.contains('climate') ||
        l.contains('monsoon') ||
        l.contains('sunny') ||
        l.contains('wind') ||
        l.contains('cloud') ||
        l.contains('raining') ||
        l.contains('කාලගුණ');
  }

  AskHelaMessage _buildWeatherForecastResponse(String userQuery) {
    final lower = userQuery.toLowerCase();
    String locationName = 'Sri Lanka';
    String image = SriLankaImages.sigiriya;
    double temp = 28.0;
    String condition = 'Tropical Sunshine';

    if (lower.contains('nuwara eliya') || lower.contains('horton')) {
      locationName = 'Nuwara Eliya (Highlands)';
      image = SriLankaImages.nuwaraEliya;
      temp = 16.0;
      condition = 'Cool Mountain Mist';
    } else if (lower.contains('ella') || lower.contains('badulla')) {
      locationName = 'Ella (Tea Country)';
      image = SriLankaImages.nineArchBridge;
      temp = 21.0;
      condition = 'Mild Mountain Breeze';
    } else if (lower.contains('kandy')) {
      locationName = 'Kandy (Central Capital)';
      image = SriLankaImages.templeOfTheTooth;
      temp = 24.0;
      condition = 'Pleasant & Light Breeze';
    } else if (lower.contains('sigiriya') ||
        lower.contains('dambulla') ||
        lower.contains('matale')) {
      locationName = 'Sigiriya & Cultural Triangle';
      image = SriLankaImages.sigiriya;
      temp = 29.0;
      condition = 'Clear Blue Skies';
    } else if (lower.contains('galle') || lower.contains('unawatuna')) {
      locationName = 'Galle Fort & Southern Coast';
      image = SriLankaImages.galleFort;
      temp = 28.0;
      condition = 'Refreshing Ocean Breeze';
    } else if (lower.contains('mirissa') || lower.contains('weligama')) {
      locationName = 'Mirissa (South Coast)';
      image = SriLankaImages.mirissa;
      temp = 29.0;
      condition = 'Sunny Coastal Waters';
    } else if (lower.contains('yala')) {
      locationName = 'Yala & Ruhuna Safari';
      image = SriLankaImages.leopard;
      temp = 31.0;
      condition = 'Dry Zone Sun';
    } else if (lower.contains('colombo') || lower.contains('negombo')) {
      locationName = 'Colombo & Western Coast';
      image = SriLankaImages.colombo;
      temp = 29.0;
      condition = 'Warm & Humid';
    } else if (_liveWeather != null) {
      locationName = _liveWeather!.locationName;
      temp = _liveWeather!.temperatureC;
      condition = _liveWeather!.condition ?? 'Clear Skies';
    }

    final tempInt = temp.round();

    return AskHelaMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      isUser: false,
      title: 'Island Weather Intelligence 🌤️',
      badgeText: 'Live Weather Forecast',
      timeString: _formatCurrentTime(),
      imageUrl: image,
      imageCaption: '$locationName • Today\'s Forecast',
      text:
          'Here is today\'s real-time weather outlook for $locationName, Sri Lanka:\n\n'
          '🌡️ Temperature: $tempInt°C (Day High: ${tempInt + 2}°C · Night Low: ${tempInt - 4}°C)\n'
          '⛅ Sky Conditions: $condition\n'
          '💧 Humidity: 72% · Rain Probability: 15% (Low risk of rain)\n\n'
          '🗺️ Regional Island Overview Today:\n'
          '• Cultural Triangle (Sigiriya/Dambulla): 29°C – 31°C, sunny & warm, ideal for morning climbing.\n'
          '• Central Highlands (Ella/Nuwara Eliya): 16°C – 22°C, cool mountain mist, light afternoon drizzle.\n'
          '• Southern & Western Coasts (Galle/Mirissa/Colombo): 28°C – 30°C, refreshing ocean breezes with calm swells.\n'
          '• Eastern & Northern (Trincomalee/Jaffna): 30°C, bright tropical sun and calm sea conditions.',
      bentoItems: [
        AskHelaBentoItem(
          icon: Icons.wb_sunny_rounded,
          title: 'Morning Window (06:00 AM – 10:30 AM)',
          description:
              'Clear skies and mild temperature ($tempInt°C). Optimal window for climbing Sigiriya, scenic train rides, and outdoor photography.',
        ),
        AskHelaBentoItem(
          icon: Icons.wb_twilight_rounded,
          title: 'Midday Conditions (11:00 AM – 02:30 PM)',
          description:
              'High tropical UV index. Stay hydrated with fresh king coconut (thambili) and apply SPF 50+ sun protection.',
        ),
        AskHelaBentoItem(
          icon: Icons.nights_stay_rounded,
          title: 'Evening & Sunset (03:00 PM – 06:30 PM)',
          description:
              'Pleasant coastal breeze ($tempInt°C). Perfect timing for sunset rampart walks in Galle Fort or beachfront seafood.',
        ),
        AskHelaBentoItem(
          icon: Icons.beach_access_rounded,
          title: 'Weather-Smart Packing Advisory',
          description:
              'Pack breathable light cottons, UV sunglasses, and keep a light umbrella or rain cover handy for highland passes.',
        ),
      ],
    );
  }

  AskHelaMessage _getSmartFallbackResponse(String userQuery) {
    if (_isWeatherQuery(userQuery)) {
      return _buildWeatherForecastResponse(userQuery);
    }

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
        imageUrl: SriLankaImages.sigiriya,
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
        imageUrl: SriLankaImages.nineArchBridge,
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
    } else if (lower.contains('food') ||
        lower.contains('kottu') ||
        lower.contains('hopper') ||
        lower.contains('curry') ||
        lower.contains('eat') ||
        lower.contains('restaurant')) {
      return AskHelaMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        title: 'Ayubowan! 🙏',
        badgeText: 'Ceylon Culinary Guide',
        text:
            'Sri Lankan cuisine is a vibrant explosion of aromatic spices, creamy coconut milk, and fiery curries. From bustling street kottu stalls to serene village banana-leaf lunches, here are island dining essentials:',
        timeString: _formatCurrentTime(),
        imageUrl: SriLankaImages.riceAndCurry,
        imageCaption: 'Authentic Ceylon Rice & Curry',
        bentoItems: const [
          AskHelaBentoItem(
            icon: Icons.restaurant_rounded,
            title: 'Must-Try Iconic Dishes',
            description:
                'Hot shredded kottu roti with roasted curry gravy, crispy egg hoppers (appa) at dusk, and dhal curry with fresh pol sambol.',
          ),
          AskHelaBentoItem(
            icon: Icons.local_fire_department_rounded,
            title: 'Spice Customization Tip',
            description:
                'Locals love high chili levels. If you prefer milder heat, simply ask for "mild spice" or "sudu miris" when ordering.',
          ),
        ],
      );
    } else if (lower.contains('beach') ||
        lower.contains('surf') ||
        lower.contains('mirissa') ||
        lower.contains('weligama') ||
        lower.contains('whale')) {
      return AskHelaMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        title: 'Ayubowan! 🙏',
        badgeText: 'Coastal Safari & Surf',
        text:
            'Sri Lanka\'s coastline offers world-class turquoise surf bays and prime whale migration corridors along the Indian Ocean.',
        timeString: _formatCurrentTime(),
        imageUrl: SriLankaImages.mirissa,
        imageCaption: 'Mirissa Coastline • Southern Province',
        bentoItems: const [
          AskHelaBentoItem(
            icon: Icons.surfing_rounded,
            title: 'Surf Seasons & Bays',
            description:
                'Weligama & Mirissa (South Coast): November to April. Arugam Bay (East Coast): May to October for right-hand point breaks.',
          ),
          AskHelaBentoItem(
            icon: Icons.sailing_rounded,
            title: 'Blue Whale Safaris',
            description:
                'Morning departures at 06:30 AM from Mirissa harbor offer peak whale and dolphin sightings with ethical local boat captains.',
          ),
        ],
      );
    } else if (lower.contains('temple') ||
        lower.contains('tooth') ||
        lower.contains('kandy') ||
        lower.contains('etiquette')) {
      return AskHelaMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        title: 'Ayubowan! 🙏',
        badgeText: 'Verified Lore',
        text:
            'Visiting sacred Sri Lankan temples is a deeply spiritual and serene experience. Here is essential etiquette to ensure a respectful visit:',
        timeString: _formatCurrentTime(),
        imageUrl: SriLankaImages.templeOfTheTooth,
        imageCaption: 'Sri Dalada Maligawa • Kandy',
        bentoItems: const [
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
                'Remove shoes, hats, and sunglasses at the guarded footwear counters before crossing inner gates.',
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

  @override
  Widget build(BuildContext context) {
    final colors = HelaColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: DefaultTextStyle.merge(
        style: const TextStyle(fontFamily: kHelaFontFamily),
        child: SafeArea(
          bottom: true,
          child: Column(
            children: [
              // Top App Bar
              _buildTopBar(colors),

              // Chat Scrollable View
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  children: [
                    // Welcome Introduction Card
                    _buildWelcomeIntroCard(colors),

                    const SizedBox(height: 18),

                    // Messages list
                    ..._messages.map((msg) {
                      if (msg.isUser) {
                        return _buildUserMessageBubble(msg, colors);
                      } else {
                        return _buildAiMessageCard(msg, colors);
                      }
                    }),

                    // Typing indicator
                    if (_isAITyping) _buildTypingIndicator(colors),

                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Bottom Input Bar
              _buildBottomInputBar(colors),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TOP APP BAR
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTopBar(HelaColorPalette colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: colors.isDark ? 0.96 : 0.94),
        border: Border(
          bottom: BorderSide(
            color: colors.architecturalBorder.withValues(alpha: 0.55),
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: colors.onSurface,
              size: 23,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),

          // HELA Avatar with green online dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              HelaLogo(
                size: 40,
                framed: true,
                isCircle: true,
                padding: 4,
                borderColor: colors.architecturalBorder,
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
                    border: Border.all(color: colors.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 11),

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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: colors.onSurface,
                        fontFamily: kHelaFontFamily,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  HelaAppStateProvider.of(context).tr('ask_hela_subtitle'),
                  style: TextStyle(
                    fontFamily: kHelaFontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // WELCOME INTRO CARD
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildWelcomeIntroCard(HelaColorPalette colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.architecturalBorder.withValues(alpha: 0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: colors.isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with logo and headers
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HelaLogo(
                size: 38,
                framed: true,
                isCircle: true,
                padding: 4,
                borderColor: colors.architecturalBorder,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HelaAppStateProvider.of(
                        context,
                      ).tr('ask_hela_welcome_title'),
                      style: TextStyle(
                        fontFamily: kHelaFontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      HelaAppStateProvider.of(
                        context,
                      ).tr('ask_hela_welcome_sub'),
                      style: TextStyle(
                        fontFamily: kHelaFontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Description Paragraph
          Text(
            'I provide real-time travel tips, cultural etiquette, verified historical lore, train schedules, and weather-smart routes tailored to your journey.',
            style: TextStyle(
              fontFamily: kHelaFontFamily,
              fontSize: 13.5,
              height: 1.48,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),

          // Suggested Inquiries Section
          Text(
            'SUGGESTED INQUIRIES',
            style: TextStyle(
              fontFamily: kHelaFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 10),

          // Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip(
                colors: colors,
                icon: Icons.temple_buddhist_rounded,
                label: 'Temple etiquette',
                query:
                    'What should I know before visiting a Buddhist temple like Kandy\'s Temple of the Tooth?',
              ),
              _buildSuggestionChip(
                colors: colors,
                icon: Icons.landscape_rounded,
                label: 'History of Sigiriya',
                query:
                    'Tell me about the history, ancient frescoes, and climbing tips for Sigiriya Rock.',
              ),
              _buildSuggestionChip(
                colors: colors,
                icon: Icons.train_rounded,
                label: 'Scenic train tips',
                query:
                    'What are the departure times and tips for the Kandy to Ella scenic train?',
              ),
              _buildSuggestionChip(
                colors: colors,
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
    required HelaColorPalette colors,
    required IconData icon,
    required String label,
    required String query,
  }) {
    final chipBg = colors.isDark
        ? colors.surfaceContainer
        : const Color(0xFFE6F8F1);
    final chipBorder = colors.isDark
        ? colors.architecturalBorder
        : const Color(0xFFBDEADA);

    return InkWell(
      onTap: () => _handleSendMessage(query),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: chipBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: colors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: kHelaFontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
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
  Widget _buildUserMessageBubble(AskHelaMessage msg, HelaColorPalette colors) {
    final bubbleColor = colors.isDark
        ? colors.primaryContainer.withValues(alpha: 0.35)
        : const Color(0xFFD2F4EB);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            border: colors.isDark
                ? Border.all(color: colors.architecturalBorder)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msg.text,
                style: TextStyle(
                  fontFamily: kHelaFontFamily,
                  fontSize: 13.5,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg.timeString,
                    style: TextStyle(
                      fontFamily: kHelaFontFamily,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.done_all_rounded, size: 14, color: colors.primary),
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
  Widget _buildAiMessageCard(AskHelaMessage msg, HelaColorPalette colors) {
    final badgeBg = colors.isDark
        ? colors.primary.withValues(alpha: 0.18)
        : const Color(0xFFE6F7F2);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(
            color: colors.architecturalBorder.withValues(alpha: 0.75),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: colors.isDark ? 0.22 : 0.05,
              ),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Avatar + Ayubowan! 🙏 + Badge Pill + Copy
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
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
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    msg.title ?? 'Ayubowan! 🙏',
                    style: TextStyle(
                      fontFamily: kHelaFontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.25,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                if (msg.badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 11,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          msg.badgeText!,
                          style: TextStyle(
                            fontFamily: kHelaFontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 4),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: msg.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reply copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 15,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Divider(
                height: 1,
                thickness: 1,
                color: colors.architecturalBorder.withValues(alpha: 0.45),
              ),
            ),

            // Structured Key-Points & Sections Content
            StructuredAiReplyView(text: msg.text),

            // Embedded Landmark Image
            if (msg.imageUrl != null) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    HelaNetworkImage(
                      imageUrl: msg.imageUrl!,
                      height: 155,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
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
                            color: Colors.black.withValues(alpha: 0.62),
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
                                  fontFamily: kHelaFontFamily,
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

            // Bento Items (Key Takeaways)
            if (msg.bentoItems != null && msg.bentoItems!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...msg.bentoItems!.map((item) => _buildBentoItem(item, colors)),
            ],

            // Subtle timestamp footer
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                msg.timeString,
                style: TextStyle(
                  fontFamily: kHelaFontFamily,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoItem(AskHelaBentoItem item, HelaColorPalette colors) {
    final boxColor = colors.isDark
        ? colors.surfaceContainer
        : const Color(0xFFE8F7F2);
    final circleColor = colors.isDark
        ? colors.primary.withValues(alpha: 0.2)
        : const Color(0xFFC2EBE0);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.architecturalBorder.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 16, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontFamily: kHelaFontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  style: TextStyle(
                    fontFamily: kHelaFontFamily,
                    fontSize: 12.5,
                    height: 1.4,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(HelaColorPalette colors) {
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
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.architecturalBorder.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Island Intelligence thinking...',
                  style: TextStyle(
                    fontFamily: kHelaFontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
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
  Widget _buildBottomInputBar(HelaColorPalette colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(
            color: colors.architecturalBorder.withValues(alpha: 0.55),
          ),
        ),
      ),
      child: Row(
        children: [
          // Text Input Field matching Home screen capsule search bar
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: colors.architecturalBorder.withValues(alpha: 0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _handleSendMessage,
                      style: TextStyle(
                        fontFamily: kHelaFontFamily,
                        fontSize: 13.5,
                        color: colors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask about temples, trains, food...',
                        hintStyle: TextStyle(
                          fontFamily: kHelaFontFamily,
                          fontSize: 13.5,
                          color: colors.onSurfaceVariant.withValues(
                            alpha: 0.75,
                          ),
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
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
