import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/guide_provider.dart';
import '../theme/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class GuideWrapper extends ConsumerWidget {
  final Widget child;
  final String title;
  final String description;
  final AlignmentGeometry alignment;
  final String? id;

  const GuideWrapper({
    super.key,
    required this.child,
    required this.title,
    required this.description,
    this.alignment = Alignment.topRight,
    this.id,
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
          bottom:
              MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom +
              24,
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
                    color: AppColors.of(
                      context,
                    ).naranjaUnimet.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.tips_and_updates,
                    color: AppColors.of(context).naranjaUnimet,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textoPrincipal,
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
                color: AppColors.of(context).sombras,
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.of(context).naranjaUnimet,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'entendido'.tr(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
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

    // Calcular posiciones basadas en la alineación
    double? top, bottom, left, right;
    if (alignment == Alignment.topLeft) {
      top = -8;
      left = -8;
    } else if (alignment == Alignment.topRight) {
      top = -8;
      right = -8;
    } else if (alignment == Alignment.bottomLeft) {
      bottom = -8;
      left = -8;
    } else if (alignment == Alignment.bottomRight) {
      bottom = -8;
      right = -8;
    } else if (alignment == Alignment.centerRight) {
      top = 0;
      bottom = 0;
      right = -8;
    } else if (alignment == Alignment.centerLeft) {
      top = 0;
      bottom = 0;
      left = -8;
    } else if (alignment == Alignment.topCenter) {
      top = -8;
      left = 0;
      right = 0;
    } else if (alignment == Alignment.bottomCenter) {
      bottom = -8;
      left = 0;
      right = 0;
    } else {
      top = -8;
      right = -8;
    } // Default topRight

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: top,
          bottom: bottom,
          left: left,
          right: right,
          child: Center(
            child: GestureDetector(
              onTap: () => _showGuideModal(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.of(context).naranjaUnimet,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
