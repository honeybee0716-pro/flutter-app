import 'package:flutter/material.dart';

class TopMenuOption extends StatefulWidget {
  const TopMenuOption({
    Key? key,
    required this.child,
    this.keepAlive = false,
  }) : super(key: key);

  final Widget child;
  final bool keepAlive;

  @override
  State<TopMenuOption> createState() => _TopMenuOptionState();
}

class _TopMenuOptionState extends State<TopMenuOption>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    scale = Tween<double>(
      begin: .7,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(.5, 1, curve: Curves.easeInOut),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScaleTransition(
      scale: scale,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
