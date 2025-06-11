import { io } from "socket.io-client";

// Replace with a valid JWT from your /auth/signin endpoint
const token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwicGhvbmUiOiI0MjM0MjM0MjM0MiIsImlhdCI6MTc0OTQ5NzIyMCwiZXhwIjoxNzQ5ODQyODIwfQ.pwZ5mHMtM50dQ6Psh7JV4kp3vA4qI3Q912Wvef-QyAA";

const socket = io("http://localhost:3000", {
  extraHeaders: {
    access_token: token
  }
});

socket.on("connect", () => {
  console.log("Connected to server!", socket.id);

  // Example: go on duty as a rider
  // socket.emit("goOnDuty", { latitude: 12.9716, longitude: 77.5946 });

  // Example: subscribe to zone as a customer
  // socket.emit("subscribeToZone", { latitude: 12.9716, longitude: 77.5946 });
});

socket.on("disconnect", () => {
  console.log("Disconnected from server");
});

socket.on("nearbyriders", (data) => {
  console.log("Nearby riders:", data);
});

// Add more event listeners as needed
//can do testing of the socket connection here throught node socketTest.js
// Example: search for a rider
socket.emit("searchrider", "1"); // Replace "1" with a valid ride ID 
socket.on("rideAccepted", (data) => {
  console.log("Ride accepted:", data);   
});