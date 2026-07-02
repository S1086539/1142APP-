import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/ai_chat_message.dart';

import '../../providers/ai_chat_provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/confirmed_trip_provider.dart';

import '../../services/trip_query_parser.dart';
import '../../services/trip_preview_parser.dart';

import '../../widgets/ai_trip/destination_weather_card.dart';
import '../../widgets/ai_trip/trip_preview_card.dart';

import '../../widgets/common/app_snack_bar.dart';

import '../ai_stylist/ai_stylist_page.dart';

class AITripPage extends ConsumerStatefulWidget {
  const AITripPage({super.key});

  @override
  ConsumerState<AITripPage> createState() => _AITripPageState();
}

class _AITripPageState extends ConsumerState<AITripPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _hiddenDestinationCity;

  static const List<String> _examples = [
    '我想去花蓮玩兩天一夜，幫我安排適合好天氣的行程。',
    '幫我安排宜蘭一日親子旅遊，如果會下雨要有室內備案。',
    '我想去臺南吃美食，幫我安排一天的散步路線。',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();

    if (trimmed.isEmpty) {
      AppSnackBar.show(
        context,
        message: '請先輸入旅遊需求',
        type: AppSnackType.warning,
      );
      return;
    }

    final isReplying = ref.read(aiChatProvider).any((m) => m.pending);

    if (isReplying) {
      AppSnackBar.show(
        context,
        message: 'AI 正在回覆中，請稍等一下',
        type: AppSnackType.info,
      );
      return;
    }

    setState(() {
      _hiddenDestinationCity = null;
    });

    ref.read(confirmedTripProvider.notifier).clear();

    _controller.clear();

    await ref.read(aiChatProvider.notifier).sendUserMessage(trimmed);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiChatProvider);
    final isReplying = messages.any((m) => m.pending);
    final hasUserMessage = messages.any((m) => m.isUser);
    final confirmedTrip = ref.watch(confirmedTripProvider);

    final latestUserText = ref.read(aiChatProvider.notifier).latestUserText;

    final userTexts = messages
        .where((message) => message.isUser)
        .map((message) => message.text);

    final destinationCity = TripQueryParser.parseLatestDestinationCityFromTexts(
      userTexts,
    );

    final shouldShowDestinationWeather =
        destinationCity != null && destinationCity != _hiddenDestinationCity;

    final destinationWeatherAsync = shouldShowDestinationWeather
        ? ref.watch(weatherProvider(destinationCity))
        : null;

    final latestAIReplyText =
        ref.read(aiChatProvider.notifier).latestAIReplyText;

    final tripPreview = isReplying
        ? null
        : TripPreviewParser.build(
      destinationCity: destinationCity,
      latestUserText: latestUserText,
      latestAIText: latestAIReplyText,
    );

    final isTripConfirmed = tripPreview != null &&
        confirmedTrip?.signature == tripPreview.signature;

    ref.listen<List<AIChatMessage>>(
      aiChatProvider,
          (previous, next) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFF08203E),
      appBar: AppBar(
        title: const Text(
          'AI 行程規劃',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              tooltip: '清除對話',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () {
                setState(() {
                  _hiddenDestinationCity = null;
                });

                ref.read(aiChatProvider.notifier).clearChat();
                ref.read(confirmedTripProvider.notifier).clear();

                AppSnackBar.show(
                  context,
                  message: 'AI 行程對話已重置',
                  type: AppSnackType.info,
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(0, 6, 0, 12),
              children: [
                if (!hasUserMessage) ...[
                  _buildExamplePrompts(),
                  const SizedBox(height: 10),
                ],

                if (destinationCity != null &&
                    destinationWeatherAsync != null)
                  destinationWeatherAsync.when(
                    data: (weather) => DestinationWeatherCard(
                      cityName: destinationCity,
                      weather: weather,
                      onClosePressed: () {
                        setState(() {
                          _hiddenDestinationCity = destinationCity;
                        });
                      },
                    ),
                    loading: () => DestinationWeatherCard(
                      cityName: destinationCity,
                      isLoading: true,
                      onClosePressed: () {
                        setState(() {
                          _hiddenDestinationCity = destinationCity;
                        });
                      },
                    ),
                    error: (_, __) => DestinationWeatherCard(
                      cityName: destinationCity,
                      hasError: true,
                      onClosePressed: () {
                        setState(() {
                          _hiddenDestinationCity = destinationCity;
                        });
                      },
                    ),
                  ),

                if (tripPreview != null)
                  TripPreviewCard(
                    preview: tripPreview,
                    isConfirmed: isTripConfirmed,
                    onConfirmPressed: () {
                      ref.read(confirmedTripProvider.notifier).confirm(tripPreview);

                      AppSnackBar.show(
                        context,
                        message: '已確認這份行程，之後可用於 AI Stylist 穿搭建議',
                        type: AppSnackType.success,
                      );
                    },
                    onStylistPressed: () {
                      if (!isTripConfirmed) {
                        AppSnackBar.show(
                          context,
                          message: '請先確認行程，再產生穿搭建議',
                          type: AppSnackType.warning,
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AIStylistPage(),
                        ),
                      );
                    },
                  ),

                ...messages.map(
                      (message) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ChatBubble(
                      message: message,
                      onRetry: message.isError
                          ? () {
                        ref
                            .read(aiChatProvider.notifier)
                            .retryLastFailedMessage();
                      }
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isReplying)
            _buildGeneratingStatusBar(destinationCity),

          _buildInputBar(isReplying),
        ],
      ),
    );
  }

  Widget _buildExamplePrompts() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _examples.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final example = _examples[index];

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => _sendMessage(example),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                example.length > 18
                    ? '${example.substring(0, 18)}...'
                    : example,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGeneratingStatusBar(String? destinationCity) {
    final text = destinationCity == null
        ? 'AI 正在整理你的旅遊需求...'
        : 'AI 正在根據 $destinationCity 天氣規劃行程...';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.lightBlueAccent.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isReplying) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          14,
          10,
          14,
          keyboardOpen ? 14 : 18,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF08203E).withValues(alpha: 0.96),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !isReplying,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: isReplying ? null : _sendMessage,
                decoration: InputDecoration(
                  hintText: isReplying
                      ? 'AI 正在回覆中...'
                      : '例如：我想去花蓮玩兩天一夜',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.10),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 48,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.lightBlueAccent,
                  foregroundColor: Colors.black87,
                  disabledBackgroundColor:
                  Colors.white.withValues(alpha: 0.14),
                  disabledForegroundColor: Colors.white38,
                  shape: const CircleBorder(),
                ),
                onPressed: isReplying
                    ? null
                    : () => _sendMessage(_controller.text),
                child: isReplying
                    ? const SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.send_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final AIChatMessage message;
  final VoidCallback? onRetry;

  const _ChatBubble({
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.lightBlueAccent.withValues(alpha: 0.9)
              : message.isError
              ? Colors.redAccent.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.11),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          border: Border.all(
            color: isUser
                ? Colors.lightBlueAccent.withValues(alpha: 0.7)
                : message.isError
                ? Colors.redAccent.withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: _buildBubbleContent(isUser),
      ),
    );
  }

  Widget _buildBubbleContent(bool isUser) {
    if (message.pending && message.text.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 17,
            height: 17,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.lightBlueAccent,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'AI 正在思考中...',
            style: TextStyle(
              fontSize: 14,
              color: isUser ? Colors.black87 : Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.text,
          style: TextStyle(
            fontSize: 14,
            height: 1.55,
            color: isUser ? Colors.black87 : Colors.white,
            fontWeight: isUser ? FontWeight.w600 : FontWeight.w400,
          ),
        ),

        if (message.pending) ...[
          const SizedBox(height: 8),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.lightBlueAccent,
                ),
              ),
              SizedBox(width: 7),
              Text(
                '生成中',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ],

        if (message.isError) ...[
          const SizedBox(height: 8),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 16,
                color: Colors.redAccent,
              ),
              SizedBox(width: 6),
              Text(
                '請稍後再試',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          if (onRetry != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 16,
              ),
              label: const Text('重試'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}