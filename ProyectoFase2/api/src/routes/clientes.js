const express = require("express");
const { sql, getPool } = require("../db");
const { httpError } = require("../errors");

const router = express.Router();

const selectCliente = `
  SELECT
    c.id_cliente,
    c.id_tipo_identificacion,
    ti.nombre_tipo_identificacion,
    c.numero_identificacion,
    p.id_persona,
    p.nombres,
    p.apellidos,
    p.telefono,
    p.correo,
    p.direccion,
    p.id_municipio,
    m.nombre_municipio
  FROM cliente AS c
  INNER JOIN persona AS p ON p.id_persona = c.id_persona
  INNER JOIN tipo_identificacion AS ti ON ti.id_tipo_identificacion = c.id_tipo_identificacion
  INNER JOIN municipio AS m ON m.id_municipio = p.id_municipio
`;

router.get("/", async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`${selectCliente} ORDER BY c.id_cliente`);
    res.json(result.recordset);
  } catch (error) {
    next(error);
  }
});

router.get("/:id", async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool
      .request()
      .input("id", sql.Int, Number(req.params.id))
      .query(`${selectCliente} WHERE c.id_cliente = @id`);
    if (!result.recordset[0]) {
      next(httpError(404, "Cliente no encontrado"));
      return;
    }
    res.json(result.recordset[0]);
  } catch (error) {
    next(error);
  }
});

router.post("/", async (req, res, next) => {
  try {
    const correo = req.body.correo === undefined || req.body.correo === "" ? null : req.body.correo;
    const { nombres, apellidos, telefono, direccion, id_municipio, id_tipo_identificacion, numero_identificacion } = req.body;
    if (!nombres || !apellidos || !telefono || !direccion || !id_municipio || !id_tipo_identificacion || !numero_identificacion) {
      next(httpError(400, "Faltan campos del cliente"));
      return;
    }
    const pool = await getPool();
    const tx = new sql.Transaction(pool);
    await tx.begin();
    try {
      const idPersona = (await new sql.Request(tx).query("SELECT ISNULL(MAX(id_persona), 0) + 1 AS nuevoId FROM persona")).recordset[0].nuevoId;
      const idCliente = (await new sql.Request(tx).query("SELECT ISNULL(MAX(id_cliente), 0) + 1 AS nuevoId FROM cliente")).recordset[0].nuevoId;
      await new sql.Request(tx)
        .input("id_persona", sql.Int, idPersona)
        .input("nombres", sql.VarChar(80), nombres)
        .input("apellidos", sql.VarChar(80), apellidos)
        .input("telefono", sql.VarChar(20), telefono)
        .input("correo", sql.VarChar(120), correo)
        .input("direccion", sql.VarChar(150), direccion)
        .input("id_municipio", sql.Int, id_municipio)
        .query(`
          INSERT INTO persona (id_persona, nombres, apellidos, telefono, correo, direccion, id_municipio)
          VALUES (@id_persona, @nombres, @apellidos, @telefono, @correo, @direccion, @id_municipio)
        `);
      await new sql.Request(tx)
        .input("id_cliente", sql.Int, idCliente)
        .input("id_tipo_identificacion", sql.Int, id_tipo_identificacion)
        .input("numero_identificacion", sql.VarChar(20), numero_identificacion)
        .input("id_persona", sql.Int, idPersona)
        .query(`
          INSERT INTO cliente (id_cliente, id_tipo_identificacion, numero_identificacion, id_persona)
          VALUES (@id_cliente, @id_tipo_identificacion, @numero_identificacion, @id_persona)
        `);
      await tx.commit();
      const created = await pool.request().input("id", sql.Int, idCliente).query(`${selectCliente} WHERE c.id_cliente = @id`);
      res.status(201).json(created.recordset[0]);
    } catch (error) {
      await tx.rollback();
      throw error;
    }
  } catch (error) {
    next(error);
  }
});

router.put("/:id", async (req, res, next) => {
  try {
    const correo = req.body.correo === undefined || req.body.correo === "" ? null : req.body.correo;
    const { nombres, apellidos, telefono, direccion, id_municipio, id_tipo_identificacion, numero_identificacion } = req.body;
    if (!nombres || !apellidos || !telefono || !direccion || !id_municipio || !id_tipo_identificacion || !numero_identificacion) {
      next(httpError(400, "Faltan campos del cliente"));
      return;
    }
    const pool = await getPool();
    const actual = await pool
      .request()
      .input("id", sql.Int, Number(req.params.id))
      .query("SELECT id_persona FROM cliente WHERE id_cliente = @id");
    if (!actual.recordset[0]) {
      next(httpError(404, "Cliente no encontrado"));
      return;
    }
    const tx = new sql.Transaction(pool);
    await tx.begin();
    try {
      await new sql.Request(tx)
        .input("id_persona", sql.Int, actual.recordset[0].id_persona)
        .input("nombres", sql.VarChar(80), nombres)
        .input("apellidos", sql.VarChar(80), apellidos)
        .input("telefono", sql.VarChar(20), telefono)
        .input("correo", sql.VarChar(120), correo)
        .input("direccion", sql.VarChar(150), direccion)
        .input("id_municipio", sql.Int, id_municipio)
        .query(`
          UPDATE persona
          SET nombres = @nombres,
              apellidos = @apellidos,
              telefono = @telefono,
              correo = @correo,
              direccion = @direccion,
              id_municipio = @id_municipio
          WHERE id_persona = @id_persona
        `);
      await new sql.Request(tx)
        .input("id_cliente", sql.Int, Number(req.params.id))
        .input("id_tipo_identificacion", sql.Int, id_tipo_identificacion)
        .input("numero_identificacion", sql.VarChar(20), numero_identificacion)
        .query(`
          UPDATE cliente
          SET id_tipo_identificacion = @id_tipo_identificacion,
              numero_identificacion = @numero_identificacion
          WHERE id_cliente = @id_cliente
        `);
      await tx.commit();
      const updated = await pool.request().input("id", sql.Int, Number(req.params.id)).query(`${selectCliente} WHERE c.id_cliente = @id`);
      res.json(updated.recordset[0]);
    } catch (error) {
      await tx.rollback();
      throw error;
    }
  } catch (error) {
    next(error);
  }
});

router.delete("/:id", async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool
      .request()
      .input("id", sql.Int, Number(req.params.id))
      .query("DELETE FROM cliente WHERE id_cliente = @id");
    if (!result.rowsAffected[0]) {
      next(httpError(404, "Cliente no encontrado"));
      return;
    }
    res.json({ mensaje: "Cliente eliminado" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
