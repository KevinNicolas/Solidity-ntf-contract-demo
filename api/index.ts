import express from "express";

const app = express();
const port = 3010;

app.use(express.static(__dirname + "/assets"));

app.listen(port, () => {
  console.info("Listen on port", port);
});
