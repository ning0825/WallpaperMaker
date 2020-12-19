class FontFileList {
  List<Results> results;

  FontFileList({this.results});

  FontFileList.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = new List<Results>();
      json['results'].forEach((v) {
        results.add(new Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.results != null) {
      data['results'] = this.results.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String mimeType;
  String updatedAt;
  String key;
  String name;
  String objectId;
  String createdAt;
  String url;
  String provider;
  MetaData metaData;
  String bucket;

  Results(
      {this.mimeType,
      this.updatedAt,
      this.key,
      this.name,
      this.objectId,
      this.createdAt,
      this.url,
      this.provider,
      this.metaData,
      this.bucket});

  Results.fromJson(Map<String, dynamic> json) {
    mimeType = json['mime_type'];
    updatedAt = json['updatedAt'];
    key = json['key'];
    name = json['name'];
    objectId = json['objectId'];
    createdAt = json['createdAt'];
    url = json['url'];
    provider = json['provider'];
    metaData = json['metaData'] != null
        ? new MetaData.fromJson(json['metaData'])
        : null;
    bucket = json['bucket'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mime_type'] = this.mimeType;
    data['updatedAt'] = this.updatedAt;
    data['key'] = this.key;
    data['name'] = this.name;
    data['objectId'] = this.objectId;
    data['createdAt'] = this.createdAt;
    data['url'] = this.url;
    data['provider'] = this.provider;
    if (this.metaData != null) {
      data['metaData'] = this.metaData.toJson();
    }
    data['bucket'] = this.bucket;
    return data;
  }
}

class MetaData {
  int size;
  String owner;

  MetaData({this.size, this.owner});

  MetaData.fromJson(Map<String, dynamic> json) {
    size = json['size'];
    owner = json['owner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['size'] = this.size;
    data['owner'] = this.owner;
    return data;
  }
}
