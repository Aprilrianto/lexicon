import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class VerificationEmailScreen extends StatefulWidget {
  const VerificationEmailScreen({super.key});

  @override
  State<VerificationEmailScreen> createState() =>
      _VerificationEmailScreenState();
}

class _VerificationEmailScreenState extends State<VerificationEmailScreen> {
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  // TODO: Tambahkan logika untuk verifikasi kode OTP
  void _verifyOtp() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      // Kode OTP yang dimasukkan
      final otp = _pinController.text;
      print('OTP yang dimasukkan: $otp');

      // Navigasi ke halaman selanjutnya jika verifikasi berhasil
      // Navigator.pushReplacementNamed(context, '/create-new-password');
    }
  }

  // TODO: Tambahkan logika untuk kirim ulang kode
  void _resendOtp() {
    print('Mengirim ulang kode OTP...');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kode verifikasi baru telah dikirim.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tema default untuk Pinput
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Verifikasi Email',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Judul utama
                        const Text(
                          'Cek Email Kamu untuk Kode Verifikasi!',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Sub-judul
                        Text(
                          'Masukkan 6 digit kode verifikasi',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Field input OTP menggunakan Pinput
                        // DIUBAH: Dibungkus dengan Center
                        Center(
                          child: Pinput(
                            controller: _pinController,
                            length: 6,
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: defaultPinTheme.copyWith(
                              decoration: defaultPinTheme.decoration!.copyWith(
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                            ),
                            submittedPinTheme: defaultPinTheme,
                            validator: (s) {
                              if (s == null || s.length < 6) {
                                return 'Kode verifikasi harus 6 digit';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Link untuk kirim ulang kode
                        Align(
                          alignment: Alignment.center,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Belum menerima kode verifikasi? ',
                                ),
                                TextSpan(
                                  text: 'Kirim ulang',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = _resendOtp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Tombol Selanjutnya
              ElevatedButton(
                onPressed: _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Selanjutnya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 16), // Padding bawah
            ],
          ),
        ),
      ),
    );
  }
}
