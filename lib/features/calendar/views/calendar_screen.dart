import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/calendar_viewmodel.dart';
import '../models/calendar_day_model.dart';
import '../../countdown/models/tet_date_model.dart';

class CalendarScreen extends StatelessWidget {
  final int initialYear;
  const CalendarScreen({Key? key, required this.initialYear}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final int tetMonth =
            TetDateModel.getTetDateForYear(initialYear)?.month ?? 1;
        return CalendarViewModel(
          initialMonth: DateTime(initialYear, tetMonth, 1),
        );
      },
      child: const _CalendarView(),
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarViewModel>();

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Lịch Âm Dương',
            style: GoogleFonts.merriweather(
              color: const Color(0xFFFFD700),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Flexible(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 120,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF1E1E1E,
                      ), // Dark container background
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(context, viewModel),
                        const SizedBox(height: 20),
                        _buildDaysOfWeek(),
                        const SizedBox(height: 10),
                        Flexible(child: _buildGrid(context, viewModel)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CalendarViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white70),
          onPressed: () => context.read<CalendarViewModel>().previousMonth(),
        ),
        Text(
          'Tháng ${viewModel.currentMonth.month.toString().padLeft(2, '0')} ${viewModel.currentMonth.year}',
          style: GoogleFonts.roboto(
            color: const Color(0xFFFFD700),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.white70),
          onPressed: () => context.read<CalendarViewModel>().nextMonth(),
        ),
      ],
    );
  }

  Widget _buildDaysOfWeek() {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: GoogleFonts.roboto(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGrid(BuildContext context, CalendarViewModel viewModel) {
    // 7 columns, 6 rows (42 days)
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.8, // Adjust ratio to prevent vertical stretch
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: viewModel.days.length,
      itemBuilder: (context, index) {
        final day = viewModel.days[index];
        return _buildDayCell(context, day);
      },
    );
  }

  Widget _buildDayCell(BuildContext context, CalendarDayModel day) {
    final isSpecial = day.isTetEvent;

    return GestureDetector(
      onTap: () {
        if (day.eventDescription != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${day.eventDescription!} (${day.solarDate.day}/${day.solarDate.month})',
              ),
              backgroundColor: const Color(0xFF8B0000),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: day.isToday
              ? Border.all(color: const Color(0xFFFFD700), width: 1.5)
              : null,
          borderRadius: BorderRadius.circular(8),
          color: day.isCurrentMonth ? Colors.transparent : Colors.black12,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.solarDate.day}',
              style: GoogleFonts.roboto(
                color: day.isCurrentMonth ? Colors.white : Colors.white30,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${day.lunarDay}/${day.lunarMonth}',
              style: GoogleFonts.roboto(
                color: isSpecial && day.isCurrentMonth
                    ? const Color(0xFFFFD700)
                    : (day.isCurrentMonth ? Colors.white54 : Colors.white24),
                fontSize: 10,
                fontWeight: isSpecial ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
