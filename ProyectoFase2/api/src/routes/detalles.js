const express = require("express");
const { sql, getPool } = require("../db");
const { httpError } = require("../errors");

const router = express.Router();

const selectDetalle = `
  SELECT
    d.id_venta,
    d.id_producto,
    pr.nombre_producto,
    d.cantidad,
    d.precio_unitario,
    d.subtotal
  FROM detalle_venta AS d
  INNER JOIN producto AS pr ON pr.id_producto = d.id_producto
`;

router.get("/", async (req, res, next) => {
  try {
    const pool = await getPool();
    const request = pool.request();
    let filtro = "";
    if (req.query.id_venta) {
      request.input("id_venta", sql.Int, Number(req.query.id_venta));
      filtro = " WHERE d.id_venta = @id_venta";
    }
    const result = await request.query(`${selectDetalle}${filtro} ORDER BY d.id_venta, d.id_producto`);
    res.json(result.recordset);
  } catch (error) {
    next(error);
  }
});

router.get("/:idVenta/:idProducto", async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool
      .request()
      .input("id_venta", sql.Int, Number(req.params.idVenta))
      .input("id_producto", sql.Int, Number(req.params.idProducto))
      .query(`${selectDetalle} WHERE d.id_venta = @id_venta AND d.id_producto = @id_producto`);
    if (!result.recordset[0]) {
      next(httpError(404, "Detalle no encontrado"));
      return;
    }
    res.json(result.recordset[0]);
  } catch (error) {
    next(error);
  }
});

router.post("/", async (req, res, next) => {
  try {
    const { id_venta, id_producto, cantidad, precio_unitario } = req.body;
    if (!id_venta || !id_producto || !cantidad || !precio_unitario) {
      next(httpError(400, "Faltan campos del detalle de venta"));
      return;
    }
    const pool = await getPool();
    const tx = new sql.Transaction(pool);
    await tx.begin();
    try {
      await new sql.Request(tx)
        .input("id_venta", sql.Int, id_venta)
        .input("id_producto", sql.Int, id_producto)
        .input("cantidad", sql.Int, cantidad)
        .input("precio_unitario", sql.Decimal(12, 2), precio_unitario)
        .query(`
          INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario, subtotal)
          VALUES (@id_venta, @id_producto, @cantidad, @precio_unitario, @cantidad * @precio_unitario)
        `);
      await tx.commit();
      const created = await pool
        .request()
        .input("id_venta", sql.Int, id_venta)
        .input("id_producto", sql.Int, id_producto)
        .query(`${selectDetalle} WHERE d.id_venta = @id_venta AND d.id_producto = @id_producto`);
      res.status(201).json(created.recordset[0]);
    } catch (error) {
      try {
        await tx.rollback();
      } catch (rollbackError) {
        // El trigger Insert_Detalle ya hizo ROLLBACK cuando no hay stock.
      }
      throw error;
    }
  } catch (error) {
    next(error);
  }
});

router.put("/:idVenta/:idProducto", async (req, res, next) => {
  try {
    const { cantidad, precio_unitario } = req.body;
    if (!cantidad || !precio_unitario) {
      next(httpError(400, "Faltan campos del detalle de venta"));
      return;
    }
    const pool = await getPool();
    const result = await pool
      .request()
      .input("id_venta", sql.Int, Number(req.params.idVenta))
      .input("id_producto", sql.Int, Number(req.params.idProducto))
      .input("cantidad", sql.Int, cantidad)
      .input("precio_unitario", sql.Decimal(12, 2), precio_unitario)
      .query(`
        UPDATE detalle_venta
        SET cantidad = @cantidad,
            precio_unitario = @precio_unitario,
            subtotal = @cantidad * @precio_unitario
        WHERE id_venta = @id_venta AND id_producto = @id_producto
      `);
    if (!result.rowsAffected[0]) {
      next(httpError(404, "Detalle no encontrado"));
      return;
    }
    const updated = await pool
      .request()
      .input("id_venta", sql.Int, Number(req.params.idVenta))
      .input("id_producto", sql.Int, Number(req.params.idProducto))
      .query(`${selectDetalle} WHERE d.id_venta = @id_venta AND d.id_producto = @id_producto`);
    res.json(updated.recordset[0]);
  } catch (error) {
    next(error);
  }
});

router.delete("/:idVenta/:idProducto", async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool
      .request()
      .input("id_venta", sql.Int, Number(req.params.idVenta))
      .input("id_producto", sql.Int, Number(req.params.idProducto))
      .query("DELETE FROM detalle_venta WHERE id_venta = @id_venta AND id_producto = @id_producto");
    if (!result.rowsAffected[0]) {
      next(httpError(404, "Detalle no encontrado"));
      return;
    }
    res.json({ mensaje: "Detalle eliminado" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
