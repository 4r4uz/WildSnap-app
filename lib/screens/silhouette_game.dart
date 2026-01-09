import 'package:flutter/material.dart';
import '../components/animated_gradient_background.dart';
import '../styles/colors.dart';

class SilhouetteGameScreen extends StatefulWidget {
  const SilhouetteGameScreen({super.key});

  @override
  State<SilhouetteGameScreen> createState() => _SilhouetteGameScreenState();
}

class _SilhouetteGameScreenState extends State<SilhouetteGameScreen> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _animals = [
    {
      'name': 'LEON',
      'category': 'Mamífero',
      'difficulty': 'Fácil',
      'hint': 'Rey de la sabana',
      'icon': Icons.pets,
    },
    {
      'name': 'ELEFANTE',
      'category': 'Mamífero',
      'difficulty': 'Fácil',
      'hint': 'La trompa más larga',
      'icon': Icons.pets,
    },
    {
      'name': 'JIRAFA',
      'category': 'Mamífero',
      'difficulty': 'Fácil',
      'hint': 'Cuello muy largo',
      'icon': Icons.pets,
    },
    {
      'name': 'TIGRE',
      'category': 'Mamífero',
      'difficulty': 'Medio',
      'hint': 'Rayas naranjas y negras',
      'icon': Icons.pets,
    },
    {
      'name': 'CANGURO',
      'category': 'Mamífero',
      'difficulty': 'Medio',
      'hint': 'Salta muy alto',
      'icon': Icons.pets,
    },
    {
      'name': 'PINGUINO',
      'category': 'Ave',
      'difficulty': 'Medio',
      'hint': 'Nada pero no vuela',
      'icon': Icons.pets,
    },
    {
      'name': 'COCODRILO',
      'category': 'Reptil',
      'difficulty': 'Difícil',
      'hint': 'Dientes afilados en la mandíbula',
      'icon': Icons.pets,
    },
    {
      'name': 'ORNITORRINCO',
      'category': 'Mamífero',
      'difficulty': 'Difícil',
      'hint': 'Pone huevos pero amamanta',
      'icon': Icons.pets,
    },
  ];

  late Map<String, dynamic> _currentAnimal;
  final List<String> _guesses = [];
  final TextEditingController _controller = TextEditingController();
  int _attemptsLeft = 6;
  bool _gameWon = false;
  bool _gameLost = false;
  bool _showHint = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _currentAnimal = _animals[DateTime.now().millisecondsSinceEpoch % _animals.length];
      _guesses.clear();
      _attemptsLeft = 6;
      _gameWon = false;
      _gameLost = false;
      _showHint = false;
      _controller.clear();
    });
  }

  void _makeGuess() {
    if (_controller.text.isEmpty || _gameWon || _gameLost) return;

    final guess = _controller.text.toUpperCase().trim();
    if (guess.isEmpty) return;

    setState(() {
      _guesses.add(guess);
      _controller.clear();

      if (guess == _currentAnimal['name']) {
        _gameWon = true;
        _score += (_attemptsLeft * 10) + (_showHint ? 0 : 20);
      } else {
        _attemptsLeft--;
        if (_attemptsLeft == 0) {
          _gameLost = true;
        }
      }
    });
  }

  List<Map<String, dynamic>> _getGuessFeedback(String guess) {
    final correctWord = _currentAnimal['name'] as String;
    final feedback = <Map<String, dynamic>>[];

    for (int i = 0; i < guess.length && i < correctWord.length; i++) {
      final letter = guess[i];
      final correctLetter = correctWord[i];

      if (letter == correctLetter) {
        feedback.add({'letter': letter, 'status': 'correct'});
      } else if (correctWord.contains(letter)) {
        feedback.add({'letter': letter, 'status': 'present'});
      } else {
        feedback.add({'letter': letter, 'status': 'absent'});
      }
    }

    return feedback;
  }

  Widget _buildSilhouette() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Silhouette container
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _currentAnimal['icon'] as IconData,
                color: Colors.white.withValues(alpha: 0.3),
                size: 80,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Animal info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  _currentAnimal['category'] as String,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(_currentAnimal['difficulty'] as String),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _currentAnimal['difficulty'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    // Usar un solo color para todas las dificultades para mantener coherencia
    return AppColors.iaPrimary.withValues(alpha: 0.8);
  }

  Widget _buildGuessInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // Input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _controller,
              enabled: !_gameWon && !_gameLost,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: '¿Qué animal es?',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 18,
                ),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  onPressed: _makeGuess,
                ),
              ),
              onSubmitted: (_) => _makeGuess(),
            ),
          ),

          const SizedBox(height: 16),

          // Guess button
          if (!_gameWon && !_gameLost)
            ElevatedButton(
              onPressed: _makeGuess,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                '¡Adivinar!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Attempts left
          Text(
            'Intentos restantes: $_attemptsLeft',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),

          // Hint button
          if (!_showHint && !_gameWon && !_gameLost)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showHint = true;
                });
              },
              icon: Icon(
                Icons.lightbulb,
                color: AppColors.statGold.withValues(alpha: 0.8),
                size: 16,
              ),
              label: Text(
                'Mostrar pista (-10 puntos)',
                style: TextStyle(
                  color: AppColors.statGold.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ),

          // Hint display
          if (_showHint)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.statGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.statGold.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _currentAnimal['hint'] as String,
                style: TextStyle(
                  color: AppColors.statGold.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuessHistory() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_guesses.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Intentos anteriores:',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ..._guesses.map((guess) => _buildGuessRow(guess)),
          ],
        ],
      ),
    );
  }

  Widget _buildGuessRow(String guess) {
    final feedback = _getGuessFeedback(guess);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: feedback.map((item) {
          final status = item['status'] as String;
          final letter = item['letter'] as String;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getLetterColor(status),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getLetterColor(String status) {
    switch (status) {
      case 'correct':
        return AppColors.iaPrimary.withValues(alpha: 0.8); // Verde IA para correcto
      case 'present':
        return AppColors.statGold.withValues(alpha: 0.8); // Oro para presente
      case 'absent':
        return AppColors.surfaceSecondary.withValues(alpha: 0.5); // Gris para ausente
      default:
        return AppColors.surfaceSecondary.withValues(alpha: 0.5);
    }
  }

  Widget _buildGameResult() {
    if (!_gameWon && !_gameLost) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _gameWon ? AppColors.statGreen.withValues(alpha: 0.2) : AppColors.serverDisconnected.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _gameWon ? AppColors.statGreen.withValues(alpha: 0.4) : AppColors.serverDisconnected.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _gameWon ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _gameWon ? '¡Felicitaciones!' : '¡Mejor suerte la próxima!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _gameWon
                ? 'Adivinaste el animal correctamente'
                : 'El animal era: ${_currentAnimal['name']}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (_gameWon) ...[
            const SizedBox(height: 8),
            Text(
              'Puntuación: +$_score',
              style: TextStyle(
                color: AppColors.statGold.withValues(alpha: 0.9),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _startNewGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Jugar de nuevo'),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.7),
                ),
                child: const Text('Volver'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Adivina la Sombra',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSilhouette(),
                _buildGuessInput(),
                _buildGuessHistory(),
                _buildGameResult(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
