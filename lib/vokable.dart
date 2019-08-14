class Vokabel {
  String source;
  String target;
  int correct = 0;
  int wrong = 0;
  bool showTarget = false;

  Vokabel(this.source, this.target);
  Vokabel.fromDynamic(dynamic word) {
    source = word["src"];
    target = word["dest"];
    correct = word["c"] ?? 0;
    wrong = word["w"] ?? 0;
    showTarget = word["st"] ?? false;
  }

  toJson() {
    return  {
      "src": source,
      "dest": target,
      "c": correct,
      "w": wrong,
      "st": showTarget,
    };
  }
}

