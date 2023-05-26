import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class Movie {
  final String name;
  final String director;
  final String posterImage;

  Movie({required this.name, required this.director, required this.posterImage});
}

class MovieController extends GetxController {
  final movies = <Movie>[].obs;

  void addMovie(String name, String director, String posterImage) {
    movies.add(Movie(name: name, director: director, posterImage: posterImage));
  }

  void removeMovie(int index) {
    movies.removeAt(index);
  }
}

class MovieForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _posterImageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Movie'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter the movie name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _directorController,
              decoration: InputDecoration(labelText: 'Director'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter the director';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _posterImageController,
              decoration: InputDecoration(labelText: 'Poster Image URL'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter the poster image URL';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final movieController = Get.find<MovieController>();
              movieController.addMovie(
                _nameController.text,
                _directorController.text,
                _posterImageController.text,
              );
              Get.back();
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

class MyApp extends StatelessWidget {
  final MovieController movieController = Get.put(MovieController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Movie Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'),
      ],
      home: Scaffold(
        appBar: AppBar(title: Text('Movie Tracker')),
        body: Obx(
              () => ListView.builder(
            itemCount: movieController.movies.length,
            itemBuilder: (context, index) {
              final movie = movieController.movies[index];
              return ListTile(
                leading: CachedNetworkImage(
                  imageUrl: movie.posterImage,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                title: Text(movie.name),
                subtitle: Text(movie.director),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => movieController.removeMovie(index),
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.dialog(MovieForm()),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
