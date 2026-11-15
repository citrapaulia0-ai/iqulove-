import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ourdays_models.dart';
import '../state/ourdays_state.dart';
import '../widgets/ourdays_widgets.dart';
import 'event_screens.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Consumer<OurDaysState>(
    builder: (context, state, _) {
      final now = DateTime.now();
      return SafeArea(
        child: ResponsivePage(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${formatWeekday(now).toUpperCase()}, ${formatDate(now).toUpperCase()}',
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            color: AppColors.latte,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Hi, ${state.partnerOne} ♡',
                          style: const TextStyle(
                            fontSize: 27,
                            color: AppColors.brown,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RoundIconButton(
                    icon: Icons.person_outline_rounded,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ProfileScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _CoupleHero(
                nameOne: state.partnerOne,
                nameTwo: state.partnerTwo,
                days: state.relationshipDays,
                photo: state.memories.isEmpty
                    ? ''
                    : state.memories.first.imageData,
              ),
              const SizedBox(height: 24),
              SectionHeading(
                'Upcoming events',
                trailing: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DatePlannerScreen(),
                    ),
                  ),
                  child: const Text(
                    'Plan a date',
                    style: TextStyle(color: AppColors.brown),
                  ),
                ),
              ),
              const SizedBox(height: 11),
              if (state.upcomingEvents.isEmpty)
                SoftCard(
                  child: const Text(
                    'Nothing on the calendar yet. Make a little plan together.',
                    style: TextStyle(fontFamily: 'Arial'),
                  ),
                )
              else
                ...state.upcomingEvents
                    .take(3)
                    .map(
                      (event) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _UpcomingCard(
                          event: event,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  EventDetailScreen(eventId: event.id),
                            ),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
              const SectionHeading('A little us-time'),
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(
                    child: _ActivityCard(
                      icon: Icons.favorite_border_rounded,
                      count: state.wishlist
                          .where((item) => !item.isDone)
                          .length,
                      label: 'to-do wishes',
                      tint: AppColors.softPink,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: _ActivityCard(
                      icon: Icons.photo_outlined,
                      count: state.memories.length,
                      label: 'sweet memories',
                      tint: const Color(0xFFF2E8DD),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: _ActivityCard(
                      icon: Icons.edit_note_rounded,
                      count: state.notes.length,
                      label: 'shared notes',
                      tint: const Color(0xFFE9EEE4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SoftCard(
                color: AppColors.softPink,
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: AppColors.brown),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Plan Together, Keep Every Memory.',
                        style: TextStyle(
                          color: AppColors.brown,
                          fontStyle: FontStyle.italic,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _CoupleHero extends StatelessWidget {
  const _CoupleHero({
    required this.nameOne,
    required this.nameTwo,
    required this.days,
    required this.photo,
  });

  final String nameOne;
  final String nameTwo;
  final int days;
  final String photo;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 236,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (decodePhoto(photo) != null)
            memoryImage(data: photo, height: 236)
          else
            Image.network(
              'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?auto=format&fit=crop&w=1200&q=85',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD8B3A5), AppColors.brown],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 78,
                    color: Color(0x99FFFFFF),
                  ),
                ),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: .02),
                  Colors.black.withValues(alpha: .65),
                ],
              ),
            ),
          ),
          Positioned(
            left: 19,
            right: 19,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Our Little Story',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    color: Colors.white70,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$nameOne & $nameTwo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$days days together',
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Every moment is better with you.',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .88),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                children: [
                  Icon(Icons.favorite_rounded, color: AppColors.pink, size: 15),
                  SizedBox(width: 5),
                  Text(
                    'together',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      color: AppColors.brown,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
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
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.event, required this.onTap});

  final CoupleEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SoftCard(
    onTap: onTap,
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Container(
          width: 58,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.softPink,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                event.date.day.toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: AppColors.brown,
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                formatDate(event.date).split(' ').first.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: AppColors.brown,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${formatTime(event.date)}  ·  ${event.location}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: AppColors.muted,
                  fontSize: 12,
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

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.tint,
  });

  final IconData icon;
  final int count;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 14, 8, 14),
    decoration: BoxDecoration(
      color: tint,
      borderRadius: BorderRadius.circular(19),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.brown),
        const SizedBox(height: 12),
        Text(
          '$count',
          style: const TextStyle(
            color: AppColors.brown,
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Arial',
            color: AppColors.muted,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}
