import 'package:flutter/material.dart';
import 'package:avatar_sheen/avatar_sheen.dart';

void main() => runApp(const MaterialApp(home: Demo()));

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    const names = ['Asha Rao', 'Ravi Kumar', 'Meera Nair', 'John Doe'];
    return Scaffold(
      appBar: AppBar(title: const Text('avatar_sheen')),
      body: ListView(
        children: [
          for (final n in names)
            ListTile(
              leading: ShadeInitialsAvatar(name: n),
              title: Text(n),
            ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(children: [
              ShadeInitialsAvatar(
                  name: 'Round One', shape: ShadeAvatarShape.circle, size: 56),
              SizedBox(width: 16),
              ShadeSweep(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: Chip(label: Text('Any widget')),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
