import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ourdays_models.dart';
import '../state/ourdays_state.dart';
import '../widgets/ourdays_widgets.dart';
import 'event_screens.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Consumer<OurDaysState>(
      builder: (context, state, _) {
        final monthStart = DateTime(_month.year, _month.month);
        final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
        final leadingDays = (monthStart.weekday + 6) % 7;
        final cellCount = ((leadingDays + daysInMonth + 6) ~/ 7) * 7;
        final monthEvents = state.events
            .where(
              (event) =>
                  event.date.year == _month.year &&
                  event.date.month == _month.month,
            )
            .toList();
        final selectedEvents = state.events
            .where((event) => DateUtils.isSameDay(event.date, _selectedDate))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
        return ResponsivePage(
          child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          children: [
            PageHeader(
              title: 'Our calendar',
              subtitle: 'Make room for the moments that matter.',
              action: RoundIconButton(
                icon: Icons.add_rounded,
                background: AppColors.brown,
                foreground: Colors.white,
                onPressed: () => _openPlanner(context),
              ),
            ),
            const SizedBox(height: 22),
            SoftCard(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 13),
              child: Column(
                children: [
                  Row(
                    children: [
                      RoundIconButton(
                        icon: Icons.chevron_left_rounded,
                        background: AppColors.cream,
                        onPressed: () => setState(
                          () => _month = DateTime(_month.year, _month.month - 1),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _monthTitle(_month),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            color: AppColors.brown,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      RoundIconButton(
                        icon: Icons.chevron_right_rounded,
                        background: AppColors.cream,
                        onPressed: () => setState(
                          () => _month = DateTime(_month.year, _month.month + 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      'M',
                      'T',
                      'W',
                      'T',
                      'F',
                      'S',
                      'S',
                    ].map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontFamily: 'Arial',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 9),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cellCount,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (context, index) {
                      final dayNumber = index - leadingDays + 1;
                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return const SizedBox.shrink();
                      }
                      final date = DateTime(_month.year, _month.month, dayNumber);
                      final isSelected = DateUtils.isSameDay(date, _selectedDate);
                      final hasEvent = monthEvents.any(
                        (event) => DateUtils.isSameDay(event.date, date),
                      );
                      final isToday = DateUtils.isSameDay(date, DateTime.now());
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => setState(() => _selectedDate = date),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.brown
                                : isToday
                                ? AppColors.softPink
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$dayNumber',
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.ink,
                                  fontWeight: isSelected || isToday
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: hasEvent
                                      ? (isSelected ? Colors.white : AppColors.pink)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 23),
            SectionHeading(
              formatDate(_selectedDate, includeYear: true),
              trailing: TextButton.icon(
                onPressed: () => _openPlanner(context, date: _selectedDate),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add plan'),
                style: TextButton.styleFrom(foregroundColor: AppColors.brown),
              ),
            ),
            const SizedBox(height: 10),
            if (selectedEvents.isEmpty)
              SoftCard(
                color: AppColors.softPink,
                child: const Row(
                  children: [
                    Icon(Icons.spa_outlined, color: AppColors.brown),
                    SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'A free day to be spontaneous.',
                        style: TextStyle(fontFamily: 'Arial'),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...selectedEvents.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CalendarEventTile(
                    event: event,
                    onTap: () => _openDetails(context, event),
                  ),
                ),
              ),
            const SizedBox(height: 13),
            const SectionHeading('Coming up'),
            const SizedBox(height: 10),
            ...state.upcomingEvents.take(4).map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CalendarEventTile(
                  event: event,
                  onTap: () => _openDetails(context, event),
                ),
              ),
            ),
          ],
          ),
        );
      },
    ),
  );

  void _openPlanner(BuildContext context, {DateTime? date}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DatePlannerScreen(initialDate: date),
      ),
    );
  }

  void _openDetails(BuildContext context, CoupleEvent event) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EventDetailScreen(eventId: event.id),
      ),
    );
  }

  String _monthTitle(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _CalendarEventTile extends StatelessWidget {
  const _CalendarEventTile({required this.event, required this.onTap});

  final CoupleEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SoftCard(
    onTap: onTap,
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Container(
          width: 5,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.pink,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${formatTime(event.date)}  ·  ${event.location}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: AppColors.latte),
      ],
    ),
  );
}
