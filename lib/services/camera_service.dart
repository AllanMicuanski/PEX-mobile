import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> tirarFoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 50,
      );

      return photo?.path;
    } catch (e) {
      // Aqui você pode logar o erro se necessário
      return null;
    }
  }
}
