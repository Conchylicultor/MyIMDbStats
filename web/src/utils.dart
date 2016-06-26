import 'dart:math';

/**
 * Generate a random number (using the generator) following the normal
 * distribution (with the given parameters)
 * Use the Box–Muller transform
 *
 * Warning: The parameters mean and std are useless
 */
double genNormDist(Random rng, {dilatation: 10.0, double mean: 0.0, double std: 1.0}) {

  double u, v, r;
  do
  {
    u = rng.nextDouble() * 2 - 1;
    v = rng.nextDouble() * 2 - 1; // Uniform on [-1, 1]
    r = u * u + v * v;
  }
  while (r == 0.0 || r >= 1.0);

  double c = sqrt(-2 * log(r) / r);
  return (u * c) / dilatation;
}
