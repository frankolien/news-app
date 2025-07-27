import 'package:news_app/models/source_model.dart';

class NewsModel {
  int? id;
  String? author;
  String? title;
  String? subtitle;
  String? description;
  String? status;
  String? type;
  String? publishedAt;
  String? content;
  String? url;
  String? imageUrl;
  Source? source;
  List<Source>? categories;

  NewsModel({
    this.id,
    this.author,
    this.title,
    this.subtitle,
    this.description,
    this.status,
    this.type,
    this.publishedAt,
    this.content,
    this.url,
    this.imageUrl,
    this.source,
    this.categories,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      author: json['author']?.toString(),
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      type: json['type']?.toString(),
      publishedAt: json['published_at']?.toString() ?? json['publishedAt']?.toString(),
      content: json['content']?.toString(),
      url: json['url']?.toString(),
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      source: json['source'] != null ? Source.fromJson(json['source']) : null,
      categories: json['categories'] != null 
          ? (json['categories'] as List).map((e) => Source.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'status': status,
      'type': type,
      'published_at': publishedAt,
      'content': content,
      'url': url,
      'image_url': imageUrl,
      'source': source?.toJson(),
      'categories': categories?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'NewsModel(id: $id, title: $title, author: $author)';
  }
}