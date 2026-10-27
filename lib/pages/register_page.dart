import 'package:chat/helpers/show_alert.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:chat/widgets/auth_scaffold.dart';
import 'package:chat/widgets/login_button.dart';
import 'package:chat/widgets/custom_input.dart';
import 'package:chat/widgets/labels.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthScaffold(
      title: 'Registro',
      form: _Form(),
      labels: Labels(
        route: 'login',
        title: '¿Ya tienes una cuenta?',
        subtitle: '¡Ingresa ahora!',
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
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    final error = await context.read<AuthService>().register(
        nameController.text.trim(),
        emailController.text.trim(),
        passController.text.trim());
    if (!mounted) return;

    if (error == null) {
      context.read<SocketService>().connect();
      Navigator.pushReplacementNamed(context, 'users');
    } else {
      showAlert(context, 'Registro incorrecto', error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authenticating = context.watch<AuthService>().authenticating;
    return Column(
      children: [
        CustomInput(
          icon: Icons.perm_identity,
          placeholder: 'Nombre',
          textController: nameController,
        ),
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
          text: 'Crear cuenta',
          loading: authenticating,
          onPressed: _register,
        ),
      ],
    );
  }
}
