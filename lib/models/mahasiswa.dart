class Mahasiswa {
  final String nim;
  final String nama;
  var nilai;

  Mahasiswa({
    required this.nim,
    required this.nama,
    required this.nilai,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    return Mahasiswa(
      nim: json['nim'],
      nama: json['nama'],
      nilai: json['nilai'],
    );
  }
}
