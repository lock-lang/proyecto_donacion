import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AppUser {
  const AppUser({required this.id, required this.name, required this.email});

  final int id;
  final String name;
  final String email;
}

class Campaign {
  const Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.goal,
    required this.raised,
    required this.urgent,
    required this.frequency,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final double goal;
  final double raised;
  final bool urgent;
  final bool frequency;

  Campaign copyWith({double? raised}) => Campaign(
        id: id,
        title: title,
        description: description,
        category: category,
        goal: goal,
        raised: raised ?? this.raised,
        urgent: urgent,
        frequency: frequency,
      );
}

class Shelter {
  const Shelter({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
}

class DonationEntry {
  const DonationEntry({
    required this.amount,
    required this.campaignTitle,
    required this.createdAt,
  });

  final double amount;
  final String campaignTitle;
  final DateTime createdAt;
}

class _Account {
  const _Account({
    required this.user,
    required this.passwordSalt,
    required this.passwordHash,
  });

  final AppUser user;
  final String passwordSalt;
  final String passwordHash;
}

class _UserDonation {
  const _UserDonation({required this.userId, required this.entry});

  final int userId;
  final DonationEntry entry;
}

class AppData {
  AppData._();
  static final AppData instance = AppData._();

  final List<_Account> _accounts = [];
  final List<_UserDonation> _donations = [];
  int _nextUserId = 1;

  final List<Campaign> _campaigns = [
    const Campaign(
      id: 1,
      title: 'Alimentos para familias de Bucaramanga',
      description:
          'Canastas básicas para familias de sectores vulnerables de Santander.',
      category: 'Alimentación',
      goal: 5000000,
      raised: 2840000,
      urgent: true,
      frequency: true,
    ),
    const Campaign(
      id: 2,
      title: 'Medicamentos para animales rescatados',
      description:
          'Ayuda veterinaria y tratamientos para perros y gatos rescatados.',
      category: 'Animales',
      goal: 3200000,
      raised: 1760000,
      urgent: true,
      frequency: false,
    ),
    const Campaign(
      id: 3,
      title: 'Útiles escolares para volver a clases',
      description:
          'Morrales, cuadernos y materiales para niñas y niños de Santander.',
      category: 'Educación',
      goal: 4500000,
      raised: 1980000,
      urgent: false,
      frequency: true,
    ),
    const Campaign(
      id: 4,
      title: 'Acompañamiento para adultos mayores',
      description:
          'Alimentos, cuidado y compañía para personas mayores de nuestra región.',
      category: 'Salud',
      goal: 6000000,
      raised: 3150000,
      urgent: false,
      frequency: true,
    ),
    const Campaign(
      id: 5,
      title: 'Un techo seguro para todos',
      description:
          'Reparación de cubiertas y espacios comunitarios para familias.',
      category: 'Vivienda',
      goal: 8000000,
      raised: 2420000,
      urgent: true,
      frequency: false,
    ),
  ];

  // Puntos de referencia de Santander. Las coordenadas de los centros
  // corresponden a ubicaciones aproximadas para visualización del prototipo;
  // confirma con cada entidad antes de desplazarte o entregar donaciones.
  final List<Shelter> _shelters = const [
    Shelter(
      id: 1,
      name: 'Unidad de Bienestar Animal de Bucaramanga',
      address: 'Calle 45 # 00-51, Campo Hermoso, Bucaramanga',
      latitude: 7.1232,
      longitude: -73.1354,
    ),
    Shelter(
      id: 2,
      name: 'Fundación Refugio PerroCalle',
      address: 'Bucaramanga y área metropolitana, Santander',
      latitude: 7.1055,
      longitude: -73.1290,
    ),
    Shelter(
      id: 3,
      name: 'Banco de Alimentos de Bucaramanga',
      address: 'Carrera 20 # 11-46, Bucaramanga',
      latitude: 7.1250,
      longitude: -73.1195,
    ),
    Shelter(
      id: 4,
      name: 'Fundación Corpoanidescol',
      address: 'Sector El Rincón, Girón, Santander',
      latitude: 7.0482425,
      longitude: -73.1413826,
    ),
  ];

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();

    if (cleanName.length < 2) {
      throw const AuthException('Escribe un nombre válido.');
    }
    if (normalizedEmail.isEmpty) {
      throw const AuthException('Escribe un correo electrónico.');
    }
    if (password.length < 6) {
      throw const AuthException('La contraseña debe tener al menos 6 caracteres.');
    }
    if (_accounts.any((account) => account.user.email == normalizedEmail)) {
      throw const AuthException('Ya existe una cuenta con ese correo.');
    }

    final user = AppUser(
      id: _nextUserId++,
      name: cleanName,
      email: normalizedEmail,
    );
    final salt = _newSalt();
    _accounts.add(
      _Account(
        user: user,
        passwordSalt: salt,
        passwordHash: _passwordHash(password, salt),
      ),
    );
    return user;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    for (final account in _accounts) {
      if (account.user.email == normalizedEmail) {
        if (_passwordHash(password, account.passwordSalt) !=
            account.passwordHash) {
          throw const AuthException('La contraseña no es correcta.');
        }
        return account.user;
      }
    }
    throw const AuthException(
      'No encontramos esa cuenta en esta sesión. Regístrate para continuar.',
    );
  }

  Future<List<Campaign>> getCampaigns() async =>
      List<Campaign>.unmodifiable(_campaigns);

  Future<List<Shelter>> getShelters() async =>
      List<Shelter>.unmodifiable(_shelters);

  Future<List<DonationEntry>> getDonationsForUser(int userId) async =>
      _donations
          .where((donation) => donation.userId == userId)
          .map((donation) => donation.entry)
          .toList(growable: false);

  Future<void> makeDonation({
    required int userId,
    required int campaignId,
    required double amount,
  }) async {
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'Debe ser mayor a cero.');
    }
    if (!_accounts.any((account) => account.user.id == userId)) {
      throw StateError(
        'La sesión ya no está disponible. Inicia sesión de nuevo.',
      );
    }

    final campaignIndex = _campaigns.indexWhere(
      (campaign) => campaign.id == campaignId,
    );
    if (campaignIndex == -1) {
      throw StateError('La campaña seleccionada ya no está disponible.');
    }

    final campaign = _campaigns[campaignIndex];
    _campaigns[campaignIndex] = campaign.copyWith(
      raised: campaign.raised + amount,
    );
    _donations.add(
      _UserDonation(
        userId: userId,
        entry: DonationEntry(
          amount: amount,
          campaignTitle: campaign.title,
          createdAt: DateTime.now(),
        ),
      ),
    );
  }

  String _newSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _passwordHash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();
}
