// middleware/validation.js

import { body, validationResult } from 'express-validator';
import { BadRequestError } from '../errors/index.js';

const withValidationErrors = (validateValues) => {
  return [
    validateValues,
    (req, res, next) => {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        const errorMessages = errors.array().map((error) => error.msg);
        throw new BadRequestError(errorMessages.join(', '));
      }
      next();
    },
  ];
};

// Validation for updating a user profile
export const validateUpdateUser = withValidationErrors([
  body('name').optional().notEmpty().withMessage('Name cannot be empty'),
  body('email').optional().isEmail().withMessage('Please provide a valid email address'),
]);

// Validation for creating a ride
export const validateCreateRide = withValidationErrors([
  body('pickupAddress').notEmpty().withMessage('Pickup address is required'),
  body('dropAddress').notEmpty().withMessage('Dropoff address is required'),
  body('vehicle').notEmpty().withMessage('Vehicle type is required'), // We will need this later
  body('fare').isFloat({ gt: 0 }).withMessage('Fare must be a positive number'), // We will need this later
]);

// --- NEW VALIDATION FOR GETTING ESTIMATES ---
export const validateRideEstimate = withValidationErrors([
    body('pickupAddress').notEmpty().withMessage('Pickup address is required'),
    body('dropAddress').notEmpty().withMessage('Dropoff address is required'),
]);