import 'package:flutter/material.dart';
import '../components/animated_gradient_background.dart';
import '../styles/colors.dart';

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({super.key});

  @override
  State<TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  int currentQuestion = 0;
  int score = 0;

  final List<Map<String, dynamic>> questions = [
    {
      'question': '¿Cuál es el animal más grande del mundo?',
      'options': ['Elefante', 'Ballena Azul', 'Jirafa', 'Oso Polar'],
      'correct': 1,
    },
    {
      'question': '¿Qué animal puede volar sin alas?',
      'options': ['Pez Volador', 'Murciélago', 'Pájaro', 'Mariposa'],
      'correct': 0,
    },
    {
      'question': '¿Cuántos corazones tiene un pulpo?',
      'options': ['1', '2', '3', '4'],
      'correct': 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (currentQuestion >= questions.length) {
      return Scaffold(
        body: HomeBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.triviaGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.celebration,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '¡Trivia Completada!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.borderPrimary,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Puntuación: $score/${questions.length}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentQuestion = 0;
                      score = 0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.iaPrimary,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Jugar de Nuevo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                  child: const Text(
                    'Volver al Inicio',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = questions[currentQuestion];

    return Scaffold(
      body: HomeBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.triviaGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.quiz,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Trivia de Naturaleza',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Progress Bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: AppColors.surfaceSecondary.withValues(alpha: 0.3),
                  ),
                  child: LinearProgressIndicator(
                    value: (currentQuestion + 1) / questions.length,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.iaPrimary),
                  ),
                ),
                const SizedBox(height: 20),

                // Question Counter
                Text(
                  'Pregunta ${currentQuestion + 1}/${questions.length}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Question
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.borderPrimary,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    question['question'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),

                // Options
                ...List.generate(4, (index) {
                  final isCorrect = index == question['correct'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        if (isCorrect) {
                          setState(() {
                            score++;
                          });
                        }
                        setState(() {
                          currentQuestion++;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCorrect
                            ? AppColors.statGreen
                            : AppColors.surfaceSecondary.withValues(alpha: 0.8),
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: isCorrect
                            ? AppColors.statGreen.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.2),
                      ),
                      child: Text(
                        question['options'][index],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 40),

                // Hint Button
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.lightbulb,
                    color: AppColors.statGold,
                    size: 20,
                  ),
                  label: Text(
                    '¿Necesitas una pista?',
                    style: TextStyle(
                      color: AppColors.statGold,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
