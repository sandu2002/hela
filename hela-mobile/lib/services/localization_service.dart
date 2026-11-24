/// Central Localization Service for HELA Travel Companion.
///
/// Provides localized translations for UI strings across supported languages:
/// - EN: English
/// - SI: Sinhala (සිංහල)
/// - TA: Tamil (தமிழ்)
/// - DE: German (Deutsch)
/// - FR: French (Français)
/// - ZH: Chinese (中文)
/// - RU: Russian (Русский)
class HelaLanguageItem {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const HelaLanguageItem({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

class LocalizationService {
  static const List<HelaLanguageItem> supportedLanguages = [
    HelaLanguageItem(code: 'EN', name: 'English (US)', nativeName: 'English', flag: '🇺🇸'),
    HelaLanguageItem(code: 'SI', name: 'සිංහල (Sinhala)', nativeName: 'සිංහල', flag: '🇱🇰'),
    HelaLanguageItem(code: 'TA', name: 'தமிழ் (Tamil)', nativeName: 'தமிழ்', flag: '🇱🇰'),
    HelaLanguageItem(code: 'DE', name: 'Deutsch (German)', nativeName: 'Deutsch', flag: '🇩🇪'),
    HelaLanguageItem(code: 'FR', name: 'Français (French)', nativeName: 'Français', flag: '🇫🇷'),
    HelaLanguageItem(code: 'ZH', name: '中文 (Mandarin)', nativeName: '中文', flag: '🇨🇳'),
    HelaLanguageItem(code: 'RU', name: 'Русский (Russian)', nativeName: 'Русский', flag: '🇷🇺'),
  ];

  static HelaLanguageItem getLanguage(String code) {
    return supportedLanguages.firstWhere(
      (l) => l.code.toUpperCase() == code.toUpperCase(),
      orElse: () => supportedLanguages.first,
    );
  }

  static String getDisplayName(String code) {
    return getLanguage(code).name;
  }

  static final Map<String, Map<String, String>> _translations = {
    'EN': {
      'language': 'Language',
      'select_language': 'Select Language',
      'language_desc': 'Choose your preferred language for island discovery.',
      'get_started': 'Get Started',
      'skip': 'Skip',
      'next': 'Next',
      'begin_journey': 'Begin Your Journey',
      'ayubowan': 'Ayubowan',
      'island_story_awaits': 'Your Island Story Awaits',
      'explore_every_corner': 'Explore Every Corner',
      'welcome_subtitle': 'Unlock personalized AI itineraries, verified tuk-tuk fares, and scenic tea train connections across Sri Lanka.',
      'settings': 'Settings',
      'language_updated': 'Language updated to',
      'sign_in': 'Sign In',
      'create_account': 'Create HELA Account',
      'home': 'Home',
      'explore': 'Explore',
      'trip_planner': 'Trip Planner',
      'bookings': 'Bookings',
      'profile': 'Profile',
    },
    'SI': {
      'language': 'භාෂාව',
      'select_language': 'භාෂාව තෝරන්න',
      'language_desc': 'ශ්‍රී ලංකා සංචාරය සඳහා ඔබ කැමති භාෂාව තෝරාගන්න.',
      'get_started': 'ආරම්භ කරමු',
      'skip': 'මඟහරින්න',
      'next': 'ඉදිරියට',
      'begin_journey': 'ඔබගේ සංචාරය අරඹන්න',
      'ayubowan': 'ආයුබෝවන්',
      'island_story_awaits': 'ඔබේ ශ්‍රී ලාංකීය චාරිකාව ඇරඹේ',
      'explore_every_corner': 'සෑම අස්සක් මුල්ලක්ම ගවේෂණය කරන්න',
      'welcome_subtitle': 'AI ගමන් විස්තර, තහවුරු කළ ත්‍රිරෝද රථ ගාස්තු, සහ දුම්රිය වේලාවන් සජීවීව දැනගන්න.',
      'settings': 'සැකසීම්',
      'language_updated': 'භාෂාව වෙනස් කරන ලදී:',
      'sign_in': 'ඇතුල් වන්න',
      'create_account': 'HELA ගිණුමක් සාදන්න',
      'home': 'මුල් පිටුව',
      'explore': 'ගවේෂණය',
      'trip_planner': 'සංචාර සැලසුම',
      'bookings': 'වෙන්කිරීම්',
      'profile': 'පැතිකඩ',
    },
    'TA': {
      'language': 'மொழி',
      'select_language': 'மொழியைத் தேர்ந்தெடுக்கவும்',
      'language_desc': 'தீவை ஆராய்வதற்கு உங்கள் விருப்பமான மொழியைத் தேர்ந்தெடுக்கவும்.',
      'get_started': 'தொடங்குங்கள்',
      'skip': 'தவிர்',
      'next': 'அடுத்து',
      'begin_journey': 'உங்கள் பயணத்தைத் தொடங்குங்கள்',
      'ayubowan': 'வணக்கம்',
      'island_story_awaits': 'உங்கள் தீவுப் பயணம் காத்திருக்கிறது',
      'explore_every_corner': 'ஒவ்வொரு மூலையையும் ஆராயுங்கள்',
      'welcome_subtitle': 'தனிப்பயனாக்கப்பட்ட AI பயணத்திட்டங்கள் மற்றும் நேரடி ரயில் அட்டவணைகளை அணுகுங்கள்.',
      'settings': 'அமைப்புகள்',
      'language_updated': 'மொழி மாற்றப்பட்டது:',
      'sign_in': 'உள்நுழையவும்',
      'create_account': 'HELA கணக்கை உருவாக்கவும்',
      'home': 'முகப்பு',
      'explore': 'ஆராய்க',
      'trip_planner': 'பயணத் திட்டம்',
      'bookings': 'பதிவுகள்',
      'profile': 'சுயவிவரம்',
    },
    'DE': {
      'language': 'Sprache',
      'select_language': 'Sprache wählen',
      'language_desc': 'Wählen Sie Ihre bevorzugte Sprache für die Entdeckung Sri Lankas.',
      'get_started': 'Loslegen',
      'skip': 'Überspringen',
      'next': 'Weiter',
      'begin_journey': 'Beginnen Sie Ihre Reise',
      'ayubowan': 'Ayubowan',
      'island_story_awaits': 'Ihre Inselgeschichte erwartet Sie',
      'explore_every_corner': 'Entdecke jeden Winkel',
      'welcome_subtitle': 'Personalisierte KI-Reiserouten, verifizierte Tuk-Tuk-Preise und malerische Zugverbindungen.',
      'settings': 'Einstellungen',
      'language_updated': 'Sprache aktualisiert auf',
      'sign_in': 'Anmelden',
      'create_account': 'HELA-Konto erstellen',
      'home': 'Start',
      'explore': 'Entdecken',
      'trip_planner': 'Reiseplaner',
      'bookings': 'Buchungen',
      'profile': 'Profil',
    },
    'FR': {
      'language': 'Langue',
      'select_language': 'Sélectionner la langue',
      'language_desc': 'Choisissez votre langue préférée pour explorer le Sri Lanka.',
      'get_started': 'Commencer',
      'skip': 'Passer',
      'next': 'Suivant',
      'begin_journey': 'Commencez votre voyage',
      'ayubowan': 'Ayubowan',
      'island_story_awaits': 'Votre aventure insulaire vous attend',
      'explore_every_corner': 'Explorez chaque recoin',
      'welcome_subtitle': 'Itinéraires personnalisés par IA, tarifs tuk-tuk vérifiés et liaisons ferroviaires.',
      'settings': 'Paramètres',
      'language_updated': 'Langue mise à jour en',
      'sign_in': 'Se connecter',
      'create_account': 'Créer un compte HELA',
      'home': 'Accueil',
      'explore': 'Explorer',
      'trip_planner': 'Planificateur',
      'bookings': 'Réservations',
      'profile': 'Profil',
    },
    'ZH': {
      'language': '语言',
      'select_language': '选择语言',
      'language_desc': '选择探索斯里兰卡的首选语言。',
      'get_started': '开始使用',
      'skip': '跳过',
      'next': '下一步',
      'begin_journey': '开启您的旅程',
      'ayubowan': '阿尤博旺',
      'island_story_awaits': '您的岛屿探险等待着您',
      'explore_every_corner': '探索每个角落',
      'welcome_subtitle': '获取个性化AI行程、经过验证的突突车费用和斯里兰卡风景火车时刻表。',
      'settings': '设置',
      'language_updated': '语言已更新为',
      'sign_in': '登录',
      'create_account': '创建HELA账户',
      'home': '首页',
      'explore': '探索',
      'trip_planner': '行程规划',
      'bookings': '预订',
      'profile': '个人资料',
    },
    'RU': {
      'language': 'Язык',
      'select_language': 'Выберите язык',
      'language_desc': 'Выберите предпочитаемый язык для знакомства со Шри-Ланкой.',
      'get_started': 'Начать',
      'skip': 'Пропустить',
      'next': 'Далее',
      'begin_journey': 'Начните свое путешествие',
      'ayubowan': 'Аюбован',
      'island_story_awaits': 'Ваша история на острове начинается',
      'explore_every_corner': 'Исследуйте каждый уголок',
      'welcome_subtitle': 'Персонализированные маршруты ИИ, проверенные тарифы на тук-тук и расписание поездов.',
      'settings': 'Настройки',
      'language_updated': 'Язык изменен на',
      'sign_in': 'Войти',
      'create_account': 'Создать аккаунт HELA',
      'home': 'Главная',
      'explore': 'Обзор',
      'trip_planner': 'Планировщик',
      'bookings': 'Бронирования',
      'profile': 'Профиль',
    },
  };

  /// Translate a key into the active language, falling back to English.
  static String tr(String key, String langCode) {
    final code = langCode.toUpperCase();
    if (_translations.containsKey(code) && _translations[code]!.containsKey(key)) {
      return _translations[code]![key]!;
    }
    return _translations['EN']?[key] ?? key;
  }
}
