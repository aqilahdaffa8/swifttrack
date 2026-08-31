import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cek_resi_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/tracking_model.dart';

class CekResiScreen extends StatelessWidget {
  const CekResiScreen({super.key});

  void _showCourierSelector(BuildContext context, CekResiProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pilih Ekspedisi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...provider.availableCouriers.map((courier) {
                final isSelected = provider.selectedCourier.code == courier.code;
                return ListTile(
                  title: Text(courier.name),
                  trailing: isSelected 
                      ? const Icon(Icons.check_circle, color: AppTheme.primaryColor) 
                      : null,
                  onTap: () {
                    provider.setCourier(courier);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CekResiProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lacak Paket', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Consumer<CekResiProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                // Bagian Header Input
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // Pilih Kurir
                      InkWell(
                        onTap: () => _showCourierSelector(context, provider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                provider.selectedCourier.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Input Resi & Tombol Lacak
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: provider.setAwb,
                              decoration: InputDecoration(
                                hintText: 'Masukkan Nomor Resi...',
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: provider.isLoading ? null : provider.trackReceipt,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: provider.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.search),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Area Hasil / Timeline
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _buildResultArea(provider),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultArea(CekResiProvider provider) {
    if (provider.isLoading) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        key: const ValueKey('error'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            provider.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (provider.trackingResult != null) {
      return _TrackingTimeline(
        key: const ValueKey('result'),
        result: provider.trackingResult!,
      );
    }

    return const Center(
      key: ValueKey('empty'),
      child: Text(
        'Masukkan nomor resi untuk melihat status pengiriman',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}

// Widget Khusus untuk Timeline Vertikal
class _TrackingTimeline extends StatelessWidget {
  final TrackingModel result;

  const _TrackingTimeline({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: result.history.length + 1, // +1 untuk Header Card
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${result.status}',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Penerima: ${result.receiver}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          );
        }

        final historyIndex = index - 1;
        final history = result.history[historyIndex];
        final isFirst = historyIndex == 0; // Item paling atas (Terbaru)

        // TweenAnimationBuilder untuk efek berjenjang (staggered fade-in)
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (historyIndex * 100)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Garis & Titik Stepper
                    Column(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: isFirst ? AppTheme.accentOrange : Colors.grey.shade400,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              if (isFirst)
                                BoxShadow(
                                  color: AppTheme.accentOrange.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                )
                            ],
                          ),
                        ),
                        if (historyIndex != result.history.length - 1)
                          Container(
                            width: 2,
                            height: 60,
                            color: Colors.grey.shade300,
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Konten Histori
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              history.date,
                              style: TextStyle(
                                fontSize: 12,
                                color: isFirst ? AppTheme.accentOrange : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              history.desc,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.pureBlack,
                                fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (history.location.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                history.location,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}