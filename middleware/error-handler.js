import { StatusCodes } from "http-status-codes";

const errorHandlerMiddleware = (err, req, res, next) => {
  let customError = {
    statusCode: err.statusCode || StatusCodes.INTERNAL_SERVER_ERROR,
    msg: err.message || "Something went wrong, try again later",
  };

  // Prisma unique constraint violation
  if (err.code === "P2002") {
    customError.msg = `Duplicate value entered for field(s): ${err.meta?.target?.join(
      ", "
    )}`;
    customError.statusCode = 400;
  }
  // Prisma record not found
  if (err.code === "P2025") {
    customError.msg = `No item found for the specified criteria.`;
    customError.statusCode = 404;
  }
  // Prisma validation error
  if (err.name === "ValidationError") {
    customError.msg = Object.values(err.errors)
      .map((item) => item.message)
      .join(",");
    customError.statusCode = 400;
  }
  // MongoDB duplicate key error (legacy, for compatibility)
  if (err.code && err.code === 11000) {
    customError.msg = `Duplicate value entered for ${Object.keys(
      err.keyValue
    )} field, please choose another value`;
    customError.statusCode = 400;
  }
  // Mongoose cast error (legacy, for compatibility)
  if (err.name === "CastError") {
    customError.msg = `No item found with id: ${err.value}`;
    customError.statusCode = 404;
  }

  return res.status(customError.statusCode).json({ msg: customError.msg });
};

export default errorHandlerMiddleware;
