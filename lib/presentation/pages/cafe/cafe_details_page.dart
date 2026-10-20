import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/services/cafe_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/cafe.dart';
import '../../blocs/cafe/cafe_bloc.dart';
import '../../blocs/cafe/cafe_event.dart';
import '../../blocs/cafe/cafe_state.dart';
import '../browse/browse_page.dart';

class CafeDetailsPage extends StatefulWidget {
  final int? cafeId;
  final Map<String, dynamic>? cafe; // For backward compatibility

  const CafeDetailsPage({
    super.key,
    this.cafeId,
    this.cafe,
  });

  @override
  State<CafeDetailsPage> createState() => _CafeDetailsPageState();
}

class _CafeDetailsPageState extends State<CafeDetailsPage>
    with SingleTickerProviderStateMixin {
  final PageController _photoController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _currentPhotoIndex = 0;
  bool _showStickyHeader = false;

  // Animation for sticky header
  late AnimationController _headerAnimController;
  late Animation<double> _headerScale;
  late Animation<double> _headerOpacity;

  int? get _effectiveCafeId {
    if (widget.cafeId != null) return widget.cafeId;
    if (widget.cafe != null && widget.cafe!['id'] != null) {
      return widget.cafe!['id'] as int;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Setup header animation
    _headerAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _headerScale = Tween<double>(begin: 2.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOutBack),
    );
    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOut),
    );
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 280;
    if (shouldShow != _showStickyHeader) {
      setState(() {
        _showStickyHeader = shouldShow;
      });
      if (shouldShow) {
        _headerAnimController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _photoController.dispose();
    _headerAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cafeId = _effectiveCafeId;

    if (cafeId == null) {
      return _buildFallbackPage();
    }

    return BlocProvider(
      create: (context) =>
          sl<CafeBloc>()..add(CafeFetchRequested(cafeId: cafeId)),
      child: BlocBuilder<CafeBloc, CafeState>(
        builder: (context, state) {
          if (state is CafeLoading) {
            return _buildLoadingPage();
          }

          if (state is CafeError) {
            return _buildErrorPage(context, state.message);
          }

          if (state is CafeLoaded) {
            return _buildCafeDetailsContent(context, state.cafe);
          }

          return _buildLoadingPage();
        },
      ),
    );
  }

  Widget _buildFallbackPage() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Cafe not found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPage() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Photo placeholder
                Container(
                  height: 420,
                  color: AppColors.divider.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                // Loading shimmer for content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPage(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load cafe',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  final cafeId = _effectiveCafeId;
                  if (cafeId != null) {
                    context.read<CafeBloc>().add(CafeFetchRequested(cafeId: cafeId));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Retry',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCafeDetailsContent(BuildContext context, Cafe cafe) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Photo Gallery with overlapping Card
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Photo Gallery
                    _buildPhotoGallery(cafe),

                    // Cafe Info Card - positioned to overlap
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: -60,
                      child: _buildCafeInfoCard(cafe),
                    ),
                  ],
                ),

                // Spacing to account for overlapping card
                const SizedBox(height: 80),

                // About Section
                if (cafe.about != null && cafe.about!.isNotEmpty)
                  _buildAboutSection(cafe),

                const SizedBox(height: 16),

                // Facilities
                if (cafe.facilities.isNotEmpty) _buildFacilitiesSection(cafe),

                const SizedBox(height: 16),

                // Manager Section
                if (cafe.managerName != null && cafe.managerName!.isNotEmpty)
                  _buildManagerSection(cafe),

                const SizedBox(height: 40),

                // Bottom padding for floating button
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Back Button (hidden when sticky header is shown)
          if (!_showStickyHeader)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

          // Sticky Header
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            top: _showStickyHeader ? 0 : -150,
            left: 0,
            right: 0,
            child: _buildStickyHeader(context, cafe),
          ),

          // Floating CTA Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFloatingCTA(cafe),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyHeader(BuildContext context, Cafe cafe) {
    final thumbnailUrl = cafe.thumbnailUrl;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Cafe mini card - left aligned
          Expanded(
            child: AnimatedBuilder(
              animation: _headerAnimController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _headerScale.value,
                  alignment: Alignment.centerLeft,
                  child: Opacity(
                    opacity: _headerOpacity.value,
                    child: child,
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cafe thumbnail
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.divider.withValues(alpha: 0.3),
                      image: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(thumbnailUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: thumbnailUrl == null || thumbnailUrl.isEmpty
                        ? const Icon(
                            Icons.store_rounded,
                            color: AppColors.textSecondary,
                            size: 18,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  // Cafe name and location
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cafe.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (cafe.city != null)
                          Text(
                            cafe.city!.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Open/Closed status - right
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cafe.isCurrentlyOpen
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cafe.isCurrentlyOpen
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  size: 14,
                  color: cafe.isCurrentlyOpen
                      ? AppColors.success
                      : AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  cafe.isCurrentlyOpen ? 'Open' : 'Closed',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cafe.isCurrentlyOpen
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery(Cafe cafe) {
    // Use photosUrl if available, otherwise fallback to thumbnailUrl
    final photos = cafe.photosUrl.isNotEmpty
        ? cafe.photosUrl
        : (cafe.thumbnailUrl != null && cafe.thumbnailUrl!.isNotEmpty
            ? [cafe.thumbnailUrl!]
            : <String>[]);

    return Stack(
      children: [
        // Photo PageView
        SizedBox(
          height: 420,
          child: photos.isEmpty
              ? Container(
                  color: AppColors.divider.withValues(alpha: 0.3),
                  child: const Center(
                    child: Icon(
                      Icons.store_rounded,
                      color: AppColors.textSecondary,
                      size: 64,
                    ),
                  ),
                )
              : PageView.builder(
                  controller: _photoController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPhotoIndex = index;
                    });
                  },
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photoUrl = photos[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.divider.withValues(alpha: 0.3),
                        image: photoUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(photoUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: photoUrl.isEmpty
                          ? const Center(
                              child: Icon(
                                Icons.store_rounded,
                                color: AppColors.textSecondary,
                                size: 64,
                              ),
                            )
                          : null,
                    );
                  },
                ),
        ),

        if (photos.length > 1) ...[
          // Photo indicators
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photos.length, (index) {
                final isActive = index == _currentPhotoIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // Photo count badge
          Positioned(
            bottom: 110,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.textPrimary,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_currentPhotoIndex + 1}/${photos.length}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCafeInfoCard(Cafe cafe) {
    final isOpen = cafe.isCurrentlyOpen;
    final openingHours = cafe.todayOpeningHours ?? '07:00 - 22:00';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cafe Name
          Text(
            cafe.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Address
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  cafe.city?.name ?? 'Location not available',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: [
              // Rating
              Expanded(
                child: _buildStatChip(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.warning,
                  value: '4.8',
                  label: '',
                ),
              ),
              const SizedBox(width: 8),

              // Status
              Expanded(
                child: _buildStatChip(
                  icon: isOpen ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  iconColor: isOpen ? AppColors.success : AppColors.error,
                  value: isOpen ? 'Open' : 'Closed',
                  label: '',
                ),
              ),
              const SizedBox(width: 8),

              // Hours
              Expanded(
                child: _buildStatChip(
                  icon: Icons.access_time_rounded,
                  iconColor: AppColors.success,
                  value: openingHours,
                  label: '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label.isNotEmpty ? '$value $label' : value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Cafe cafe) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            cafe.about!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesSection(Cafe cafe) {
    final facilities = cafe.facilities;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Facilities',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate item width: 4 items per row with spacing
              const itemsPerRow = 4;
              const spacing = 12.0;
              final itemWidth =
                  (constraints.maxWidth - (spacing * (itemsPerRow - 1))) /
                      itemsPerRow;

              return Wrap(
                spacing: spacing,
                runSpacing: 16,
                alignment: WrapAlignment.start,
                children: facilities
                    .map((facility) =>
                        _buildFacilityItem(facility, itemWidth))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityItem(String facility, double width) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.textSecondary.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Icon(
              _getFacilityIcon(facility),
              size: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            facility,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getFacilityIcon(String facility) {
    switch (facility.toLowerCase()) {
      case 'wifi':
        return Icons.wifi_rounded;
      case 'power':
        return Icons.power_rounded;
      case 'meeting':
        return Icons.meeting_room_rounded;
      case 'outdoor':
        return Icons.deck_rounded;
      case 'parking':
        return Icons.local_parking_rounded;
      case 'ac':
        return Icons.ac_unit_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'toilet':
        return Icons.wc_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  Widget _buildManagerSection(Cafe cafe) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meet Our Manager',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Manager Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 28,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 14),

              // Manager Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cafe.managerName!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Store Manager',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Contact Button
              GestureDetector(
                onTap: () {
                  // TODO: Contact manager
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showChangeCafeConfirmation(Cafe cafe) {
    final currentCafe = CafeService().selectedCafe;
    final isSameCafe = currentCafe['name'] == cafe.name;

    // If same cafe, just navigate without confirmation
    if (isSameCafe) {
      _proceedWithCafeSelection(cafe);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Change Cafe Location?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'You will change your order location from',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Cafe change indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    currentCafe['name'] ?? 'Unknown',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                Flexible(
                  child: Text(
                    cafe.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Confirm button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _proceedWithCafeSelection(cafe);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Yes, Change',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _proceedWithCafeSelection(Cafe cafe) async {
    // Save selected cafe to local storage
    final cafeToSave = {
      'id': cafe.id,
      'name': cafe.name,
      'address': cafe.city?.name ?? '',
      'isOpen': cafe.isCurrentlyOpen,
    };
    await CafeService().setSelectedCafe(cafeToSave);

    // Navigate to browse page and clear stack
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BrowsePage()),
        (route) => false,
      );
    }
  }

  Widget _buildFloatingCTA(Cafe cafe) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _showChangeCafeConfirmation(cafe),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.coffee_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Make Order Now',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
