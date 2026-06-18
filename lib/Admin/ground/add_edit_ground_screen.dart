// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:slotbookingadmin/theme/app_colors.dart';

// class AddGroundScreen extends StatefulWidget {
//   const AddGroundScreen({super.key});

//   @override
//   State<AddGroundScreen> createState() => _AddGroundScreenState();
// }

// class _AddGroundScreenState extends State<AddGroundScreen> {
//   static const _green = Color(0xFF0D5C3A);
//   static const _greenLight = Color(0xFFE8F5EE);
//   static const _bg = Color(0xFFF0F3F0);

//   final _formKey = GlobalKey<FormState>();
//   final _nameCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   final _addressCtrl = TextEditingController();
//   final _cityCtrl = TextEditingController();

//   String _sportType = 'Cricket';
//   bool _isLoading = false;
//   List<XFile> _pickedImages = [];

//   final List<String> _sportTypes = [
//     'Cricket',
//     'Football',
//     'Basketball',
//     'Tennis',
//     'Badminton',
//     'Volleyball',
//     'Hockey',
//   ];

//   final List<_AmenityOption> _amenities = [
//     _AmenityOption(label: 'Parking', icon: Icons.local_parking_rounded),
//     _AmenityOption(label: 'Drinking Water', icon: Icons.water_drop_outlined),
//     _AmenityOption(label: 'Floodlights', icon: Icons.light_mode_outlined),
//     _AmenityOption(label: 'Washroom', icon: Icons.wc_rounded),
//     _AmenityOption(label: 'Cafeteria', icon: Icons.restaurant_outlined),
//     _AmenityOption(label: 'First Aid', icon: Icons.medical_services_outlined),
//     _AmenityOption(label: 'Free Wi-Fi', icon: Icons.wifi_rounded),
//   ];

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _descCtrl.dispose();
//     _addressCtrl.dispose();
//     _cityCtrl.dispose();
//     super.dispose();
//   }

//   List<String> get _selectedAmenities =>
//       _amenities.where((a) => a.selected).map((a) => a.label).toList();

//   // ── Pick images ────────────────────────────────────────────────────────────
//   Future<void> _pickImages() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickMultiImage(imageQuality: 70);
//     if (picked.isNotEmpty) {
//       setState(() {
//         _pickedImages = [..._pickedImages, ...picked].take(4).toList();
//       });
//     }
//   }

//   // ── Upload images to Firebase Storage ─────────────────────────────────────
//   Future<List<String>> _uploadImages(String groundId) async {
//     final List<String> urls = [];
//     for (int i = 0; i < _pickedImages.length; i++) {
//       final file = File(_pickedImages[i].path);
//       final ref = FirebaseStorage.instance.ref().child(
//         'grounds/$groundId/image_$i.jpg',
//       );
//       await ref.putFile(file);
//       final url = await ref.getDownloadURL();
//       urls.add(url);
//     }
//     return urls;
//   }

//   // ── Save ground to Firestore ───────────────────────────────────────────────
//   Future<void> _saveGround() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isLoading = true);

//     try {
//       final user = FirebaseAuth.instance.currentUser!;

//       final adminDoc = await FirebaseFirestore.instance
//           .collection('admin')
//           .doc(user.uid)
//           .get();
//       final adminName = adminDoc.data()?['name'] ?? 'Ground Owner';

