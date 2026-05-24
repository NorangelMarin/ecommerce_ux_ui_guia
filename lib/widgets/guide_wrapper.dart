import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/guide_provider.dart';
import '../theme/app_colors.dart';

class GuideWrapper extends ConsumerWidget {
  final Widget child;
  final String title;
  final String description;
  final AlignmentGeometry alignment;

  const GuideWrapper({
    super.key,
    required this.child,
    required this.title,
    required this.description,
    this.alignment = Alignment.topRight,
  });

  void _showGuideModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.naranjaUnimet.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.tips_and_updates, color: AppColors.naranjaUnimet, size: 28),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoPrincipal,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                fontSize: 15,
                color: AppColors.sombras,
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.naranjaUnimet,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text('Entendido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuideMode = ref.watch(guideProvider);

    if (!isGuideMode) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: Align(
            alignment: alignment,
            child: FractionalTranslation(
              translation: _getTranslationOffset(alignment),
              child: GestureDetector(
                onTap: () => _showGuideModal(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.naranjaUnimet,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Offset _getTranslationOffset(AlignmentGeometry align) {
    if (align == Alignment.topLeft) return Offset(-0.3, -0.3);
    if (align == Alignment.topRight) return Offset(0.3, -0.3);
    if (align == Alignment.bottomLeft) return Offset(-0.3, 0.3);
    if (align == Alignment.bottomRight) return Offset(0.3, 0.3);
    if (align == Alignment.centerRight) return Offset(0.3, 0.0);
    if (align == Alignment.centerLeft) return Offset(-0.3, 0.0);
    if (align == Alignment.topCenter) return Offset(0.0, -0.3);
    if (align == Alignment.bottomCenter) return Offset(0.0, 0.3);
    return Offset(0.3, -0.3);
  }
}
