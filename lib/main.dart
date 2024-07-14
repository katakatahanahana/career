import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Search App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: MainScreen(),
    );
  }
}

class Job {
  final String title;
  final String genre;
  final String description;
  final String detailedDescription;
  bool isBookmarked;

  Job({
    required this.title,
    required this.genre,
    required this.description,
    required this.detailedDescription,
    this.isBookmarked = false,
  });
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Job> jobs = [];
  List<Job> filteredJobs = [];
  bool isLoading = true;
  String selectedGenre = 'すべて';

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    try {
      final rawData = await rootBundle.loadString('assets/jobs.csv');

      List<List<dynamic>> listData = CsvToListConverter(
        eol: '\n',
        fieldDelimiter: ',',
      ).convert(rawData);

      setState(() {
        jobs = listData
            .skip(1)
            .map((row) {
              if (row.length >= 4) {
                return Job(
                  title: row[0].toString(),
                  genre: row[1].toString(),
                  description: row[2].toString(),
                  detailedDescription: row[3].toString(),
                );
              } else {
                return null;
              }
            })
            .whereType<Job>()
            .toList();
        filteredJobs = jobs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterJobsByGenre(String? genre) {
    setState(() {
      selectedGenre = genre ?? 'すべて';
      if (selectedGenre == 'すべて') {
        filteredJobs = jobs;
      } else {
        filteredJobs = jobs.where((job) => job.genre == selectedGenre).toList();
      }
    });
  }

  List<Widget> _widgetOptions() => [
        JobListScreen(
            jobs: filteredJobs,
            onBookmarkToggle: _toggleBookmark,
            selectedGenre: selectedGenre,
            onGenreChanged: _filterJobsByGenre),
        QuizScreen(),
        BookmarkScreen(
            jobs: jobs.where((job) => job.isBookmarked).toList(),
            onBookmarkToggle: _toggleBookmark),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleBookmark(Job job) {
    setState(() {
      job.isBookmarked = !job.isBookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: _widgetOptions()[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tag_faces),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        onTap: _onItemTapped,
      ),
    );
  }
}

//職業一覧画面
class JobListScreen extends StatelessWidget {
  final List<Job> jobs;
  final Function(Job) onBookmarkToggle;
  final String selectedGenre;
  final void Function(String?) onGenreChanged;

  JobListScreen({
    required this.jobs,
    required this.onBookmarkToggle,
    required this.selectedGenre,
    required this.onGenreChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[100],
        title: Center(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.0),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: DropdownButton<String>(
              isDense: true,
              value: selectedGenre,
              items: <String>[
                'すべて',
                '公共安全',
                '医療',
                '教育',
                '法律',
                '技術',
                'クリエイティブ',
                'サービス',
                'メディア',
                '研究',
                '交通',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onGenreChanged,
              underline: Container(),
              dropdownColor: Colors.white,
              icon: Icon(Icons.arrow_drop_down, color: Colors.black),
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.yellow[100],
      body: ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: SizedBox(
              height: 100,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailScreen(job: job),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                job.description,
                                style: TextStyle(fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            job.isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: job.isBookmarked ? Colors.pink : null,
                          ),
                          onPressed: () {
                            onBookmarkToggle(job);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class JobDetailScreen extends StatelessWidget {
  final Job job;

  JobDetailScreen({required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: Text(job.title),
          backgroundColor: Colors.yellow[100],
          leading: IconButton(
            icon: Icon(Icons.arrow_circle_left_outlined),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      backgroundColor: Colors.yellow[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              job.description,
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16),
            Text(
              job.detailedDescription,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

//クイズ画面
class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  Map<String, int> _genreScores = {};

  List<Map<String, Object>> _questions = [
    {
      'question': 'あなたはどのような作業が得意ですか？',
      'answers': [
        {'text': '技術的な問題を解決する', 'type': '技術'},
        {'text': '人々とコミュニケーションをとる', 'type': 'サービス'},
        {'text': '新しいアイデアを考える', 'type': 'クリエイティブ'},
        {'text': '体力を使う作業', 'type': '公共安全'},
        {'text': '細かい作業やデータ分析', 'type': '研究'},
      ],
    },
    {
      'question': 'あなたの性格に最も近いものは？',
      'answers': [
        {'text': '論理的', 'type': '技術'},
        {'text': '社交的', 'type': 'サービス'},
        {'text': '創造的', 'type': 'クリエイティブ'},
        {'text': '真面目', 'type': '法律'},
        {'text': '探究心が強い', 'type': '研究'},
      ],
    },
    {
      'question': 'あなたが興味を持っている分野は？',
      'answers': [
        {'text': '医療・健康', 'type': '医療'},
        {'text': '法律・正義', 'type': '法律'},
        {'text': '建築・デザイン', 'type': 'クリエイティブ'},
        {'text': '教育・子ども', 'type': '教育'},
        {'text': '科学・研究', 'type': '研究'},
      ],
    },
    {
      'question': 'あなたはリーダーシップを発揮するタイプですか？',
      'answers': [
        {'text': 'はい', 'type': 'サービス'},
        {'text': 'いいえ', 'type': '技術'},
      ],
    },
    {
      'question': 'チームで働くことが好きですか？',
      'answers': [
        {'text': 'はい', 'type': 'サービス'},
        {'text': 'いいえ', 'type': '技術'},
      ],
    },
    {
      'question': 'どのような環境で働きたいですか？',
      'answers': [
        {'text': 'オフィス', 'type': '技術'},
        {'text': '屋外', 'type': '公共安全'},
        {'text': '室内で静かに', 'type': '研究'},
        {'text': '人と接する', 'type': 'サービス'},
        {'text': '交通機関で移動', 'type': '交通'},
      ],
    },
    {
      'question': '問題が発生した時、あなたはどうしますか？',
      'answers': [
        {'text': '自分で解決策を考える', 'type': '技術'},
        {'text': 'チームと協力して解決する', 'type': 'サービス'},
        {'text': 'クリエイティブなアプローチを試みる', 'type': 'クリエイティブ'},
        {'text': 'ルールに従って解決する', 'type': '法律'},
      ],
    },
    {
      'question': 'あなたは何を楽しんでいますか？',
      'answers': [
        {'text': '新しい技術を学ぶこと', 'type': '技術'},
        {'text': '人々を助けること', 'type': '医療'},
        {'text': '創造的な活動', 'type': 'クリエイティブ'},
        {'text': '分析と研究', 'type': '研究'},
        {'text': '教えること', 'type': '教育'},
      ],
    },
    {
      'question': 'ストレスの多い状況で、あなたはどう反応しますか？',
      'answers': [
        {'text': '冷静に分析し、解決策を見つける', 'type': '技術'},
        {'text': '他人と協力して乗り越える', 'type': 'サービス'},
        {'text': 'ストレスを創造的に発散する', 'type': 'クリエイティブ'},
        {'text': 'ルールや手順に従う', 'type': '法律'},
      ],
    },
    {
      'question': 'あなたはどのように問題を解決しますか？',
      'answers': [
        {'text': 'ロジカルに解決', 'type': '技術'},
        {'text': '創造的に解決', 'type': 'クリエイティブ'},
        {'text': 'チームで解決', 'type': 'サービス'},
        {'text': '一人で解決', 'type': '研究'},
      ],
    },
    {
      'question': 'あなたは公共の安全を守る役割に興味がありますか？',
      'answers': [
        {'text': 'はい', 'type': '公共安全'},
        {'text': 'いいえ', 'type': '技術'},
      ],
    },
    {
      'question': 'あなたは医療分野に興味がありますか？',
      'answers': [
        {'text': 'はい', 'type': '医療'},
        {'text': 'いいえ', 'type': '教育'},
      ],
    },
    {
      'question': 'あなたは交通機関の管理や運転に興味がありますか？',
      'answers': [
        {'text': 'はい', 'type': '交通'},
        {'text': 'いいえ', 'type': '技術'},
      ],
    },
  ];

  void _answerQuestion(String type) {
    setState(() {
      if (_genreScores.containsKey(type)) {
        _genreScores[type] = _genreScores[type]! + 1;
      } else {
        _genreScores[type] = 1;
      }

      _currentQuestionIndex++;
    });
  }

  String _getRecommendedGenre() {
    String recommendedGenre = _genreScores.keys.first;
    int maxScore = _genreScores.values.first;

    _genreScores.forEach((type, score) {
      if (score > maxScore) {
        recommendedGenre = type;
        maxScore = score;
      }
    });

    return recommendedGenre;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        backgroundColor: Colors.yellow[100],
        // title: Center(child: Text('適性診断クイズ')),
      ),
      body: _currentQuestionIndex < _questions.length
          ? Quiz(
              question: _questions[_currentQuestionIndex]['question'] as String,
              answers: (_questions[_currentQuestionIndex]['answers']
                      as List<Map<String, Object>>)
                  .map((answer) => Answer(
                        answerText: answer['text'] as String,
                        onTap: () => _answerQuestion(answer['type'] as String),
                      ))
                  .toList(),
            )
          : ResultScreen(
              recommendedGenre: _getRecommendedGenre(),
              onRestart: () {
                setState(() {
                  _currentQuestionIndex = 0;
                  _genreScores = {};
                });
              },
            ),
    );
  }
}

class Quiz extends StatelessWidget {
  final String question;
  final List<Widget> answers;

  Quiz({required this.question, required this.answers});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            question,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ...answers,
        ],
      ),
    );
  }
}

class Answer extends StatelessWidget {
  final String answerText;
  final VoidCallback onTap;

  Answer({required this.answerText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(vertical: 20),
        ),
        onPressed: onTap,
        child: Text(
          answerText,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final String recommendedGenre;
  final VoidCallback onRestart;

  ResultScreen({
    required this.recommendedGenre,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'あなたの適している職業は...',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            recommendedGenre,
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            onPressed: onRestart,
            child: Text(
              'もう一度診断する',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//ブックマーク画面
class BookmarkScreen extends StatelessWidget {
  final List<Job> jobs;
  final Function(Job) onBookmarkToggle;

  BookmarkScreen({required this.jobs, required this.onBookmarkToggle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[100],
        // title: Center(child: Text('ブックマーク')),
      ),
      backgroundColor: Colors.yellow[100],
      body: jobs.isEmpty
          ? Center(child: Text('ブックマークした職業はありません'))
          : ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: SizedBox(
                    height: 100,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobDetailScreen(job: job),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      job.description,
                                      style: TextStyle(fontSize: 14),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.bookmark, color: Colors.pink),
                                onPressed: () {
                                  onBookmarkToggle(job);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
