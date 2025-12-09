library;

import 'package:flutter/material.dart';

/// Controller to open, close, or toggle the [FlatSideDrawer] programmatically.
class FlatSideDrawerController {
  VoidCallback? _open;
  VoidCallback? _close;
  VoidCallback? _toggle;

  /// Notifies listeners about the current state (isOpen).
  final ValueNotifier<bool> isOpenNotifier = ValueNotifier(false);

  /// Opens the drawer.
  void open() => _open?.call();

  /// Closes the drawer.
  void close() => _close?.call();

  /// Toggles the drawer state.
  void toggle() => _toggle?.call();

  /// Register a closure to be called when the object changes.
  void addListener(VoidCallback listener) {
    isOpenNotifier.addListener(listener);
  }

  /// Remove a previously registered closure from the list of closures that are
  /// notified when the object changes.
  void removeListener(VoidCallback listener) {
    isOpenNotifier.removeListener(listener);
  }

  /// Discards any resources used by the object.
  void dispose() {
    isOpenNotifier.dispose();
  }
}

/// A side drawer widget that slides the main content horizontally
/// without scaling it, similar to iOS or ChatGPT app behavior.
class FlatSideDrawer extends StatefulWidget {
  const FlatSideDrawer({
    super.key,
    required this.body,
    required this.menu,
    this.controller,
    this.slideWidthFraction = 0.75,
    this.dragStartEdge = 60.0,
    this.shadowColor = Colors.black,
    this.shadowOpacity = 0.3,
    this.animationDuration = const Duration(milliseconds: 250),
    this.direction = TextDirection.ltr,
  });

  /// The main screen of your application (the one that slides).
  final Widget body;

  /// The menu widget that stays behind the body.
  final Widget menu;

  /// Optional controller to manage drawer state.
  final FlatSideDrawerController? controller;

  /// Fraction of the screen width that the body slides (0.0 to 1.0).
  /// Default is 0.75 (75%).
  final double slideWidthFraction;

  /// Width of the active zone on the left edge to start the drag gesture.
  /// Default is 60.0.
  final double dragStartEdge;

  /// Color of the overlay shadow when the drawer is open.
  final Color shadowColor;

  /// Maximum opacity of the overlay shadow (0.0 to 1.0).
  final double shadowOpacity;

  /// Duration of the open/close animation.
  final Duration animationDuration;

  /// Text direction, useful for RTL support.
  final TextDirection direction;

  @override
  State<FlatSideDrawer> createState() => _FlatSideDrawerState();
}

class _FlatSideDrawerState extends State<FlatSideDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late FlatSideDrawerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? FlatSideDrawerController();

    _controller._open = _openDrawer;
    _controller._close = _closeDrawer;
    _controller._toggle = _toggleDrawer;

    _animationController =
        AnimationController(vsync: this, duration: widget.animationDuration)
          ..addListener(() {
            final isOpen = _animationController.value > 0.5;
            if (_controller.isOpenNotifier.value != isOpen) {
              _controller.isOpenNotifier.value = isOpen;
            }
          });
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _openDrawer() => _animationController.forward();
  void _closeDrawer() => _animationController.reverse();

  void _toggleDrawer() {
    if (_animationController.isDismissed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final slideWidth = screenWidth * widget.slideWidthFraction;

    _animationController.value += details.primaryDelta! / slideWidth;
  }

  void _onDragEnd(DragEndDetails details) {
    if (_animationController.isDismissed || _animationController.isCompleted) {
      return;
    }

    final double visualVelocity = details.velocity.pixelsPerSecond.dx;

    if (visualVelocity.abs() >= 365.0) {
      visualVelocity > 0
          ? _animationController.forward()
          : _animationController.reverse();
    } else {
      _animationController.value > 0.5
          ? _animationController.forward()
          : _animationController.reverse();
    }
  }

  bool _canStartDrag(DragStartDetails details) {
    final isDrawerOpen = _animationController.value > 0.5;
    if (isDrawerOpen) return true;
    return details.globalPosition.dx < widget.dragStartEdge;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final slideWidth = screenSize.width * widget.slideWidthFraction;

    return GestureDetector(
      onHorizontalDragStart: (details) {
        if (!_canStartDrag(details)) return;
      },
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        children: [
          SizedBox(
            width: slideWidth,
            height: screenSize.height,
            child: widget.menu,
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final slide = _animationController.value * slideWidth;
              return Transform.translate(
                offset: Offset(slide, 0),
                child: child,
              );
            },
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: Offset(-5, 0),
                      ),
                    ],
                  ),
                  child: widget.body,
                ),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, _) {
                    if (_animationController.value == 0) {
                      return const SizedBox.shrink();
                    }
                    return GestureDetector(
                      onTap: _closeDrawer,
                      child: Container(
                        width: screenSize.width,
                        height: screenSize.height,
                        color: widget.shadowColor.withValues(
                          alpha:
                              _animationController.value * widget.shadowOpacity,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
