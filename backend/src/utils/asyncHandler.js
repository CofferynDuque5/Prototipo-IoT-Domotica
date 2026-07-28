// Envuelve un handler async para que los errores lleguen al middleware de
// manejo de errores de Express sin repetir try/catch en cada controlador.
export function asyncHandler(fn) {
  return (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);
}
