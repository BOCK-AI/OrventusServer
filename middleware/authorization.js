// In middleware/authorization.js
import { UnauthenticatedError } from '../errors/index.js';

export const authorizePermissions = (...roles) => {
  return (req, res, next) => {
    
    console.log(`--- Authorizing... Required roles: [${roles}], User's role: '${req.user.role}' ---`);
    
    
    
    if (!roles.includes(req.user.role)) {
      throw new UnauthenticatedError('Unauthorized to access this route');
    }
    next();
  };
};