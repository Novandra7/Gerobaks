import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiAIService {
  static final GeminiAIService _instance = GeminiAIService._internal();
  factory GeminiAIService() => _instance;
  GeminiAIService._internal();

  late GenerativeModel _model;
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY not found in .env file');
      }

      _model = GenerativeModel(
        model: 'gemini-2.0-flash-exp',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
        systemInstruction: Content.system(
          'Anda adalah customer service Gerobaks, aplikasi pengelolaan sampah yang ramah lingkungan. '
          'Anda membantu pengguna dengan informasi tentang layanan pengangkutan sampah, jadwal, '
          'recycling, tips eco-friendly, dan berlangganan. Jawab dengan ramah, informatif, dan dalam bahasa Indonesia. '
          'Fokus pada solusi praktis untuk pengelolaan sampah dan edukasi lingkungan.',
        ),
      );
      _isInitialized = true;
    } catch (e) {
      print('Error initializing Gemini AI: $e');
      _isInitialized = false;
    }
  }

  Future<String> generateResponse(String message, {List<String>? conversationHistory}) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      return _getFallbackResponse(message);
    }

    try {
      // Build conversation context
      String contextMessage = message;
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        final recentHistory = conversationHistory.take(6).join('\n');
        contextMessage = 'Riwayat percakapan:\n$recentHistory\n\nPesan terbaru: $message';
      }

      final content = [Content.text(contextMessage)];
      final response = await _model.generateContent(content);
      
      String aiResponse = response.text ?? '';
      
      // Clean up response
      aiResponse = aiResponse.trim();
      if (aiResponse.isEmpty) {
        return _getFallbackResponse(message);
      }

      // Add context-aware responses
      aiResponse = _enhanceResponse(aiResponse, message);
      
      return aiResponse;
    } catch (e) {
      print('Error generating AI response: $e');
      return _getFallbackResponse(message);
    }
  }

  String _enhanceResponse(String response, String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    // Add specific context based on keywords
    if (lowerMessage.contains('jadwal') || lowerMessage.contains('pickup') || lowerMessage.contains('angkut')) {
      if (!response.contains('jadwal') && !response.contains('pickup')) {
        response += '\n\n💡 Tip: Anda dapat melihat jadwal pengangkutan real-time di menu "Lokasi" aplikasi kami.';
      }
    }
    
    if (lowerMessage.contains('langganan') || lowerMessage.contains('paket') || lowerMessage.contains('berlangganan')) {
      if (!response.contains('paket') && !response.contains('langganan')) {
        response += '\n\n⭐ Info: Kami memiliki 3 paket langganan mulai dari Rp 50.000/bulan. Lihat detail di menu Profile > Langganan Saya.';
      }
    }
    
    if (lowerMessage.contains('sampah') || lowerMessage.contains('waste') || lowerMessage.contains('recycle')) {
      if (!response.contains('recycle') && !response.contains('daur ulang')) {
        response += '\n\n♻️ Eco Tip: Pisahkan sampah organik dan anorganik untuk recycling yang lebih efektif!';
      }
    }

    return response;
  }

  String _getFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Keyword-based fallback responses
    if (lowerMessage.contains('halo') || lowerMessage.contains('hai') || lowerMessage.contains('hello')) {
      return 'Halo! Selamat datang di Gerobaks 👋\n\nSaya siap membantu Anda dengan layanan pengelolaan sampah. Ada yang bisa saya bantu hari ini?';
    }
    
    if (lowerMessage.contains('jadwal') || lowerMessage.contains('pickup') || lowerMessage.contains('angkut')) {
      return 'Untuk informasi jadwal pengangkutan sampah:\n\n📅 Cek menu "Lokasi" untuk melihat jadwal real-time\n🚛 Notifikasi otomatis 30 menit sebelum pickup\n⏰ Jadwal dapat berubah sesuai kondisi cuaca\n\nAda yang ingin ditanyakan tentang jadwal?';
    }
    
    if (lowerMessage.contains('langganan') || lowerMessage.contains('paket') || lowerMessage.contains('berlangganan')) {
      return 'Paket Langganan Gerobaks:\n\n🏠 Basic: Rp 50.000/bulan - Pickup 2x seminggu\n⭐ Premium: Rp 75.000/bulan - Pickup 3x seminggu + rewards\n🏢 Pro: Rp 120.000/bulan - Pickup harian + analytics\n\nMau berlangganan paket mana?';
    }
    
    if (lowerMessage.contains('recycling') || lowerMessage.contains('daur ulang') || lowerMessage.contains('recycle')) {
      return 'Tips Recycling Gerobaks:\n\n♻️ Pisahkan sampah organik & anorganik\n📦 Bersihkan kemasan sebelum dibuang\n🗞️ Kumpulkan kertas & kardus\n🍃 Sampah organik jadi kompos\n\nDengan premium/pro, dapatkan poin reward untuk setiap recycling!';
    }
    
    if (lowerMessage.contains('pembayaran') || lowerMessage.contains('bayar') || lowerMessage.contains('payment')) {
      return 'Metode Pembayaran Gerobaks:\n\n🏦 Transfer Bank: BCA, Mandiri, BNI\n💳 E-Wallet: GoPay, OVO\n📱 QRIS tersedia\n💰 Auto-debit untuk langganan\n\nSemuanya aman dan mudah!';
    }
    
    if (lowerMessage.contains('help') || lowerMessage.contains('bantuan') || lowerMessage.contains('masalah')) {
      return 'Saya di sini untuk membantu! 😊\n\nSaya bisa bantu dengan:\n📞 Informasi layanan\n📅 Jadwal pengangkutan\n💳 Paket langganan\n♻️ Tips recycling\n🔧 Troubleshooting\n\nSilakan tanyakan apa saja!';
    }
    
    // Default response
    return 'Terima kasih telah menghubungi Gerobaks! 🌱\n\nSaya customer service AI yang siap membantu Anda dengan:\n• Informasi layanan pengangkutan sampah\n• Jadwal pickup\n• Paket langganan\n• Tips eco-friendly\n\nAda yang bisa saya bantu?';
  }

  // Generate daily motivational messages about waste management
  Future<String> generateDailyPantun() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const prompt = '''
Buatkan 1 pantun motivasi tentang pengelolaan sampah dan lingkungan yang:
- Berkaitan dengan aplikasi Gerobaks
- Menggunakan bahasa Indonesia yang mudah dipahami
- Memotivasi untuk menjaga lingkungan
- Singkat dan berima
- Mengandung pesan positif tentang recycling atau waste management

Format: 2 baris pantun tradisional (A-B) & Langsung Pantun tanpa Kata Lain.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      String pantun = response.text ?? '';
      pantun = pantun.trim();
      
      if (pantun.isEmpty) {
        return _getFallbackPantun();
      }
      
      return pantun;
    } catch (e) {
      print('Error generating daily pantun: $e');
      return _getFallbackPantun();
    }
  }

  String _getFallbackPantun() {
    final pantuns = [
      'Bunga melati harum semerbak\nPagi hari burung berkicau\nSampah dipilah jangan sepak\nLingkungan bersih hati pun rau',
      'Jalan setapak menuju pasar\nPembeli datang membawa tas\nGerobaks hadir solusi besar\nSampah terkelola hidup makin pas',
      'Kupu-kupu hinggap di bunga\nTerbang melayang ke sana kemari\nDaur ulang sampah jadi guna\nBumi lestari untuk nanti',
      'Pohon rindang teduh di halaman\nDaun berguguran musim kemarau\nPilah sampah kebiasaan\nHidup sehat bahagia terus',
      'Awan putih mengapung tinggi\nAngin sepoi meniup pelan\nRecycling habit mulai hari ini\nMasa depan cerah dan terang',
    ];
    
    final randomIndex = DateTime.now().millisecond % pantuns.length;
    return pantuns[randomIndex];
  }

  bool get isInitialized => _isInitialized;
}
