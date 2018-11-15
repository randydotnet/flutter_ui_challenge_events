import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: MyHomePage(title: 'Events'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List<ViewModel> models = [
    ViewModel(
      "assets/asia.jpg",
      0.0,
      1.0,
      0.0,
    ),
    ViewModel(
      "assets/man.jpg",
      70,
      0.6,
      30.0,
    ),
    ViewModel(
      "assets/trees.jpg",
      140,
      0.3,
      60.0,
    )
  ];

  List<Tween<double>> offsetTweens = [];
  List<Tween<double>> sizeOffsetTweens = [];
  List<Tween<double>> opacityTweens = [];

  AnimationController _swipeController;

  int position = 0;
  Direction direction = Direction.NONE;

  @override
  void initState() {
    _swipeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250))
          ..addListener(() {
            setState(() {
              for (var i = 0; i < models.length - position; ++i) {
                models[position + i].offset =
                    offsetTweens[i].evaluate(_swipeController);
                models[position + i].sizeOffset =
                    sizeOffsetTweens[i].evaluate(_swipeController);
                models[position + i].opacity =
                    opacityTweens[i].evaluate(_swipeController);
              }
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              position += 1;
            }
          });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0.0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            EventTitle(),
            GestureDetector(
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              child: Stack(children: _buildStack()),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStack() {
    return models
        .map((model) {
          return EventCard(
            image: model.image,
            opacity: model.opacity,
            offset: model.offset,
            sizeOffset: model.sizeOffset,
          );
        })
        .toList()
        .reversed
        .toList();
  }

  _onDragStart(DragStartDetails details) {}

  _onDragUpdate(DragUpdateDetails details) {
    if (direction == Direction.NONE) {
      if (details.delta.dx > 0) {
        direction = Direction.BACK;
        position -= 1;
      } else {
        direction = Direction.AWAY;
      }
    }

    setState(() {
      for (var i = position; i < models.length; ++i) {
        final model = models[i];

        if (i == position) {
          model.opacity = 1.0;
          model.offset += details.delta.dx;
          model.sizeOffset -= details.delta.dx / 12;
          continue;
        }

        final distance = details.delta.dx / (i * 6);
        model.offset += distance;
        model.sizeOffset += distance;
        model.opacity = (model.opacity + (model.offset.abs() / (i * 5000)))
            .clamp(0.0, 1.0 / i);
      }
    });
  }

  _onDragEnd(DragEndDetails details) {
    offsetTweens.clear();
    sizeOffsetTweens.clear();
    opacityTweens.clear();

    for (var i = position; i < models.length; ++i) {
      offsetTweens.add(Tween(
          begin: models[i].offset,
          end: i == position ? -600.0 : 70.0 * (i - position - 1)));
      sizeOffsetTweens.add(Tween(
          begin: models[i].sizeOffset,
          end: i == position ? 0 : 30.0 * (i - position - 1)));
      opacityTweens.add(Tween(
          begin: models[i].opacity,
          end: i == position ? 0 : 1 - (0.3 * (i - position - 1))));
    }
    _swipeController.forward(from: 0.0);
    direction = Direction.NONE;
  }

  @override
  void reassemble() {
    models = [
      ViewModel(
        "assets/asia.jpg",
        0.0,
        1.0,
        0.0,
      ),
      ViewModel(
        "assets/man.jpg",
        70,
        0.6,
        30.0,
      ),
      ViewModel(
        "assets/trees.jpg",
        140,
        0.3,
        60.0,
      )
    ];

    super.reassemble();
  }
}

class ViewModel {
  String image;
  double offset = 0.0;
  double opacity = 1.0;
  double sizeOffset = 0.0;

  ViewModel(this.image, this.offset, this.opacity, this.sizeOffset);
}

class EventTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[Text("Fashion Talk"), Text("Kyiv")],
            ),
          ),
          Text("Nov 24, 2017")
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String image;
  final bool interested;

  final double opacity;
  final double offset;
  final double sizeOffset;

  final Size size = const Size(280, 400);

  const EventCard({
    Key key,
    this.image,
    this.interested,
    this.offset = 0.0,
    this.opacity = 1.0,
    this.sizeOffset = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(40 + offset, sizeOffset / 2),
      child: SizedBox(
        width: size.width - sizeOffset,
        height: size.height - sizeOffset,
        child: Opacity(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),
          opacity: opacity,
        ),
      ),
    );
  }
}

enum Direction { AWAY, BACK, NONE }
