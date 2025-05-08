import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class UserProfile {
  String name;
  String email;

  UserProfile({required this.name, required this.email});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final UserProfile _userProfile = UserProfile(name: 'User', email: 'user@gmail.com');
  final List<String> _calculationHistory = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _selectedIndex == 0
          ? Calculator(onCalculation: (result) {
              setState(() {
                _calculationHistory.add(result);
              });
            })
          : _selectedIndex == 1
              ? CalculationHistory(calculationHistory: _calculationHistory)
              : UserProfileDisplay(userProfile: _userProfile),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Kalkulator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.grey[400],
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
      ),
    );
  }
}

class Calculator extends StatefulWidget {
  final Function(String) onCalculation;

  const Calculator({Key? key, required this.onCalculation}) : super(key: key);

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _expression = '';
  String _display = '0';

  void _handleInput(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _display = '0';
      } else if (value == 'Del') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _display = _expression.isEmpty ? '0' : _expression;
        }
      } else if (value == '=') {
        try {
          final result = _evaluateExpression(_expression);
          widget.onCalculation('$_expression = $result');
          _expression = result;
          _display = result;
        } catch (e) {
          _display = 'Error';
        }
      } else {
        _expression += value;
        _display = _expression;
      }
    });
  }

  String _evaluateExpression(String expr) {
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/');
    try {
      final result = _simpleEvaluate(expr);
      return result.toString().endsWith('.0')
          ? result.toString().split('.')[0]
          : result.toString();
    } catch (_) {
      return 'Error';
    }
  }

  double _simpleEvaluate(String expr) {
    List<String> tokens = expr.split(RegExp(r'(?<=[-+*/])|(?=[-+*/])'));
    List<double> numbers = [];
    List<String> ops = [];

    for (var token in tokens) {
      if (['+', '-', '*', '/'].contains(token)) {
        ops.add(token);
      } else {
        numbers.add(double.tryParse(token.trim()) ?? 0);
      }
    }

    while (ops.contains('*') || ops.contains('/')) {
      for (int i = 0; i < ops.length; i++) {
        if (ops[i] == '*' || ops[i] == '/') {
          double res = ops[i] == '*'
              ? numbers[i] * numbers[i + 1]
              : numbers[i + 1] != 0
                  ? numbers[i] / numbers[i + 1]
                  : double.nan;
          numbers[i] = res;
          numbers.removeAt(i + 1);
          ops.removeAt(i);
          break;
        }
      }
    }

    while (ops.isNotEmpty) {
      double res = ops[0] == '+'
          ? numbers[0] + numbers[1]
          : numbers[0] - numbers[1];
      numbers[0] = res;
      numbers.removeAt(1);
      ops.removeAt(0);
    }

    return numbers[0];
  }

  Widget _buildButton(String text, {Color color = Colors.white}) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(72, 72),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        onPressed: () => _handleInput(text),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 24,
            color: color == Colors.white ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons.map((text) {
        return _buildButton(
          text,
          color: ['÷', '×', '-', '+', '='].contains(text) ? const Color.fromARGB(255, 252, 82, 3) : Colors.black,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.grey[900],
        width: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Expression Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              alignment: Alignment.centerRight,
              child: Text(
                _display,
                style: TextStyle(
                  fontSize: 36,
                  color: _display == 'Error' ? const Color.fromARGB(255, 252, 82, 3) : Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),

            // Button Grid
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildButtonRow(['7', '8', '9', '÷']),
                    _buildButtonRow(['4', '5', '6', '×']),
                    _buildButtonRow(['1', '2', '3', '-']),
                    _buildButtonRow(['C', '0', '=', '+']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalculationHistory extends StatelessWidget {
  final List<String> calculationHistory;

  const CalculationHistory({Key? key, required this.calculationHistory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: calculationHistory.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(calculationHistory[index], style: const TextStyle(color: Colors.white)),
        );
      },
    );
  }
}

class UserProfileDisplay extends StatelessWidget {
  final UserProfile userProfile;

  const UserProfileDisplay({Key? key, required this.userProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil Pengguna',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text('Nama: ${userProfile.name}', style: const TextStyle(color: Colors.white)),
          Text('Email: ${userProfile.email}', style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
