import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/settings_entity.dart';
import '../repositories/settings_repository.dart';

class UpdateSettings implements UseCase<SettingsEntity, SettingsEntity> {
  final SettingsRepository repository;
  
  UpdateSettings(this.repository);
  
  @override
  Future<Either<Failure, SettingsEntity>> call(SettingsEntity settings) {
    return repository.updateSettings(settings);
  }
}
