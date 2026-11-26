import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:proyecto_donaciones/data/app_data.dart';

const _green = Color(0xFF177B5B);
const _ink = Color(0xFF1E3029);
const _muted = Color(0xFF75827C);
const _canvas = Color(0xFFF6F8F5);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manos Unidas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _green,
          primary: _green,
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: _canvas,
          foregroundColor: _ink,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F7F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
      ),
      home: const AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;
  bool _isLoading = false;
  bool _hidePassword = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = _isRegistering
          ? await AppData.instance.register(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
            )
          : await AppData.instance.login(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => MainPage(user: user)),
      );
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (error) {
      if (mounted) setState(() => _error = 'No pudimos completar el acceso: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(26, 28, 26, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 74,
                      width: 74,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2F2E9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.volunteer_activism,
                        size: 38,
                        color: _green,
                      ),
                    ),
                    const SizedBox(height: 27),
                    Text(
                      _isRegistering
                          ? 'Únete a la comunidad'
                          : 'Un gesto cambia todo',
                      style: const TextStyle(
                        fontSize: 30,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isRegistering
                          ? 'Crea tu cuenta y ayuda a llegar más lejos.'
                          : 'Conecta con causas locales y transforma vidas.',
                      style: const TextStyle(color: _muted, fontSize: 15),
                    ),
                    const SizedBox(height: 30),
                    if (_isRegistering) ...[
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) =>
                            (value == null || value.trim().length < 2)
                            ? 'Escribe tu nombre'
                            : null,
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null ||
                            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(value.trim())) {
                          return 'Escribe un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Usa al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        style: const TextStyle(color: Color(0xFFB3261E)),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _isRegistering
                                  ? 'Crear cuenta'
                                  : 'Iniciar sesión',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () => setState(() {
                        _isRegistering = !_isRegistering;
                        _error = null;
                      }),
                      child: Text(
                        _isRegistering
                            ? '¿Ya tienes una cuenta? Inicia sesión'
                            : '¿Eres nuevo? Crea tu cuenta',
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 16,
                          color: _muted,
                        ),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Datos de demostración: no se guardan al cerrar la app',
                            style: TextStyle(color: _muted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.user});
  final AppUser user;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late Future<List<Campaign>> _campaigns;

  @override
  void initState() {
    super.initState();
    _campaigns = AppData.instance.getCampaigns();
  }

  Future<void> _refresh() async {
    setState(() => _campaigns = AppData.instance.getCampaigns());
    await _campaigns;
  }

  void _donate(Campaign campaign) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DonationSheet(
        campaign: campaign,
        onDonate: (amount) async {
          await AppData.instance.makeDonation(
            userId: widget.user.id,
            campaignId: campaign.id,
            amount: amount,
          );
          await _refresh();
          if (mounted) {
            ScaffoldMessenger.of(this.context).showSnackBar(
              const SnackBar(
                content: Text('¡Gracias! Tu aporte ya fue registrado.'),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(
        user: widget.user,
        campaigns: _campaigns,
        onRefresh: _refresh,
        onDonate: _donate,
        onCategories: () => setState(() => _selectedIndex = 1),
      ),
      CategoriesTab(campaigns: _campaigns, onDonate: _donate),
      const MapTab(),
      ProfileTab(
        user: widget.user,
        onLogout: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const AuthPage()),
          (_) => false,
        ),
      ),
    ];
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Categorías',
          ),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.user,
    required this.campaigns,
    required this.onRefresh,
    required this.onDonate,
    required this.onCategories,
  });
  final AppUser user;
  final Future<List<Campaign>> campaigns;
  final Future<void> Function() onRefresh;
  final void Function(Campaign) onDonate;
  final VoidCallback onCategories;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Campaign>>(
        future: campaigns,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorState(
              message: 'No se pudieron cargar las campañas: ${snapshot.error}',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snapshot.data!;
          final urgent = all.where((campaign) => campaign.urgent).toList();
          final frequent = all.where((campaign) => campaign.frequency).toList();
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MANOS UNIDAS',
                            style: TextStyle(
                              color: _green,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.6,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Hola, ${user.name.split(' ').first} 👋',
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: const Color(0xFFE2F2E9),
                      foregroundColor: _green,
                      child: Text(
                        user.name.isEmpty
                            ? '?'
                            : user.name.isEmpty ? '?' : user.name.substring(0, 1).toUpperCase(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF177B5B), Color(0xFF105C45)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'PEQUEÑOS ACTOS, GRAN IMPACTO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Tu ayuda llega\na quien más la necesita.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          height: 1.18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Encuentra una causa y sé parte del cambio.',
                        style: TextStyle(color: Color(0xFFD8EEE4)),
                      ),
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        onPressed: onCategories,
                        icon: const Icon(Icons.favorite_border, size: 18),
                        label: const Text('Explorar causas'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: .6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _SectionHeading(
                  title: 'Necesitan ayuda urgente',
                  trailing: 'Ver todas',
                ),
                const SizedBox(height: 13),
                if (urgent.isEmpty)
                  const _EmptyInline(
                    text: 'No hay campañas urgentes por ahora.',
                  )
                else
                  SizedBox(
                    height: 290,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: urgent.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, index) => _CampaignCard(
                        campaign: urgent[index],
                        onDonate: () => onDonate(urgent[index]),
                      ),
                    ),
                  ),
                const SizedBox(height: 27),
                _SectionHeading(
                  title: 'Donaciones frecuentes',
                  trailing: 'Ver todas',
                ),
                const SizedBox(height: 13),
                ...frequent.map(
                  (campaign) => _FrequentCard(
                    campaign: campaign,
                    onDonate: () => onDonate(campaign),
                  ),
                ),
                const SizedBox(height: 14),
                _SectionHeading(
                  title: 'Dona por categoría',
                  trailing: 'Explorar',
                  onTap: onCategories,
                ),
                const SizedBox(height: 13),
                const _CategoryRow(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CategoriesTab extends StatefulWidget {
  const CategoriesTab({
    super.key,
    required this.campaigns,
    required this.onDonate,
  });
  final Future<List<Campaign>> campaigns;
  final void Function(Campaign) onDonate;

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  String _selected = 'Todas';
  static const _categories = [
    'Todas',
    'Alimentación',
    'Salud',
    'Educación',
    'Animales',
    'Vivienda',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Campaign>>(
        future: widget.campaigns,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorState(
              message:
                  'No se pudieron cargar las categorías: ${snapshot.error}',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final visible = snapshot.data!
              .where(
                (campaign) =>
                    _selected == 'Todas' || campaign.category == _selected,
              )
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 6),
                child: Text(
                  'Encuentra tu causa',
                  style: TextStyle(
                    fontSize: 26,
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Cada aporte, sin importar su tamaño, cuenta.',
                  style: TextStyle(color: _muted),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 46,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return ChoiceChip(
                      label: Text(category),
                      selected: _selected == category,
                      onSelected: (_) => setState(() => _selected = category),
                      selectedColor: const Color(0xFFDCEFE4),
                      side: BorderSide.none,
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: visible.isEmpty
                    ? const _EmptyInline(
                        text: 'No hay campañas en esta categoría.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 13),
                        itemBuilder: (context, index) => _FrequentCard(
                          campaign: visible[index],
                          onDonate: () => widget.onDonate(visible[index]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  late final Future<List<Shelter>> _sheltersFuture;
  Shelter? _selected;

  @override
  void initState() {
    super.initState();
    // Se crea una sola vez: reconstruir el mapa no vuelve a solicitar los datos.
    _sheltersFuture = AppData.instance.getShelters();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Shelter>>(
        future: _sheltersFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorState(
              message: 'No se pudieron cargar los puntos de ayuda. Intenta nuevamente.',
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final shelters = snapshot.data ?? const <Shelter>[];
          final center = shelters.isEmpty
              ? const LatLng(7.1193, -73.1227) // Bucaramanga, Santander.
              : LatLng(shelters.first.latitude, shelters.first.longitude);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 5),
                child: Text(
                  'Puntos de ayuda',
                  style: TextStyle(
                    fontSize: 26,
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Fundaciones y centros de apoyo en Bucaramanga y Santander.',
                  style: TextStyle(color: _muted),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: RepaintBoundary(
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: center,
                          initialZoom: 12.5,
                          minZoom: 10,
                          maxZoom: 18,
                          onTap: (_, __) {
                            if (_selected != null) {
                              setState(() => _selected = null);
                            }
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.proyecto_donaciones',
                            maxNativeZoom: 19,
                          ),
                          RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution('© OpenStreetMap contributors'),
                            ],
                          ),
                          MarkerLayer(
                            markers: shelters.map((shelter) {
                              return Marker(
                                point: LatLng(
                                  shelter.latitude,
                                  shelter.longitude,
                                ),
                                width: 48,
                                height: 54,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      setState(() => _selected = shelter),
                                  child: const Icon(
                                    Icons.location_on,
                                    size: 44,
                                    color: _green,
                                  ),
                                ),
                              );
                            }).toList(growable: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_selected != null)
                _ShelterTile(
                  shelter: _selected!,
                  onClose: () => setState(() => _selected = null),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    const Icon(Icons.map_outlined, size: 17, color: _muted),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '${shelters.length} puntos registrados · Santander',
                        style: const TextStyle(
                          color: _muted,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.user, required this.onLogout});
  final AppUser user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<DonationEntry>>(
        future: AppData.instance.getDonationsForUser(user.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorState(
              message: 'No se pudo cargar tu perfil: ${snapshot.error}',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final donations = snapshot.data!;
          final total = donations.fold<double>(
            0,
            (sum, donation) => sum + donation.amount,
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              const Text(
                'Mi perfil',
                style: TextStyle(
                  fontSize: 26,
                  color: _ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFFE2F2E9),
                      foregroundColor: _green,
                      child: Text(
                        user.name.isEmpty ? '?' : user.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: const TextStyle(color: _muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Aportes realizados',
                      value: '${donations.length}',
                      icon: Icons.volunteer_activism_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Total donado',
                      value: _money(total),
                      icon: Icons.favorite_border,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const Text(
                'Mis donaciones',
                style: TextStyle(
                  color: _ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (donations.isEmpty)
                const _EmptyInline(
                  text:
                      'Tus donaciones aparecerán aquí cuando apoyes una causa.',
                )
              else
                ...donations.map(
                  (donation) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE2F2E9),
                      child: Icon(Icons.favorite, color: _green, size: 19),
                    ),
                    title: Text(
                      donation.campaignTitle,
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _date(donation.createdAt),
                      style: const TextStyle(color: _muted),
                    ),
                    trailing: Text(
                      _money(donation.amount),
                      style: const TextStyle(
                        color: _green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB3261E),
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DonationSheet extends StatefulWidget {
  const DonationSheet({
    super.key,
    required this.campaign,
    required this.onDonate,
  });
  final Campaign campaign;
  final Future<void> Function(double) onDonate;

  @override
  State<DonationSheet> createState() => _DonationSheetState();
}

class _DonationSheetState extends State<DonationSheet> {
  double _amount = 20000;
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        12,
        22,
        22 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9DFDA),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Haz tu aporte',
              style: TextStyle(
                color: _ink,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(widget.campaign.title, style: const TextStyle(color: _muted)),
            const SizedBox(height: 18),
            Wrap(
              spacing: 9,
              children: [10000, 20000, 50000, 100000].map((amount) {
                return ChoiceChip(
                  label: Text(_money(amount.toDouble())),
                  selected: _amount == amount,
                  onSelected: (_) =>
                      setState(() => _amount = amount.toDouble()),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Otro monto (COP)',
                prefixIcon: Icon(Icons.attach_money),
              ),
              onChanged: (value) {
                final amount = double.tryParse(value);
                if (amount != null && amount > 0) {
                  setState(() => _amount = amount);
                }
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Color(0xFFB3261E))),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _loading
                  ? null
                  : () async {
                      if (_amount <= 0) {
                        setState(
                          () => _error = 'Ingresa un monto mayor a cero.',
                        );
                        return;
                      }
                      setState(() {
                        _loading = true;
                        _error = null;
                      });
                      try {
                        await widget.onDonate(_amount);
                        if (context.mounted) Navigator.pop(context);
                      } catch (error) {
                        if (mounted) {
                          setState(
                            () => _error =
                                'No se pudo registrar el aporte: $error',
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Donar ${_money(_amount)}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({required this.campaign, required this.onDonate});
  final Campaign campaign;
  final VoidCallback onDonate;

  @override
  Widget build(BuildContext context) {
    final progress = (campaign.raised / campaign.goal).clamp(0.0, 1.0);
    return Container(
      width: 270,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CategoryIcon(category: campaign.category),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEFE3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'URGENTE',
                  style: TextStyle(
                    color: Color(0xFFBA5A24),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            campaign.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Text(
              campaign.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _muted, height: 1.35),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFFE9EEE9),
              color: _green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_money(campaign.raised)} de ${_money(campaign.goal)}',
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onDonate,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Donar ahora'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FrequentCard extends StatelessWidget {
  const _FrequentCard({required this.campaign, required this.onDonate});
  final Campaign campaign;
  final VoidCallback onDonate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          _CategoryIcon(category: campaign.category),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  campaign.frequency
                      ? 'Aporte recurrente · ${campaign.category}'
                      : campaign.category,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
                const SizedBox(height: 7),
                Text(
                  '${_money(campaign.raised)} reunidos',
                  style: const TextStyle(
                    color: _green,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: onDonate,
            tooltip: 'Donar',
            icon: const Icon(Icons.favorite_border),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  static const _items = [
    ('Alimentación', Icons.restaurant_outlined),
    ('Salud', Icons.health_and_safety_outlined),
    ('Educación', Icons.menu_book_outlined),
    ('Animales', Icons.pets_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 102,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Container(
            width: 90,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.$2, color: _green),
                const SizedBox(height: 7),
                Text(
                  item.$1,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (category) {
      'Alimentación' => (Icons.restaurant, const Color(0xFFEF9E40)),
      'Salud' => (Icons.health_and_safety, const Color(0xFFDD6972)),
      'Educación' => (Icons.menu_book, const Color(0xFF697EC7)),
      'Animales' => (Icons.pets, const Color(0xFFAF7BC5)),
      'Vivienda' => (Icons.home_work, const Color(0xFF5C9CB0)),
      _ => (Icons.favorite, _green),
    };
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.trailing,
    this.onTap,
  });
  final String title;
  final String trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            trailing,
            style: const TextStyle(
              color: _green,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _green, size: 21),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: _ink,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ShelterTile extends StatelessWidget {
  const _ShelterTile({required this.shelter, required this.onClose});
  final Shelter shelter;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: _green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shelter.name,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  shelter.address,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }
}

class _EmptyInline extends StatelessWidget {
  const _EmptyInline({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 25),
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: _muted),
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFB3261E), size: 36),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

String _money(double amount) {
  final value = amount.round().toString();
  final grouped = value.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
  return '\$$grouped';
}

String _date(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
