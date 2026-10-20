import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/cafe.dart';
import '../../blocs/cafe/cafe_bloc.dart';
import '../../blocs/cafe/cafe_event.dart';
import '../../blocs/cafe/cafe_state.dart';
import '../cafe/cafe_details_page.dart';

class CityDetailsPage extends StatefulWidget {
  final String cityName;
  final String cityImage;
  final int cafesCount;
  final int? cityId;

  const CityDetailsPage({
    super.key,
    required this.cityName,
    required this.cityImage,
    required this.cafesCount,
    this.cityId,
  });

  @override
  State<CityDetailsPage> createState() => _CityDetailsPageState();
}

class _CityDetailsPageState extends State<CityDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showStickyHeader = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 180;
    if (shouldShow != _showStickyHeader) {
      setState(() {
        _showStickyHeader = shouldShow;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = sl<CafeBloc>();
        if (widget.cityId != null) {
          bloc.add(CafesByCityFetchRequested(cityId: widget.cityId!));
        }
        return bloc;
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Banner with City Image
                _buildHeroSection(context),
                const SizedBox(height: 24),
                // Cafes List
                _buildCafesSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // Sticky Header (appears when scrolling down with slide animation)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            top: _showStickyHeader ? 0 : -150,
            left: 0,
            right: 0,
            child: _buildStickyHeader(context),
          ),
        ],
      ),
    );
  }

  /// Sticky Header that appears when scrolling
  Widget _buildStickyHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 22,
        left: 20,
        right: 20,
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
          const SizedBox(width: 16),

          // City name and cafe count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.cityName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${widget.cafesCount} Awake Cafes',
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),

          // Location icon
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner with location icon
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Image Banner
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                color: AppColors.primary.withValues(alpha: 0.2),
                image: widget.cityImage.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(widget.cityImage),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Location Icon Circle - positioned at bottom center
            Positioned(
              bottom: -30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
        // City name and cafe count
        const SizedBox(height: 44),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.cityName,
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.cafesCount} Awake Cafes',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCafesSection() {
    if (widget.cityId == null) {
      return _buildNoCityIdState();
    }

    return BlocBuilder<CafeBloc, CafeState>(
      builder: (context, state) {
        if (state is CafeLoading) {
          return _buildCafeLoadingShimmer();
        }

        if (state is CafeError) {
          return _buildCafeErrorState(context, state.message);
        }

        if (state is CafesLoaded) {
          return _buildCafesList(state.cafes);
        }

        // Initial state - show loading
        return _buildCafeLoadingShimmer();
      },
    );
  }

  Widget _buildNoCityIdState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: AppColors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load cafes',
              style: AppTextStyles.bodySemibold,
            ),
            const SizedBox(height: 4),
            Text(
              'City information is incomplete',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCafesList(List<Cafe> cafes) {
    if (cafes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.store_outlined,
                color: AppColors.textSecondary,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'No cafes available',
                style: AppTextStyles.bodySemibold,
              ),
              const SizedBox(height: 4),
              Text(
                'There are no Awake cafes in this city yet',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: cafes.map((cafe) => _buildCafeCard(cafe)).toList(),
      ),
    );
  }

  Widget _buildCafeCard(Cafe cafe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CafeDetailsPage(
              cafe: {
                'id': cafe.id,
                'name': cafe.name,
                'slug': cafe.slug,
                'address': cafe.city?.name ?? widget.cityName,
                'about': cafe.about,
                'facilities': cafe.facilities,
                'imageUrl': cafe.thumbnailUrl ?? '',
                'isOpen': true, // TODO: Calculate from time slots
                'rating': 4.8, // TODO: Get from backend
              },
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cafe Image with rating badge
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.divider.withValues(alpha: 0.3),
                    image: cafe.thumbnailUrl != null && cafe.thumbnailUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(cafe.thumbnailUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: cafe.thumbnailUrl == null || cafe.thumbnailUrl!.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.store_rounded,
                            color: AppColors.textSecondary,
                            size: 48,
                          ),
                        )
                      : null,
                ),
                // Rating badge - top right
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        SizedBox(height: 2),
                        Text(
                          '4.8',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Cafe name
            Text(
              cafe.name,
              style: AppTextStyles.heading3,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Location and open status
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 18,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    cafe.city?.name ?? widget.cityName,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCafeLoadingShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.divider.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: 180,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.divider.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.divider.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCafeErrorState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                if (widget.cityId != null) {
                  context.read<CafeBloc>().add(
                        CafesByCityFetchRequested(cityId: widget.cityId!),
                      );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Retry',
                  style: AppTextStyles.bodySemibold.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
