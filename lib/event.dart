typedef void DataChanged<T>(T changedData);

class Event<T> {
  List<DataChanged<T>> handlers = new List<DataChanged<T>>();
  void add(DataChanged<T> handler) => handlers.add(handler);
  void invoke(T data) => handlers.forEach((h) {h(data);});
}