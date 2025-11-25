import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // generado por flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Firebase inicializado correctamente");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Director's Fav",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const RootScreen(),
    );
  }
}

/// RootScreen decide si mostrar Auth o la app (según sesión)
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const CatalogScreen();
        } else {
          return const WelcomeAuthScreen();
        }
      },
    );
  }
}

/// Pantalla de Bienvenida + Login/Registro
class WelcomeAuthScreen extends StatefulWidget {
  const WelcomeAuthScreen({super.key});

  @override
  State<WelcomeAuthScreen> createState() => _WelcomeAuthScreenState();
}

class _WelcomeAuthScreenState extends State<WelcomeAuthScreen> {
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.black),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.movie, size: 110, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    "¡Bienvenido a Director's Fav!",
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Accede a tu cuenta o regístrate para ver el catálogo.",
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: showLogin
                          ? LoginForm(onSwitch: () => setState(() => showLogin = false))
                          : RegisterForm(onSwitch: () => setState(() => showLogin = true)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Login
class LoginForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const LoginForm({required this.onSwitch, super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool loading = false;
  String? error;

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    } catch (_) {
      setState(() => error = 'Error desconocido');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Iniciar sesión',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (error != null)
          Text(error!, style: const TextStyle(color: Colors.red)),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                key: const Key('login_email'),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresa correo' : null,
                onChanged: (v) => email = v,
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('login_password'),
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Min 6 caracteres' : null,
                onChanged: (v) => password = v,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Entrar'),
                ),
              ),
              TextButton(
                onPressed: widget.onSwitch,
                child: const Text("¿No tienes cuenta? Regístrate"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Registro
class RegisterForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const RegisterForm({required this.onSwitch, super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool loading = false;
  String? error;

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    } catch (_) {
      setState(() => error = 'Error desconocido');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Registro',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (error != null)
          Text(error!, style: const TextStyle(color: Colors.red)),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                key: const Key('reg_email'),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresa correo' : null,
                onChanged: (v) => email = v,
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('reg_password'),
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Min 6 caracteres' : null,
                onChanged: (v) => password = v,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Crear cuenta'),
                ),
              ),
              TextButton(
                onPressed: widget.onSwitch,
                child: const Text("¿Ya tienes cuenta? Inicia sesión"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Catálogo
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final CollectionReference moviesCol =
      FirebaseFirestore.instance.collection('movies');

  String search = '';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Catálogo de Películas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Admin',
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const AdminScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por título...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) => setState(() => search = v.trim().toLowerCase()),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: moviesCol.orderBy('title').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs.where((d) {
            if (search.isEmpty) return true;
            final title = (d['title'] ?? '').toString().toLowerCase();
            return title.contains(search);
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text('No hay películas.'));
          }

          return ListView.builder(
  itemCount: docs.length,
  itemBuilder: (context, i) {
    final doc = docs[i];
    final data = doc.data() as Map<String, dynamic>;
    final title = data['title'] ?? '';
    final imageUrl = data['imageUrl'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: ListTile(
        leading: imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image),
                ),
              )
            : Container(
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image),
              ),
        title: Text(title),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailsScreen(movieId: doc.id),
            ),
          );
        },
      ),
    );
  },
);

        },
      ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminScreen()));
              },
            ),
    );
  }
}

/// Detalles
class DetailsScreen extends StatelessWidget {
  final String movieId;
  const DetailsScreen({required this.movieId, super.key});

  @override
  Widget build(BuildContext context) {
    final docRef =
        FirebaseFirestore.instance.collection('movies').doc(movieId);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalles')),
      body: FutureBuilder<DocumentSnapshot>(
        future: docRef.get(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.data!.exists) {
            return const Center(child: Text('Película no encontrada'));
          }

          final data = snap.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data['imageUrl'] != null && data['imageUrl'] != "")
                  Center(
                    child: Image.network(
                      data['imageUrl'],
                      height: 240,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 120),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(data['title'],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  '${data['year']} • ${data['genre']} • Director: ${data['director']}',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                const Text('Sinopsis',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(data['synopsis'] ?? ''),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Admin CRUD
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final CollectionReference moviesCol =
      FirebaseFirestore.instance.collection('movies');

  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController yearCtrl = TextEditingController();
  final TextEditingController directorCtrl = TextEditingController();
  final TextEditingController genreCtrl = TextEditingController();
  final TextEditingController synopsisCtrl = TextEditingController();
  final TextEditingController imageUrlCtrl = TextEditingController();

  String? editingId;
  bool saving = false;

  Future<void> saveMovie() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => saving = true);

    final data = {
      'title': titleCtrl.text.trim(),
      'year': int.tryParse(yearCtrl.text.trim()) ?? 0,
      'director': directorCtrl.text.trim(),
      'genre': genreCtrl.text.trim(),
      'synopsis': synopsisCtrl.text.trim(),
      'imageUrl': imageUrlCtrl.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (editingId == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
        await moviesCol.add(data);
      } else {
        await moviesCol.doc(editingId).update(data);
      }
      _clearForm();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Película guardada')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => saving = false);
    }
  }

  void _clearForm() {
    editingId = null;
    titleCtrl.clear();
    yearCtrl.clear();
    directorCtrl.clear();
    genreCtrl.clear();
    synopsisCtrl.clear();
    imageUrlCtrl.clear();
  }

  Future<void> _editMovie(String id) async {
    final doc = await moviesCol.doc(id).get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    setState(() {
      editingId = id;
      titleCtrl.text = data['title'] ?? '';
      yearCtrl.text = (data['year'] ?? '').toString();
      directorCtrl.text = data['director'] ?? '';
      genreCtrl.text = data['genre'] ?? '';
      synopsisCtrl.text = data['synopsis'] ?? '';
      imageUrlCtrl.text = data['imageUrl'] ?? '';
    });
  }

  Future<void> _deleteMovie(String id) async {
    try {
      await moviesCol.doc(id).delete();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Película eliminada')));

      if (editingId == id) _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')));
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    yearCtrl.dispose();
    directorCtrl.dispose();
    genreCtrl.dispose();
    synopsisCtrl.dispose();
    imageUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración de Películas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: 'Título'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Obligatorio' : null,
                      ),
                      TextFormField(
                        controller: yearCtrl,
                        decoration: const InputDecoration(labelText: 'Año'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Obligatorio' : null,
                      ),
                      TextFormField(
                        controller: directorCtrl,
                        decoration: const InputDecoration(labelText: 'Director'),
                      ),
                      TextFormField(
                        controller: genreCtrl,
                        decoration: const InputDecoration(labelText: 'Género'),
                      ),
                      TextFormField(
                        controller: synopsisCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Sinopsis'),
                      ),
                      TextFormField(
                        controller: imageUrlCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Imagen (URL)'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: saving ? null : saveMovie,
                              child: saving
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(editingId == null
                                      ? 'Agregar'
                                      : 'Actualizar'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _clearForm,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey),
                            child: const Text('Limpiar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            const Text('Películas existentes',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: moviesCol.orderBy('title').snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snap.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text('No hay películas agregadas.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text(data['title'] ?? ''),
                        subtitle: Text(data['year']?.toString() ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editMovie(doc.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMovie(doc.id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
