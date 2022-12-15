// server.js
const jsonServer = require('json-server');
const app = jsonServer.create();
const minDelay = 30;
const maxDelay = 250;

// Collect metrics
const prometheusExporter = require('@tailorbrands/node-exporter-prometheus');
const options = {
  appName: "php-myapache",
  collectDefaultMetrics: true,
  ignoredRoutes: ['/metrics', '/favicon.ico', '/__rules']
};
const promExporter = prometheusExporter(options);
app.use(promExporter.middleware);
app.get('/metrics', promExporter.metrics);

const middlewares = jsonServer.defaults()
app.use(middlewares);

// Add a delay to /myapache requests only
app.use('/', function (req, res, next) {
  let delay = Math.floor(Math.random() * (maxDelay - minDelay)) + minDelay;
  setTimeout(next, delay)
});

const router = jsonServer.router('db.json');
app.use(router);

const port = 5005;
app.listen(port, () => {
  console.log(
    `JSON server listening on 0.0.0.0:${port}`,
  );
});
