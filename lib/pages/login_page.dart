import 'package:chat/helpers/show_alert.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:chat/widgets/auth_scaffold.dart';
import 'package:chat/widgets/login_button.dart';
import 'package:chat/widgets/custom_input.dart';
import 'package:chat/widgets/labels.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthScaffold(
      title: 'Iniciar sesión',
      form: _Form(),
      labels: Labels(
        route: 'register',
        title: '¿No tienes cuenta?',
        subtitle: 'Regístrate',
      ),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form();

  @override
  State<_Form> createState() => __FormState();
}

class __FormState extends State<_Form> {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    final authService = context.read<AuthService>();
    final loginOk = await authService.login(
        emailController.text.trim(), passController.text.trim());
    if (!mounted) return;

    if (loginOk) {
      context.read<SocketService>().connect();
      Navigator.pushReplacementNamed(context, 'users');
    } else {
      showAlert(
          context, 'Login incorrecto', 'Revise sus credenciales nuevamente');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authenticating = context.watch<AuthService>().authenticating;
    return Column(
      children: [
        CustomInput(
          icon: Icons.mail_outline,
          placeholder: 'Correo',
          keyboardType: TextInputType.emailAddress,
          textController: emailController,
        ),
        CustomInput(
          icon: Icons.lock_outline,
          placeholder: 'Contraseña',
          keyboardType: TextInputType.visiblePassword,
          textController: passController,
          isPassword: true,
        ),
        const SizedBox(height: 8),
        LoginButton(
          text: 'Ingresar',
          loading: authenticating,
          onPressed: _login,
        ),
      ],
    );
  }
}
