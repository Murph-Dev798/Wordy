import 'package:flutter/material.dart';
import 'package:my_app/game.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text('Wordy'),
          ),
        ),
        body: Center(child: GamePage()),
      ),
    );
}
}

class GamePage extends StatefulWidget {
 const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Game _game = Game();

  void _handleSubmitGuess(String rawGuess) {
    final guess = rawGuess.trim().toLowerCase();

    if (_game.didWin || _game.didLose) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game over, restart the page to play again.')),
      );
      return;
    }

    if (guess.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guess must be 5 letters.')),
      );
      return;
    }

    if (!_game.isLegalGuess(guess)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That word is not in the allowed word list.')),
      );
      return;
    }

    setState(() {
      _game.guess(guess);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          for (var guess in _game.guesses)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var letter in guess)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
                    child: Tile(letter.char, letter.type),
                  )
              ],
            ),
          if (_game.didWin)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('You win!'),
            ),
          if (_game.didLose)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('You lose! Word was: ${_game.hiddenWord.toString().toUpperCase()}'),
            ),
          GuessInput(
            onSubmitGuess: _handleSubmitGuess,
          ),
        ],
      ),
    );
  }
}


class Tile extends StatelessWidget {
  const Tile(this.letter, this.hitType, {super.key});

  final String letter;
  final HitType hitType;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration:Duration(milliseconds: 500),
      curve: Curves.bounceIn,
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        color: switch (hitType) {
          HitType.hit => Colors.green,
          HitType.partial => Colors.yellow,
          HitType.miss => Colors.grey,
          _ => Colors.white,
        },
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
class GuessInput extends StatelessWidget {
   GuessInput({super.key, required this.onSubmitGuess});

  final void Function(String) onSubmitGuess;

  final TextEditingController _textEditingController = TextEditingController();

   final FocusNode _focusNode = FocusNode(); 

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textEditingController,
            focusNode: _focusNode,
            decoration: const InputDecoration(
              hintText: 'Enter your guess',
            ),
            onSubmitted: (_) {
              onSubmitGuess(_textEditingController.text.trim());
              _textEditingController.clear();
              _focusNode.requestFocus();
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_circle_up),
          iconSize: 50,
          onPressed: () {
            onSubmitGuess(_textEditingController.text.trim());
            _textEditingController.clear();
            _focusNode.requestFocus();
          },
        ),
      ],
    );
  }
}