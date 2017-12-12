const express = require('express');
const app = express();
const glob = require('glob');
const fs = require('fs');

function getFiles() {
    return new Promise((resolve, reject) => {
        glob('./**/*.lua', (error, files) => {
            if (error) {
                reject(error);
            } else {
                resolve(files.map((file) => file.slice(2, -4)));
            }
        });
    });
}

app.get('/', async(req, res) => {
    const files = await getFiles();
    res.end(files.join('\n'));
});

app.get('/*', async(req, res) => {
    const path = req.path.replace('..', '');
    try {
        res.end(fs.readFileSync(`.${path}.lua`));
    } catch(error) {
        res.status(404);
        res.end();
    }
});


app.listen(8080);