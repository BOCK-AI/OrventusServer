# Node.js Backend with Neon PostgreSQL, Prisma ORM, and Socket.IO

This project is a Node.js backend Prisma ORM, and Neon PostgreSQL. It supports real-time ride sharing features with Socket.IO, user authentication with JWT, and RESTful APIs for users and rides.

## Setup

1. Set your Neon PostgreSQL connection string in the `.env` file as `DATABASE_URL`.
2. Run `npx prisma migrate dev --name init` to create the initial tables.
3. Run `npx prisma migrate dev --name <migration_name>` after any schema changes.
4. Start the server with `node index.js` or `npm start`.
5. (Optional) Use `socketTest.js` to test Socket.IO connections.

## Features
- User authentication (JWT-based)
- User model (role, phone, timestamps, ride relations)
- Ride model (vehicle, pickup/drop, fare, status, OTP, relations)
- REST API for users and rides
- Real-time ride updates and rider/customer location with Socket.IO
- Error handling and not-found middleware

## Project Structure
- `index.js` - Main entry point, server, and Socket.IO setup    
- `controllers/` - Business logic for users, rides, and sockets
- `routes/` - Express route definitions for auth and rides
- `middleware/` - Authentication, error handler, and not-found middleware
- `prisma/schema.prisma` - Prisma schema for PostgreSQL
- `generated/prisma/` - Generated Prisma client
- `utils/mapUtils.js` - Utility functions for distance, fare, OTP
- `socketTest.js` - Node.js script to test Socket.IO connection

## API Usage

### Authentication
- `POST /auth/signin` - Sign in or register, returns JWT access and refresh tokens
- Use the returned access token as `Authorization: Bearer <token>` in all protected requests

### Rides
- `POST /rides/create` - Create a new ride (requires authentication)
- `PATCH /rides/accept/:rideId` - Accept a ride as a rider
- `PATCH /rides/update/:rideId` - Update ride status
- `GET /rides/rides` - Get all rides for the authenticated user

### Socket.IO
- Connect to `ws://localhost:3000` with a valid JWT in the `access_token` header (see `socketTest.js`)
- Emit events like `goOnDuty`, `subscribeToZone`, `searchrider`, etc.

## Environment Variables
- `DATABASE_URL` - Neon PostgreSQL connection string
- `ACCESS_TOKEN_SECRET` - JWT secret for access tokens
- `ACCESS_TOKEN_EXPIRY` - Access token expiry (e.g., `4d`)
- `REFRESH_TOKEN_SECRET` - JWT secret for refresh tokens
- `REFRESH_TOKEN_EXPIRY` - Refresh token expiry (e.g., `30d`)

---

Replace the Neon connection string and secrets in `.env` with your own credentials. See code comments and each file for more details on usage and customization.
