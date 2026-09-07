/// Um modelo de IA cadastrado pelo usuário para um provedor, com
/// temperatura opcional (vazia = usa o padrão da API).
class ModelConfig {
  const ModelConfig({required this.name, this.temperature});

  factory ModelConfig.fromJson(Map<String, dynamic> json) => ModelConfig(
        name: json['name'] as String,
        temperature: (json['temperature'] as num?)?.toDouble(),
      );

  final String name;
  final double? temperature;

  Map<String, dynamic> toJson() => {'name': name, 'temperature': temperature};
}
