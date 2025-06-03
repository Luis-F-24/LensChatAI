import 'package:flutter/material.dart';
import 'dart:io';
import '../models/history_item.dart';
import '../services/history_service.dart';
import '../services/tts_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryService _historyService = HistoryService();
  final TtsHelper _ttsHelper = TtsHelper();

  @override
  void dispose() {
    _ttsHelper.stop(); // ✅ Garante que o TTS pare ao sair
    super.dispose();
  }

  Future<void> _refreshHistory() async {
    setState(() {});
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF4A3A58),
            title: Text(title, style: const TextStyle(color: Colors.white)),
            content: Text(content, style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD1C7B8),
                ),
                child: const Text('Confirmar', style: TextStyle(color: Colors.black)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF372440),
      appBar: AppBar(
        backgroundColor: const Color(0xFF372440),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'LensChatAI - Histórico',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            tooltip: 'Limpar tudo',
            onPressed: () async {
              final confirmed = await _showConfirmationDialog(
                'Confirmar limpeza',
                'Você tem certeza que deseja apagar todo o histórico?',
              );
              if (confirmed) {
                await _historyService.clearHistory();
                await _ttsHelper.stop();
                _refreshHistory();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<HistoryItem>>(
        future: _historyService.getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum histórico disponível.',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            final historyItems = snapshot.data!;
            return ListView.builder(
              itemCount: historyItems.length,
              itemBuilder: (context, index) {
                final item = historyItems[index];
                return Card(
                  color: const Color(0xFF4A3A58),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Image.file(
                      File(item.imagePath),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      item.description,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Data: ${item.timestamp.toLocal()}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.volume_up, color: Colors.white),
                          onPressed: () async {
                            await _ttsHelper.stop();
                            await _ttsHelper.speak(item.description);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () async {
                            final confirmed = await _showConfirmationDialog(
                              'Confirmar exclusão',
                              'Deseja realmente excluir este item do histórico?',
                            );
                            if (confirmed) {
                              await _ttsHelper.stop();
                              await _historyService.deleteHistoryItem(item);
                              _refreshHistory();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}