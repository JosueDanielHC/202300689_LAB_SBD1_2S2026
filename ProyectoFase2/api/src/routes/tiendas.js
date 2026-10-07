const express = require("express");
const { sql, getPool, nextId } = require("../db");
const { httpError } = require("../errors");

const router = express.Router();

const selectTienda = `
  SELECT
    t.id_tienda,
    t.nombre_tienda,
    t.direccion,
    t.telefono,
    t.id_municipio,
    m.nombre_municipio,
    t.id_tipo_tienda,
    tt.nombre_tipo_tienda
  FROM tienda AS t
  INNER JOIN municipio AS m ON m.id_municipio = t.id_municipio
  INNER JOIN tipo_tienda AS tt ON tt.id_tipo_tienda = t.id_tipo_tienda
`;

router.get("/", async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`${selectTienda} ORDER BY t.id_tienda`);
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
      .query(`${selectTienda} WHERE t.id_tienda = @id`);
    if (!result.recordset[0]) {
      next(httpError(404, "Tienda no encontrada"));
      return;
    }
    res.json(result.recordset[0]);
  } catch (error) {
    next(error);
  }
});

router.post("/", async (req, res, next) => {
  try {
    const { nombre_tienda, direccion, telefono, id_municipio, id_tipo_tienda } = req.body;
    if (!nombre_tienda || !direccion || !telefono || !id_municipio || !id_tipo_tienda) {
      next(httpError(400, "Faltan campos de la tienda"));
      return;
    }
    const pool = await getPool();
    const tx = new sql.Transaction(pool);
    await tx.begin();
    try {
      const id = await nextId(tx, "tienda", "id_tienda");
      await new sql.Request(tx)
        .input("id_tienda", sql.Int, id)
        .input("nombre_tienda", sql.VarChar(100), nombre_tienda)
        .input("direccion", sql.VarChar(150), direccion)
        .input("telefono", sql.VarChar(20), telefono)
        .input("id_municipio", sql.Int, id_municipio)
        .input("id_tipo_tienda", sql.Int, id_tipo_tienda)
        .query(`
          INSERT INTO tienda (id_tienda, nombre_tienda, direccion, telefono, id_municipio, id_tipo_tienda)
          VALUES (@id_tienda, @nombre_tienda, @direccion, @telefono, @id_municipio, @id_tipo_tienda)
        `);
      await tx.commit();
      const created = await pool.request().input("id", sql.Int, id).query(`${selectTienda} WHERE t.id_tienda = @id`);
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
    const { nombre_tienda, direccion, telefono, id_municipio, id_tipo_tienda } = req.body;
    if (!nombre_tienda || !direccion || !telefono || !id_municipio || !id_tipo_tienda) {
      next(httpError(400, "Faltan campos de la tienda"));
      return;
    }
    const pool = await getPool();
    const result = await pool
      .request()
      .input("id_tienda", sql.Int, Number(req.params.id))
      .input("nombre_tienda", sql.VarChar(100), nombre_tienda)
      .input("direccion", sql.VarChar(150), direccion)
      .input("telefono", sql.VarChar(20), telefono)
      .input("id_municipio", sql.Int, id_municipio)
      .input("id_tipo_tienda", sql.Int, id_tipo_tienda)
      .query(`
        UPDATE tienda
        SET nombre_tienda = @nombre_tienda,
            direccion = @direccion,
            telefono = @telefono,
            id_municipio = @id_municipio,
            id_tipo_tienda = @id_tipo_tienda
        WHERE id_tienda = @id_tienda
      `);
    if (!result.rowsAffected[0]) {
      next(httpError(404, "Tienda no encontrada"));
      return;
    }
    const updated = await pool
      .request()
      .input("id", sql.Int, Number(req.params.id))
      .query(`${selectTienda} WHERE t.id_tienda = @id`);
    res.json(updated.recordset[0]);
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
      .query("DELETE FROM tienda WHERE id_tienda = @id");
    if (!result.rowsAffected[0]) {
      next(httpError(404, "Tienda no encontrada"));
      return;
    }
    res.json({ mensaje: "Tienda eliminada" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
