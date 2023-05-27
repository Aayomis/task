import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MovieAdapter());
  await Hive.openBox('movies');
  runApp(MyApp());
}

class Movie {
  final String name;
  final String director;
  final String posterImage;

  Movie({required this.name, required this.director, required this.posterImage});
}

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final typeId = 0;

  @override
  Movie read(BinaryReader reader) {
    return Movie(
      name: reader.readString(),
      director: reader.readString(),
      posterImage: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.director);
    writer.writeString(obj.posterImage);
  }
}

class MovieController extends GetxController {
  final movies = <Movie>[].obs;

  void addMovie(String name, String director, String posterImage) {
    final movie = Movie(
      name: name,
      director: director,
      posterImage: posterImage,
    );
    final moviesBox = Hive.box('movies');
    moviesBox.add(movie);
    fetchMovies();
  }

  void deleteMovie(int index) {
    final moviesBox = Hive.box('movies');
    moviesBox.deleteAt(index);
    fetchMovies();
  }

  void fetchMovies() {
    final moviesBox = Hive.box('movies');
    movies.assignAll(moviesBox.values.toList().cast<Movie>());
  }
}

class MovieForm extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _posterImageController = TextEditingController();

  void _addMovie(MovieController controller) {
    final name = _nameController.text;
    final director = _directorController.text;
    final posterImage = _posterImageController.text;
    controller.addMovie(name, director, posterImage);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MovieController>();

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      title: Text('Add Movie'),
      content: SingleChildScrollView(
        child: Form(
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
      ),
      actions: [
        TextButton(

          onPressed: () => Get.back(),
          child: const Text('Cancel',
            style: TextStyle(
              color: Colors.redAccent
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent, // Set the primary color
          ),
          onPressed: () => _addMovie(controller),
          child: Text('Save'),
        ),
      ],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Tracker',
      theme: ThemeData(primarySwatch: Colors.red),
      translations: MovieAppTranslations(),
      locale: Locale('en'), // Set your desired locale
      fallbackLocale: Locale('en'),
      home: MovieList(),
    );
  }
}

class MovieList extends StatelessWidget {
  final controller = Get.put(MovieController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Tracker'),
      ),
      body: Obx(
            () => ListView.builder(
          itemCount: controller.movies.length,
          itemBuilder: (context, index) {
            final movie = controller.movies[index];
            return ListTile(
              title: Text(movie.name),
              subtitle: Text(movie.director),
              leading: Image.network(movie.posterImage,
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return Icon(Icons.error); // Replace with your custom error UI
                },

              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  controller.deleteMovie(index);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.dialog(MovieForm());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class MovieAppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      'title': 'Movie Tracker',
      'add_movie': 'Add Movie',
      'cancel': 'Cancel',
      'save': 'Save',
      'name': 'Name',
      'director': 'Director',
      'poster_image_url': 'Poster Image URL',
    },
  };
}
