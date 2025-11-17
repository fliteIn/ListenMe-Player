import 'package:flutter/material.dart';

PageRoute<T> helpLicensesPageRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    opaque: true,                        // страница полностью заменяет предыдущую
    barrierColor: null,                  // не накладываем прозрачный слой
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (context, anim, secondary, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03), // лёгкий сдвиг вверх при появлении
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
    maintainState: true,
  );
}

