var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  console.log('Home page accessed');
  res.render('index', { title: 'Node from Docker' });
});

/* GET health check endpoint. */
router.get('/health', function(req, res, next) {
  console.log('Health check accessed');
  res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

module.exports = router;
