import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Aforo - Ferry Cozumel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const _LogicScreen(),
    );
  }
}

class _LogicScreen extends StatefulWidget {
  const _LogicScreen({super.key});

  @override
  State<_LogicScreen> createState() => _LogicScreenState();
}

class _LogicScreenState extends State<_LogicScreen> {
  int cantidadPasajeros = 0;
  int capacidadMaxima = 800;
  bool capacidadChanged = true;
  List<String> historialPasajeros = [];
  final TextEditingController _controller = TextEditingController();

  String get _colorSemaforo {
    if (capacidadMaxima == 0) return "verde";
    double aforo = cantidadPasajeros / capacidadMaxima;
    if (aforo >= 0.9) return "rojo";
    if (aforo >= 0.6) return "amarillo";
    return "verde";
  }

  void _actualizarPasajeros(int cambio) {
    setState(() {
      if((cantidadPasajeros + cambio) > capacidadMaxima){
        cambio = 0;
        return;
      }
      if((cantidadPasajeros + cambio) < 0){
        return;
      }
      cantidadPasajeros += cambio;
      if (cantidadPasajeros < 0) cantidadPasajeros = 0;
      historialPasajeros.insert(0 ,
        "${DateTime.now().hour}:${DateTime.now().minute} - $cantidadPasajeros pasajeros",
      );
    });
  }

  void _reiniciar() {
    setState(() {
      cantidadPasajeros = 0;
      historialPasajeros.clear();
      capacidadChanged = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control de Aforo - Ferry Cozumel')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://static.wixstatic.com/media/82fb61_75a9387813f44b34b5dafd1e12958611~mv2.jpg/v1/fill/w_1200,h_674,al_c/82fb61_75a9387813f44b34b5dafd1e12958611~mv2.jpg',
                width: 250,
              ),
            ),
            const SizedBox(height: 20),

            // Campo de capacidad con boton bloqueable
            Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: capacidadChanged,
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Capacidad Máxima',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    int? nuevaCapacidad = int.tryParse(_controller.text);
                    if (nuevaCapacidad != null && nuevaCapacidad > 0) {
                      setState(() {
                        capacidadMaxima = nuevaCapacidad;
                        capacidadChanged = false;
                      });
                      _controller.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                  child: const Text('Establecer'),
                ),
              ],
            ),

            
            const SizedBox(height: 20),

            // Semáforo
            PantallaSemaforo(colorActivo: _colorSemaforo),
            const SizedBox(height: 20),

            // Contador de pasajeros
            Text(
              'Aforo: $cantidadPasajeros / $capacidadMaxima',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // LinearProgress
            LinearProgressIndicator(
              value: capacidadMaxima == 0 ? 0 : cantidadPasajeros / capacidadMaxima,
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _colorSemaforo == "rojo"
                    ? Colors.red
                    : _colorSemaforo == "amarillo"
                        ? Colors.yellow
                        : Colors.green,
              ),
            ),

            const SizedBox(height: 20),

            // Historial de pasajeros
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: historialPasajeros.length,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(historialPasajeros[index]));
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // Botonera inferior
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Tooltip(
                message: "-5",
                child: ElevatedButton(
                  onPressed: () => _actualizarPasajeros(-5),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  child: const Text('-5'),
                ),
              ),
              Tooltip(
                message: "-1",
                child: ElevatedButton(
                  onPressed: () => _actualizarPasajeros(-1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  child: const Text('-1'),
                ),
              ),
              Tooltip(
                message: "Reiniciar",
                child: ElevatedButton(
                  onPressed: _reiniciar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.restart_alt),
                ),
              ),
              Tooltip(
                message: "+1",
                child: ElevatedButton(
                  onPressed: () => _actualizarPasajeros(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  child: const Text('+1'),
                ),
              ),
              Tooltip(
                message: "+2",
                child: ElevatedButton(
                  onPressed: () => _actualizarPasajeros(2),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  child: const Text('+2'),
                ),
              ),
              Tooltip(
                message: "+5",
                child: ElevatedButton(
                  onPressed: () => _actualizarPasajeros(5),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  child: const Text('+5'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PantallaSemaforo extends StatelessWidget {
  final String colorActivo;
  const PantallaSemaforo({super.key, required this.colorActivo});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLuz(Colors.red, colorActivo == "rojo"),
        const SizedBox(width: 20),
        _buildLuz(Colors.yellow, colorActivo == "amarillo"),
        const SizedBox(width: 20),
        _buildLuz(Colors.green, colorActivo == "verde"),
      ],
    );
  }

  Widget _buildLuz(Color color, bool encendida) {
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: encendida ? color : color.withOpacity(0.3),
        border: Border.all(color: Colors.black, width: 2),
      ),
    );
  }
}
