class Company {
  final String name;
  final int established;
  final int employees;
  final String capital;
  final String address;
  final String category;
  final String needs;
  final String country;
  final String imageUrl;
  final String group;
  final String introduction;

  Company({
    required this.name,
    required this.established,
    required this.employees,
    required this.capital,
    required this.address,
    required this.category,
    required this.needs,
    required this.country,
    required this.imageUrl,
    required this.group,
    required this.introduction,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'],
      established: json['established'],
      employees: json['employees'],
      capital: json['capital'],
      address: json['address'],
      category: json['category'],
      needs: json['needs'],
      country: json['country'],
      imageUrl: json['imageUrl'],
      group: json['group'],
      introduction: json['introduction'],
    );
  }
}
