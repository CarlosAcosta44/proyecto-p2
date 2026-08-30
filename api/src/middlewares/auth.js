// Autenticación mock para propósitos de la API.
// En un proyecto real esto validaría un JWT u otra credencial.
export function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ error: 'Falta encabezado de autorización' });
  }
  
  // Extraemos el id del token simulado "Bearer <userId>"
  const token = authHeader.split(' ')[1];
  req.usuario_id = parseInt(token, 10) || 1; 

  next();
}
