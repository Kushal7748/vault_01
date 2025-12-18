import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/vault_service.dart';
import '../../data/secret_model.dart';
import '../widgets/add_secret_dialog.dart';

// CHANGED: Converted to ConsumerStatefulWidget to manage Search State
class VaultHomeScreen extends ConsumerStatefulWidget {
  const VaultHomeScreen({super.key});

  @override
  ConsumerState<VaultHomeScreen> createState() => _VaultHomeScreenState();
}

class _VaultHomeScreenState extends ConsumerState<VaultHomeScreen> {
  // State for Search
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Listen to text changes to update the UI
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGOUT LOGIC ---
  void handleLogout() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // --- MENU ACTION HANDLER ---
  void handleMenuSelection(String value) {
    switch (value) {
      case 'profile':
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile clicked')));
        break;
      case 'settings':
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Settings clicked')));
        break;
      case 'about':
        showDialog(
          context: context,
          builder: (ctx) => const AlertDialog(
              title: Text('About'), content: Text('Vault_01 v1.0')),
        );
        break;
      case 'logout':
        handleLogout();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get Full List
    final allSecrets = ref.watch(vaultProvider);

    // 2. Filter List based on Search Query
    final filteredSecrets = allSecrets.where((secret) {
      final title = secret.title.toLowerCase();
      final username = secret.username.toLowerCase();
      return title.contains(_searchQuery) || username.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey[900],
        elevation: 0,

        // --- SEARCH BAR LOGIC ---
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Search secrets...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              )
            : const Text('My Vault',
                style: TextStyle(fontWeight: FontWeight.bold)),

        centerTitle: false,

        actions: [
          // 1. SEARCH ICON BUTTON
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  // If closing search, clear query
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = "";
                } else {
                  // If opening search
                  _isSearching = true;
                }
              });
            },
          ),

          // 2. PROFILE MENU (Only show if not searching to save space, optional)
          if (!_isSearching)
            PopupMenuButton<String>(
              onSelected: handleMenuSelection,
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blueGrey[100],
                  child: const Icon(Icons.person,
                      color: Colors.blueGrey, size: 20),
                ),
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                    value: 'profile', child: Text('Profile')),
                const PopupMenuItem<String>(
                    value: 'settings', child: Text('Settings')),
                const PopupMenuItem<String>(
                    value: 'about', child: Text('About')),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Log Out',
                      style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
        ],
      ),

      // --- BODY (Uses filteredSecrets) ---
      body: filteredSecrets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      _searchQuery.isEmpty
                          ? Icons.lock_outline
                          : Icons.search_off,
                      size: 80,
                      color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                      _searchQuery.isEmpty
                          ? 'Vault is empty'
                          : 'No matches found',
                      style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredSecrets.length,
              itemBuilder: (context, index) {
                return _SecretTile(secret: filteredSecrets[index]);
              },
            ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        onPressed: () {
          showDialog(context: context, builder: (_) => const AddSecretDialog());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- TILE WIDGET (Unchanged from previous version) ---
class _SecretTile extends ConsumerStatefulWidget {
  final SecretModel secret;
  const _SecretTile({required this.secret});

  @override
  ConsumerState<_SecretTile> createState() => _SecretTileState();
}

class _SecretTileState extends ConsumerState<_SecretTile> {
  void _copyToClipboard(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Secret?'),
        content: Text('Delete "${widget.secret.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(vaultProvider.notifier).deleteSecret(widget.secret.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[50],
          child: Icon(Icons.lock, color: Colors.blue[800]),
        ),
        title: Text(widget.secret.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(widget.secret.username,
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 4),
            // Masked Password
            Text(
              '••••••••••••',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                color: Colors.grey[400],
                letterSpacing: 2.0,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (value) {
            if (value == 'copy') _copyToClipboard(widget.secret.value);
            if (value == 'edit') {
              showDialog(
                context: context,
                builder: (_) => AddSecretDialog(secretToEdit: widget.secret),
              );
            }
            if (value == 'delete') _confirmDelete();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
                value: 'copy',
                child: Row(children: [
                  Icon(Icons.copy, size: 20),
                  SizedBox(width: 8),
                  Text('Copy')
                ])),
            const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit')
                ])),
            const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red))
                ])),
          ],
        ),
      ),
    );
  }
}
