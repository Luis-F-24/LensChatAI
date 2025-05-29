import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lenschatai/Widgets/history_entry.dart';
import 'package:lenschatai/Widgets/tts_helper.dart';

class HistoryWidget extends StatelessWidget {
  final TtsHelper ttsHelper = TtsHelper();

  HistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<HistoryEntry>('history').listenable(),
      builder: (context, Box<HistoryEntry> box, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: box.isEmpty
              ? const Center(
                  key: ValueKey('empty'),
                  child: Text(
                    'Nenhuma análise registrada.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  key: const ValueKey('list'),
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final entry = box.getAt(index);
                    if (entry == null) return const SizedBox.shrink();

                    final imageFile = File(entry.imagePath);
                    final hasImage = imageFile.existsSync();

                    return Card(
                      color: const Color(0xFFD1C7B8),
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: hasImage
                            ? Image.file(
                                imageFile,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.black54,
                              ),
                        title: Text(
                          entry.description,
                          style: const TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          entry.date.toLocal().toString(),
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.volume_up,
                                  color: Colors.black),
                              tooltip: 'Ouvir descrição',
                              onPressed: () =>
                                  ttsHelper.speak(entry.description),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Excluir item',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar exclusão'),
                                    content: const Text(
                                        'Deseja excluir esta análise do histórico?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Excluir'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm ?? false) {
                                  if (await imageFile.exists()) {
                                    await imageFile.delete();
                                  }
                                  await box.deleteAt(index);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Análise excluída com sucesso!')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}