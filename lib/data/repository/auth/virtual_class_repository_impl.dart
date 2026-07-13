import 'package:jumpup_app/domain/model/virtual_class_models.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';

class VirtualClassRepositoryImpl extends BaseRepository {
  const VirtualClassRepositoryImpl();

  Future<List<VirtualClassModel>> getVirtualClasses() async {
    return getList('live-sessions/', VirtualClassModel.fromJson,
        message: 'No se pudieron cargar las clases virtuales');
  }

  Future<VirtualClassRegistrationModel> joinVirtualClass(int classId) async {
    return handleRequest<VirtualClassRegistrationModel>(() async {
      final response = await dio.post<dynamic>(
        'live-sessions/$classId/join/',
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return VirtualClassRegistrationModel.fromJson(data);
      }
      return VirtualClassRegistrationModel(
        id: 0,
        virtualClass: VirtualClassModel(
          id: classId,
          title: '',
          description: '',
          instructorName: '',
          scheduledAt: DateTime.now(),
          durationMinutes: 60,
          maxParticipants: 50,
          status: 'scheduled',
        ),
        registeredAt: DateTime.now(),
        status: 'registered',
      );
    }, message: 'No te pudiste unir a la clase virtual');
  }

  Future<List<CertificateModel>> getCertificates() async {
    return getList('certificates/', CertificateModel.fromJson,
        message: 'No se pudieron cargar los certificados');
  }

  Future<List<VirtualClassModel>> getClassroomEnrollments() async {
    return getList('classrooms/mine/', VirtualClassModel.fromJson,
        message: 'No se pudieron obtener tus inscripciones');
  }

  Future<VirtualClassRegistrationModel> enrollInClassroom(String code) async {
    return handleRequest<VirtualClassRegistrationModel>(() async {
      final response = await dio.post<Map<String, dynamic>>(
        'classrooms/join/',
        data: {'access_code': code},
      );
      return VirtualClassRegistrationModel.fromJson(response.data!);
    }, message: 'No se pudo completar la inscripción');
  }
}
