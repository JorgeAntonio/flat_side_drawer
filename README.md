# Flat Side Drawer

A Flutter package that provides a "flat" side drawer navigation experience, similar to the ChatGPT mobile application or modern iOS apps.

Unlike other drawer packages that use 3D rotations or scale down the main screen, FlatSideDrawer keeps the main screen flat and slides it horizontally, adding a subtle shadow and an interactive overlay.

### Features

🚀 Flat Slide Animation: No 3D perspective or scaling.

🌑 Interactive Overlay: Dims the main content when open. Tap to close.

👆 Gesture Support: Swipe to open (from edge) and swipe to close (from anywhere).

⚙️ Fully Customizable: Control slide width, drag threshold, shadow color, and animation speed.

🎮 Controller: Programmatic control via FlatSideDrawerController.

### Usage

```
import 'package:flat_side_drawer/flat_side_drawer.dart';
```

```
FlatSideDrawer(
  controller: _controller,
  menu: MyMenuScreen(), 
  body: Scaffold(
     appBar: AppBar(
       leading: IconButton(
         icon: Icon(Icons.menu),
         onPressed: () => _controller.toggle(),
       ),
     ),
     body: Center(child: Text("Main Content")),
  ),
)
```
