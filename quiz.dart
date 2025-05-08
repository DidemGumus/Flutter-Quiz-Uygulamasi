//Proje Ekibi:
//Kadir IR - 1220505055
//Didem Gümüş - 1220505059
import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const QuizApp());

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QuizPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Question {
  final String questionText;
  final List<String> options;
  final int correctIndex;
  bool isTimeUp;
  bool isSkipped;
  int? selectedOption;

  Question({
    required this.questionText,
    required this.options,
    required this.correctIndex,
    this.isTimeUp = false,
    this.isSkipped = false,
    this.selectedOption,
  });
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final List<Question> _questions = [
    Question(questionText: "Flutter nedir?", options: ["Framework", "Dil", "IDE", "Kütüphane", "Donanım"], correctIndex: 0),
    Question(questionText: "Dart hangi şirkete aittir?", options: ["Apple", "Facebook", "Microsoft", "Google", "Amazon"], correctIndex: 3),
    Question(questionText: "StatefulWidget nedir?", options: ["Değişmeyen", "Statik", "Dinamik", "Yavaş", "Basit"], correctIndex: 2),
    Question(questionText: "Hot reload ne işe yarar?", options: ["Debug", "Kod yazmak", "Hata bulmak", "Anında güncelleme", "Çalıştırmak"], correctIndex: 3),
    Question(questionText: "Flutter'da UI tasarımı için kullanılan yapı?", options: ["Model", "Service", "Widget", "Package", "Function"], correctIndex: 2),
    Question(questionText: "Flutter'da navigation için ne kullanılır?", options: ["Navigator", "Driver", "Conductor", "Switcher", "Pager"], correctIndex: 0),
    Question(questionText: "Flutter'ın temel bileşeni?", options: ["Service", "API", "Widget", "Logic", "Plugin"], correctIndex: 2),
    Question(questionText: "Dart'ta listeyi tanımlamak için ne kullanılır?", options: ["Map", "Set", "Array", "List", "Table"], correctIndex: 3),
    Question(questionText: "MaterialApp ne işe yarar?", options: ["Temel yapı sağlar", "Veri tutar", "Veritabanı", "Animasyon", "Tema"], correctIndex: 0),
    Question(questionText: "StatelessWidget'ta ne yoktur?", options: ["Gövde", "State", "Build", "Context", "Widget"], correctIndex: 1),
  ];

  late List<Question> _shuffledQuestions;
  int _currentIndex = 0;
  int _score = 0;
  int _timeLeft = 20;
  Timer? _timer;
  bool _quizFinished = false;

  @override
  void initState() {
    super.initState();
    _shuffledQuestions = [..._questions]..shuffle();
    _startTimer();
  }

bool _areAllQuestionsAnswered() {
  return _shuffledQuestions.every((q) => q.selectedOption != null);
}

  void _startTimer() {
    _timeLeft = 20;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _shuffledQuestions[_currentIndex].isTimeUp = true;
          _timer?.cancel();
        }
      });
    });
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _timer?.cancel();
      setState(() {
        _currentIndex--;
        _startTimer();
      });
    }
  }

  void _goToNext() {
    final current = _shuffledQuestions[_currentIndex];
    if (current.selectedOption == null && !current.isSkipped && !current.isTimeUp) return;

    if (_currentIndex < _shuffledQuestions.length - 1) {
      _timer?.cancel();
      setState(() {
        _currentIndex++;
        _startTimer();
      });
    }
  }

  void _selectOption(int index) {
    if (_shuffledQuestions[_currentIndex].selectedOption != null || _shuffledQuestions[_currentIndex].isTimeUp) return;
    setState(() {
      _shuffledQuestions[_currentIndex].selectedOption = index;
      if (index == _shuffledQuestions[_currentIndex].correctIndex) {
        _score += 10;
      }
    });
  }

  void _markAsSkipped() {
    setState(() {
      _shuffledQuestions[_currentIndex].isSkipped = true;
      _goToNext();
    });
  }

  void _finishQuiz() {
  if (_areAllQuestionsAnswered()) {
    _timer?.cancel();
    setState(() {
      _quizFinished = true;
    });
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eksik Sorular Var!"),
        content: const Text("Tüm soruları cevaplamadın. Sınavı bitireceğine emin misin?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), 
            child: const Text("Teste Devam Et"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); 
              _timer?.cancel();
              setState(() {
                _quizFinished = true;
              });
            },
            child: const Text("Yine de Bitir"),
          ),
        ],
      ),
    );
  }
}

  void _restartQuiz() {
    setState(() {
      _shuffledQuestions = [..._questions]..shuffle();
      for (var q in _shuffledQuestions) {
        q.isTimeUp = false;
        q.isSkipped = false;
        q.selectedOption = null;
      }
      _currentIndex = 0;
      _score = 0;
      _quizFinished = false;
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  if (_quizFinished) {
    bool success = _score >= 70;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (success)
              const Text('🎉 Tebrikler! 🎉', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            if (!success)
              const Text('Daha çok çalışmalısın 💪', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('Puanın: $_score', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _restartQuiz,
              child: const Text('Yeniden Başla'),
            )
          ],
        ),
      ),
    );
  }

  final question = _shuffledQuestions[_currentIndex];

  return Scaffold(
    backgroundColor: question.isTimeUp ? Colors.orange.shade100 : Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.deepPurpleAccent,
      centerTitle: true,
      title: Column(
        children: [
          Text(
            'Flutter Quiz Uygulaması',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Georgia',
            ),
          ),
          Text(
            '${_currentIndex + 1}/${_shuffledQuestions.length}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(child: Text('$_timeLeft s', style: const TextStyle(fontSize: 18))),
        )
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.questionText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (question.isTimeUp)
            const Text("Maalesef bu soru için süreniz doldu", style: TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
          ...List.generate(question.options.length, (index) {
            Color? optionColor;
            if (question.selectedOption != null) {
              if (index == question.correctIndex) {
                optionColor = Colors.green;
              } else if (index == question.selectedOption) {
                optionColor = Colors.red;
              } else {
                optionColor = Colors.grey.shade200;
              }
            }
            return GestureDetector(
              onTap: () => _selectOption(index),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: optionColor ?? Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(question.options[index], style: const TextStyle(fontSize: 16)),
              ),
            );
          }),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(onPressed: _goToPrevious, child: const Text("Önceki")),
              ElevatedButton(onPressed: _markAsSkipped, child: const Text("Boş Bırak")),
              ElevatedButton(onPressed: _goToNext, child: const Text("Sonraki")),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: List.generate(_shuffledQuestions.length, (index) {
              final q = _shuffledQuestions[index];
              Color color;
              if (q.isTimeUp) {
                color = Colors.orange;
              } else if (q.selectedOption != null) {
                color = Colors.blue;
              } else if (q.isSkipped) {
                color = Colors.yellow;
              } else {
                color = Colors.grey;
              }

              return GestureDetector(
                onTap: q.isTimeUp ? null : () {
                  _timer?.cancel();
                  setState(() {
                    _currentIndex = index;
                    _startTimer();
                  });
                },
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
                ),
              );
            }),
          ),
                   const SizedBox(height: 20),
                   if (_currentIndex == _shuffledQuestions.length - 1)
            Column(
              children: [
                if (_areAllQuestionsAnswered())
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      "🎯 Tüm soruları cevapladın, sınavı bitirebiliriz 😎",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.deepPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Center(
                  child: ElevatedButton(
                    onPressed: _finishQuiz,
                    child: const Text("Sınavı Bitir"),
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}
}