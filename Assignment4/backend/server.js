/**
 * @author: Atul Gupta, +91-9899685864, atulgupta.perssonal@gmail.com
 * @description:  This is main file who have the following configuration information.
 */
var express = require('express'),
  http = require('http'),
  app = express(),
  bodyParser = require('body-parser'),
  cors = require('cors'),
  dotenv = require('dotenv').config(), // Use for providing the configuration file details
  router = require('./router/routers'),
  // mongoose = require('mongoose'),
  errorhandler = require('errorhandler'),
  basicAuth = require('express-basic-auth'),
  fileUpload = require('express-fileupload')
const axios = require('axios')
// mongoose.Promise = global.Promise
// mongoose.connect(process.env.CONNECT_URL).then(() => console.log('DB Successfully Connect...')).catch((err) => console.error(err))

var port = process.env.PORT

app.use(fileUpload())
app.use(express.static('public'))
app.use(bodyParser.urlencoded({ extended: true, limit: '1024mb', parameterLimit: process.env.PARAMETER_LIMIT})); // for parsing the application/x-www-form-urlencode
app.use(bodyParser.json({limit: '1024mb', parameterLimit: process.env.PARAMETER_LIMIT})) // for parsing the application/json format
app.use(cors()) // Used for provide to handle the cross platform request and response.

app.use((request, response, next) => {
  // Send the response of the api in application/json format
  response.header('Content-Type', 'application/json')
  response.header('Access-Control-Allow-Origin', '*')
  request.header('Access-Control-Allow-Methods', 'GET,POST,DELETE')
  next()
})

app.use((err, req, res, next) => {
  if (err.name === 'StatusError') {
    res.send(err.status, err.message)
  } else {
    next(err)
  }
})

app.use('/web-api', router)
http.createServer(app).listen(port, (req, res, err) => {
  if (err)
    console.log(`Error: ${err}`)

  console.log(`Port is running on http://localhost:${port}`)
})
