import 'package:flutter/material.dart';
import 'package:hela/state/app_state.dart';
import 'package:hela/theme/hela_colors.dart';

/// Available avatar presets for the explorer
class _AvatarPreset {
  final String label;
  final String url;
  const _AvatarPreset({required this.label, required this.url});
}

const List<_AvatarPreset> _avatarPresets = [
  _AvatarPreset(
    label: 'Highlands Explorer',
    url:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
  ),
  _AvatarPreset(
    label: 'Coastal Nomad',
    url:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
  ),
  _AvatarPreset(
    label: 'Heritage Guide',
    url:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
  ),
  _AvatarPreset(
    label: 'Tea Planter',
    url:
        'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=300&q=80',
  ),
  _AvatarPreset(
    label: 'Wildlife Trekker',
    url:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
  ),
];

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;

  String? _selectedPhotoUrl;
  bool _isSaving = false;
  bool _initialized = false;

  final Set<String> _selectedInterests = {
    '🌿 Eco-Havens',
    '🍃 Tea Estates',
    '🚂 Scenic Trains',
  };

  final List<String> _allInterests = const [
    '🌿 Eco-Havens',
    '🍃 Tea Estates',
    '🛕 Heritage & Temples',
    '🚂 Scenic Trains',
    '🐘 Wildlife Safaris',
    '🌊 Coastal Surfing',
    '🧘 Ayurveda & Wellness',
    '🍲 Ceylon Gastronomy',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      String currentName = 'Kavinda Wickramasinghe';
      String currentEmail = 'kavinda.w@gmail.com';
      String currentTitle = '🌿 Tea Country Pathfinder · Level 4';
      String currentBio =
          'Explorer of Ceylon highlands, tea estates, and ancient sanctuaries.';
      String currentPhone = '+94 77 123 4567';
      String currentLocation = 'Kandy, Central Province';
      String? currentPhoto;

      try {
        final appState = HelaAppStateProvider.of(context);
        currentName = appState.userName;
        currentEmail = appState.userEmail.isNotEmpty
            ? appState.userEmail
            : 'kavinda.w@gmail.com';
        currentTitle = appState.userTitle;
        currentBio = appState.userBio;
        currentPhone = appState.userPhone;
        currentLocation = appState.userLocation;
        currentPhoto = appState.userPhotoUrl;
      } catch (_) {}

      _nameController = TextEditingController(text: currentName);
      _titleController = TextEditingController(text: currentTitle);
      _emailController = TextEditingController(text: currentEmail);
      _phoneController = TextEditingController(text: currentPhone);
      _locationController = TextEditingController(text: currentLocation);
      _bioController = TextEditingController(text: currentBio);
      _selectedPhotoUrl = currentPhoto ?? _avatarPresets.first.url;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    try {
      final appState = HelaAppStateProvider.of(context);
      appState.updateProfile(
        name: _nameController.text.trim(),
        title: _titleController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        bio: _bioController.text.trim(),
        photoUrl: _selectedPhotoUrl,
      );
    } catch (_) {}

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: HelaColors.tertiaryFixed, size: 20),
            SizedBox(width: 10),
            Text(
              'Profile updated successfully!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: HelaColors.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop(true);
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: HelaColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Choose Explorer Portrait',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: HelaColors.primary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _avatarPresets.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final preset = _avatarPresets[index];
                      final isSelected = _selectedPhotoUrl == preset.url;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedPhotoUrl = preset.url);
                          Navigator.of(ctx).pop();
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 66,
                              height: 66,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? HelaColors.secondary
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  preset.url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: HelaColors.primaryContainer,
                                    child: const Icon(Icons.person,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 70,
                              child: Text(
                                preset.label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? HelaColors.primary
                                      : HelaColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = HelaAppStateProvider.of(context);
    return Scaffold(
      backgroundColor: HelaColors.surface,
      appBar: AppBar(
        backgroundColor: HelaColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: HelaColors.primary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          appState.tr('edit_profile'),
          style: const TextStyle(
            color: HelaColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: HelaColors.primary,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        color: HelaColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar Section ─────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 104,
                            height: 104,
                            padding: const EdgeInsets.all(3.5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFB8C34A), Color(0xFF7FA88A)],
                              ),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                _selectedPhotoUrl ?? _avatarPresets.first.url,
                                width: 97,
                                height: 97,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: HelaColors.primaryContainer,
                                  child: const Icon(
                                    Icons.person_rounded,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: _showAvatarPicker,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: HelaColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: HelaColors.surface,
                                    width: 2.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _showAvatarPicker,
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          child: Text(
                            'Change Portrait',
                            style: TextStyle(
                              color: HelaColors.secondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Personal Info Card ─────────────────────────
                _buildSectionHeader('Explorer Identity', Icons.badge_outlined),
                const SizedBox(height: 12),
                _buildCardContainer(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your name',
                      icon: Icons.person_outline_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _titleController,
                      label: 'Explorer Rank / Subtitle',
                      hint: 'e.g. 🌿 Tea Country Pathfinder · Level 4',
                      icon: Icons.spa_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Contact & Location Card ────────────────────
                _buildSectionHeader(
                    'Contact & Location', Icons.contact_mail_outlined),
                const SizedBox(height: 12),
                _buildCardContainer(
                  children: [
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'you@domain.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || !val.contains('@')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: '+94 77 123 4567',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _locationController,
                      label: 'Home Base / Province',
                      hint: 'e.g. Kandy, Central Province',
                      icon: Icons.location_on_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── About / Bio Card ───────────────────────────
                _buildSectionHeader('Bio & Travel Notes', Icons.notes_rounded),
                const SizedBox(height: 12),
                _buildCardContainer(
                  children: [
                    _buildTextField(
                      controller: _bioController,
                      label: 'About You',
                      hint: 'Share a note about your travel aspirations in Ceylon...',
                      icon: Icons.format_quote_rounded,
                      maxLines: 3,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Travel Interests ───────────────────────────
                _buildSectionHeader('Wanderlust Interests', Icons.interests_outlined),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: HelaColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: HelaColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allInterests.map((interest) {
                      final isSelected = _selectedInterests.contains(interest);
                      return FilterChip(
                        label: Text(interest),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedInterests.add(interest);
                            } else {
                              _selectedInterests.remove(interest);
                            }
                          });
                        },
                        selectedColor:
                            HelaColors.secondaryContainer.withValues(alpha: 0.6),
                        checkmarkColor: HelaColors.primary,
                        backgroundColor: HelaColors.surface,
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? HelaColors.primary
                              : HelaColors.onSurfaceVariant,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? HelaColors.secondary
                              : HelaColors.outlineVariant.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Save Button ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HelaColors.tertiaryFixed,
                      foregroundColor: HelaColors.onTertiaryFixed,
                      elevation: 2,
                      shadowColor: HelaColors.primary.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      disabledBackgroundColor:
                          HelaColors.tertiaryFixed.withValues(alpha: 0.5),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: HelaColors.onTertiaryFixed,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.save_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                appState.tr('save_changes'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: HelaColors.secondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: HelaColors.primary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HelaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HelaColors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: HelaColors.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: HelaColors.onSurfaceVariant,
        ),
        hintStyle: TextStyle(
          fontSize: 13,
          color: HelaColors.outline.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(icon, color: HelaColors.secondary, size: 18),
        filled: true,
        fillColor: HelaColors.surfaceContainerLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: HelaColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: HelaColors.secondary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: HelaColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: HelaColors.error, width: 1.5),
        ),
      ),
    );
  }
}
