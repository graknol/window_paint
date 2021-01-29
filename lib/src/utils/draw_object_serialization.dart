import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';

List<dynamic> drawObjectsToJSON(List<DrawObject> objects) => objects
    .map((o) => {
          't': o.adapter.typeId,
          'd': o.toJSON(),
        })
    .toList();

List<DrawObject> drawObjectsFromJSON(
    List encoded, List<DrawObjectAdapter> adapters) {
  final adaptersMap = Map<String, DrawObjectAdapter>.fromIterable(
    adapters,
    key: (a) => a.typeId,
  );
  return encoded
      .map((e) {
        final typeId = e['t'] as String;
        final adapter = adaptersMap[typeId];
        return adapter?.fromJSON(e['d'] as Map);
      })
      .where((o) => o != null)
      .cast<DrawObject>()
      .toList();
}
