import 'package:flutter/material.dart';

class Movie {
  int id;
  String title;
  String image;
  String director;
  String rating;
  String duration;
  String price;

  Movie({
    required this.id,
    required this.title,
    required this.image,
    required this.director,
    required this.rating,
    required this.duration,
    required this.price,
  });

  // ✅ BƯỚC 1: THÊM PHẦN CODE NÀY VÀO
  // Factory constructor để tạo Movie từ JSON
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'], // Đọc 'id' từ JSON
      title: json['title'] ?? '', // Thêm ?? '' để tránh lỗi null
      image: json['thumbnailUrl'] ?? '', // API của bạn dùng 'thumbnailUrl'
      director: json['genre'] ?? 'N/A', // API không có director, dùng tạm genre
      rating: json['year']?.toString() ?? 'N/A', // API không có rating, dùng tạm year
      duration: 'N/A', // API không có duration
      price: 'N/A',    // API không có price
    );
  }
}


final List<Movie> movieItems = [
  Movie(
    id: 1,
    title: 'Liễu Thần',
    image: 'assets/images/lieuthan.jpg', // <-- Đã đổi
    director: 'Tiên Vương Liễu Thần',
    rating: '5.0',
    duration: "2h:42m",
    price: "250"
  ),
  Movie(
    id: 2,
    title: 'Liễu Thần',
    image: 'assets/images/lieuthan4.jpg', // <-- Đã đổi
    director: ' Tiên Vương Liễu Thần',
    rating: '5.0',
    duration: "2h:10m",
      price: "200"
  ),
  Movie(
    id: 3,
   title: 'Liễu Thần',
    image: 'assets/images/lieuthan2.jpg', // <-- Đã đổi
    director: 'Tiên Vương Liễu Thần',
    rating: '4.6',
    duration: "1h:45m",
    price: "100"
  ),
  Movie(
    id: 4,
    title: 'Liễu Thần',
    image: 'assets/images/lieuthan3.jpg', // <-- Đã đổi
    director: 'Tiên Vương Liễu Thần',
    rating: '5.0',
    duration: "2h:42m",
    price: "50"
  ),
  Movie(
    id: 5,
    title: 'Thạch Hạo',
    image: 'assets/images/thachhao.jpg', // <-- Đã đổi
    director: 'Chuẩn Tiên Đế Hoang',
    rating: '4.0',
    duration: "1h:22m",
    price: "150"
  ),
  Movie(
    id: 6,
    title: 'Thạch Hạo',
    image: 'assets/images/thachhao1.jpg', // <-- Đã đổi
    director: 'Hoang Thiên Đế',
    rating: '4.0',
    duration: "1h:22m",
    price: "150"
  ),
  Movie(
    id: 7,
    title: 'Liễu Thần',
    image: 'assets/images/image1.jpg', // <-- Đã đổi
    director: 'Hoang Thiên Đế',
    rating: '4.0',
    duration: "1h:22m",
    price: "150"
  ),
  Movie(
    id: 8,
    title: 'Liễu Thần',
    image: 'assets/images/image2.jpg', // <-- Đã đổi
    director: 'Hoang Thiên Đế',
    rating: '4.0',
    duration: "1h:22m",
    price: "150"
  ),
  Movie(
    id: 9,
    title: 'Liễu Thần',
    image: 'assets/images/image3.jpg', // <-- Đã đổi
    director: 'Hoang Thiên Đế',
    rating: '4.0',
    duration: "1h:22m",
    price: "150"
  ),
  Movie(
    id: 10,
    title: 'Liễu Thần',
    image: 'assets/images/image4.jpg', // <-- Đã đổi
    director: 'Hoang Thiên Đế',
    rating: '4.0',
    duration: "1h:22m",
    price: "150"
  ),
  Movie(
    id: 11,
    title: 'Thanh Y',
    image: 'assets/images/image5.jpg', // <-- Đã đổi
    director: 'Hoang Thiên Đế',
    rating: '4.0',
    duration: "1h:22m",
    price: "150"
  ),
];
List<String> time = [
  '8am',
  '11am',
  '1pm',
  '3pm',
  '6pm',
  '8pm'
];
List<Color> colors = [
  Colors.green,
  Colors.black,
  Colors.purple,
  Colors.amber,
  Colors.black,
  Colors.deepPurple,
  Colors.yellow,
];