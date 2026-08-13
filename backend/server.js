const express = require('express');
const mysql = require('mysql');
const cors = require('cors');
const multer = require('multer');
const bodyParser = require('body-parser');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());
app.use(express.json());

const uploadDir = 'public/images';
if (!fs.existsSync(uploadDir)){
    fs.mkdirSync(uploadDir, { recursive: true });
}
app.use('/images', express.static(uploadDir));

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'admin123',
  database: 'ecommerce' 
});

db.connect(err => {
  if (err) throw err;
  console.log('Connected to MySQL (ecommerce)');
});

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});
const upload = multer({ storage });

app.post('/login', (req, res) => {
  const { email, password } = req.body;
  db.query('SELECT * FROM users WHERE email = ? AND password = ?', [email, password], (err, result) => {
    if (err) return res.status(500).json(err);
    if (result.length > 0) res.json({ message: 'Login successful' });
    else res.status(401).json({ message: 'Invalid credentials' });
  });
});

app.get('/products', (req, res) => {
  db.query('SELECT * FROM products', (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
});

app.post('/products', upload.single('image'), (req, res) => {
  const { name, price } = req.body;
  const image = req.file ? req.file.filename : '';
  db.query('INSERT INTO products (name, price, image_url) VALUES (?, ?, ?)', [name, price, image], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json({ message: 'Product added', id: result.insertId });
  });
});

app.put('/products/:id', (req, res) => {
  const { name, price } = req.body;
  db.query('UPDATE products SET name=?, price=? WHERE id=?', [name, price, req.params.id], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json({ message: 'Product updated' });
  });
});

app.delete('/products/:id', (req, res) => {
  db.query('DELETE FROM products WHERE id=?', [req.params.id], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json({ message: 'Product deleted' });
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://localhost:${PORT}`);
});