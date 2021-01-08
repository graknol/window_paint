import 'package:example/custom_radio_controller.dart';
import 'package:flutter/widgets.dart';

typedef IndexedRadioBuilder = Widget Function(
    BuildContext context, int index, bool isActive);

class CustomRadio extends StatefulWidget {
  final CustomRadioController controller;
  final IndexedRadioBuilder itemBuilder;
  final int itemCount;

  CustomRadio({
    Key key,
    this.controller,
    @required this.itemBuilder,
    @required this.itemCount,
  })  : assert(itemBuilder != null),
        assert(itemCount != null && itemCount > 0),
        super(key: key);

  @override
  _CustomRadioState createState() => _CustomRadioState();
}

class _CustomRadioState extends State<CustomRadio> {
  CustomRadioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? CustomRadioController();
  }

  @override
  void dispose() {
    _controller.dispose();
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
    final isActive = index == _controller.currentIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.currentIndex = index;
        });
      },
      child: widget.itemBuilder(context, index, isActive),
    );
  }
}
