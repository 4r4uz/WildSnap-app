import 'package:flutter/material.dart';

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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¡Trivia Completada!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Puntuación: $score/${questions.length}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentQuestion = 0;
                    score = 0;
                  });
                },
                child: const Text('Jugar de Nuevo'),
              ),
            ],
          ),
        ),
      );
    }

    final question = questions[currentQuestion];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (currentQuestion + 1) / questions.length,
            ),
            const SizedBox(height: 20),
            Text(
              'Pregunta ${currentQuestion + 1}/${questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              question['question'],
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ...List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: () {
                    if (index == question['correct']) {
                      setState(() {
                        score++;
                      });
                    }
                    setState(() {
                      currentQuestion++;
                    });
                  },
                  child: Text(question['options'][index]),
                ),
              );
            }),
          ],
        ),
        ),
      ),
    );
  }
}
