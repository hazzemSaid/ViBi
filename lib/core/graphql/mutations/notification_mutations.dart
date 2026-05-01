class NotificationMutations {
  /// Mark notification as read
  static const String markNotificationRead = r'''
    mutation MarkNotificationRead($notificationId: UUID!) {
      updateNotificationsCollection(
        filter: { id: { eq: $notificationId } }
        set: { is_read: true }
      ) {
        records {
          id
          is_read
        }
      }
    }
  ''';

  /// Mark all notifications as read
  static const String markAllNotificationsRead = r'''
    mutation MarkAllNotificationsRead($userId: UUID!) {
      updateNotificationsCollection(
        filter: { 
          user_id: { eq: $userId }
          is_read: { eq: false }
        }
        set: { is_read: true }
      ) {
        records {
          id
        }
      }
    }
  ''';
}
