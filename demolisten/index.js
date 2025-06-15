// ws-client.js
const WebSocket = require("ws");

const socket = new WebSocket("ws://localhost:5000/ws"); // use your actual WS endpoint

socket.on("open", () => {
  console.log("Connected to WebSocket server");
});

socket.on("message", (data) => {
  try {
    const parsed = JSON.parse(data);
    console.log("Received message:", parsed);
  } catch (e) {
    console.log("Raw message:", data);
  }
});

socket.on("error", (err) => {
  console.error("WebSocket error:", err);
});

socket.on("close", (code, reason) => {
  console.log(`Connection closed: ${code} - ${reason}`);
});
