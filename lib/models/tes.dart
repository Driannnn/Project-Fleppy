// ListView.separated(
//                   physics: const NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   itemCount: _challenges.length,
//                   separatorBuilder: (_, __) => const SizedBox(height: 10),
//                   itemBuilder: (context, i) {
//                     final c = _challenges[i];

//                     // Jika Advanced, gunakan warna & icon kustom
//                     Color chipColor = Colors.white.withOpacity(0.18);
//                     String? iconPath;
//                     if (c is AdvancedGameConfig) {
//                       chipColor = c.themeColor.withOpacity(0.25);
//                       iconPath = c.iconPath;
//                     }

//                     return Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.14),
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(color: Colors.white30, width: 1.2),
//                       ),
//                       child: ExpansionTile(
//                         tilePadding: const EdgeInsets.symmetric(horizontal: 14),
//                         collapsedIconColor: Colors.white70,
//                         iconColor: Colors.white,
//                         leading: Container(
//                           width: 44,
//                           height: 44,
//                           decoration: BoxDecoration(
//                             color: chipColor,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white30),
//                           ),
//                           child: iconPath != null && iconPath.endsWith('.svg')
//                               ? Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: SvgPicture.asset(
//                                     iconPath,
//                                     fit: BoxFit.contain,
//                                   ),
//                                 )
//                               : const Icon(
//                                   Icons.flag_rounded,
//                                   color: Colors.white,
//                                 ),
//                         ),
//                         title: Text(
//                           c.name,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w800,
//                             fontSize: 16,
//                           ),
//                         ),
//                         subtitle: Text(
//                           c.description,
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 13,
//                           ),
//                         ),
//                         childrenPadding: const EdgeInsets.fromLTRB(
//                           14,
//                           0,
//                           14,
//                           14,
//                         ),
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: _glassStat(
//                                   label: 'Gap',
//                                   value: '${c.pipeGapH.toStringAsFixed(0)} px',
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: _glassStat(
//                                   label: 'Speed',
//                                   value:
//                                       '${c.pipeSpeed.toStringAsFixed(1)} px/tick',
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           SizedBox(
//                             width: double.infinity,
//                             height: 44,
//                             child: FilledButton.icon(
//                               style: FilledButton.styleFrom(
//                                 backgroundColor: Colors.white.withOpacity(0.22),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               onPressed: () => _playWithConfig(c),
//                               icon: const Icon(Icons.play_arrow_rounded),
//                               label: const Text('Mainkan tantangan ini'),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),