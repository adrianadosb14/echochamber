const express = require('express');
const app = express();

const cors = require('cors');

app.use(cors());

var bodyParser = require('body-parser');
app.use(bodyParser.json({limit: '10mb'}));

const port = 3000;
require('dotenv').config();
const fs = require('node:fs');

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

    client.query(`select * from create_user($1,$2,$3,$4);`,
        [
          req.body['i_username'],
          req.body['i_email'],
          req.body['i_password'],
          req.body['i_type']
        ])
    .then(response => {
        console.log(response.rows);
        var rows = response.rows;
        client.release();
        res.send(rows);
    })
    .catch(err => {
        client.release();
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
        client.release();
        res.send(rows);
    })
    .catch(err => {
        client.release();
        res.send(err);
    });
    
});

app.post('/api/create_post', async (req, res) => {
    const client = await pool.connect();

    client.query(`select * from create_post($1,$2,$3);`,
        [
          req.body['i_user_id'],
          req.body['i_event_id'],
          req.body['i_content']
        ])
    .then(response => {
        console.log(response.rows);
        var rows = response.rows;
        client.release();
        res.send(rows);
    })
    .catch(err => {
        client.release();
        res.send(err);
    });
    
});

app.post('/api/get_posts', async (req, res) => {
    const client = await pool.connect();

    client.query(`select * from get_posts($1);`,
        [
          req.body['i_event_id']
        ])
    .then(response => {
        console.log(response.rows);
        var rows = response.rows;
        client.release();
        res.send(rows);
    })
    .catch(err => {
        client.release();
        res.send(err);
    });
    
});

app.post('/api/get_events', async (req, res) => {
    const client = await pool.connect();

    client.query(`select * from get_events($1,$2,$3,$4,$5,$6);`, 
        [
            req.body['i_search_term'],
            req.body['i_start_date'],
            req.body['i_end_date'],
            req.body['i_longitude'],
            req.body['i_latitude'],
            req.body['i_radius'],
        ]
    )
    .then(response => {
        console.log(response.rows);
        var rows = response.rows;
        client.release();
        res.send(rows);
    })
    .catch(err => {
        console.log(err);
        client.release();
        res.send(err);
    });
    
});

app.post('/api/create_event', async (req, res) => {
    const client = await pool.connect();

    client.query(`select * from create_event($1,$2,$3,$4,$5,$6,$7);`,
        [
            req.body['i_user_id'],
            req.body['i_title'],
            req.body['i_description'],
            req.body['i_start_date'],
            req.body['i_end_date'],
            req.body['i_longitude'],
            req.body['i_latitude']
        ])
    .then(response => {
        console.log(response.rows);
        var rows = response.rows;
        client.release();
        res.send(rows);
    })
    .catch(err => {
        console.log(err);
        client.release();
        res.send(err);
    });
    
});


app.post('/api/create_event_file', async (req, res) => {
    const client = await pool.connect();

    client.query(`select * from create_event_file($1,$2,$3);`,
        [
            req.body['i_event_id'],
            req.body['i_user_id'],
            req.body['i_filename']
        ])
    .then(response => {
        console.log(response.rows[0]['o_file_id']);
        if (response.rows[0]['o_file_id'] != null) {
            var base64Str = req.body['i_content'];
            console.log(base64Str);
            var buf = Buffer.from(base64Str, 'base64');
            fs.writeFileSync(`files/${response.rows[0]['o_file_id']}`, buf);
        }
        var rows = response.rows;
        client.release();
        res.send(rows);
    })
    .catch(err => {
        console.log(err);
        client.release();
        res.send(err);
    });
});

app.post('/api/read_file', async (req, res) => {
    var fileId = req.body['i_file_id'];
    var rows = {};

    const data = fs.readFileSync(`files/${fileId}`);
    rows = {
        "o_content" : Buffer.from(data).toString('base64')
    };
    res.send(rows);
});

app.post('/api/remove_event_file', async (req, res) => {
    const client = await pool.connect();

    client.query(`select * from remove_event_file($1,$2);`,
        [
            req.body['i_event_file_id'],
            req.body['i_user_id']
        ])
    .then(response => {
        var rows = response.rows;
        client.release();
        res.send(rows);
    })
    .catch(err => {
        console.log(err);
        client.release();
        res.send(err);
    });
});

app.post('/api/get_event_files', async (req, res) => {
    const client = await pool.connect();

    client.query(`select * from get_event_files($1);`,
        [
            req.body['i_event_id'],
        ])
    .then(response => {
        var rows = response.rows;
        client.release();
        res.send(rows);
    })
    .catch(err => {
        console.log(err);
        client.release();
        res.send(err);
    });
});

app.post('/api/create_tag', async (req, res) => {
    const client = await pool.connect();

    client.query(`select * from create_tag($1, $2);`,
        [
            req.body['i_name'],
            req.body['i_color']
        ])
    .then(response => {
        var rows = response.rows;
        client.release();
        res.send(rows);
    })
    .catch(err => {
        console.log(err);
        client.release();
        res.send(err);
    });
});

app.post('/api/create_event_tag', async (req, res) => {
    const client = await pool.connect();

    client.query(`select * from create_event_tag($1, $2);`,
        [
            req.body['i_event_id'],
            req.body['i_tag_id'],
        ])
    .then(response => {
        var rows = response.rows;
        client.release();
        res.send(rows);
    })
    .catch(err => {
        console.log(err);
        client.release();
        res.send(err);
    });
});

app.post('/api/get_all_tags', async (req, res) => {
    const client = await pool.connect();

    client.query(`select * from get_all_tags();`,
        [
        ])
    .then(response => {
        var rows = response.rows;
        client.release();
        res.send(rows);
    })
    .catch(err => {
        console.log(err);
        client.release();
        res.send(err);
    });
});

app.post('/api/get_event_tags', async (req, res) => {
    const client = await pool.connect();

    client.query(`select * from get_event_tags($1);`,
        [
            req.body['i_event_id']
        ])
    .then(response => {
        var rows = response.rows;
        client.release();
        res.send(rows);
    })
    .catch(err => {
        console.log(err);
        client.release();
        res.send(err);
    });
});

app.post('/api/create_event_like', async (req, res) => {
    const client = await pool.connect();

    client.query(`select * from create_event_like($1, $2);`,
        [
            req.body['i_user_id'],
            req.body['i_event_id'],
        ])
    .then(response => {
        var rows = response.rows;
        client.release();
        res.send(rows);
    })
    .catch(err => {
        console.log(err);
        client.release();
        res.send(err);
    });
});

app.post('/api/remove_event_like', async (req, res) => {
    const client = await pool.connect();

    client.query(`select * from remove_event_like($1, $2);`,
        [
            req.body['i_user_id'],
            req.body['i_event_like_id'],
        ])
    .then(response => {
        var rows = response.rows;
        client.release();
        res.send(rows);
    })
    .catch(err => {
        console.log(err);
        client.release();
        res.send(err);
    });
});

app.post('/api/get_event_likes', async (req, res) => {
    const client = await pool.connect();

    client.query(`select * from get_event_likes($1);`,
        [
            req.body['i_event_id']
        ])
    .then(response => {
        var rows = response.rows;
        client.release();
        res.send(rows);
    })
    .catch(err => {
        console.log(err);
        client.release();
        res.send(err);
    });
});