const express = require("express");
const { sql, getPool } = require("../db");
const { httpError } = require("../errors");

const router = express.Router();

const selectVenta = `
  SELECT
    v.id_venta,
    v.fecha_venta,
    v.id_tienda,
    t.nombre_tienda,
    v.id_empleado,
    v.id_cliente,
    v.id_estado_venta,
    ev.nombre_estado_venta,
    (
      SELECT ISNULL(SUM(d.subtotal), 0)
      FROM detalle_venta AS d
      WHERE d.id_venta = v.id_venta
    ) AS total_venta,
    (
      SELECT ISNULL(SUM(p.monto), 0)
      FROM pago AS p
      WHERE p.id_venta = v.id_venta
    ) AS monto_pagado
  FROM venta AS v
  INNER JOIN tienda AS t ON t.id_tienda = v.id_tienda
  INNER JOIN estado_venta AS ev ON ev.id_estado_venta = v.id_estado_venta
`;

router.get("/", async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`${selectVenta} ORDER BY v.id_venta`);
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
      .query(`${selectVenta} WHERE v.id_venta = @id`);
    if (!result.recordset[0]) {
      next(httpError(404, "Venta no encontrada"));
      return;
    }
    res.json(result.recordset[0]);
  } catch (error) {
    next(error);
  }
});

router.post("/", async (req, res, next) => {
  try {
    const { fecha_venta, id_tienda, id_empleado, id_cliente } = req.body;
    let { id_estado_venta } = req.body;
    if (!fecha_venta || !id_tienda || !id_empleado || !id_cliente) {
      next(httpError(400, "Faltan campos de la venta"));
      return;
    }
    const pool = await getPool();
    if (!id_estado_venta) {
      const estado = await pool.request().query(`
        SELECT id_estado_venta
        FROM estado_venta
        WHERE nombre_estado_venta = 'REGISTRADA'
      `);
      id_estado_venta = estado.recordset[0].id_estado_venta;
    }
    const tx = new sql.Transaction(pool);
    await tx.begin();
    try {
      const id = (await new sql.Request(tx).query("SELECT ISNULL(MAX(id_venta), 0) + 1 AS nuevoId FROM venta")).recordset[0].nuevoId;
      await new sql.Request(tx)
        .input("id_venta", sql.Int, id)
        .input("fecha_venta", sql.Date, fecha_venta)
        .input("id_tienda", sql.Int, id_tienda)
        .input("id_empleado", sql.Int, id_empleado)
        .input("id_cliente", sql.Int, id_cliente)
        .input("id_estado_venta", sql.Int, id_estado_venta)
        .query(`
          INSERT INTO venta (id_venta, fecha_venta, id_tienda, id_empleado, id_cliente, id_estado_venta)
          VALUES (@id_venta, @fecha_venta, @id_tienda, @id_empleado, @id_cliente, @id_estado_venta)
        `);
      await tx.commit();
      const created = await pool.request().input("id", sql.Int, id).query(`${selectVenta} WHERE v.id_venta = @id`);
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
    const { fecha_venta, id_tienda, id_empleado, id_cliente, id_estado_venta } = req.body;
    if (!fecha_venta || !id_tienda || !id_empleado || !id_cliente || !id_estado_venta) {
      next(httpError(400, "Faltan campos de la venta"));
      return;
    }
    const pool = await getPool();
    const result = await pool
      .request()
      .input("id_venta", sql.Int, Number(req.params.id))
      .input("fecha_venta", sql.Date, fecha_venta)
      .input("id_tienda", sql.Int, id_tienda)
      .input("id_empleado", sql.Int, id_empleado)
      .input("id_cliente", sql.Int, id_cliente)
      .input("id_estado_venta", sql.Int, id_estado_venta)
      .query(`
        UPDATE venta
        SET fecha_venta = @fecha_venta,
            id_tienda = @id_tienda,
            id_empleado = @id_empleado,
            id_cliente = @id_cliente,
            id_estado_venta = @id_estado_venta
        WHERE id_venta = @id_venta
      `);
    if (!result.rowsAffected[0]) {
      next(httpError(404, "Venta no encontrada"));
      return;
    }
    const updated = await pool.request().input("id", sql.Int, Number(req.params.id)).query(`${selectVenta} WHERE v.id_venta = @id`);
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
      .query("DELETE FROM venta WHERE id_venta = @id");
    if (!result.rowsAffected[0]) {
      next(httpError(404, "Venta no encontrada"));
      return;
    }
    res.json({ mensaje: "Venta eliminada" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
