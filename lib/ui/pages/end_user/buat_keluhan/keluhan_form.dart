import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/widgets/shared/form.dart';
import 'package:flutter/material.dart';

class KeluhanForm extends StatelessWidget {
  const KeluhanForm({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController judulController = TextEditingController();
    final TextEditingController deskripsiController = TextEditingController();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // title
                Text(
                  'Form Keluhan',
                  style: blackTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 16),

                // Judul keluhan
                CustomFormField(
                  title: 'Judul Keluhan',
                  controller: judulController,
                ),
                const SizedBox(height: 16),

                // Deskripsi keluhan
                Text(
                  'Deskripsi Keluhan',
                  style: blackTextStyle.copyWith(fontWeight: medium),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: deskripsiController,
                  maxLines: 5,
                  style: blackTextStyle,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: whiteColor,
                    hintText: 'Tuliskan deskripsi keluhan kamu...',
                    hintStyle: greyTextStyle,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: greyColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: greenColor, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Tombol kirim keluhan
                CustomFilledButton(
                  title: 'Kirim Keluhan',
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: greenColor,
                        content: Text('Keluhan berhasil dikirim!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
