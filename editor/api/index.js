const fs = require('fs')
const path = require('path')
const express = require('express')
const bodyParser = require('body-parser')
const app = express()

app.use(bodyParser.json())

const dictionaryPath = path.resolve(__dirname, '../dictionaries')
const dictionaries = ['conversation', 'badword', 'greeting', 'leave', 'fallback']

app.get('/dictionaries', (req, res) => {
  const name = req.query.name
  if (!dictionaries.includes(name)) {
    res.status(404).json({})
  } else {
    const filePath = path.join(dictionaryPath, `${name}.json`)
    fs.readFile(filePath, (err, data) => {
      if (err != null) {
        res.status(500).send(err.message)
      } else {
        res.json(JSON.parse(data))
      }
    })
  }
})

app.post('/dictionaries', (req, res) => {
  const name = req.body.name
  if (!dictionaries.includes(name)) {
    res.status(404).json({})
  } else {
    const filePath = path.join(dictionaryPath, `${name}.json`)
    fs.writeFile(filePath, JSON.stringify(req.body.data, null, 2), (err) => {
      if (err != null) {
        res.status(500).send(err.message)
      } else {
        res.json({})
      }
    })
  }
})

module.exports = {
  path: '/api',
  handler: app,
}
