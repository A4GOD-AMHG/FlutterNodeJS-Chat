import 'package:chat/models/user.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:chat/services/users_service.dart';
import 'package:chat/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final userService = UsersService();

  List<User> users = [];
  List<String?> _lastMessages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final chatService = context.read<ChatService>();
    final myUid = context.read<AuthService>().user?.uid;

    final loaded = await userService.getUsers();
    final lasts = await Future.wait(loaded.map((u) => chatService.getLast(u.uid)));
    if (!mounted) return;

    setState(() {
      users = loaded;
      _lastMessages = lasts
          .map((m) => m == null
              ? null
              : m.from == myUid
                  ? 'Tú: ${m.message}'
                  : m.message)
          .toList();
      _loading = false;
    });
  }

  Future<void> _logout() async {
    context.read<SocketService>().disconnect();
    await context.read<AuthService>().logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, 'login');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;
    final online =
        context.watch<SocketService>().serverStatus == ServerStatus.Online;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            UserAvatar(name: user?.name ?? '', online: online, radius: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.name ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    online ? 'Conectado' : 'Sin conexión',
                    style: TextStyle(
                        fontSize: 12,
                        color: online ? Colors.green : colors.error),
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          tooltip: 'Cerrar sesión',
          onPressed: _logout,
          icon: const Icon(Icons.logout),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: users.isEmpty ? _emptyState(colors) : _listViewUsers(),
            ),
    );
  }

  Widget _emptyState(ColorScheme colors) {
    // ListView keeps pull-to-refresh working when there is nothing to show.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 160),
        Icon(Icons.people_outline, size: 64, color: colors.outline),
        const SizedBox(height: 12),
        Text(
          'No hay usuarios todavía',
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _listViewUsers() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (_, i) => _userListTile(users[i], _lastMessages[i]),
      itemCount: users.length,
    );
  }

  Widget _userListTile(User user, String? lastMessage) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: UserAvatar(name: user.name, online: user.online),
      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        lastMessage ?? user.email,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.read<ChatService>().userFor = user;
        Navigator.pushReplacementNamed(context, 'chat');
      },
    );
  }
}
