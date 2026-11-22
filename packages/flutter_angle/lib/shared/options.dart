class AngleOptions {
  final int width;
  final int height;
  final double dpr;
  final bool antialias;
  final bool alpha;
  final bool customRenderer;
  final bool useSurfaceProducer;

  const AngleOptions({
    required this.width,
    required this.height,
    required this.dpr,
    this.alpha = false,
    this.antialias = false,
    this.customRenderer = true,
    this.useSurfaceProducer = false,
  });
}
