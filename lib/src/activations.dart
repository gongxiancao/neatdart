import 'dart:math';

double sigmoidActivation(double z) {
  double nz = max(-60.0, min(60.0, 5.0 * z));
  return 1.0 / (1.0 + exp(-nz));
}

double tanActivation(double z) {
  double nz = max(-60.0, min(60.0, 2.5 * z));
  return tan(nz);
}

double sinActivation(double z) {
  double nz = max(-60.0, min(60.0, 5.0 * z));
  return sin(nz);
}

double gaussActivation(double z) {
  double nz = max(-3.4, min(3.4, z));
  return exp(-5.0 * nz * nz);
}

double reluActivation(double z) {
  return z > 0.0 ? z : 0.0;
}

double eluActivation(double z) {
  return z > 0.0 ? z : exp(z) - 1;
}

double leluActivation(double z) {
  double leaky = 0.005;
  return z > 0.0 ? z : leaky * z;
}

double seluActivation(double z) {
  double lam = 1.0507009873554804934193349852946;
  double alpha = 1.6732632423543772848170429916717;
  return z > 0.0 ? lam * z : lam * alpha * (exp(z) - 1);
}

double softplusActivation(double z) {
  double nz = max(-60.0, min(60.0, 5.0 * z));
  return 0.2 * log(1 + exp(nz));
}

double identityActivation(double z) {
  return z;
}

double clampedActivation(double z) {
  return max(-1.0, min(1.0, z));
}

double invActivation(double z) {
  if (z == 0) {
    return 0.0;
  }
  return 1.0 / z;
}

double logActivation(double z) {
  double nz = max(1e-7, z);
  return log(nz);
}

double expActivation(double z) {
  double nz = max(-60.0, min(60.0, z));
  return exp(nz);
}

double absActivation(double z) {
  return z >= 0 ? z : -z;
}

double hatActivation(double z) {
  return max(0.0, 1 - absActivation(z));
}

double squareActivation(double z) {
  return z * z;
}

double cubeActivation(double z) {
  return z * z * z;
}
