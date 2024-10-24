const express = require('express');
const app = express();

const cors = require('cors');

app.use(cors());

var bodyParser = require('body-parser');
app.use(bodyParser.json());

const port = 3000;
require('dotenv').config();

// Express
app.get('/', (req, res) => {
    res.send('Hello World!');
   });
   
app.listen(port, () => {
 console.log(`Server running at http://localhost:${port}`);
});

// PostgreSQL connection
var pg = require('pg');
const dbConfig = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    host: process.env.DB_HOST,
    port: '5432',
    database: process.env.DB_DATABASE
};
const pool = new pg.Pool(dbConfig);

pool.on('error', (err, client) => {
    console.error('Unexpected error on idle client', err)
    process.exit(-1)
  });

// Endpoints
app.post('/api/create_user', async (req, res) => {
    const client = await pool.connect();

    client.query(`select * from create_user($1,$2,$3,$4,$5,$6);`,
        [
          req.body['i_username'],
          req.body['i_email'],
          req.body['i_password'],
          req.body['i_description'],
          req.body['i_avatar'],
          req.body['i_type']
        ])
    .then(response => {
        console.log(response.rows);
        var rows = response.rows;
        client.end();
        res.send(rows);
    })
    .catch(err => {
        client.end();
        res.send(err);
    });
    
});

app.post('/api/login_user', async (req, res) => {
    const client = await pool.connect();

    client.query(`select * from login_user($1,$2);`,
        [
          req.body['i_email'],
          req.body['i_password']
        ])
    .then(response => {
        console.log(response.rows);
        var rows = response.rows;
        client.end();
        res.send(rows);
    })
    .catch(err => {
        client.end();
        res.send(err);
    });
    
});

app.post('/api/create_post', async (req, res) => {
    const client = await pool.connect();

    client.query(`select * from create_post($1,$2);`,
        [
          req.body['i_user_id'],
          req.body['i_content']
        ])
    .then(response => {
        console.log(response.rows);
        var rows = response.rows;
        client.end();
        res.send(rows);
    })
    .catch(err => {
        client.end();
        res.send(err);
    });
    
});