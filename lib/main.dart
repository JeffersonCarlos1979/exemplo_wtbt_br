import 'dart:async';

import 'package:exemplo_wtbt/auxiliar/tratar_peso.dart';
import 'package:exemplo_wtbt/constantes/wtbt.dart';
import 'package:exemplo_wtbt/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

//https://pub.dev/packages/flutter_blue

void main() {
  runApp(const MyApp());
}

//Repositório alterado para GitHub

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBluePlus.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return const DeviceScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  final BluetoothState? state;

  const BluetoothOffScreen({super.key, this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  FindDevicesScreen({super.key}) {
    _startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _startScan(),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBluePlus.instance.scanResults,
                initialData: const [],
                builder: (c, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  return Column(
                    children: snapshot.data!
                        .map(
                          (r) => ScanResultTile(
                            result: r,
                            onTap: () {
                              FlutterBluePlus.instance.stopScan();
                              Navigator.pop(context, r.device);
                            },
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBluePlus.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          final isScanning = snapshot.data;
          return FloatingActionButton(
            onPressed: () => isScanning == null
                ? null
                : isScanning
                    ? FlutterBluePlus.instance.stopScan()
                    : _startScan(),
            backgroundColor: isScanning == true ? null : Colors.red,
            child: isScanning == true
                ? const Icon(Icons.stop)
                : const Icon(Icons.search),
          );
        },
      ),
    );
  }

  _startScan() {
    FlutterBluePlus.instance.startScan(timeout: const Duration(seconds: 10));
  }
}

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});
  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  final TratarPeso _tratarPeso = TratarPeso();
  BluetoothDevice? _device;
  BluetoothService? _wtbtService;
  BluetoothCharacteristic? _pesoCharacteristic;
  BluetoothCharacteristic? _comandoCharacteristic;

  //Notificadores que auxiliam a alterar as partes da UI correspondente aos valores e status do peso
  final _bateriaNotifier = ValueNotifier<int>(0);

  final _isBrutoNotifier = ValueNotifier<bool>(true);

  final _isEstavelNotifier = ValueNotifier<bool>(true);

  final _unidadeNotifier = ValueNotifier<String>('kg');

  final _campoPesoNotifier = ValueNotifier<String>(TratarPeso.pesoInvalido);

  final _campoTaraNotifier =
      ValueNotifier<String>('Tara: ${TratarPeso.pesoInvalido} kg');

  final _imagens = [
    'images/bateria_25.png',
    'images/bateria_50.png',
    'images/bateria_75.png',
    'images/bateria_100.png',
  ];

  StreamSubscription<List<int>>? _pesoSubscription;

  @override
  Widget build(BuildContext context) {
    final larguraDaTela = MediaQuery.of(context).size.width;
    final alturaDaTela = MediaQuery.of(context).size.height;
    final paddingHorizontal = larguraDaTela /
        40.0; //Apenas para ajustar os widgets em relação a tamanho da tela.
    final paddingVertical = alturaDaTela / 61.6;
    final paddinPadrao = paddingHorizontal;
    final fonteSizePeso = larguraDaTela / 5.714286;
    final fonteSizeTara = larguraDaTela / 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exemplo WTBT-BR"),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //Informações do Peso
            Expanded(
              flex: 0,
              child: Container(
                padding: EdgeInsets.only(
                    left: paddingHorizontal, right: paddingHorizontal),
                height: alturaDaTela / 3,
                color: Colors.blue,
                child: Row(
                  //Display com todas as informações de peso
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            //Tara e bateria
                            children: [
                              Container(
                                padding: EdgeInsets.all(paddinPadrao),
                                //color: Colors.green,
                                child: ValueListenableBuilder(
                                    valueListenable: _campoTaraNotifier,
                                    builder: (BuildContext context,
                                        String campoTara, _) {
                                      return Text(
                                        //Tara
                                        campoTara,
                                        style: TextStyle(
                                          fontSize: fonteSizeTara, //50
                                        ),
                                      );
                                    }),
                              ),
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 1,
                                child: Container(
                                  padding: EdgeInsets.all(paddinPadrao),
                                  alignment: Alignment.centerRight,
                                  //color: Colors.red,
                                  child: ValueListenableBuilder(
                                      valueListenable: _bateriaNotifier,
                                      builder: (BuildContext context,
                                          int imagemIndexBateria, _) {
                                        return Image(
                                          image: AssetImage(
                                              _imagens[imagemIndexBateria]),
                                        );
                                      }),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                                //Estável, peso e unidade
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    //Estável
                                    alignment: Alignment.bottomCenter,
                                    padding: EdgeInsets.only(
                                        bottom: paddingVertical * 3,
                                        left: paddingHorizontal),
                                    //color: Colors.blue,
                                    child: ValueListenableBuilder(
                                      valueListenable: _isEstavelNotifier,
                                      builder: (BuildContext context,
                                          bool isEstavel, _) {
                                        if (isEstavel) {
                                          return const Image(
                                              image: AssetImage(
                                                  'images/estavel.png'));
                                        } else {
                                          //tem que retornar algo, então vou retornar uma caixa vazia
                                          return const SizedBox(
                                            height: 10,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Container(
                                      //Peso
                                      alignment: Alignment.bottomRight,
                                      padding: EdgeInsets.only(
                                          bottom: paddingVertical * 2,
                                          right: paddingHorizontal),
                                      //color: Colors.yellow,
                                      child: ValueListenableBuilder(
                                        valueListenable: _campoPesoNotifier,
                                        builder: (BuildContext context,
                                            String campoPeso, _) {
                                          return Text(
                                            //Peso
                                            campoPeso,
                                            style: TextStyle(
                                              fontSize: fonteSizePeso, //140
                                            ),
                                            textAlign: TextAlign.end,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    //Unidade
                                    alignment: Alignment.bottomCenter,
                                    padding: EdgeInsets.only(
                                        bottom: paddingVertical * 3,
                                        right: paddingHorizontal),
                                    child: ValueListenableBuilder(
                                      valueListenable: _unidadeNotifier,
                                      builder: (BuildContext context,
                                          String unidade, _) {
                                        return Text(
                                          unidade,
                                          style: TextStyle(
                                            fontSize: fonteSizeTara, //50
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    child: Text(
                      "Tarar",
                      style: TextStyle(fontSize: fonteSizeTara),
                    ),
                    onPressed: () {
                      _tarar();
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    child: Text(
                      "Zerar",
                      style: TextStyle(fontSize: fonteSizeTara),
                    ),
                    onPressed: () {
                      _zerar();
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.white,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _selecionarPlataforma(context);
              },
              style: const ButtonStyle(),
              child: Text(
                'Selecionar plataforma',
                style: TextStyle(fontSize: fonteSizeTara),
              ),
            ),
          ]),
    );
  }

  void _selecionarPlataforma(BuildContext context) async {
    await _pesoCharacteristic?.setNotifyValue(false);
    _device?.disconnect();

    if (mounted) {
      _device = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FindDevicesScreen()),
      );
    }

    if (kDebugMode) {
      print('Device ${_device?.name}');
    }

    if (_device == null) return;
    _conectar();
  }

  Future<void> _conectar() async {
    await _device!.connect();

    _wtbtService = null;
    List<BluetoothService> services = await _device!.discoverServices();

    for (var service in services) {
      if (service.uuid == ConstantesWtbt.uuidWtbtService) {
        _wtbtService = service;
      }
    }

    if (_wtbtService == null) {
      if (kDebugMode) {
        print('Não foi possível localizar o serviço');
      }
      return;
    }

    _pesoCharacteristic = null;
    _comandoCharacteristic = null;
    // Reads all characteristics
    for (BluetoothCharacteristic c in _wtbtService!.characteristics) {
      if (c.uuid == ConstantesWtbt.uuidCharPeso) {
        _pesoCharacteristic = c;
      } else if (c.uuid == ConstantesWtbt.uuidCharComando) {
        _comandoCharacteristic = c;
      }
    }

    if (_pesoCharacteristic == null || _comandoCharacteristic == null) {
      if (kDebugMode) {
        print('Não foi possível localizar o charactristic');
      }
      return;
    }

    //Habilita o notify/indicator do dispositivo para começar a receber a transmissão de peso
    _pesoCharacteristic!.setNotifyValue(true);

    await _pesoSubscription?.cancel();
    _pesoSubscription = _pesoCharacteristic!.value.listen((data) {
      if (_tratarPeso.lerWtBtbr(data)) {
        /*
        Modificar os campos ValueNotifiers faz com que os Widgets ValueListenableBuilder associados
        se modifiquem automaticamente com os novos valores.
         */

        _bateriaNotifier.value = _tratarPeso.imagemIndexBateria;
        _isBrutoNotifier.value = _tratarPeso.isBruto;
        _isEstavelNotifier.value = _tratarPeso.isEstavel;
        _unidadeNotifier.value = _tratarPeso.unidade;
        _campoPesoNotifier.value = _tratarPeso.pesoLiqFormatado;
        _campoTaraNotifier.value =
            "Tara: ${_tratarPeso.taraFormatada} ${_tratarPeso.unidade}";
      }
    });
  }

  Future<void> _tarar() async {
    _enviarComando("${Comandos.tarar};");
  }

  Future<void> _zerar() async {
    _enviarComando("${Comandos.zerar};");
  }

  Future<void> _enviarComando(String commandData) async {
    var buff = commandData.codeUnits;

    try {
      _comandoCharacteristic?.write(buff);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
