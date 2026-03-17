import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/timeline_viewmodel.dart';
import '../models/timeline_event_model.dart';
import '../../van_khan/viewmodels/van_khan_viewmodel.dart';
import '../../van_khan/views/van_khan_detail_screen.dart';

class TimelineScreen extends StatefulWidget {
  final int initialYear;
  final String selectedTheme;
  const TimelineScreen({
    super.key,
    required this.initialYear,
    required this.selectedTheme,
  });

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimelineViewModel()..changeYear(widget.initialYear),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTitle(context),
            const SizedBox(height: 20),
            _buildTimelineList(),
            const SizedBox(
              height: 120,
            ), // Increased spacing so the last item isn't blocked by the bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Consumer<TimelineViewModel>(
      builder: (context, viewModel, child) {
        return Text(
          'Lịch Trình Tết ${viewModel.selectedYear}',
          style: GoogleFonts.merriweather(
            color: const Color(0xFFFFD700), // Gold
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        );
      },
    );
  }

  Widget _buildTimelineList() {
    return Consumer<TimelineViewModel>(
      builder: (context, viewModel, child) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          itemCount: viewModel.events.length,
          itemBuilder: (context, index) {
            final event = viewModel.events[index];
            final status = viewModel.getEventStatus(event);
            final isLast = index == viewModel.events.length - 1;

            return _buildTimelineItem(event, status, isLast, index);
          },
        );
      },
    );
  }

  Widget _buildTimelineItem(
    TimelineEventModel event,
    int status,
    bool isLast,
    int index,
  ) {
    // status: 1 (Passed), 0 (Current), -1 (Future)
    final bool isPassed = status == 1;
    final bool isCurrent = status == 0;

    final Color iconColor = widget.selectedTheme == 'Tối'
        ? Colors.grey.shade400
        : (isPassed ? Colors.white70 : const Color(0xFFFFD700));
    final Color lineColor = widget.selectedTheme == 'Tối'
        ? Colors.grey.withValues(alpha: 0.3)
        : (isPassed
              ? Colors.white30
              : const Color(0xFFFFD700).withValues(alpha: 0.5));
    final Color cardBackground = Colors.white.withValues(alpha: 
      isPassed ? 0.05 : 0.15,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 150)),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Timeline Tracker
            SizedBox(
              width: 40,
              child: Column(
                children: [
                   // Icon Node
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(
                        color: isCurrent ? const Color(0xFFFFD700) : iconColor,
                        width: isCurrent ? 2.5 : 2,
                      ),
                    ),
                    child: Center(
                      child: isPassed
                          ? Icon(Icons.check, size: 14, color: iconColor)
                          : (isCurrent
                                ? Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFFFD700),
                                    ),
                                  )
                                : null),
                    ),
                  ),
                  // Vertical Line
                  if (!isLast)
                    Expanded(child: Container(width: 2, color: lineColor)),
                ],
              ),
            ),

            // Right Content Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrent
                          ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.1),
                      width: isCurrent ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                       // Gold Highlight strip for current event
                      if (isCurrent)
                        Container(
                           width: 6,
                           color: const Color(0xFFFFD700),
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // "SẮP DIỄN RA" Text if it's the current one
                                        if (isCurrent)
                                           Padding(
                                             padding: const EdgeInsets.only(bottom: 4.0),
                                             child: Text(
                                               'SỰ KIỆN SẮP TỚI',
                                               style: GoogleFonts.roboto(
                                                 color: const Color(0xFFFFD700),
                                                 fontSize: 9,
                                                 fontWeight: FontWeight.w900,
                                                 letterSpacing: 1.2,
                                               ),
                                             ),
                                           )
                                        else if (!isPassed)
                                          Padding(
                                             padding: const EdgeInsets.only(bottom: 4.0),
                                             child: Text(
                                               'SẮP DIỄN RA',
                                               style: GoogleFonts.roboto(
                                                 color: Colors.white54,
                                                 fontSize: 9,
                                                 fontWeight: FontWeight.w700,
                                                 letterSpacing: 1.2,
                                               ),
                                             ),
                                           ),
                                        Text(
                                          event.title,
                                          style: GoogleFonts.roboto(
                                            color: isPassed ? Colors.white70 : Colors.white,
                                            fontSize: 20, // Slightly bigger
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          event.description,
                                          style: GoogleFonts.roboto(
                                            color: isPassed
                                                ? Colors.white54
                                                : Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          event.solarDateText,
                                          style: GoogleFonts.roboto(
                                            color: isCurrent
                                                ? const Color(0xFFFFD700)
                                                : (isPassed ? Colors.white38 : const Color(0xFFFFD700).withValues(alpha: 0.7)),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      event.lunarDate,
                                      style: GoogleFonts.roboto(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              

                              // Button "Xem văn khấn" if vanKhanId is present
                              if (event.vanKhanId != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                         // Show the VanKhan detail screen
                                         final vanKhanVM = Provider.of<VanKhanViewModel>(context, listen: false);
                                         final vanKhan = vanKhanVM.getVanKhanById(event.vanKhanId!);
                                         if(vanKhan != null) {
                                            Navigator.push(context, MaterialPageRoute(
                                              builder: (context) => VanKhanDetailScreen(vanKhan: vanKhan),
                                            ));
                                         }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isCurrent ? const Color(0xFFFFD700) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(20),
                                          border: isCurrent ? null : Border.all(
                                            color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                                            width: 1,
                                          ),
                                          boxShadow: isCurrent ? [
                                             BoxShadow(
                                               color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                                               blurRadius: 10,
                                               offset: const Offset(0, 2),
                                             )
                                          ] : null,
                                        ),
                                        child: Text(
                                          'Xem văn khấn',
                                          style: GoogleFonts.roboto(
                                            color: isCurrent ? const Color(0xFF3B0B02) : const Color(0xFFFFD700),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
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
                    ],
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

