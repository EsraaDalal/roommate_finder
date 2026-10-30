// import 'package:flutter/material.dart';

// import '../../../../core/resources/app_colors.dart';
// import '../../../../core/resources/app_spacing.dart';

// /// Photo slot picker for the Create / Edit listing form.
// ///
// /// The designs specify "Add housing photos / Up to 8 images". No image
// /// picker dependency is added: slots are added and removed in memory, and
// /// each renders as a placeholder until real photo support is introduced.
// class PhotoPickerField extends StatelessWidget {
//   const PhotoPickerField({
//     super.key,
//     required this.count,
//     required this.onChanged,
//     this.maxPhotos = 8,
//   });

//   final int count;
//   final ValueChanged<int> onChanged;
//   final int maxPhotos;

//   @override
//   Widget build(BuildContext context) {
//     final ThemeData theme = Theme.of(context);
//     final bool canAdd = count < maxPhotos;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (count > 0) ...[
//           SizedBox(
//             height: 76,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               itemCount: count,
//               separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
//               itemBuilder: (BuildContext context, int index) {
//                 return _PhotoSlot(
//                   onRemove: () => onChanged(count - 1),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: AppSpacing.sm),
//         ],
//         InkWell(
//           onTap: canAdd ? () => onChanged(count + 1) : null,
//           borderRadius: BorderRadius.circular(AppRadius.md),
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primaryContainer,
//               borderRadius: BorderRadius.circular(AppRadius.md),
//               border: Border.all(
//                 color: theme.colorScheme.secondary.withValues(alpha: 0.4),
//               ),
//             ),
//             child: Column(
//               children: [
//                 Icon(
//                   canAdd ? Icons.add_rounded : Icons.image_not_supported_outlined,
//                   size: 22,
//                   color: canAdd
//                       ? theme.colorScheme.secondary
//                       : theme.textTheme.bodySmall?.color,
//                 ),
//                 const SizedBox(height: AppSpacing.xxs),
//                 Text(
//                   'Add housing photos',
//                   style: theme.textTheme.labelLarge?.copyWith(
//                     color: canAdd
//                         ? theme.colorScheme.secondary
//                         : theme.textTheme.bodySmall?.color,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   canAdd
//                       ? 'Up to $maxPhotos images'
//                       : 'Maximum of $maxPhotos images reached',
//                   style: theme.textTheme.bodySmall,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _PhotoSlot extends StatelessWidget {
//   const _PhotoSlot({required this.onRemove});

//   final VoidCallback onRemove;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 96,
//       child: Stack(
//         children: [
//           Container(
//             width: 96,
//             height: 76,
//             decoration: BoxDecoration(
//               color: AppColors.primaryTint,
//               borderRadius: BorderRadius.circular(AppRadius.md),
//             ),
//             child: Icon(
//               Icons.home_outlined,
//               size: 24,
//               color: AppColors.avatarGreen.withValues(alpha: 0.6),
//             ),
//           ),
//           Positioned(
//             top: 2,
//             right: 2,
//             child: Material(
//               color: Colors.white,
//               shape: const CircleBorder(),
//               child: InkWell(
//                 onTap: onRemove,
//                 customBorder: const CircleBorder(),
//                 child: const SizedBox(
//                   width: 22,
//                   height: 22,
//                   child: Icon(Icons.close_rounded, size: 13),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }