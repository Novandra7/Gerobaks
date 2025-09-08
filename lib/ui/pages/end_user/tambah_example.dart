// import 'package:bank_sha/shared/theme.dart';
// import 'package:bank_sha/ui/widgets/shared/buttons.dart';
// import 'package:bank_sha/ui/widgets/shared/form.dart';
// import 'package:flutter/material.dart';

// class TambahJadwalPage extends StatefulWidget {
//   const TambahJadwalPage({super.key});

//   @override
//   State<TambahJadwalPage> createState() => _TambahJadwalPageState();
// }

// class _TambahJadwalPageState extends State<TambahJadwalPage>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Offset> _offsetAnimation;
//   late Animation<double> _fadeAnimation;

//   final TextEditingController alamatController = TextEditingController();
//   final TextEditingController tanggalController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );

//     _offsetAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.2),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

//     _fadeAnimation = Tween<double>(
//       begin: 0,
//       end: 1,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     alamatController.dispose();
//     tanggalController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate() async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//     );

//     if (pickedDate != null) {
//       tanggalController.text =
//           "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;

//     return SlideTransition(
//       position: _offsetAnimation,
//       child: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           height: screenHeight * 0.55,
//           decoration: BoxDecoration(
//             color: whiteColor,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 50,
//                   height: 5,
//                   margin: const EdgeInsets.only(bottom: 16),
//                   decoration: BoxDecoration(
//                     color: greyColor,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//               Text(
//                 'Tambah Jadwal Pengambilan',
//                 style: blackTextStyle.copyWith(
//                   fontSize: 18,
//                   fontWeight: semiBold,
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Custom Form Field: Alamat
//               CustomFormField(title: 'Alamat', controller: alamatController),
//               const SizedBox(height: 12),

//               // Custom Form Field: Tanggal
//               CustomFormJadwal(
//                 title: 'Tanggal Pengambilan',
//                 controller: tanggalController,
//                 readOnly: true,
//                 suffixIcon: Icon(Icons.calendar_today, color: greyColor),
//                 onTap: _selectDate,
//               ),
//               const Spacer(),

//               // Custom Filled Button
//               CustomFilledButton(
//                 title: 'Kirim Jadwal',
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
