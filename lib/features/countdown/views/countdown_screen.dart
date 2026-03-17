import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;
import '../viewmodels/countdown_viewmodel.dart';
import '../../timeline/views/timeline_screen.dart';
import '../../timeline/models/timeline_event_model.dart';
import '../../timeline/viewmodels/timeline_viewmodel.dart';
import '../../calendar/views/calendar_screen.dart';

import '../../van_khan/viewmodels/van_khan_viewmodel.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0; // 0 for Home, 1 for Timeline
  late ConfettiController _confettiController;
  int? _confettiPlayedYear;
  late AnimationController _particleController;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 10),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  // Define some rich colors for the elegant masterpiece UI
  final Color _bgDarkBrown = const Color(0xFF2B0A04); // Even darker rich brown
  final Color _circleFill = const Color(0xFF421208); // Solid center dark circle
  final Color _goldLight = const Color(0xFFFFD700);
  final Color _goldDark = const Color(0xFFB8860B);
  final Color _orangeFiery = const Color(0xFFFF4500);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CountdownViewModel()),
        ChangeNotifierProvider(create: (_) => VanKhanViewModel()),
      ],
      child: Scaffold(
        extendBody: true,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/bg_do.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 
                  0.5,
                ), // Darken the background to make the glowing circle pop
                BlendMode.darken,
              ),
            ),
          ),
          child: Stack(
            children: [
              // Background blur blobs
              Positioned(
                top: -100,
                right: -50,
                child: _buildGradientBlob(200, Alignment.bottomLeft),
              ),
              Positioned(
                bottom: -50,
                left: -100,
                child: _buildGradientBlob(300, Alignment.topRight),
              ),

              // Confetti background
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 3.14 / 2, // burst strictly downwards
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 5,
                  gravity: 0.1,
                  colors: const [
                    Colors.red,
                    Colors.yellow,
                    Colors.orange,
                    Colors.blue,
                    Colors.green,
                  ],
                ),
              ),

              // Gold Dust Particles
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _GoldDustPainter(_particleController, _particles),
                  ),
                ),
              ),

              // Main Content
              SafeArea(
                bottom: false,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutQuart,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      _buildTopAppBar(context),
                      Expanded(
                        child: _currentIndex == 0
                            ? Center(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 20),
                                      _buildElegantCircularTimer(context),
                                      const SizedBox(height: 40),
                                      _buildUpcomingEventCard(),
                                      const SizedBox(
                                        height: 100,
                                      ), // Space for bottom nav
                                    ],
                                  ),
                                ),
                              )
                            : _currentIndex == 1
                            ? Consumer<CountdownViewModel>(
                                builder: (context, viewModel, child) {
                                  return TimelineScreen(
                                    key: ValueKey(
                                      'timeline_${viewModel.selectedYear}',
                                    ),
                                    initialYear: viewModel.selectedYear,
                                    selectedTheme:
                                        'Đỏ Truyền Thống', // Hardcoded theme
                                  );
                                },
                              )
                            : Consumer<CountdownViewModel>(
                                builder: (context, viewModel, child) {
                                  return CalendarScreen(
                                    key: ValueKey(
                                      'calendar_${viewModel.selectedYear}',
                                    ),
                                    initialYear: viewModel.selectedYear,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildGradientBlob(double size, AlignmentGeometry begin) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFD4AF37).withValues(alpha: 0.4), // Pale gold
            const Color(0xFFD4AF37).withValues(alpha: 0.0),
          ],
          center: Alignment.center,
          radius: 0.8,
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.end, // Only the Year dropdown remains
        children: [
          // Year Dropdown
          Consumer<CountdownViewModel>(
            builder: (context, viewModel, child) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: viewModel.selectedYear,
                    dropdownColor: _bgDarkBrown,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFFD4AF37),
                    ),
                    style: GoogleFonts.merriweather(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        viewModel.changeYear(newValue);
                      }
                    },
                    items: [2026, 2027, 2028, 2029, 2030]
                        .map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('Năm $value'),
                          );
                        })
                        .toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildElegantCircularTimer(BuildContext context) {
    return Consumer<CountdownViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isPassed) {
          if (_confettiPlayedYear != viewModel.selectedYear) {
            _confettiPlayedYear = viewModel.selectedYear;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _confettiController.play();
            });
          }
          return _buildNewYearCelebration(viewModel);
        } else {
          if (_confettiPlayedYear == viewModel.selectedYear) {
            _confettiPlayedYear = null;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _confettiController.stop();
            });
          }
        }

        // The massive circle diameter
        double diameter = MediaQuery.of(context).size.width * 0.85;

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Solid Brown background circle
              Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  color: _circleFill,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),

              // 2. Beautiful Rings (Concentric borders)
              CustomPaint(
                size: Size(diameter + 15, diameter + 15), // Outer ring
                painter: _ConcentricRingsPainter(color: _goldDark),
              ),

              // 3. Inner Content Layout
              SizedBox(
                width: diameter - 40,
                height: diameter - 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top Title
                    Text(
                      'ĐẾM NGƯỢC ĐẾN',
                      style: GoogleFonts.merriweather(
                        color: _goldLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Massive "Days" Text with Gradient
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          const Color(0xFFFFF1BA), // Very bright gold/white
                          _goldLight,
                          _goldDark,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: Text(
                        viewModel.days.toString(),
                        style: GoogleFonts.roboto(
                          color: Colors.white, // Required for shader mask
                          fontSize: 100, // Massive size
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          letterSpacing: -2.0,
                        ),
                      ),
                    ),

                    // "NGÀY CÒN LẠI"
                    Text(
                      'NGÀY CÒN LẠI',
                      style: GoogleFonts.merriweather(
                        color: _goldLight,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // The Bottom Row: Hours | Minutes | Seconds
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTimeComponent(
                            viewModel.hours.toString().padLeft(2, '0'),
                            'GIỜ',
                            Colors.white,
                          ),
                          _buildVerticalDivider(),
                          _buildTimeComponent(
                            viewModel.minutes.toString().padLeft(2, '0'),
                            'PHÚT',
                            Colors.white,
                          ),
                          _buildVerticalDivider(),
                          _buildTimeComponent(
                            viewModel.seconds.toString().padLeft(2, '0'),
                            'GIÂY',
                            _orangeFiery,
                            isGlowing: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 40,
      width: 1.5,
      color: _goldDark.withValues(alpha: 0.5),
    );
  }

  Widget _buildTimeComponent(
    String value,
    String label,
    Color valueColor, {
    bool isGlowing = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.roboto(
            color: valueColor,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            shadows: isGlowing
                ? [
                    Shadow(
                      blurRadius: 15.0,
                      color: valueColor.withValues(alpha: 0.8),
                      offset: const Offset(0, 0),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.merriweather(
            color: _goldLight.withValues(alpha: 0.8),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildNewYearCelebration(CountdownViewModel viewModel) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'CHÚC MỪNG\nNĂM MỚI!',
          textAlign: TextAlign.center,
          style: GoogleFonts.merriweather(
            color: _goldLight,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                blurRadius: 30.0,
                color: _goldDark.withValues(alpha: 0.8),
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        ElevatedButton(
          onPressed: () {
            viewModel.changeYear(viewModel.selectedYear + 1);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _goldLight,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 10,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text(
            'BẮT ĐẦU NĂM MỚI',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingEventCard() {
    return Consumer<CountdownViewModel>(
      builder: (context, countdownViewModel, child) {
        final timelineViewModel = TimelineViewModel()
          ..changeYear(countdownViewModel.selectedYear);
        final now = DateTime.now();

        TimelineEventModel? upcomingEvent;
        for (var event in timelineViewModel.events) {
          final eventEndOfDay = DateTime(
            event.solarDate.year,
            event.solarDate.month,
            event.solarDate.day,
            23,
            59,
            59,
          );
          if (now.isBefore(eventEndOfDay)) {
            upcomingEvent = event;
            break;
          }
        }

        upcomingEvent ??= timelineViewModel.events.last;

        return IntrinsicHeight(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF1F0703), // Very dark warm color
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _goldDark.withValues(alpha: 0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Golden highlight strip
                Container(
                  width: 8,
                  decoration: BoxDecoration(
                    color: _goldLight,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'SỰ KIỆN SẮP TỚI',
                                style: GoogleFonts.merriweather(
                                  color: _goldLight,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                upcomingEvent.title,
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                upcomingEvent.description,
                                style: GoogleFonts.roboto(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                upcomingEvent.solarDateText,
                                style: GoogleFonts.roboto(
                                  color: _goldLight.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentIndex = 1;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _goldLight,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _goldLight.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF180502), // Extremely dark mahogany
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                Icons.home_rounded,
                'TRANG CHỦ',
                _currentIndex == 0,
                () => setState(() => _currentIndex = 0),
              ),
              _buildNavItem(
                Icons.list_alt_rounded,
                'MỐC TẾT',
                _currentIndex == 1,
                () => setState(() => _currentIndex = 1),
              ),
              _buildNavItem(
                Icons.calendar_month_rounded,
                'LỊCH',
                _currentIndex == 2,
                () => setState(() => _currentIndex = 2),
              ),
              _buildNavItem(
                Icons.help_outline_rounded,
                '',
                false,
                () {},
                isIconOnly: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap, {
    bool isIconOnly = false,
  }) {
    if (isIconOnly) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 20),
        ),
      );
    }

    if (isSelected) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _goldLight,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _goldLight.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.black, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.merriweather(
                  color: Colors.black,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.4), size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.merriweather(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConcentricRingsPainter extends CustomPainter {
  final Color color;

  _ConcentricRingsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = math.min(size.width / 2, size.height / 2);

    // Inner glowing solid ring
    Paint innerRing = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Outer thin solid ring
    Paint outerRing = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius - 10, innerRing);
    canvas.drawCircle(center, radius, outerRing);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _Particle {
  final double x;
  final double y;
  final double speed;
  final double radius;
  final double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.opacity,
  });
}

class _GoldDustPainter extends CustomPainter {
  final Animation<double> animation;
  final List<_Particle> particles;

  _GoldDustPainter(this.animation, this.particles) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty && size.width > 0) {
      final random = math.Random();
      for (int i = 0; i < 50; i++) {
        particles.add(
          _Particle(
            x: random.nextDouble(),
            y: random.nextDouble(),
            speed: random.nextDouble() * 0.8 + 0.2,
            radius: random.nextDouble() * 2 + 1,
            opacity: random.nextDouble() * 0.5 + 0.2,
          ),
        );
      }
    }

    final paint = Paint();

    for (var p in particles) {
      double currentY = (p.y + (animation.value * p.speed)) % 1.0;
      paint.color = const Color(0xFFFFD700).withValues(alpha: p.opacity);
      canvas.drawCircle(
        Offset(p.x * size.width, currentY * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
