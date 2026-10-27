import 'package:chat/models/messages_response.dart';
import 'package:chat/models/user.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:chat/widgets/chat_message.dart';
import 'package:chat/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  late ChatService chatService;
  late SocketService socketService;
  late AuthService authService;
  late User userFor;

  final List<ChatMessage> _messages = [];

  bool _isWrite = false;
  bool _loading = true;

  /// Id of the message being edited, null when composing a new one.
  String? _editingId;

  final int limit = 30;

  @override
  void initState() {
    super.initState();
    chatService = context.read<ChatService>();
    socketService = context.read<SocketService>();
    authService = context.read<AuthService>();
    userFor = chatService.userFor;

    socketService.socket?.on('personal-message', _listenMessage);
    socketService.socket?.on('delete-message', _deleteMessage);
    socketService.socket?.on('edit-message', _editMessage);

    _loadHistory();
  }

  @override
  void dispose() {
    socketService.socket?.off('personal-message', _listenMessage);
    socketService.socket?.off('delete-message', _deleteMessage);
    socketService.socket?.off('edit-message', _editMessage);
    for (final message in _messages) {
      message.animationController.dispose();
    }
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  ChatMessage _buildMessage(
      {required String id,
      required String text,
      required String from,
      DateTime? time,
      bool animate = false}) {
    final controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: animate ? 250 : 0));
    return ChatMessage(
      id: id,
      text: text,
      uid: from,
      time: time,
      isMyMessage: from == authService.user?.uid,
      animationController: controller,
    );
  }

  Future<void> _loadHistory() async {
    final List<Message> chat = await chatService.getChat(userFor.uid, limit);
    if (!mounted) return;

    final history = chat.map((m) =>
        _buildMessage(id: m.id, text: m.message, from: m.from, time: m.createdAt)
          ..animationController.forward());

    setState(() {
      _messages.insertAll(0, history);
      _loading = false;
    });
  }

  void _insertMessage(ChatMessage message) {
    setState(() => _messages.insert(0, message));
    message.animationController.forward();
  }

  void _listenMessage(dynamic payload) {
    // Only messages from the open conversation belong in this list.
    if (!mounted || payload['from'] != userFor.uid) return;
    _insertMessage(_buildMessage(
      id: payload['uid'],
      text: payload['message'],
      from: payload['from'],
      time: DateTime.now(),
      animate: true,
    ));
  }

  void _deleteMessage(dynamic id) {
    if (!mounted) return;
    final index = _messages.indexWhere((m) => m.id == id);
    if (index == -1) return;
    setState(() => _messages.removeAt(index).animationController.dispose());
  }

  void _editMessage(dynamic data) {
    if (!mounted) return;
    _replaceText(data['_id'], data['message']);
  }

  void _replaceText(String id, String text) {
    final index = _messages.indexWhere((m) => m.id == id);
    if (index == -1) return;
    setState(() => _messages[index] = _messages[index].copyWith(text: text));
  }

  void _onSubmit() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    setState(() => _isWrite = false);
    _editingId != null ? _saveEdit(_editingId!, text) : _send(text);
  }

  Future<void> _send(String text) async {
    _focusNode.requestFocus();
    final newMessage = await chatService.sendMessage(userFor.uid, text);
    if (!mounted) return;
    if (newMessage == null) {
      _showError('No se pudo enviar el mensaje');
      return;
    }

    socketService.emit('personal-message', {
      'uid': newMessage.id,
      'from': newMessage.from,
      'to': userFor.uid,
      'message': newMessage.message,
    });

    _insertMessage(_buildMessage(
      id: newMessage.id,
      text: newMessage.message,
      from: newMessage.from,
      time: newMessage.createdAt,
      animate: true,
    ));
  }

  Future<void> _saveEdit(String id, String text) async {
    setState(() => _editingId = null);
    final ok = await chatService.editMessage(id, text);
    if (!mounted) return;
    if (!ok) {
      _showError('No se pudo editar el mensaje');
      return;
    }
    socketService.emit(
        'edit-message', {'_id': id, 'to': userFor.uid, 'message': text});
    _replaceText(id, text);
  }

  Future<void> _delete(String id) async {
    final ok = await chatService.deleteMessage(id);
    if (!mounted) return;
    if (!ok) {
      _showError('No se pudo eliminar el mensaje');
      return;
    }
    socketService.emit('delete-message', {'id': id, 'to': userFor.uid});
    _deleteMessage(id);
  }

  void _startEditing(ChatMessage message) {
    setState(() {
      _editingId = message.id;
      _textController.text = message.text;
      _isWrite = true;
    });
    _focusNode.requestFocus();
  }

  void _cancelEditing() {
    setState(() {
      _editingId = null;
      _isWrite = false;
      _textController.clear();
    });
  }

  void _showError(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }

  void _showOptions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(sheetContext);
                _startEditing(message);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error),
              title: Text('Eliminar',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.pop(sheetContext);
                _delete(message.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, 'users'),
        ),
        title: Row(
          children: [
            UserAvatar(name: userFor.name, online: userFor.online, radius: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                userFor.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _messageList(colors)),
          _inputChat(colors),
        ],
      ),
    );
  }

  Widget _messageList(ColorScheme colors) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.waving_hand_outlined, size: 56, color: colors.outline),
            const SizedBox(height: 12),
            Text('Saluda a ${userFor.name}',
                style: TextStyle(color: colors.onSurfaceVariant)),
          ],
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _messages.length,
      reverse: true,
      itemBuilder: (_, i) {
        final message = _messages[i];
        return GestureDetector(
          onLongPress: message.isMyMessage ? () => _showOptions(message) : null,
          child: message,
        );
      },
    );
  }

  Widget _inputChat(ColorScheme colors) {
    final editingText = _editingId == null
        ? null
        : _messages.where((m) => m.id == _editingId).firstOrNull?.text;

    return Material(
      color: colors.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: editingText == null
                    ? const SizedBox(width: double.infinity)
                    : Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.only(left: 12),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16, color: colors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                editingText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: colors.onPrimaryContainer),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Cancelar edición',
                              onPressed: _cancelEditing,
                              icon: const Icon(Icons.close, size: 18),
                            ),
                          ],
                        ),
                      ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _onSubmit(),
                      onChanged: (text) =>
                          setState(() => _isWrite = text.trim().isNotEmpty),
                      decoration: InputDecoration(
                        hintText: 'Enviar mensaje',
                        fillColor: colors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: _editingId != null ? 'Guardar' : 'Enviar',
                    onPressed: _isWrite ? _onSubmit : null,
                    icon: Icon(_editingId != null ? Icons.check : Icons.send),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
