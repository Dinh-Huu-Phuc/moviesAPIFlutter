import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_api_flutter/pages/media_gallery_page.dart';

import '../Model/model.dart';
import 'detail_screen.dart';

class MovieDisplay extends StatefulWidget {
  const MovieDisplay({super.key});

  @override
  State<MovieDisplay> createState() => _MovieDisplayState();
}

int current = 0;

class _MovieDisplayState extends State<MovieDisplay> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      // ✅ BÂY GIỜ BODY SẼ LÀ MỘT STACK LỚN CHỨA MỌI THỨ
      body: Stack(
        children: [
          // LỚP 1: ẢNH NỀN VÀ CAROUSEL
          // Positioned.fill để nó chiếm toàn bộ không gian có sẵn
          Positioned.fill(
            child: Stack(
              children: [
                Image.asset(
                  movieItems[current].image,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.grey.shade50.withOpacity(1),
                          Colors.grey.shade50.withOpacity(1),
                          Colors.grey.shade100.withOpacity(1),
                          Colors.grey.shade100.withOpacity(0.0),
                          Colors.grey.shade100.withOpacity(0.0),
                          Colors.grey.shade100.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Carousel được đặt ở giữa màn hình
                Align(
                  alignment: Alignment.center,
                  child: carousel.CarouselSlider(
                    options: carousel.CarouselOptions(
                      height: 550,
                      viewportFraction: 0.7,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          current = index;
                        });
                      },
                    ),
                    items: movieItems.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final Movie movie = entry.value;
                      return Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(movie: movie),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                // ... (Nội dung card giữ nguyên)
                                width: size.width,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Hero(
                                        tag: movie.id,
                                        child: Container(
                                          height: 350,
                                          width: MediaQuery.of(context).size.width * 0.55,
                                          margin: const EdgeInsets.only(top: 20),
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Image.asset(
                                            movie.image,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        movieItems[index].title,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        movie.director,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // LỚP 2: NÚT BẤM (LUÔN NẰM TRÊN CÙNG)
          // Dùng Align để đặt nút ở dưới cùng
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              // Thêm padding để nút không bị sát cạnh màn hình
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
              child: SizedBox(
                width: double.infinity, // Nút sẽ rộng hết chiều ngang
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MediaGalleryPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 20, 26, 30),
                    padding: const EdgeInsets.symmetric(vertical: 20), // Chỉnh chiều cao nút ở đây
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Tới trang xem phim',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}