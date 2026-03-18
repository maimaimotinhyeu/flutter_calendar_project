import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/van_khan_model.dart';

class VanKhanDetailScreen extends StatefulWidget {
  final VanKhan vanKhan;

  const VanKhanDetailScreen({super.key, required this.vanKhan});

  @override
  State<VanKhanDetailScreen> createState() => _VanKhanDetailScreenState();
}

class _VanKhanDetailScreenState extends State<VanKhanDetailScreen>
    with TickerProviderStateMixin {
  // Deep rich theme colors
  final Color bgColorTop = const Color(0xFF3B0B02); // Deep mahogany
  final Color bgColorBottom = const Color(0xFF140301); // Almost black red
  final Color goldText = const Color(0xFFDCA93C); // Antique gold
  final Color mutedGoldText = const Color(0xFFB08C4A); // Muted gold for subtitles
  final Color offWhiteText = const Color(0xFFF0EBE0); // Easy reading white

  double _fontSizeOffset = 0.0;
  final double _maxFontSizeOffset = 8.0;
  final double _minFontSizeOffset = -4.0;

// Reading mode state
  bool _isAutoScrolling = false;
  bool _showControls = true;
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  final double _scrollSpeed = 1.0; // pixels per step
  final int _scrollDelayMillis = 50; // milliseconds per step

  // Particle System
  late AnimationController _particleController;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initParticles();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  void _initParticles() {
    for (int i = 0; i < 40; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.1 + _random.nextDouble() * 0.3,
        size: 1.0 + _random.nextDouble() * 2.5,
        opacity: 0.1 + _random.nextDouble() * 0.5,
      ));
    }
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _increaseFontSize() {
    setState(() {
      if (_fontSizeOffset < _maxFontSizeOffset) {
        _fontSizeOffset += 2.0;
      }
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_fontSizeOffset > _minFontSizeOffset) {
        _fontSizeOffset -= 2.0;
      }
    });
  }

  // --- Auto Scroll Logic ---
  void _toggleReadingMode() {
    setState(() {
      _isAutoScrolling = !_isAutoScrolling;
      _showControls = !_isAutoScrolling;
    });

    if (_isAutoScrolling) {
      _startAutoScroll();
    } else {
      _stopAutoScroll();
    }
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(Duration(milliseconds: _scrollDelayMillis), (timer) {
      if (_scrollController.hasClients) {
        double currentPosition = _scrollController.position.pixels;
        double maxScroll = _scrollController.position.maxScrollExtent;

        if (currentPosition < maxScroll) {
          _scrollController.jumpTo(currentPosition + _scrollSpeed);
        } else {
          // Reached bottom
          _stopAutoScroll();
          setState(() {
            _isAutoScrolling = false;
            _showControls = true;
          });
        }
      }
    });
  }

  void _stopAutoScroll() {
    _scrollTimer?.cancel();
  }

  void _onUserInteraction() {
    if (_isAutoScrolling) {
      _toggleReadingMode();
    } else if (!_showControls) {
      setState(() {
        _showControls = true;
      });
    }
  }

  void _showReadingModeOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFF1F0602),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                border: Border.all(
                  color: goldText.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Container(
                     width: 40,
                     height: 4,
                     decoration: BoxDecoration(
                       color: goldText.withValues(alpha: 0.3),
                       borderRadius: BorderRadius.circular(2),
                     ),
                   ),
                   const SizedBox(height: 24),
                  Text(
                    'TÙY CHỈNH KÍCH THƯỚC CHỮ',
                    style: GoogleFonts.merriweather(
                      color: goldText,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Decrease Button
                      GestureDetector(
                        onTap: () {
                           _decreaseFontSize();
                           setModalState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                            border: Border.all(color: goldText.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            'A-',
                            style: GoogleFonts.merriweather(
                              color: offWhiteText,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      
                      // Current Size indicator
                      Text(
                        'CỠ CHỮ',
                        style: GoogleFonts.roboto(
                          color: offWhiteText.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      // Increase Button
                      GestureDetector(
                        onTap: () {
                           _increaseFontSize();
                           setModalState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                            border: Border.all(color: goldText.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            'A+',
                            style: GoogleFonts.merriweather(
                              color: goldText,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _onUserInteraction,
        child: Stack(
          children: [
            // 1. Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [bgColorTop, bgColorBottom],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
            
            // 2. Particle Effects
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: _particleController.value,
                    color: goldText,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // 3. Main Content
            SafeArea(
              child: Column(
                children: [
                  AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: _showControls ? _buildAppBar(context) : const SizedBox(height: 48), // reserve space
                  ),
                  
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is UserScrollNotification && _isAutoScrolling) {
                          // Stop scrolling if user starts dragging
                          _toggleReadingMode();
                        }
                        return false;
                      },
                      child: _buildScrollableContent(),
                    ),
                  ),

                  AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: _showControls ? _buildBottomControls(context) : const SizedBox(height: 80), // reserve space
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: goldText,
              size: 20,
            ),
          ),

          // Title
          Expanded(
            child: Text(
              widget.vanKhan.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.merriweather(
                color: goldText,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),

          // Placeholder for spacing to keep title centered
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildScrollableContent() {
    // Helper to format text lines
    List<Widget> formatContentLines() {
      final lines = widget.vanKhan.content.split('\n');
      return lines.map((line) {
        if (line.trim().isEmpty) {
          return const SizedBox(height: 16); // Paragraph spacing
        }

        // Highlight specific mantra
        if (line.contains('NAM MÔ A DI ĐÀ PHẬT')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              line,
              textAlign: TextAlign.center,
              style: GoogleFonts.merriweather(
                color: offWhiteText,
                fontSize: 16 + _fontSizeOffset,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          );
        }

        // Highlight specific bows
        if (line.startsWith('Con lạy') || line.startsWith('Con kính lạy')) {
           final firstSpaceIndex = line.indexOf(' ', line.indexOf('lạy'));
           String boldPart = line;
           String normalPart = '';

           if(firstSpaceIndex != -1) {
              boldPart = line.substring(0, firstSpaceIndex);
              normalPart = line.substring(firstSpaceIndex);
           }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.merriweather(
                  fontSize: 15 + _fontSizeOffset,
                  height: 1.6,
                ),
                children: [
                  TextSpan(
                    text: boldPart,
                    style: TextStyle(
                      color: goldText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text: normalPart,
                    style: TextStyle(
                      color: offWhiteText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            line,
            style: GoogleFonts.merriweather(
              color: offWhiteText,
              fontSize: 15 + _fontSizeOffset,
              height: 1.6,
            ),
          ),
        );
      }).toList();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: mutedGoldText.withValues(alpha: _showControls ? 0.2 : 0.05), // Dim border when reading
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SingleChildScrollView(
            controller: _scrollController, // Attach controller
            padding: const EdgeInsets.all(24.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Subtitle (Italicized instruction)
                Text(
                  widget.vanKhan.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.merriweather(
                    color: mutedGoldText,
                    fontSize: 14 + (_fontSizeOffset * 0.8), // Scale slightly less than main text
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 32),

                // Content
                ...formatContentLines(),
                
                const SizedBox(height: 24),
                // Decorative dots at the end
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDot(mutedGoldText.withValues(alpha: 0.4)),
                    const SizedBox(width: 8),
                    _buildDot(mutedGoldText),
                    const SizedBox(width: 8),
                    _buildDot(mutedGoldText.withValues(alpha: 0.4)),
                  ],
                ),
                const SizedBox(height: 48), // Extra padding at bottom for auto-scroll finish
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Reading Mode Button
          GestureDetector(
            onTap: _toggleReadingMode, // Toggle scroll
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _isAutoScrolling ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFD4B969), // Matches yellow button style
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isAutoScrolling ? goldText.withValues(alpha: 0.2) : Colors.transparent,
                ),
                boxShadow: _isAutoScrolling ? [] : [
                  BoxShadow(
                    color: const Color(0xFFD4B969).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isAutoScrolling ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: _isAutoScrolling ? goldText : const Color(0xFF3B0B02),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isAutoScrolling ? 'DỪNG ĐỌC' : 'TỰ ĐỘNG CUỘN',
                    style: GoogleFonts.merriweather(
                      color: _isAutoScrolling ? goldText : const Color(0xFF3B0B02),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Change Font Size Button
          GestureDetector(
            onTap: () => _showReadingModeOptions(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                )
              ),
              child: const Icon(
                Icons.text_fields_rounded, // T for text sizing
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Model for Particle
class _Particle {
  double x;
  double y;
  double speed;
  double size;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}

// Custom Painter for burning incense effect
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      // Calculate current Y position based on progress and speed
      // Particles move upwards: Y decreases from 1.0 to 0.0
      double currentY = particle.y - (progress * particle.speed);
      
      // Wrap around logic
      if (currentY < -0.1) {
        currentY = 1.0 + (currentY % 1.0);
      }

      // Add a slight horizontal sway using sin wave
      double sway = sin((progress + particle.x) * pi * 4) * 0.02;
      double currentX = particle.x + sway;

      // Wrap X if needed
      if (currentX < 0) currentX += 1.0;
      if (currentX > 1.0) currentX -= 1.0;

      // Pulse opacity
      double currentOpacity = particle.opacity * (0.5 + 0.5 * sin((progress + particle.x) * pi * 8));
      
      // Fade out at top and bottom edges (smooth enter/exit)
      if (currentY > 0.8) currentOpacity *= (1.0 - currentY) / 0.2;
      if (currentY < 0.2) currentOpacity *= currentY / 0.2;

      paint.color = color.withValues(alpha: currentOpacity.clamp(0.0, 1.0));
      
      canvas.drawCircle(
        Offset(currentX * size.width, currentY * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
