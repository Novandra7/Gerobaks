import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class TaxiCallButton extends StatefulWidget {
  final String phoneNumber;
  final bool isElevated;
  
  const TaxiCallButton({
    Key? key, 
    this.phoneNumber = '0812-3456-7890',
    this.isElevated = true,
  }) : super(key: key);

  @override
  State<TaxiCallButton> createState() => _TaxiCallButtonState();
}

class _TaxiCallButtonState extends State<TaxiCallButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
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
  
  Future<void> _callTaxi() async {
    HapticFeedback.mediumImpact();
    
    final Uri url = Uri.parse('tel:${widget.phoneNumber.replaceAll('-', '')}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat menghubungi layanan taksi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        _callTaxi();
      },
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: widget.isElevated ? Colors.white : Colors.amber[700],
                borderRadius: BorderRadius.circular(12),
                boxShadow: widget.isElevated ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.taxi_alert,
                    color: widget.isElevated ? Colors.amber[700] : Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Panggil Taksi',
                    style: TextStyle(
                      color: widget.isElevated ? Colors.amber[700] : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TaxiCallFAB extends StatelessWidget {
  final String phoneNumber;
  
  const TaxiCallFAB({
    Key? key, 
    this.phoneNumber = '0812-3456-7890',
  }) : super(key: key);

  Future<void> _callTaxi() async {
    HapticFeedback.mediumImpact();
    
    final Uri url = Uri.parse('tel:${phoneNumber.replaceAll('-', '')}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _callTaxi,
      backgroundColor: Colors.amber[700],
      icon: const Icon(Icons.taxi_alert, color: Colors.white),
      label: const Text(
        'Taksi',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
