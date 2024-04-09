const mysql = require("mysql2");
require("dotenv").config();

const connection = mysql.createConnection({
  host: "localhost",
  user: process.env.MYSQL_USERNAME,
  password: process.env.MYSQL_PASSWORD,
});

const connectDB = () => {
  return connection.connect();
};

const setupDB = () => {
  // Create database  
  const createDatabaseQuery = "CREATE DATABASE IF NOT EXISTS RIDE_SHARE;";
  connection.query(createDatabaseQuery);

  // Create table
};

module.exports = { connectDB, setupDB };
