String? parseDrawingUrl(dynamic value) {
  if (value == null) return null;
  final edges = value['edges'] as List<dynamic>?;
  if (edges == null || edges.isEmpty) return null;
  final node = edges.first['node'] as Map<String, dynamic>?;
  if (node?['media_type'] == 'drawing') {
    return node?['media_url'] as String?;
  }
  return null;
}
