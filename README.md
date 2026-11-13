<h1 align="center">avatar_sheen</h1>

<p align="center">
  A soft band of light that sweeps across avatars, initials tiles, badges or any widget.
  <br />
  Sweeps take turns, so a list shimmers one item at a time.
</p>

<p align="center">
  <img src="doc/demo.gif" alt="avatar_sheen demo" width="320" />
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-%3E%3D3.24-02569B?logo=flutter&logoColor=white" />
  <img alt="Dart" src="https://img.shields.io/badge/Dart-%5E3.5-0175C2?logo=dart&logoColor=white" />
  <img alt="Version" src="https://img.shields.io/badge/version-0.1.0-blue" />
  <img alt="License" src="https://img.shields.io/badge/license-MIT-green" />
</p>

---

## Features

- **Turn-taking sweeps** – multiple sweeps play top to bottom, one at a time, instead of all at once.
- **Off-screen aware** – sweeps that are not visible are skipped.
- **Paint-only animation** – the child is never rebuilt.
- **Accessible** – honours the OS "reduce motion" setting.
- **Ready-made avatar** – `ShadeInitialsAvatar` with initials fallback and circle or rounded shapes.
- **Predictable state** – sequencing is managed with `flutter_bloc` (`ShadeSequenceCubit`).

## Installation

```yaml
dependencies:
  avatar_sheen: ^0.1.0
```

```dart
import 'package:avatar_sheen/avatar_sheen.dart';
```

## Usage

### Initials avatar

```dart
ShadeInitialsAvatar(name: 'Asha Rao', size: 44);
```

### Circular avatar with a photo

Initials are shown as the fallback while the image is unavailable.

```dart
ShadeInitialsAvatar(
  name: 'Asha Rao',
  shape: ShadeAvatarShape.circle,
  imageProvider: NetworkImage(url),
);
```

### Wrap any widget

```dart
ShadeSweep(
  borderRadius: BorderRadius.circular(12),
  intensity: 0.5,
  child: MyBadge(),
);
```

## API

| Property       | Default | Description                              |
| -------------- | ------- | ---------------------------------------- |
| `borderRadius` | `zero`  | Keeps the light inside the child's shape |
| `intensity`    | `0.5`   | Brightness of the light, from 0 to 1     |
| `color`        | white   | Colour of the light                      |

## Example

A runnable demo lives in [example/](example/).

```bash
cd example
flutter run
```

## Contributors

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/subshegde">
        <img src="https://images.weserv.nl/?url=github.com/subshegde.png&w=120&h=120&fit=cover&mask=circle" width="96" height="96" alt="subshegde" />
        <br />
        <sub><b>subshegde</b></sub>
      </a>
      <br />
      <sub>Author &amp; Maintainer</sub>
    </td>
  </tr>
</table>

Contributions are welcome. Open an issue to discuss a change, or send a pull request.

## License

Released under the [MIT License](LICENSE).
