import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../counter/controllers/counter_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  bool _incPressed = false;
  bool _decPressed = false;
  bool _resetPressed = false;

  double _hueFromCount(int c) => (c % 360).toDouble();

  Future<void> _logout() async {
    try {
      await ref.read(authControllerProvider.notifier).signOut();
      if (!mounted) return;
      // AuthGate will switch to Login automatically.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logged out')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  Widget _actionButton({
    required bool pressed,
    required void Function(bool) onPressedState,
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color,
    Color? foreground,
    bool outlined = false,
  }) {
    final fg = foreground ?? Colors.white;

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );

    final button =
        outlined
            ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withOpacity(0.35), width: 1.2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onTap,
              child: child,
            )
            : FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: fg,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              onPressed: onTap,
              child: child,
            );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => setState(() => onPressedState(true)),
      onTapUp: (_) => setState(() => onPressedState(false)),
      onTapCancel: () => setState(() => onPressedState(false)),
      child: AnimatedScale(
        scale: pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: button,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(counterProvider);
    final positive = Colors.teal;
    final negative = Colors.pink;
    final neutral = Colors.indigo;
    final accent = count == 0 ? neutral : (count > 0 ? positive : negative);
    final hue = _hueFromCount(count);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Countly App'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  HSLColor.fromAHSL(1, hue, 0.55, 0.58).toColor(),
                  HSLColor.fromAHSL(1, (hue + 40) % 360, 0.65, 0.42).toColor(),
                  HSLColor.fromAHSL(1, (hue + 90) % 360, 0.60, 0.30).toColor(),
                ],
              ),
            ),
          ),

          // Soft animated blobs (decor)
          Positioned(
            left: -80,
            top: -60,
            child: _GlowBlob(color: accent.withOpacity(0.35), size: 220),
          ),
          Positioned(
            right: -60,
            bottom: -40,
            child: _GlowBlob(color: accent.withOpacity(0.25), size: 180),
          ),

          SafeArea(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Glass card
                  const _GlassCard(child: _CounterCard()),

                  const Spacer(),

                  // Buttons section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 420;
                        final spacing = isWide ? 16.0 : 12.0;

                        final minusBtn = _actionButton(
                          pressed: _decPressed,
                          onPressedState: (v) => _decPressed = v,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(counterProvider.notifier).dec();
                          },
                          icon: Icons.remove_rounded,
                          label: 'Minus 1',
                          color: negative,
                          foreground: Colors.white,
                        );

                        final resetBtn = _actionButton(
                          pressed: _resetPressed,
                          onPressedState: (v) => _resetPressed = v,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ref.read(counterProvider.notifier).reset();
                          },
                          icon: Icons.refresh_rounded,
                          label: 'Reset',
                          color: Colors.white,
                          outlined: true,
                        );

                        final plusBtn = _actionButton(
                          pressed: _incPressed,
                          onPressedState: (v) => _incPressed = v,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(counterProvider.notifier).inc();
                          },
                          icon: Icons.add_rounded,
                          label: 'Plus 1',
                          color: positive,
                          foreground: Colors.white,
                        );

                        if (isWide) {
                          return Row(
                            children: [
                              Expanded(child: minusBtn),
                              SizedBox(width: spacing),
                              Expanded(child: resetBtn),
                              SizedBox(width: spacing),
                              Expanded(child: plusBtn),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 52, child: minusBtn),
                            SizedBox(height: spacing),
                            SizedBox(height: 52, child: resetBtn),
                            SizedBox(height: spacing),
                            SizedBox(height: 52, child: plusBtn),
                          ],
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
    );
  }
}

class _CounterCard extends ConsumerWidget {
  const _CounterCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    final positive = Colors.teal;
    final negative = Colors.pink;
    final neutral = Colors.indigo;
    final accent = count == 0 ? neutral : (count > 0 ? positive : negative);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Counter',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder:
                (child, anim) => ScaleTransition(
                  scale: Tween<double>(begin: 0.85, end: 1).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
            child: Text(
              '$count',
              key: ValueKey(count),
              style: TextStyle(
                fontSize: 72,
                height: 1,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ),
          const SizedBox(height: 22),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: (count.abs() % 10) / 10),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return CustomPaint(
                painter: _RingPainter(
                  color: accent.withOpacity(0.6),
                  progress: value,
                ),
                size: const Size(120, 120),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1600),
      tween: Tween<double>(begin: 0.92, end: 1.08),
      curve: Curves.easeInOut,
      builder:
          (_, value, __) => Container(
            height: size * value,
            width: size * value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 60,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double progress;
  _RingPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final center = (Offset.zero & size).center;
    final radius = (size.shortestSide / 2) - stroke;

    final base =
        Paint()
          ..color = color.withOpacity(0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke;

    final prog =
        Paint()
          ..shader = SweepGradient(
            colors: [color, color.withOpacity(0.2)],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = stroke;

    canvas.drawCircle(center, radius, base);

    final sweep = 2 * 3.1415926535 * progress;
    const start = -3.1415926535 / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      prog,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.color != color || old.progress != progress;
}
