import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';

// Create a yellow color for taxi button
Color yellowColor = const Color(0xFFFFD700); // Gold yellow color
Color darkBackgroundColor = const Color(0xFF333333); // Dark color for tooltip

class TaxiCallButton extends StatefulWidget {
  final Function() onCall;
  final String? phoneNumber;
  final bool showTooltip;

  const TaxiCallButton({
    Key? key,
    required this.onCall,
    this.phoneNumber,
    this.showTooltip = true,
  }) : super(key: key);

  @override
  State<TaxiCallButton> createState() => _TaxiCallButtonState();
}

class _TaxiCallButtonState extends State<TaxiCallButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isCalling = false;

  @override
  void initState() {
    super.initState();
    
    // Setup animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    // Setup scale animation
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    // Start animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    // Set calling state
    setState(() {
      _isCalling = true;
    });
    
    // Call the onCall callback
    await widget.onCall();
    
    // Reset calling state after a delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isCalling = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: yellowColor,
      foregroundColor: whiteColor,
      elevation: 4,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: ElevatedButton.icon(
                onPressed: _isCalling ? null : _handleTap,
                style: elevatedButtonStyle,
                icon: _isCalling
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: whiteColor,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        Icons.local_taxi,
                        color: whiteColor,
                      ),
                label: Text(
                  _isCalling ? 'Menghubungi...' : 'Panggil Taksi',
                  style: whiteTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: semiBold,
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.showTooltip && widget.phoneNumber != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Akan menghubungi: ${widget.phoneNumber}',
              style: greyTextStyle.copyWith(
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

// Floating action button version with ripple effect
class TaxiCallFAB extends StatefulWidget {
  final Function() onCall;
  final String? phoneNumber;

  const TaxiCallFAB({
    Key? key,
    required this.onCall,
    this.phoneNumber,
  }) : super(key: key);

  @override
  State<TaxiCallFAB> createState() => _TaxiCallFABState();
}

class _TaxiCallFABState extends State<TaxiCallFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isCalling = false;
  bool _showLabel = false;

  @override
  void initState() {
    super.initState();
    
    // Setup animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    // Setup scale animation
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    // Start animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    // Set calling state
    setState(() {
      _isCalling = true;
      _showLabel = false;
    });
    
    // Call the onCall callback
    await widget.onCall();
    
    // Reset calling state after a delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isCalling = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _isCalling ? null : _handleTap,
            onLongPress: () {
              setState(() {
                _showLabel = true;
              });
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  setState(() {
                    _showLabel = false;
                  });
                }
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // FAB with ripple effect
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        yellowColor,
                        yellowColor.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: yellowColor.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isCalling ? null : _handleTap,
                      customBorder: const CircleBorder(),
                      splashColor: Colors.white.withOpacity(0.3),
                      highlightColor: Colors.transparent,
                      child: _isCalling
                          ? Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: whiteColor,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.local_taxi,
                              color: whiteColor,
                              size: 28,
                            ),
                    ),
                  ),
                ),
                
                // Label tooltip
                if (_showLabel)
                  Positioned(
                    bottom: 64,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: darkBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.phoneNumber != null
                            ? 'Panggil Taksi (${widget.phoneNumber})'
                            : 'Panggil Taksi',
                        style: whiteTextStyle.copyWith(
                          fontSize: 12,
                          fontWeight: medium,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
