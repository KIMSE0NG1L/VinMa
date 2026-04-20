Map<String, String>? imageRequestHeaders(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return null;
  }

  if (uri.host.contains('ngrok-free.dev') || uri.host.contains('ngrok-free.app')) {
    return const {'ngrok-skip-browser-warning': 'true'};
  }

  return null;
}
