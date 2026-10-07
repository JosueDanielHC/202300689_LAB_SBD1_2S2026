const sql = require("mssql");

const config = {
  server: process.env.DB_SERVER || "localhost",
  port: Number(process.env.DB_PORT || 1433),
  user: process.env.DB_USER || "sa",
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE || "ComercialLaEstrella",
  options: {
    encrypt: true,
    trustServerCertificate: true,
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000,
  },
};

let poolPromise;

function getPool() {
  if (!poolPromise) {
    poolPromise = new sql.ConnectionPool(config).connect();
  }
  return poolPromise;
}

async function query(text, params = {}) {
  const pool = await getPool();
  const request = pool.request();
  bind(request, params);
  return request.query(text);
}

async function nextId(executor, table, column) {
  const request = executor.request();
  const result = await request.query(
    `SELECT ISNULL(MAX(${column}), 0) + 1 AS nuevoId FROM ${table}`
  );
  return result.recordset[0].nuevoId;
}

function bind(request, params) {
  for (const [name, spec] of Object.entries(params)) {
    if (spec && typeof spec === "object" && Object.prototype.hasOwnProperty.call(spec, "type")) {
      request.input(name, spec.type, spec.value);
    } else {
      request.input(name, spec);
    }
  }
}

module.exports = {
  sql,
  getPool,
  query,
  nextId,
  bind,
};
