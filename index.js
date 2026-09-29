const express = require('express');
const app = express();

const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok", message: "Service is healthy", uptime: process.uptime() });
});

app.get('/', (req, res) => {
    console.log("AWS code pipeline CI/CD for Node.js Application is working fine! 123456");
    res.send("AWS code pipeline CI/CD for Node.js Application is working fine!");
});

app.get('/about', (req, res) => {
    console.log("About page is working fine!");
    res.send("About page is working fine! New data will be added soon!");
});

app.get('/home', (req, res) => {
    console.log("Home page is working fine!");
    res.send("Home page is working fine .more data will be added soon!");
});

app.get('/gallery', (req, res) => {
    console.log("Gallery page is working fine!");
    res.send("Gallery page is working fine .more data will be added soon!");
});

app.get('/user', (req, res) => {
    console.log("User page is working fine!");
    res.send("User page is working fine .learning more about AWS code pipeline CI/CD for Node.js Application is working fine!");
});


app.get('/user/list', (req, res) => {
    console.log("User page is working fine!");
    res.send({"status": "ok", "message": "User list is working fine .learning more about AWS code pipeline CI/CD for Node.js Application is working fine!"});
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on port ${PORT}`);
});