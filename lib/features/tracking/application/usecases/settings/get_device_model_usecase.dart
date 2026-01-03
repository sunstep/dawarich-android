
import 'package:dawarich/features/tracking/application/repositories/hardware_repository_interfaces.dart';

final class GetDeviceModelUseCase {

  final IHardwareRepository _hardwareRepository;

  GetDeviceModelUseCase(this._hardwareRepository);

  Future<String> call() {
    return _hardwareRepository.getDeviceModel();
  }
}