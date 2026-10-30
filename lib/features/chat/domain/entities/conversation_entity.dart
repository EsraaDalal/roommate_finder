
class ConversationEntity {
  final String id;
  final List<String> participantIds;
  final String? listingId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;

  const ConversationEntity({
    required this.id,
    required this.participantIds,
    this.listingId,
    this.lastMessage,
    this.lastMessageAt,
    this.createdAt,
  });

  bool contains(String userId) {
    return participantIds.contains(userId);
  }

  String? otherParticipant(String userId) {
    for (final participantId in participantIds) {
      if (participantId != userId) {
        return participantId;
      }
    }

    return null;
  }
}
