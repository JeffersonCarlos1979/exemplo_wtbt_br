import 'dart:math';
import 'package:exemplo_wtbt/constantes/wtbt.dart';
import 'bit_converter.dart';

class TratarPeso {
  static final String pesoInvalido = "------";
  static final String falhaAd = "F. A/D";
  static final String sobrecarga = "++OL++";

  int imagemIndexBateria = 0;
  bool isPesoOk = false;
  int casasDecimais = 0;
  int nivelBateria = 0;
  double pesoLiq = 0.0;
  double tara = 0.0;
  double pesoBruto = 0.0;
  bool isBruto = false;
  bool isEstavel = false;
  bool isFalhaAd = false;
  String pesoLiqFormatado = '';
  String taraFormatada = '';
  String unidade = '';

  final unidades = [
    '',
    'g',
    'kg',
    't',
    'lb',
  ];

  //Essa funçãoretorna true se o dado for válido
  bool lerWtBtbr(List<int> data) {
    if (data.length != 15) return false;

    int nivelBateria = data[0];
    int imagemBateria;
    if (nivelBateria > 75) {
      imagemBateria = ConstantesWtbt.bateria100;
    } else if (nivelBateria > 50) {
      imagemBateria = ConstantesWtbt.bateria75;
    } else if (nivelBateria > 25) {
      imagemBateria = ConstantesWtbt.bateria50;
    } else {
      imagemBateria = ConstantesWtbt.bateria25;
    }

    int unidade = (data[1] & 0xf);
    int casasDecimais = (data[1] >> 4);

    int pesoInt = BitConverter.toInt32(data, 11);
    double peso = (pesoInt * pow(10, -casasDecimais)).toDouble();

    int taraInt = BitConverter.toInt32(data, 7);
    double tara = (taraInt * pow(10, -casasDecimais)).toDouble();

    bool isBruto = ((data[2] & 1) == 1);
    bool isEstavel = ((data[2] & 2) == 2);
    bool isSobrecarga = ((data[2] & 4) == 4);
    bool isFalhaAd = ((data[2] & 8) == 8);
    //bool isBrincoDisponivel = ((data[2] & 16) == 16); Esse bit indica que o WTBT-BR recebeu uma leitura de brinco transmitida pelo leitor. Vídeo: https://www.youtube.com/watch?v=dRN87ape4nA

    String pesoLiqFormatado;
    String taraFormatada;
    bool isPesoOk;

    if (isFalhaAd) {
      isPesoOk = false;
      pesoLiqFormatado = falhaAd;
      taraFormatada = pesoInvalido;
    } else if (isSobrecarga) {
      isPesoOk = false;
      pesoLiqFormatado = sobrecarga;
      taraFormatada = pesoInvalido;
    } else {
      isPesoOk = true;
      pesoLiqFormatado = peso.toStringAsFixed(casasDecimais);
      taraFormatada = tara.toStringAsFixed(casasDecimais);
    }

    this.casasDecimais = casasDecimais;
    this.nivelBateria = nivelBateria;
    this.imagemIndexBateria = imagemBateria;
    this.pesoLiq = peso;
    this.tara = tara;
    this.pesoBruto = peso + tara;
    this.isBruto = isBruto;
    this.isEstavel = isEstavel;
    this.isFalhaAd = isFalhaAd;
    this.unidade = unidades[unidade];
    this.isPesoOk = isPesoOk;
    this.pesoLiqFormatado = pesoLiqFormatado;
    this.taraFormatada = taraFormatada;

    return true;
  }
}