//       await FirebaseFirestore.instance.collection('grounds').add({
//         'name': _nameCtrl.text.trim(),
//         'address': _addressCtrl.text.trim(),
//         'city': _cityCtrl.text.trim(),
//         'sportType': _sportType,
//         'description': _descCtrl.text.trim(),
//         'amenities': _selectedAmenities,
//         'images': _pickedImages.isNotEmpty
//             ? _pickedImages
//             : "", // ✅ plain string instead of upload
//         'adminId': user.uid,
//         'adminName': adminName,
//         'status': true,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       if (!mounted) return;
//       _showSuccessDialog();
//     } catch (e) {
//       if (!mounted) return;
//       _showSnack('Failed to save ground: $e', Colors.red[700]!);
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _showSnack(String msg, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Padding(
//           padding: const EdgeInsets.all(28),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 72,
//                 height: 72,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(.10),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.check_circle_rounded,
//                   color: AppColors.primary,
//                   size: 42,
//                 ),
//               ),
//               const SizedBox(height: 18),
//               const Text(
//                 'Ground Added!',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w800,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Your ground has been saved and is pending review.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: AppColors.textSecondary,
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(ctx);
//                     context.go('/admin/grounds');
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                   ),
//                   child: const Text(
//                     'View Grounds',
//                     style: TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         bottom: false,
//         child: Column(
//           children: [
//             // ── App bar ──────────────────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(
//                       Icons.arrow_back_ios_new_rounded,
//                       color: AppColors.primary,
//                     ),
//                     onPressed: () => context.pop(),
//                   ),
//                   const Text(
//                     'Add New\nGround',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w800,
//                       color: AppColors.primary,
//                       height: 1.2,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: const Icon(Icons.notifications_none_rounded),
//                     color: AppColors.primary,
//                     onPressed: () {},
//                   ),
//                   Container(
//                     width: 36,
//                     height: 36,
//                     decoration: BoxDecoration(
//                       color: AppColors.primary.withOpacity(.12),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.person_rounded,
//                       color: AppColors.primary,
//                       size: 20,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ── Form ─────────────────────────────────────────────────────────
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // ── Gallery ────────────────────────────────────────────
//                       _sectionLabel(
//                         'GROUND GALLERY',
//                         padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//                       ),
//                       _buildGallery(),

//                       // ── Location ───────────────────────────────────────────
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Location',
//                               style: Theme.of(context).textTheme.bodyLarge
//                                   ?.copyWith(
//                                     fontWeight: FontWeight.w700,
//                                     color: AppColors.textPrimary,
//                                   ),
//                             ),
//                             GestureDetector(
//                               onTap: () {},
//                               child: Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.edit_location_alt_outlined,
//                                     size: 16,
//                                     color: AppColors.primary,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     'Edit',
//                                     style: TextStyle(
//                                       fontSize: 13,
//                                       color: AppColors.primary,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 10),

//                       // Map placeholder
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: AppColors.border,
//                               image: DecorationImage(
//                                 image: AssetImage("assets/images/bg_map.png"),
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                             width: double.infinity,
//                             height: 140,
//                             child: Stack(
//                               alignment: Alignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.map_outlined,
//                                   size: 60,
//                                   color: AppColors.textSecondary,
//                                 ),
//                                 Container(
//                                   padding: const EdgeInsets.all(8),
//                                   decoration: const BoxDecoration(
//                                     color: AppColors.primary,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(
//                                     Icons.location_on,
//                                     color: AppColors.textSecondary,
//                                     size: 20,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),

//                       // Address fields
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Column(
//                           children: [
//                             _buildField(
//                               controller: _addressCtrl,
//                               hint: 'Civil Lines, Jhansi, Uttar Pradesh 284001',
//                               validator: (v) => (v == null || v.trim().isEmpty)
//                                   ? 'Address required'
//                                   : null,
//                             ),
//                             const SizedBox(height: 10),
//                             _buildField(
//                               controller: _cityCtrl,
//                               hint: 'City (e.g. Jhansi)',
//                               validator: (v) => (v == null || v.trim().isEmpty)
//                                   ? 'City required'
//                                   : null,
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 16),
//                       const Divider(height: 1, color: AppColors.divider),
//                       const SizedBox(height: 16),

//                       // ── Ground Name ────────────────────────────────────────
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _fieldLabel('Ground Name'),
//                             const SizedBox(height: 8),
//                             _buildField(
//                               controller: _nameCtrl,
//                               hint: 'DDA Cricket Ground',
//                               validator: (v) =>
//                                   (v == null || v.trim().length < 3)
//                                   ? 'Enter ground name'
//                                   : null,
//                             ),
//                             const SizedBox(height: 14),

//                             // ── Sport Type ─────────────────────────────────
//                             _fieldLabel('Sport Type'),
//                             const SizedBox(height: 8),
//                             _buildDropdown(),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 20),
//                       const Divider(height: 1, color: AppColors.divider),
//                       const SizedBox(height: 16),

//                       // ── Amenities ──────────────────────────────────────────
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text(
//                                   'Amenities',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w800,
//                                     color: AppColors.textPrimary,
//                                   ),
//                                 ),
//                                 Text(
//                                   'Select all that apply',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: AppColors.textSecondary,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//                             Wrap(
//                               spacing: 8,
//                               runSpacing: 8,
//                               children: _amenities.map((a) {
//                                 return GestureDetector(
//                                   onTap: () =>
//                                       setState(() => a.selected = !a.selected),
//                                   child: AnimatedContainer(
//                                     duration: const Duration(milliseconds: 180),
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 14,
//                                       vertical: 10,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: a.selected
//                                           ? AppColors.primary.withOpacity(.10)
//                                           : AppColors.card,
//                                       borderRadius: BorderRadius.circular(30),
//                                       border: Border.all(
//                                         color: a.selected
//                                             ? AppColors.primary
//                                             : AppColors.primary.withOpacity(
//                                                 .12,
//                                               ),
//                                         width: a.selected ? 1.5 : 1,
//                                       ),
//                                     ),
//                                     child: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Icon(
//                                           a.icon,
//                                           size: 16,
//                                           color: a.selected
//                                               ? AppColors.primary
//                                               : AppColors.textSecondary,
//                                         ),
//                                         const SizedBox(width: 6),
//                                         Text(
//                                           a.label,
//                                           style: TextStyle(
//                                             fontSize: 13,
//                                             fontWeight: a.selected
//                                                 ? FontWeight.w600
//                                                 : FontWeight.w400,
//                                             color: a.selected
//                                                 ? AppColors.primary
//                                                 : AppColors.textSecondary,
//                                           ),
//                                         ),
//                                         if (a.selected) ...[
//                                           const SizedBox(width: 6),
//                                           const Icon(
//                                             Icons.check_circle,
//                                             size: 14,
//                                             color: AppColors.primary,
//                                           ),
//                                         ],
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 16),
//                       const Divider(height: 1, color: AppColors.divider),
//                       const SizedBox(height: 16),

//                       // ── Description ────────────────────────────────────────
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _fieldLabel('Ground Description'),
//                             const SizedBox(height: 8),
//                             TextFormField(
//                               controller: _descCtrl,
//                               maxLines: 4,
//                               style: const TextStyle(fontSize: 14),
//                               decoration: InputDecoration(
//                                 hintText:
//                                     'A premium cricket facility located in the heart of Civil Lines...',
//                                 hintStyle: TextStyle(
//                                   color: AppColors.textSecondary,
//                                   fontSize: 13,
//                                 ),
//                                 filled: true,
//                                 fillColor: AppColors.surface,
//                                 contentPadding: const EdgeInsets.all(14),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                     color: AppColors.border!,
//                                     width: 1,
//                                   ),
//                                 ),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide(
//                                     color: AppColors.border!,
//                                     width: 1,
//                                   ),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                     color: AppColors.primary,
//                                     width: 1.5,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // const SizedBox(height: 16),

//                       // ── Stats chips ────────────────────────────────────────
//                       // Padding(
//                       //   padding: const EdgeInsets.symmetric(horizontal: 16),
//                       //   child: Row(
//                       //     children: [
//                       //       Expanded(
//                       //         child: _StatChip(
//                       //           icon: Icons.trending_up_rounded,
//                       //           label: 'ESTIMATED\nREACH',
//                       //           value: '2.4k',
//                       //           unit: 'Users/mo',
//                       //           color:AppColors.primary,
//                       //         ),
//                       //       ),
//                       //       const SizedBox(width: 12),
//                       //       Expanded(
//                       //         child: _StatChip(
//                       //           icon: Icons.stars_rounded,
//                       //           label: 'PLATFORM\nSCORE',
//                       //           value: '98',
//                       //           unit: '/100',
//                       //           color: Colors.blue[700]!,
//                       //         ),
//                       //       ),
//                       //     ],
//                       //   ),
//                       // ),
//                       const SizedBox(height: 24),

//                       // ── Save button ────────────────────────────────────────
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: SizedBox(
//                           width: double.infinity,
//                           height: 52,
//                           child: ElevatedButton.icon(
//                             onPressed: _isLoading ? null : _saveGround,
//                             icon: _isLoading
//                                 ? const SizedBox(
//                                     width: 20,
//                                     height: 20,
//                                     child: CircularProgressIndicator(
//                                       color: AppColors.primary,
//                                       strokeWidth: 2.5,
//                                     ),
//                                   )
//                                 : const Icon(Icons.save_rounded, size: 20),
//                             label: Text(
//                               _isLoading ? 'Saving...' : 'Save Details',
//                               style: const TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.primary,
//                               foregroundColor: Colors.white,
//                               elevation: 0,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                               disabledBackgroundColor: AppColors.primary
//                                   .withOpacity(0.5),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10),

//                       // ── Discard ────────────────────────────────────────────
//                       Center(
//                         child: TextButton(
//                           onPressed: () => context.pop(),
//                           child: Text(
//                             'Discard Changes',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: AppColors.textSecondary,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // ── Nav bar ──────────────────────────────────────────────────────
//             // const AdminNavBar(currentIndex: 1),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Gallery widget ─────────────────────────────────────────────────────────
//   Widget _buildGallery() {
//     return Column(
//       children: [
//         // Main preview
//         if (_pickedImages.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.file(
//                 File(_pickedImages[0].path),
//                 width: double.infinity,
//                 height: 180,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           )
//         else
//           GestureDetector(
//             onTap: _pickImages,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Container(
//                 width: double.infinity,
//                 height: 180,
//                 decoration: BoxDecoration(
//                   color: AppColors.surface,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: AppColors.primary.withOpacity(.12)!,
//                     style: BorderStyle.solid,
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.add_photo_alternate_outlined,
//                       size: 44,
//                       color: AppColors.textSecondary,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Tap to add ground photos',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         const SizedBox(height: 10),

//         // Thumbnails row
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Row(
//             children: [
//               ...List.generate(_pickedImages.length.clamp(0, 3), (i) {
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(
//                       File(_pickedImages[i].path),
//                       width: 72,
//                       height: 54,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 );
//               }),
//               // Upload button
//               GestureDetector(
//                 onTap: _pickImages,
//                 child: Container(
//                   width: 72,
//                   height: 54,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[50],
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: AppColors.primary.withOpacity(.12)!,
//                       style: BorderStyle.solid,
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.camera_alt_outlined,
//                         size: 18,
//                         color: AppColors.textSecondary,
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         'Upload',
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildField({
//     required TextEditingController controller,
//     required String hint,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       validator: validator,
//       style: const TextStyle(fontSize: 14),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
//         filled: true,
//         fillColor: AppColors.surface,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 14,
//           vertical: 13,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: AppColors.border!, width: 1),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: AppColors.border!, width: 1),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Colors.red),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: AppColors.border!, width: 1),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: _sportType,
//           isExpanded: true,
//           icon: Icon(
//             Icons.keyboard_arrow_down_rounded,
//             color: AppColors.textSecondary,
//           ),
//           style: const TextStyle(
//             fontSize: 14,
//             color: AppColors.textPrimary,
//             fontWeight: FontWeight.w500,
//           ),
//           items: _sportTypes
//               .map((s) => DropdownMenuItem(value: s, child: Text(s)))
//               .toList(),
//           onChanged: (v) => setState(() => _sportType = v!),
//         ),
//       ),
//     );
//   }

//   Widget _sectionLabel(String text, {EdgeInsets? padding}) {
//     return Padding(
//       padding: padding ?? EdgeInsets.zero,
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.w700,
//           letterSpacing: 1.4,
//           color: AppColors.textSecondary,
//         ),
//       ),
//     );
//   }

//   Widget _fieldLabel(String text) {
//     return Text(
//       text,
//       style: TextStyle(
//         fontSize: 13,
//         fontWeight: FontWeight.w600,
//         color: AppColors.textPrimary,
//       ),
//     );
//   }
// }

// // ── Amenity option model ──────────────────────────────────────────────────────
// class _AmenityOption {
//   final String label;
//   final IconData icon;
//   bool selected;
//   _AmenityOption({
//     required this.label,
//     required this.icon,
//     this.selected = false,
//   });
// }

// // ── Stat chip ─────────────────────────────────────────────────────────────────
// class _StatChip extends StatelessWidget {
//   final IconData icon;
//   final String label, value, unit;
//   final Color color;

//   const _StatChip({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.unit,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.06),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.15)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 14, color: color),
//               const SizedBox(width: 6),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 9,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 0.8,
//                   color: color.withOpacity(0.7),
//                   height: 1.4,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.baseline,
//             textBaseline: TextBaseline.alphabetic,
//             children: [
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.w800,
//                   color: color,
//                   letterSpacing: -0.5,
//                 ),
//               ),
//               const SizedBox(width: 3),
//               Text(
//                 unit,
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: color.withOpacity(0.7),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slotbookingadmin/theme/app_colors.dart';

// ── Import the separate image picker widget ───────────────────────────────────
// import 'package:slotbookingadmin/widgets/ground_image_picker.dart';
// (paste GroundImagePicker from image_picker_widget.dart into your widgets folder)

class AddGroundScreen extends StatefulWidget {
  const AddGroundScreen({super.key});

  @override
  State<AddGroundScreen> createState() => _AddGroundScreenState();
}

class _AddGroundScreenState extends State<AddGroundScreen> {
  static const _green = Color(0xFF0D5C3A);
  static const _greenLight = Color(0xFFE8F5EE);

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  String _sportType = 'Cricket';
  bool _isLoading = false;

  // ✅ FIX: Store XFile list — never pass this directly to Firestore
  List<XFile> _pickedImages = [];

  // Upload progress tracking
  double _uploadProgress = 0;
  String _uploadStatus = '';

  final List<String> _sportTypes = [
    'Cricket',
    'Football',
    'Basketball',
    'Tennis',
    'Badminton',
    'Volleyball',
    'Hockey',
  ];

  final List<_AmenityOption> _amenities = [
    _AmenityOption(label: 'Parking', icon: Icons.local_parking_rounded),
    _AmenityOption(label: 'Drinking Water', icon: Icons.water_drop_outlined),
    _AmenityOption(label: 'Floodlights', icon: Icons.light_mode_outlined),
    _AmenityOption(label: 'Washroom', icon: Icons.wc_rounded),
    _AmenityOption(label: 'Cafeteria', icon: Icons.restaurant_outlined),
    _AmenityOption(label: 'First Aid', icon: Icons.medical_services_outlined),
    _AmenityOption(label: 'Free Wi-Fi', icon: Icons.wifi_rounded),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  List<String> get _selectedAmenities =>
      _amenities.where((a) => a.selected).map((a) => a.label).toList();

  // ── Pick images ────────────────────────────────────────────────────────────
  Future<void> _pickImages() async {
    final remaining = 4 - _pickedImages.length;
    if (remaining <= 0) {
      _showSnack('Maximum 4 images allowed.', Colors.orange[700]!);
      return;
    }

    final picker = ImagePicker();

    // ✅ FIX: imageQuality + maxWidth compresses before storing
    // This prevents large XFile sizes and upload failures
    final picked = await picker.pickMultiImage(
      imageQuality: 70,
      maxWidth: 1280,
      maxHeight: 960,
    );

    if (picked.isEmpty) return;

    setState(() {
      _pickedImages = [..._pickedImages, ...picked].take(4).toList();
    });
  }

  // ── Remove image ───────────────────────────────────────────────────────────
  void _removeImage(int index) {
    setState(() => _pickedImages.removeAt(index));
  }

  // ── Upload images to Firebase Storage ─────────────────────────────────────
  // ✅ FIX: Returns List<String> (download URLs) — these are safe for Firestore
  Future<List<String>> _uploadImages(String groundId) async {
    final List<String> downloadUrls = [];

    for (int i = 0; i < _pickedImages.length; i++) {
      // Update progress
      setState(() {
        _uploadProgress = i / _pickedImages.length;
        _uploadStatus =
            'Uploading image ${i + 1} of ${_pickedImages.length}...';
      });

      final file = File(_pickedImages[i].path);

      // ✅ Storage path: grounds/{groundId}/image_0.jpg
      final ref = FirebaseStorage.instance.ref().child(
        'grounds/$groundId/image_$i.jpg',
      );

      // Upload with metadata
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for upload to complete
      await uploadTask;

      // ✅ Get the download URL (a String) — safe to store in Firestore
      final url = await ref.getDownloadURL();
      downloadUrls.add(url);
    }

    return downloadUrls;
  }

  // ── Save ground to Firestore ───────────────────────────────────────────────
  Future<void> _saveGround() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _uploadProgress = 0;
      _uploadStatus = 'Saving ground details...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // 1. Read admin name — 1 Firestore read
      setState(() => _uploadStatus = 'Fetching admin details...');
      final adminDoc = await FirebaseFirestore.instance
          .collection('admin')
          .doc(user.uid)
          .get();
      final adminName = adminDoc.data()?['name'] ?? 'Ground Owner';

      // 2. Create ground doc first to get the groundId
      setState(() => _uploadStatus = 'Creating ground...');
      final groundRef = FirebaseFirestore.instance.collection('grounds').doc();
      final groundId = groundRef.id;

      // 3. Upload images → get List<String> download URLs
      List<String> imageUrls = [];
      if (_pickedImages.isNotEmpty) {
        imageUrls = await _uploadImages(groundId);
      }

      setState(() => _uploadStatus = 'Finalizing...');

      // 4. ✅ FIX: Save to Firestore with imageUrls (List<String>), NOT XFile
      // Firestore only accepts: String, int, double, bool, List, Map, Timestamp, GeoPoint, DocumentReference
      await groundRef.set({
        'name': _nameCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'sportType': _sportType,
        'description': _descCtrl.text.trim(),
        'amenities': _selectedAmenities,

        // ✅ Store as List<String> of download URLs (or empty list)
        'images': imageUrls, // e.g. ["https://firebasestorage..."]
        'coverImage':
            imageUrls
                .isNotEmpty // first image as cover
            ? imageUrls[0]
            : '',

        'adminId': user.uid,
        'adminName': adminName,
        'status': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      // ✅ Better error message — shows what actually went wrong
      _showSnack('Failed to save ground: ${e.toString()}', Colors.red[700]!);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _uploadProgress = 0;
          _uploadStatus = '';
        });
      }
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _green.withOpacity(.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: _green,
                  size: 42,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Ground Added!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0E1A13),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your ground has been saved successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/admin/grounds');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'View Grounds',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primary,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  const Text(
                    'Add New\nGround',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      height: 1.2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    color: AppColors.primary,
                    onPressed: () {},
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // ── Upload progress bar (shows during save) ───────────────────
            if (_isLoading && _uploadProgress > 0)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _uploadStatus,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(_green),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Form ─────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Gallery ────────────────────────────────────────────
                      _sectionLabel(
                        'GROUND GALLERY',
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      ),

                      // ✅ Use the separate GroundImagePicker widget OR inline gallery below
                      _buildGallery(),

                      // ── Location ───────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Location',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.edit_location_alt_outlined,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Map placeholder
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            height: 140,
                            color: AppColors.border,
                            child: const Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.map_outlined,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Address fields
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildField(
                              controller: _addressCtrl,
                              hint: 'Civil Lines, Jhansi, Uttar Pradesh 284001',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Address required'
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            _buildField(
                              controller: _cityCtrl,
                              hint: 'City (e.g. Jhansi)',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'City required'
                                  : null,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1, color: AppColors.divider),
                      const SizedBox(height: 16),

                      // ── Ground Name ────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('Ground Name'),
                            const SizedBox(height: 8),
                            _buildField(
                              controller: _nameCtrl,
                              hint: 'DDA Cricket Ground',
                              validator: (v) =>
                                  (v == null || v.trim().length < 3)
                                  ? 'Enter ground name'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            _fieldLabel('Sport Type'),
                            const SizedBox(height: 8),
                            _buildDropdown(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Divider(height: 1, color: AppColors.divider),
                      const SizedBox(height: 16),

                      // ── Amenities ──────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Amenities',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Select all that apply',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _amenities.map((a) {
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => a.selected = !a.selected),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: a.selected
                                          ? AppColors.primary.withOpacity(.10)
                                          : AppColors.card,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: a.selected
                                            ? AppColors.primary
                                            : AppColors.primary.withOpacity(
                                                .12,
                                              ),
                                        width: a.selected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          a.icon,
                                          size: 16,
                                          color: a.selected
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          a.label,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: a.selected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: a.selected
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                        if (a.selected) ...[
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.check_circle,
                                            size: 14,
                                            color: AppColors.primary,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1, color: AppColors.divider),
                      const SizedBox(height: 16),

                      // ── Description ────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('Ground Description'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _descCtrl,
                              maxLines: 4,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText:
                                    'A premium cricket facility located in the heart of Civil Lines...',
                                hintStyle: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                                contentPadding: const EdgeInsets.all(14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.border!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.border!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Save button ────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _saveGround,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Icon(Icons.save_rounded, size: 20),
                            label: Text(
                              _isLoading
                                  ? _uploadStatus.isNotEmpty
                                        ? _uploadStatus
                                        : 'Saving...'
                                  : 'Save Details',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              disabledBackgroundColor: AppColors.primary
                                  .withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Discard ────────────────────────────────────────────
                      Center(
                        child: TextButton(
                          onPressed: _isLoading ? null : () => context.pop(),
                          child: Text(
                            'Discard Changes',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Gallery widget (inline version) ───────────────────────────────────────
  Widget _buildGallery() {
    return Column(
      children: [
        // Main preview
        if (_pickedImages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_pickedImages[0].path),
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                // Cover label
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Cover Photo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Remove cover button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removeImage(0),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: _pickImages,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: _greenLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _green.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 44,
                      color: _green.withOpacity(0.7),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add ground photos',
                      style: TextStyle(
                        fontSize: 13,
                        color: _green.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Up to 4 photos · JPG, PNG',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 10),

        // Thumbnail row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Thumbnails (skip index 0 — it's the cover)
              ...List.generate(_pickedImages.length.clamp(0, 4), (i) {
                if (i == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_pickedImages[i].path),
                          width: 68,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _removeImage(i),
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Add more button
              if (_pickedImages.length < 4)
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 68,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _greenLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _green.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 18,
                          color: _green,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_pickedImages.length}/4',
                          style: TextStyle(
                            fontSize: 10,
                            color: _green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Helper text
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Text(
            _pickedImages.isEmpty
                ? 'Add up to 4 photos of your ground'
                : '${_pickedImages.length} photo${_pickedImages.length > 1 ? 's' : ''} selected',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border!, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sportType,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          items: _sportTypes
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) => setState(() => _sportType = v!),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, {EdgeInsets? padding}) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  // void _removeImage(int index) {
  //   setState(() => _pickedImages.removeAt(index));
  // }
}

// ── Amenity option model ──────────────────────────────────────────────────────
class _AmenityOption {
  final String label;
  final IconData icon;
  bool selected;
  _AmenityOption({
    required this.label,
    required this.icon,
    this.selected = false,
  });
}
