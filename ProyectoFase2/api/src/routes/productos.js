const express = require("express");
const { sql, getPool, query } = require("../db");
const { httpError } = require("../errors");

const router = express.Router();

const selectProducto = `
  SELECT
    pr.id_producto,
    pr.nombre_producto,
    pr.descripcion,
    pr.id_categoria,
    c.nombre_categoria,
    pr.id_marca,
    m.nombre_marca
  FROM producto AS pr
  INNER JOIN categoria AS c ON c.id_categoria = pr.id_categoria
  INNER JOIN marca AS m ON m.id_marca = pr.id_marca
`;

async function conExistencias(producto) {
  const existencias = await query(
    `
      SELECT
        cp.id_tienda,
        t.nombre_tienda,
        cp.precio_vigente,
        cp.existencia_actual
      FROM catalogo_producto AS cp
      INNER JOIN tienda AS t ON t.id_tienda = cp.id_tienda
      WHERE cp.id_producto = @id_producto
      ORDER BY cp.id_tienda
    `,
    { id_producto: { type: sql.Int, value: producto.id_producto } }
  );
  return { ...producto, existencias: existencias.recordset };
}

router.get("/", async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`${selectProducto} ORDER BY pr.id_producto`);
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
      .query(`${selectProducto} WHERE pr.id_producto = @id`);
    if (!result.recordset[0]) {
      next(httpError(404, "Producto no encontrado"));
      return;
    }
    res.json(await conExistencias(result.recordset[0]));
  } catch (error) {
    next(error);
  }
});

router.post("/", async (req, res, next) => {
  try {
    const { nombre_producto, descripcion, id_categoria, id_marca } = req.body;
    if (!nombre_producto || !descripcion || !id_categoria || !id_marca) {
      next(httpError(400, "Faltan campos del producto"));
      return;
    }
    const pool = await getPool();
    const tx = new sql.Transaction(pool);
    await tx.begin();
    try {
      const idResult = await new sql.Request(tx).query(
        "SELECT ISNULL(MAX(id_producto), 0) + 1 AS nuevoId FROM producto"
      );
      const id = idResult.recordset[0].nuevoId;
      await new sql.Request(tx)
        .input("id_producto", sql.Int, id)
        .input("nombre_producto", sql.VarChar(100), nombre_producto)
        .input("descripcion", sql.VarChar(200), descripcion)
        .input("id_categoria", sql.Int, id_categoria)
        .input("id_marca", sql.Int, id_marca)
        .query(`
          INSERT INTO producto (id_producto, nombre_producto, descripcion, id_categoria, id_marca)
          VALUES (@id_producto, @nombre_producto, @descripcion, @id_categoria, @id_marca)
        `);
      await tx.commit();
      const created = await pool.request().input("id", sql.Int, id).query(`${selectProducto} WHERE pr.id_producto = @id`);
      res.status(201).json(await conExistencias(created.recordset[0]));
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
    const { nombre_producto, descripcion, id_categoria, id_marca } = req.body;
    if (!nombre_producto || !descripcion || !id_categoria || !id_marca) {
      next(httpError(400, "Faltan campos del producto"));
      return;
    }
    const pool = await getPool();
    const result = await pool
      .request()
      .input("id_producto", sql.Int, Number(req.params.id))
      .input("nombre_producto", sql.VarChar(100), nombre_producto)
      .input("descripcion", sql.VarChar(200), descripcion)
      .input("id_categoria", sql.Int, id_categoria)
      .input("id_marca", sql.Int, id_marca)
      .query(`
        UPDATE producto
        SET nombre_producto = @nombre_producto,
            descripcion = @descripcion,
            id_categoria = @id_categoria,
            id_marca = @id_marca
        WHERE id_producto = @id_producto
      `);
    if (!result.rowsAffected[0]) {
      next(httpError(404, "Producto no encontrado"));
      return;
    }
    const updated = await pool
      .request()
      .input("id", sql.Int, Number(req.params.id))
      .query(`${selectProducto} WHERE pr.id_producto = @id`);
    res.json(await conExistencias(updated.recordset[0]));
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
      .query("DELETE FROM producto WHERE id_producto = @id");
    if (!result.rowsAffected[0]) {
      next(httpError(404, "Producto no encontrado"));
      return;
    }
    res.json({ mensaje: "Producto eliminado" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
