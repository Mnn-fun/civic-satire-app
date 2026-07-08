// Type-safe Complaint data model matching MongoDB Atlas / Stitch schema
class Complaint {
  final String id;
  final String title;
  final String description;
  final String rtoCode;
  final String imageUrl;
  final String? ghibliMemeUrl; // Ghibli Art Style Meme illustration for AI Satire Mode
  final String satireText;
  final int upvotes;
  final DateTime createdAt;
  final List<String> comments;

  const Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.rtoCode,
    required this.imageUrl,
    this.ghibliMemeUrl,
    required this.satireText,
    required this.upvotes,
    required this.createdAt,
    this.comments = const [],
  });

  /// Factory constructor mapping incoming Stitch JSON/BSON payloads into Dart objects
  factory Complaint.fromJson(Map<String, dynamic> json) {
    // Robust ID extraction handling raw strings or BSON extended JSON { "$oid": "..." }
    String extractId(dynamic idVal) {
      if (idVal == null) return 'unknown_id';
      if (idVal is String) return idVal;
      if (idVal is Map && idVal.containsKey(r'$oid')) return idVal[r'$oid'].toString();
      return idVal.toString();
    }

    // Robust Date extraction handling ISO strings, BSON { "$date": "..." }, or int timestamps
    DateTime extractDate(dynamic dateVal) {
      if (dateVal == null) return DateTime.now();
      if (dateVal is String) {
        return DateTime.tryParse(dateVal) ?? DateTime.now();
      }
      if (dateVal is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateVal);
      }
      if (dateVal is Map && dateVal.containsKey(r'$date')) {
        final inner = dateVal[r'$date'];
        if (inner is String) return DateTime.tryParse(inner) ?? DateTime.now();
        if (inner is int) return DateTime.fromMillisecondsSinceEpoch(inner);
      }
      return DateTime.now();
    }

    return Complaint(
      id: extractId(json['_id'] ?? json['id']),
      title: json['title']?.toString() ?? 'Untitled Civic Issue',
      description: json['description']?.toString() ?? 'No description provided.',
      rtoCode: json['rto_code']?.toString() ?? json['rtoCode']?.toString() ?? 'MH-01',
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString() ?? 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?auto=format&fit=crop&w=800&q=80',
      ghibliMemeUrl: json['ghibli_meme_url']?.toString() ?? json['ghibliMemeUrl']?.toString(),
      satireText: json['satire_text']?.toString() ?? json['satireText']?.toString() ?? 'Municipal authorities declare this hazard an essential modern art installation.',
      upvotes: (json['upvotes'] is num) ? (json['upvotes'] as num).toInt() : 0,
      createdAt: extractDate(json['created_at'] ?? json['createdAt']),
      comments: (json['comments'] is List)
          ? (json['comments'] as List).map((e) => e.toString()).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'rto_code': rtoCode,
      'image_url': imageUrl,
      if (ghibliMemeUrl != null) 'ghibli_meme_url': ghibliMemeUrl,
      'satire_text': satireText,
      'upvotes': upvotes,
      'created_at': createdAt.toIso8601String(),
      'comments': comments,
    };
  }

  Complaint copyWith({
    String? id,
    String? title,
    String? description,
    String? rtoCode,
    String? imageUrl,
    String? ghibliMemeUrl,
    String? satireText,
    int? upvotes,
    DateTime? createdAt,
    List<String>? comments,
  }) {
    return Complaint(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rtoCode: rtoCode ?? this.rtoCode,
      imageUrl: imageUrl ?? this.imageUrl,
      ghibliMemeUrl: ghibliMemeUrl ?? this.ghibliMemeUrl,
      satireText: satireText ?? this.satireText,
      upvotes: upvotes ?? this.upvotes,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? this.comments,
    );
  }
}
