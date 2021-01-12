import 'package:example/custom_radio_controller.dart';
import 'package:flutter/widgets.dart';

typedef IndexedRadioBuilder = Widget Function(
    BuildContext context, int index, bool isActive);

class CustomRadio extends StatefulWidget {
  CustomRadio({
    Key? key,
    this.controller,
    required this.itemBuilder,
    required this.itemCount,
    this.restorationId,
  })  : assert(itemCount > 0),
        super(key: key);

  final CustomRadioController? controller;
  final IndexedRadioBuilder itemBuilder;
  final int itemCount;

  /// Restoration ID to save and restore the state of the custom radio widget.
  ///
  /// If non-null, and no [controller] has been provided, the custom radio
  /// widget will persist and restore its current index. If a [controller] has
  /// been provided, it is the responsibility of the owner of that controller to
  /// persist and restore it, e.g. by using a [RestorableCustomRadioController].
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  final String? restorationId;

  @override
  _CustomRadioState createState() => _CustomRadioState();
}

class _CustomRadioState extends State<CustomRadio> with RestorationMixin {
  RestorableCustomRadioController? _controller;
  CustomRadioController get _effectiveController =>
      widget.controller ?? _controller!.value;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _createLocalController();
    }
  }

  @override
  void didUpdateWidget(CustomRadio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null) {
      _createLocalController(oldWidget.controller!.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      unregisterFromRestoration(_controller!);
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_controller != null) {
      _registerController();
    }
  }

  void _registerController() {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller');
  }

  void _createLocalController([CustomRadioValue? value]) {
    assert(_controller == null);
    _controller = value == null
        ? RestorableCustomRadioController()
        : RestorableCustomRadioController.fromValue(value);
    if (!restorePending) {
      _registerController();
    }
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _buildChildren(context).toList(),
    );
  }

  Iterable<Widget> _buildChildren(BuildContext context) sync* {
    for (var i = 0; i < widget.itemCount; i++) {
      yield _buildChild(context, i);
    }
  }

  Widget _buildChild(BuildContext context, int index) {
    final isActive = index == _effectiveController.index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _effectiveController.index = index;
        });
      },
      child: widget.itemBuilder(context, index, isActive),
    );
  }
}
