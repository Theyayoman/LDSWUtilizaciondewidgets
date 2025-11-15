import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Director's Fav",
      home: MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  Map<String, dynamic>? weatherData;
  bool loadingWeather = true;

  // --- Obtener clima desde OpenWeather ---
  Future<void> loadWeather() async {
    const String apiKey = "776760c6173cf6fe80ee8e77ac569015";
    const String city = "Guadalajara"; // puedes cambiarla

    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&lang=es&appid=$apiKey",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        weatherData = jsonDecode(response.body);
        loadingWeather = false;
      });
    } else {
      setState(() {
        loadingWeather = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadWeather(); // cargar clima al iniciar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Icon(Icons.movie, color: Colors.white, size: 32),
        backgroundColor: Colors.indigo,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 180,
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.indigo.shade400,
                  contentPadding: const EdgeInsets.all(0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),

      body: Column(
        children: [
          // ===================== SECCIÓN DEL CLIMA ======================
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.indigo.shade100,
            child: loadingWeather
                ? const Text("Cargando clima...")
                : weatherData == null
                    ? const Text("No se pudo cargar el clima")
                    : Row(
                        children: [
                          Image.network(
                            "https://openweathermap.org/img/wn/${weatherData!["weather"][0]["icon"]}@2x.png",
                            width: 60,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${weatherData!["name"]}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${weatherData!["main"]["temp"]}°C, ${weatherData!["weather"][0]["description"]}",
                              ),
                            ],
                          )
                        ],
                      ),
          ),

          // ===================== LISTA ORIGINAL ======================
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image,
                            size: 40, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Título de la película #${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text('Director: Nombre del director'),
                            const Text('Año: 2025'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
