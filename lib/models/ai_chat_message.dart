class AIChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;

  final bool pending;
  final bool isError;

  const AIChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
    this.pending = false,
    this.isError = false,
  });

  AIChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? createdAt,
    bool? pending,
    bool? isError,
  }) {
    return AIChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      createdAt: createdAt ?? this.createdAt,
      pending: pending ?? this.pending,
      isError: isError ?? this.isError,
    );
  }
}