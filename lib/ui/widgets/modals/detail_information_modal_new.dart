import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/models/information_model.dart';
import 'package:bank_sha/ui/widgets/animations/animation_widgets.dart';

class DetailInformationModal extends StatefulWidget {
  final InformationModel information;
  final int? currentIndex;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const DetailInformationModal({
    super.key,
    required this.information,
    this.currentIndex,
    this.onPrevious,
    this.onNext,
  });
  
  @override
  State<DetailInformationModal> createState() => _DetailInformationModalState();
}

class _DetailInformationModalState extends State<DetailInformationModal> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuint,
    );
    
    // Start the animation when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar with shimmer animation
                  Center(
                    child: ShimmerIndicator(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      width: 40,
                      height: 4,
                    ),
                  ),
                  
                  // Hero image dengan gradient overlay
                  Stack(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                        child: Image.asset(
                          widget.information.image,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Gradient overlay
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                      // Title
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.information.title,
                              style: whiteTextStyle.copyWith(
                                fontSize: 24,
                                fontWeight: bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.information.description,
                              style: whiteTextStyle.copyWith(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Navigation buttons row
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Row(
                          children: [
                            // Previous button
                            if (widget.onPrevious != null)
                              GestureDetector(
                                onTap: widget.onPrevious,
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_rounded,
                                    color: whiteColor,
                                    size: 16,
                                  ),
                                ),
                              ),
                            
                            // Next button
                            if (widget.onNext != null)
                              GestureDetector(
                                onTap: widget.onNext,
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: whiteColor,
                                    size: 16,
                                  ),
                                ),
                              ),
                              
                            // Close button
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: whiteColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Detail title
                            Text(
                              widget.information.detailTitle,
                              style: blackTextStyle.copyWith(
                                fontSize: 20,
                                fontWeight: semiBold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Detail description
                            Text(
                              widget.information.detailDescription,
                              style: greyTextStyle.copyWith(
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Bullet points with staggered animation
                            ...List.generate(widget.information.detailPoints.length, (index) {
                              final point = widget.information.detailPoints[index];
                              return AnimatedBuilder(
                                animation: _animation,
                                builder: (context, child) {
                                  final delay = index * 0.2;
                                  final startTime = delay;
                                  final endTime = 1.0;
                                  
                                  final animationProgress = (_animation.value - startTime) / (endTime - startTime);
                                  final opacity = animationProgress.clamp(0.0, 1.0);
                                  final slideDistance = 20.0 * (1.0 - opacity);
                                  
                                  return Transform.translate(
                                    offset: Offset(slideDistance, 0),
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(top: 5),
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: greenColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                point,
                                                style: blackTextStyle.copyWith(
                                                  fontSize: 14,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                            
                            const SizedBox(height: 24),
                            
                            // Action button
                            BouncingButton(
                              onPressed: () {
                                Navigator.pop(context);
                                if (widget.information.buttonRoute != null) {
                                  Navigator.pushNamed(context, widget.information.buttonRoute!);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: greenColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: greenColor.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    widget.information.buttonText,
                                    style: whiteTextStyle.copyWith(
                                      fontSize: 16,
                                      fontWeight: semiBold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            // Navigation indicators
                            if (widget.currentIndex != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      informationList.length,
                                      (index) => Container(
                                        width: index == widget.currentIndex ? 20 : 8,
                                        height: 8,
                                        margin: const EdgeInsets.symmetric(horizontal: 3),
                                        decoration: BoxDecoration(
                                          color: index == widget.currentIndex
                                              ? greenColor
                                              : Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
