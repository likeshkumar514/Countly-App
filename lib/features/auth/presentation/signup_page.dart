import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/auth_controller.dart';
import 'login_page.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _scale;
  late AnimationController _btnCtrl;
  late Animation<double> _btnScale;
  bool _obscurePassword = true;
  final _confirmPassword = TextEditingController();
  bool _obscureConfirmPassword = true;

  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _submitting = false;
  String? _emailAuthError;
  String? _passwordAuthError;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _btnScale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _btnCtrl.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();

    super.dispose();
  }

  bool _validEmail(String v) => RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v);

  void _clearAuthErrors() => setState(() {
    _emailAuthError = null;
    _passwordAuthError = null;
  });

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _submit() async {
    _clearAuthErrors();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signUp(_email.text.trim(), _password.text);

      // ✅ Do NOT push to Home. Pop to AuthGate; it will rebuild to Home.
      if (!mounted) return;
      Navigator.of(context).popUntil((r) => r.isFirst);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          setState(
            () =>
                _emailAuthError =
                    'This email is already registered. Try logging in instead.',
          );
          break;
        case 'invalid-email':
          setState(() => _emailAuthError = 'Invalid email address.');
          break;
        case 'weak-password':
          setState(
            () =>
                _passwordAuthError =
                    'Weak password. Use at least 6 characters.',
          );
          break;
        case 'operation-not-allowed':
          _showSnack('Password sign-in is disabled for this project.');
          break;
        case 'network-request-failed':
          _showSnack('Network error. Check your connection and try again.');
          break;
        default:
          _showSnack('Signup failed: ${e.message ?? e.code}');
      }
    } catch (e) {
      _showSnack('Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disable = _submitting;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: FadeTransition(
          opacity: _fade,
          child: const Text('Join Us!', style: TextStyle(fontSize: 30)),
        ),
      ),
      body: AbsorbPointer(
        absorbing: disable,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SlideTransition(
                    position: _slide,
                    child: Container(
                      height: MediaQuery.of(context).size.height / 3,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/Images/sign_up_image.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 90),
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        _field(
                          controller: _username,
                          hintText: 'User Name',
                          prefixIcon: Icons.person_outline,
                          validator:
                              (v) =>
                                  (v == null || v.isEmpty)
                                      ? 'Please enter your username'
                                      : null,
                        ),
                        const SizedBox(height: 20),
                        _field(
                          controller: _email,
                          hintText: 'Your Email',
                          prefixIcon: Icons.email_outlined,
                          validator:
                              (v) =>
                                  (v == null || !_validEmail(v))
                                      ? 'Please enter a valid email'
                                      : null,
                          errorText: _emailAuthError,
                        ),
                        const SizedBox(height: 20),
                        _field(
                          controller: _password,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          validator:
                              (v) =>
                                  (v == null || v.length < 6)
                                      ? 'Password must be at least 6 characters long'
                                      : null,
                          errorText: _passwordAuthError,
                          onToggle: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        _field(
                          controller: _confirmPassword,
                          hintText: 'Confirm Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Please confirm your password';
                            if (v != _password.text)
                              return 'Passwords do not match';
                            return null;
                          },
                          onToggle: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),

                        const SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            onTapDown: (_) => _btnCtrl.forward(),
                            onTapUp: (_) => _btnCtrl.reverse(),
                            onTapCancel: () => _btnCtrl.reverse(),
                            child: ScaleTransition(
                              scale: _btnScale,
                              child: SizedBox(
                                width: 150,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child:
                                      _submitting
                                          ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Text(
                                            'SIGN UP',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already Have An Account? '),
                              GestureDetector(
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginPage(),
                                      ),
                                    ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required String? Function(String?)? validator,
    bool obscureText = false,
    String? errorText,
    VoidCallback? onToggle,
  }) {
    return ScaleTransition(
      scale: _scale,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIcon),
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide.none,
          ),
          errorText: errorText,
          suffixIcon:
              onToggle != null
                  ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: onToggle,
                  )
                  : null,
        ),
        validator: validator,
      ),
    );
  }
}
