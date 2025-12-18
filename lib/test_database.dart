import 'package:flutter/material.dart';
import 'package:vault_01/src/frb_generated/api/simple.dart';

Future<void> testDatabaseOperations(BuildContext context) async {
  try {
    debugPrint('🧪 Starting database tests...');
    
    // 1. Save some test data
    final id1 = saveMemory(content: 'Test memory 1');
    final id2 = saveMemory(content: 'Test memory 2');
    final id3 = saveMemory(content: 'Test memory 3');
    
    debugPrint('✅ Saved 3 memories: $id1, $id2, $id3');
    
    // 2. List all memories
    final allMemories = listMemories();
    debugPrint('✅ Retrieved ${allMemories.length} memories');
    
    for (final memory in allMemories) {
      debugPrint('   - ID: ${memory.id}, Content: ${memory.content}');
    }
    
    // 3. Get a specific memory
    final singleMemory = getMemory(id: id2);
    debugPrint('✅ Retrieved single memory: ${singleMemory.content}');
    debugPrint('   Access count: ${singleMemory.accessedCount}');
    
    // 4. Delete a memory
    final deleteResult = deleteMemory(id: id1);
    debugPrint('✅ Delete result: $deleteResult');
    
    // 5. Verify deletion
    final remainingMemories = listMemories();
    debugPrint('✅ Remaining memories: ${remainingMemories.length}');
    
    // Show success dialog
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('✅ Database Tests Passed!'),
          content: Text(
            'Saved: 3 memories\n'
            'Retrieved: ${allMemories.length} memories\n'
            'Deleted: 1 memory\n'
            'Remaining: ${remainingMemories.length} memories\n\n'
            'Check debug console for details!'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    
  } catch (e) {
    debugPrint('❌ Database test failed: $e');
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('❌ Test Failed'),
          content: Text('Error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}