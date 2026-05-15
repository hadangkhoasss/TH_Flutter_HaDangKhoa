import 'package:flutter/material.dart';

/// Text chạy ngang (Marquee) – dùng cho tên bài hát dài (style Spotify)
class MarqueeText extends StatefulWidget {
  /// Nội dung text cần hiển thị
  final String text;

  /// Style của text
  final TextStyle style;

  /// Thời gian hoàn thành 1 vòng chạy
  final Duration duration;

  /// Khoảng trễ trước khi bắt đầu chạy
  final Duration startDelay;

  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 12),
    this.startDelay = const Duration(milliseconds: 800),
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  /// Có cần chạy marquee hay không
  bool _shouldScroll = false;

  @override
  void initState() {
    super.initState();

    /// Controller điều khiển animation
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    /// Animation dịch chuyển từ phải → trái
    _animation = Tween<double>(begin: 1.0, end: -1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    /// Đợi layout xong để kiểm tra text có bị tràn không
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfOverflow();
    });
  }

  /// Kiểm tra text có dài hơn khung hiển thị không
  void _checkIfOverflow() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    if (!mounted) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final isOverflow = textPainter.width > box.size.width;

    setState(() {
      _shouldScroll = isOverflow;
    });

    /// Chỉ chạy marquee nếu text bị tràn
    if (isOverflow) {
      Future.delayed(widget.startDelay, () {
        if (mounted) {
          _controller.repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Nếu text ngắn → hiển thị bình thường (giống Spotify)
    if (!_shouldScroll) {
      return Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    /// Text dài → chạy marquee
    return ClipRect(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return FractionalTranslation(
            translation: Offset(_animation.value, 0),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 24),
          child: Text(
            widget.text,
            style: widget.style,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }
}
