import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConstantesWtbt {
  static String teste = "teste";
  //Serviços
  static String clientCharacteristConfig =
      "00002902-0000-1000-8000-00805f9b34fb";
  static const String atWtbtService = "0000181D-0000-1000-8000-00805f9b34fb";
  static const String atDeviceInformationService =
      "0000180A-0000-1000-8000-00805f9b34fb";
  //Characteristcs
  static const String atCharComando = "00002B26-0000-1000-8000-00805f9b34fb";
  static const String atCharStatus = "00002b21-0000-1000-8000-00805f9b34fb";
  static const String atCharPeso = "00002A98-0000-1000-8000-00805f9b34fb";
  static const String atCharSoftwareRevision =
      "00002A28-0000-1000-8000-00805f9b34fb";
  //Guid serviços
  static final Guid uuidWtbtService = Guid(atWtbtService);
  static final Guid uuisDeviceInformationService =
      Guid(atDeviceInformationService);
  //Guid characteristics
  static final Guid uuidCharComando = Guid(atCharComando);
  static final Guid uuidCharStatus = Guid(atCharStatus);
  static final Guid uuidCharPeso = Guid(atCharPeso);
  static final Guid uuidCharSoftwareRevision = Guid(atCharSoftwareRevision);
  //Bateria
  static const int bateriaSemStatus = -1;
  static const int bateria25 = 0;
  static const int bateria50 = 1;
  static const int bateria75 = 2;
  static const int bateria100 = 3;
}

class Comandos {
  static String zerar = "CDL";
  static String tarar = "TAR";
}
