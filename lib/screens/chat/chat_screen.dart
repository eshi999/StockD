import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/sage_service.dart';

// ── Message Model ─────────────────────────────────────────────────────────────
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// ── Chat Provider ─────────────────────────────────────────────────────────────
class ChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() => [
        ChatMessage(
          text: 'Hi! I\'m SAGE — your stock market education assistant.\n\n'
              'I can help you with:\n'
              '• Stock concepts — P/E, RSI, moving averages, ETFs...\n'
              '• S&P 500 data — just type a ticker like AAPL or MSFT\n'
              '• Chart indicators — candlesticks, support, resistance\n\n'
              'What would you like to learn about?\n\n'
              '⚠️ I provide educational information only, not financial advice.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    state = [
      ...state,
      ChatMessage(text: text.trim(), isUser: true, timestamp: DateTime.now()),
    ];

    // Build history for backend
    final history = state
        .where((m) => !m.isUser)
        .take(10)
        .map((m) => {'role': 'assistant', 'content': m.text})
        .toList();

    // Get SAGE response
    final service = ref.read(sageServiceProvider);
    final response = await service.chat(
      message: text.trim(),
      history: history,
    );

    state = [
      ...state,
      ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
  }

  void clear() => state = [
        ChatMessage(
          text: 'Chat cleared. What would you like to learn about?\n\n'
              '⚠️ Educational information only, not financial advice.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
}

final chatProvider =
    NotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);

// ── Chat Screen ───────────────────────────────────────────────────────────────
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _controller.clear();
    _scrollToBottom();

    await ref.read(chatProvider.notifier).sendMessage(text);

    setState(() => _sending = false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: _buildMessageList(messages),
        ),
        if (_sending) _buildTypingIndicator(),
        _buildInputBar(),
      ],
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: StockDTheme.surface,
        border: Border(bottom: BorderSide(color: StockDTheme.border)),
      ),
      child: Row(
        children: [
          Text('SAGE', style: StockDTheme.labelSmall),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded,
              size: 14, color: StockDTheme.textMuted),
          const SizedBox(width: 6),
          Text('CHAT',
              style: StockDTheme.labelSmall.copyWith(color: StockDTheme.sage)),
          const Spacer(),
          // Clear button
          GestureDetector(
            onTap: () => ref.read(chatProvider.notifier).clear(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: StockDTheme.card,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: StockDTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.delete_outline_rounded,
                      size: 13, color: StockDTheme.textMuted),
                  const SizedBox(width: 5),
                  Text('Clear', style: StockDTheme.labelSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Message List ──────────────────────────────────────────────────────────
  Widget _buildMessageList(List<ChatMessage> messages) {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      itemCount: messages.length,
      itemBuilder: (ctx, i) => _MessageBubble(
        message: messages[i],
        delay: i == messages.length - 1 ? 0 : -1,
      ),
    );
  }

  // ── Typing Indicator ──────────────────────────────────────────────────────
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Row(
        children: [
          _SageAvatar(),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: StockDTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: StockDTheme.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: StockDTheme.sage,
                  ),
                )
                    .animate(
                        onPlay: (c) => c.repeat(),
                        delay: Duration(milliseconds: i * 150))
                    .fadeIn(duration: 300.ms)
                    .then()
                    .fadeOut(duration: 300.ms),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Input Bar ─────────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: StockDTheme.surface,
        border: Border(top: BorderSide(color: StockDTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: StockDTheme.bodyLarge.copyWith(
                fontSize: 14,
                color: StockDTheme.textPrimary,
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText:
                    'Ask SAGE about stocks, concepts, or type a ticker...',
                hintStyle: StockDTheme.bodyLarge.copyWith(fontSize: 13),
                filled: true,
                fillColor: StockDTheme.card,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: StockDTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: StockDTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: StockDTheme.sage),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _SendButton(
            onTap: _send,
            sending: _sending,
          ),
        ],
      ),
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final int delay;
  const _MessageBubble({required this.message, required this.delay});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _SageAvatar(),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  constraints: const BoxConstraints(maxWidth: 560),
                  decoration: BoxDecoration(
                    color: isUser
                        ? StockDTheme.sage.withValues(alpha: 0.12)
                        : StockDTheme.card,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isUser ? 12 : 2),
                      bottomRight: Radius.circular(isUser ? 2 : 12),
                    ),
                    border: Border.all(
                      color: isUser
                          ? StockDTheme.sage.withValues(alpha: 0.3)
                          : StockDTheme.border,
                    ),
                  ),
                  child: _buildText(message.text, isUser),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatTime(message.timestamp),
                  style: StockDTheme.labelSmall.copyWith(fontSize: 9),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 10),
        ],
      ),
    ).animate(
      effects: delay >= 0
          ? [
              FadeEffect(duration: 300.ms),
              SlideEffect(
                begin: Offset(isUser ? 0.05 : -0.05, 0),
                duration: 300.ms,
              ),
            ]
          : [],
    );
  }

  Widget _buildText(String text, bool isUser) {
    // Parse basic markdown-style bold (**text**)
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) return const SizedBox(height: 4);

        if (line.startsWith('**') && line.endsWith('**')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line.replaceAll('**', ''),
              style: StockDTheme.headingMedium.copyWith(
                fontSize: 13,
                color: isUser ? StockDTheme.sage : StockDTheme.textPrimary,
              ),
            ),
          );
        }

        if (line.startsWith('•') || line.startsWith('-')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 3, left: 4),
            child: Text(
              line,
              style: StockDTheme.bodyLarge.copyWith(
                fontSize: 13,
                color: isUser
                    ? StockDTheme.textPrimary
                    : StockDTheme.textSecondary,
              ),
            ),
          );
        }

        if (line.startsWith('⚠️')) {
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              line,
              style: StockDTheme.labelSmall.copyWith(
                color: StockDTheme.gold,
                fontSize: 10,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            line,
            style: StockDTheme.bodyLarge.copyWith(
              fontSize: 13,
              height: 1.5,
              color:
                  isUser ? StockDTheme.textPrimary : StockDTheme.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── SAGE Avatar ───────────────────────────────────────────────────────────────
class _SageAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: StockDTheme.gradient,
        boxShadow: [
          BoxShadow(
            color: StockDTheme.sage.withValues(alpha: 0.3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: Text(
          'S',
          style: TextStyle(
            fontFamily: 'Syne',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: StockDTheme.bg,
          ),
        ),
      ),
    );
  }
}

// ── Send Button ───────────────────────────────────────────────────────────────
class _SendButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool sending;
  const _SendButton({required this.onTap, required this.sending});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.sending ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _hovered && !widget.sending ? StockDTheme.gradient : null,
            color: _hovered && !widget.sending ? null : StockDTheme.card,
            border: Border.all(
              color: _hovered && !widget.sending
                  ? Colors.transparent
                  : StockDTheme.sage.withValues(alpha: 0.5),
            ),
          ),
          child: Center(
            child: widget.sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(StockDTheme.sage),
                    ),
                  )
                : Icon(
                    Icons.send_rounded,
                    size: 18,
                    color: _hovered ? StockDTheme.bg : StockDTheme.sage,
                  ),
          ),
        ),
      ),
    );
  }
}
