const express = require("express");
const { sql, getPool } = require("../db");
const { httpError } = require("../errors");

const router = express.Router();

const selectPago = `
  SELECT
    p.id_pago,
    p.monto,
    p.id_metodo_pago,
    mp.nombre_metodo_pago,
    p.id_venta
  FROM pago AS p
  INNER JOIN metodo_pago AS mp ON mp.id_metodo_pago = p.id_metodo_pago
`;

router.get("/", async (req, res, next) => {
  try {
    const pool = await getPool();
    const request = pool.request();
    let filtro = "";
    if (req.query.id_venta) {
      request.input("id_venta", sql.Int, Number(req.query.id_venta));
      filtro = " WHERE p.id_venta = @id_venta";
    }
    const result = await request.query(`${selectPago}${filtro} ORDER BY p.id_pago`);
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
      .query(`${selectPago} WHERE p.id_pago = @id`);
    if (!result.recordset[0]) {
      next(httpError(404, "Pago no encontrado"));
      return;
    }
    res.json(result.recordset[0]);
  } catch (error) {
    next(error);
  }
});

router.post("/", async (req, res, next) => {
  try {
    const { monto, id_metodo_pago, id_venta } = req.body;
    if (!monto || !id_metodo_pago || !id_venta) {
      next(httpError(400, "Faltan campos del pago"));
      return;
    }
    const pool = await getPool();
    const tx = new sql.Transaction(pool);
    await tx.begin();
    try {
      const id = (await new sql.Request(tx).query("SELECT ISNULL(MAX(id_pago), 0) + 1 AS nuevoId FROM pago")).recordset[0].nuevoId;
      await new sql.Request(tx)
        .input("id_pago", sql.Int, id)
        .input("monto", sql.Decimal(12, 2), monto)
        .input("id_metodo_pago", sql.Int, id_metodo_pago)
        .input("id_venta", sql.Int, id_venta)
        .query(`
          INSERT INTO pago (id_pago, monto, id_metodo_pago, id_venta)
          VALUES (@id_pago, @monto, @id_metodo_pago, @id_venta)
        `);
      await tx.commit();
      const created = await pool.request().input("id", sql.Int, id).query(`${selectPago} WHERE p.id_pago = @id`);
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
    const { monto, id_metodo_pago, id_venta } = req.body;
    if (!monto || !id_metodo_pago || !id_venta) {
      next(httpError(400, "Faltan campos del pago"));
      return;
    }
    const pool = await getPool();
    const result = await pool
      .request()
      .input("id_pago", sql.Int, Number(req.params.id))
      .input("monto", sql.Decimal(12, 2), monto)
      .input("id_metodo_pago", sql.Int, id_metodo_pago)
      .input("id_venta", sql.Int, id_venta)
      .query(`
        UPDATE pago
        SET monto = @monto,
            id_metodo_pago = @id_metodo_pago,
            id_venta = @id_venta
        WHERE id_pago = @id_pago
      `);
    if (!result.rowsAffected[0]) {
      next(httpError(404, "Pago no encontrado"));
      return;
    }
    const updated = await pool.request().input("id", sql.Int, Number(req.params.id)).query(`${selectPago} WHERE p.id_pago = @id`);
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
      .query("DELETE FROM pago WHERE id_pago = @id");
    if (!result.rowsAffected[0]) {
      next(httpError(404, "Pago no encontrado"));
      return;
    }
    res.json({ mensaje: "Pago eliminado" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
