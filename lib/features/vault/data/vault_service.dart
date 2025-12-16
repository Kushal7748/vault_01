import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'secret_model.dart';

class VaultService {
  static final VaultService _instance = VaultService._internal();
  factory VaultService() => _instance;
  VaultService._internal();

  final List<SecretModel> _mockDatabase = [
    const SecretModel(
        id: '1',
        title: 'Gmail',
        value: 'password123',
        username: 'user@gmail.com'),
    const SecretModel(
        id: '2', title: 'Netflix', value: 'myflixpass', username: 'chill_user'),
    const SecretModel(id: '3', title: 'GitHub', value: 'git_secure_99'),
  ];

  List<SecretModel> getSecrets() {
    return [..._mockDatabase];
  }

  void addSecret(SecretModel secret) {
    _mockDatabase.add(secret);
  }

  void deleteSecret(String id) {
    _mockDatabase.removeWhere((element) => element.id == id);
  }

  // NEW: Update Logic
  void updateSecret(SecretModel updatedSecret) {
    final index =
        _mockDatabase.indexWhere((element) => element.id == updatedSecret.id);
    if (index != -1) {
      _mockDatabase[index] = updatedSecret;
    }
  }
}

final vaultListProvider =
    NotifierProvider<VaultListNotifier, List<SecretModel>>(() {
  return VaultListNotifier();
});

class VaultListNotifier extends Notifier<List<SecretModel>> {
  final _service = VaultService();

  @override
  List<SecretModel> build() {
    return _service.getSecrets();
  }

  void addSecret(String title, String value, String? username) {
    final newSecret = SecretModel(
      id: DateTime.now().toString(),
      title: title,
      value: value,
      username: username,
    );
    _service.addSecret(newSecret);
    state = [...state, newSecret];
  }

  void removeSecret(String id) {
    _service.deleteSecret(id);
    state = [
      for (final secret in state)
        if (secret.id != id) secret,
    ];
  }

  // NEW: Edit Logic
  void editSecret(SecretModel updatedSecret) {
    _service.updateSecret(updatedSecret);
    // Update the specific item in the state list
    state = [
      for (final secret in state)
        if (secret.id == updatedSecret.id) updatedSecret else secret,
    ];
  }
}
