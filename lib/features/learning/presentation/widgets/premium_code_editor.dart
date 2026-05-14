import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

import '../../domain/models/code_execution.dart';
import '../../infrastructure/services/code_runner_service.dart';

class PremiumCodeEditor extends ConsumerStatefulWidget {
  const PremiumCodeEditor({
    super.key,
    required this.initialCode,
    this.language = 'java',
    this.onResult,
  });

  final String initialCode;
  final String language;
  final ValueChanged<CodeExecutionResult>? onResult;

  @override
  ConsumerState<PremiumCodeEditor> createState() => _PremiumCodeEditorState();
}

class _PremiumCodeEditorState extends ConsumerState<PremiumCodeEditor> {
  late CodeController _codeController;
  bool _isRunning = false;
  CodeExecutionResult? _lastResult;

  @override
  void initState() {
    super.initState();
    String code = widget.initialCode;
    if (code.isEmpty || !code.contains('class')) {
      code = 'public class Main {\n    public static void main(String[] args) {\n        // Напишите ваш код здесь\n        System.out.println("Hello World");\n    }\n}';
    }
    _codeController = CodeController(
      text: code,
      language: widget.language == 'java' ? java : python,
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _runCode() async {
    setState(() {
      _isRunning = true;
      _lastResult = null;
    });

    final service = ref.read(codeRunnerServiceProvider);
    
    String finalCode = _codeController.text;
    // Auto-wrap with Main class if missing (basic check)
    if (widget.language == 'java' && !finalCode.contains('class Main')) {
      if (!finalCode.contains('public class')) {
        finalCode = 'public class Main {\n    public static void main(String[] args) {\n        $finalCode\n    }\n}';
      }
    }

    final result = await service.runCode(
      CodeExecutionRequest(
        language: widget.language,
        code: finalCode,
      ),
    );

    if (mounted) {
      setState(() {
        _isRunning = false;
        _lastResult = result;
      });
      widget.onResult?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450, // Slightly increased but stable height
      child: Column(
        children: [
        // Editor Header (Window-like)
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF282C34),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Mac-style window buttons
              Row(
                children: [
                  _windowButton(Colors.redAccent),
                  const SizedBox(width: 8),
                  _windowButton(Colors.orangeAccent),
                  const SizedBox(width: 8),
                  _windowButton(Colors.greenAccent),
                ],
              ),
              const Spacer(),
              // Run Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isRunning ? null : _runCode,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _isRunning
                              ? Colors.white10
                              : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        if (_isRunning)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        else
                          const Icon(
                            Icons.play_arrow_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        const SizedBox(width: 6),
                        Text(
                          _isRunning ? 'Running...' : 'Run Code',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF282C34),
              border: Border.symmetric(vertical: BorderSide(color: Colors.white10)),
            ),
            child: CodeTheme(
              data: const CodeThemeData(styles: atomOneDarkTheme),
              child: CodeField(
                controller: _codeController,
                expands: true,
                textStyle: GoogleFonts.firaCode(fontSize: 13, height: 1.5),
                cursorColor: const Color(0xFF569CD6),
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: const Color(0xFF569CD6),
                  selectionColor: const Color(0xFF264F78).withValues(alpha: 0.5),
                  selectionHandleColor: const Color(0xFF569CD6),
                ),
                lineNumberStyle: const LineNumberStyle(
                  width: 65,
                  textAlign: TextAlign.right,
                  margin: 15,
                  textStyle: TextStyle(color: Colors.white30, fontSize: 12),
                ),
                background: const Color(0xFF282C34),
              ),
            ),
          ),
        ),
        // Console Output
        Container(
          height: 120, // Fixed height for terminal to ensure overall 400px height is respected
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2127),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            border: Border.all(color: Colors.white10),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terminal Output:',
                  style: GoogleFonts.firaCode(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                if (_lastResult != null) ...[
                  if (_lastResult!.stdout.isNotEmpty)
                    Text(
                      _lastResult!.stdout,
                      style: GoogleFonts.firaCode(
                        color: Colors.greenAccent,
                        fontSize: 12,
                      ),
                    ),
                  if (_lastResult!.stderr.isNotEmpty)
                    Text(
                      _lastResult!.stderr,
                      style: GoogleFonts.firaCode(
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  if (_lastResult!.error.isNotEmpty)
                    Text(
                      _lastResult!.error,
                      style: GoogleFonts.firaCode(
                        color: Colors.orangeAccent,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ] else if (_isRunning)
                  Text(
                    'Compiling and running...',
                    style: GoogleFonts.firaCode(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  )
                else
                  Text(
                    'Click "Run Code" to see execution results.',
                    style: GoogleFonts.firaCode(
                      color: Colors.white24,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _windowButton(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
