import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:search_page/search_page.dart';

Future<List<SimpsonsCharacter>> fetchSimpsonsCharacters() async {
  final response = await http.get(Uri.parse(
      'https://api.duckduckgo.com/?q=simpsons+characters&format=json'));

  if (response.statusCode == 200) {
    final list = <SimpsonsCharacter>[];
    final map = jsonDecode(response.body);
    list.addAll((map["RelatedTopics"] as List<dynamic>)
        .map((e) => SimpsonsCharacter.fromJson(e as Map<String, dynamic>)));

    return list;
  } else {
    throw Exception('Failed to load characters');
  }
}

class SimpsonsCharacter {
  final CharacterIcon icon;
  final String name;
  final String details;

  const SimpsonsCharacter({
    required this.icon,
    required this.name,
    required this.details,
  });

  factory SimpsonsCharacter.fromJson(Map<String, dynamic> json) {
    return SimpsonsCharacter(
      icon: json['Icon'] != null
          ? CharacterIcon.fromJson(json['Icon'])
          : const CharacterIcon(url: ""),
      name: json['Text'].split(" - ")[0] ?? "",
      details: json['Text'].split(" - ")[1] ?? "",
    );
  }
}

class CharacterIcon {
  final String url;

  const CharacterIcon({
    required this.url,
  });

  factory CharacterIcon.fromJson(Map<String, dynamic> json) {
    return CharacterIcon(
      url: json['URL'] ?? "",
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Simpsons Characters',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          textTheme: TextTheme(
            titleMedium: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w700,
                fontSize: 18.sp),
            bodyMedium: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 12.sp),
            titleSmall: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w700,
                fontSize: 12.sp),
            bodySmall: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 9.sp),
          ),
        ),
        home: const SearchScreen(),
      );
    });
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<List<SimpsonsCharacter>> futureSimpsonsCharacters;

  @override
  void initState() {
    super.initState();
    futureSimpsonsCharacters = fetchSimpsonsCharacters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simpsons Characters'),
      ),
      body: SizerUtil.deviceType == DeviceType.mobile
          ? buildMobileBody(futureSimpsonsCharacters)
          : buildTabletBody(futureSimpsonsCharacters),
      floatingActionButton: FutureBuilder<List<SimpsonsCharacter>>(
        future: futureSimpsonsCharacters,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FloatingActionButton(
              tooltip: 'Search characters',
              onPressed: () => showSearch(
                context: context,
                delegate: SearchPage(
                  onQueryUpdate: print,
                  items: snapshot.data!,
                  searchLabel: 'Search characters',
                  suggestion: const Center(
                    child: Text('Filter characters by name or description'),
                  ),
                  failure: const Center(
                    child: Text('No character found :('),
                  ),
                  filter: (character) => [
                    character.name,
                    character.details,
                  ],
                  builder: (character) => GestureDetector(
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailsScreen(character: character),
                          ))
                    },
                    child: ListTile(
                      title: Text(character.name,
                          style: Theme.of(context).textTheme.titleSmall),
                      subtitle: Text(character.details,
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ),
                ),
              ),
              child: const Icon(Icons.search),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

FutureBuilder<List<SimpsonsCharacter>> buildMobileBody(
    Future<List<SimpsonsCharacter>> futureSimpsonsCharacters) {
  return FutureBuilder<List<SimpsonsCharacter>>(
    future: futureSimpsonsCharacters,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return ListView(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 10.w),
          children: [
            for (var character in snapshot.data!)
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
                  child: Text(character.name,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                onTap: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailsScreen(character: character),
                      ))
                },
              )
          ],
        );
      } else if (snapshot.hasError) {
        return Text('${snapshot.error}');
      }
      return const Center(child: CircularProgressIndicator());
    },
  );
}

FutureBuilder<List<SimpsonsCharacter>> buildTabletBody(
    Future<List<SimpsonsCharacter>> futureSimpsonsCharacters) {
  return FutureBuilder<List<SimpsonsCharacter>>(
    future: futureSimpsonsCharacters,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return ListView(
          padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 5.w),
          children: [
            for (var character in snapshot.data!)
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
                leading: character.icon.url != ""
                    ? Image.network(
                        "https://duckduckgo.com${character.icon.url}")
                    : Image(
                        height: 20.h,
                        width: 5.w,
                        image: const AssetImage('images/profilepic.png'),
                      ),
                title: Text(character.name,
                    style: Theme.of(context).textTheme.titleSmall),
                subtitle: Text(character.details,
                    style: Theme.of(context).textTheme.bodySmall),
              )
          ],
        );
      } else if (snapshot.hasError) {
        return Text('${snapshot.error}');
      }
      return const Center(child: CircularProgressIndicator());
    },
  );
}

class DetailsScreen extends StatelessWidget {
  final SimpsonsCharacter character;

  const DetailsScreen({required this.character, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simpsons Characters'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            character.icon.url != ""
                ? Image.network("https://duckduckgo.com${character.icon.url}")
                : Image(
                    height: 20.h,
                    width: 20.w,
                    image: const AssetImage('images/profilepic.png'),
                  ),
            SizedBox(height: 3.h),
            Text(character.name,
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 3.h),
            Text(character.details,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
