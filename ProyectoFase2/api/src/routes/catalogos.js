const express = require("express");
const { sql, getPool, nextId } = require("../db");
const { httpError } = require("../errors");

function catalogRouter(table, idColumn, columns) {
  const router = express.Router();
  const listed = columns.map((column) => column).join(", ");

  router.get("/", async (req, res, next) => {
    try {
      const pool = await getPool();
      const result = await pool.request().query(`SELECT ${idColumn}, ${listed} FROM ${table} ORDER BY ${idColumn}`);
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
        .query(`SELECT ${idColumn}, ${listed} FROM ${table} WHERE ${idColumn} = @id`);
      if (!result.recordset[0]) {
        next(httpError(404, "No encontrado"));
        return;
      }
      res.json(result.recordset[0]);
    } catch (error) {
      next(error);
    }
  });

  router.post("/", async (req, res, next) => {
    try {
      for (const column of columns) {
        if (req.body[column] === undefined || req.body[column] === null || req.body[column] === "") {
          next(httpError(400, `Falta el campo ${column}`));
          return;
        }
      }
      const pool = await getPool();
      const tx = new sql.Transaction(pool);
      await tx.begin();
      try {
        const id = await nextId(tx, table, idColumn);
        const request = new sql.Request(tx);
        request.input("id", sql.Int, id);
        const names = [idColumn];
        const values = ["@id"];
        columns.forEach((column, index) => {
          request.input(`p${index}`, req.body[column]);
          names.push(column);
          values.push(`@p${index}`);
        });
        await request.query(`INSERT INTO ${table} (${names.join(", ")}) VALUES (${values.join(", ")})`);
        await tx.commit();
        const created = await pool
          .request()
          .input("id", sql.Int, id)
          .query(`SELECT ${idColumn}, ${listed} FROM ${table} WHERE ${idColumn} = @id`);
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
      for (const column of columns) {
        if (req.body[column] === undefined || req.body[column] === null || req.body[column] === "") {
          next(httpError(400, `Falta el campo ${column}`));
          return;
        }
      }
      const pool = await getPool();
      const request = pool.request().input("id", sql.Int, Number(req.params.id));
      const sets = columns.map((column, index) => {
        request.input(`p${index}`, req.body[column]);
        return `${column} = @p${index}`;
      });
      const result = await request.query(`UPDATE ${table} SET ${sets.join(", ")} WHERE ${idColumn} = @id`);
      if (!result.rowsAffected[0]) {
        next(httpError(404, "No encontrado"));
        return;
      }
      const updated = await pool
        .request()
        .input("id", sql.Int, Number(req.params.id))
        .query(`SELECT ${idColumn}, ${listed} FROM ${table} WHERE ${idColumn} = @id`);
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
        .query(`DELETE FROM ${table} WHERE ${idColumn} = @id`);
      if (!result.rowsAffected[0]) {
        next(httpError(404, "No encontrado"));
        return;
      }
      res.json({ mensaje: "Eliminado" });
    } catch (error) {
      next(error);
    }
  });

  return router;
}

const personas = express.Router();

personas.get("/", async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query("SELECT * FROM persona ORDER BY id_persona");
    res.json(result.recordset);
  } catch (error) {
    next(error);
  }
});

personas.get("/:id", async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request().input("id", sql.Int, Number(req.params.id)).query("SELECT * FROM persona WHERE id_persona = @id");
    if (!result.recordset[0]) {
      next(httpError(404, "Persona no encontrada"));
      return;
    }
    res.json(result.recordset[0]);
  } catch (error) {
    next(error);
  }
});

personas.post("/", async (req, res, next) => {
  try {
    const correo = req.body.correo === undefined || req.body.correo === "" ? null : req.body.correo;
    const { nombres, apellidos, telefono, direccion, id_municipio } = req.body;
    if (!nombres || !apellidos || !telefono || !direccion || !id_municipio) {
      next(httpError(400, "Faltan campos de la persona"));
      return;
    }
    const pool = await getPool();
    const tx = new sql.Transaction(pool);
    await tx.begin();
    try {
      const id = await nextId(tx, "persona", "id_persona");
      await new sql.Request(tx)
        .input("id_persona", sql.Int, id)
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
      await tx.commit();
      const created = await pool.request().input("id", sql.Int, id).query("SELECT * FROM persona WHERE id_persona = @id");
      res.status(201).json(created.recordset[0]);
    } catch (error) {
      await tx.rollback();
      throw error;
    }
  } catch (error) {
    next(error);
  }
});

personas.put("/:id", async (req, res, next) => {
  try {
    const correo = req.body.correo === undefined || req.body.correo === "" ? null : req.body.correo;
    const { nombres, apellidos, telefono, direccion, id_municipio } = req.body;
    if (!nombres || !apellidos || !telefono || !direccion || !id_municipio) {
      next(httpError(400, "Faltan campos de la persona"));
      return;
    }
    const pool = await getPool();
    const result = await pool
      .request()
      .input("id_persona", sql.Int, Number(req.params.id))
      .input("nombres", sql.VarChar(80), nombres)
      .input("apellidos", sql.VarChar(80), apellidos)
      .input("telefono", sql.VarChar(20), telefono)
      .input("correo", sql.VarChar(120), correo)
      .input("direccion", sql.VarChar(150), direccion)
      .input("id_municipio", sql.Int, id_municipio)
      .query(`
        UPDATE persona
        SET nombres = @nombres, apellidos = @apellidos, telefono = @telefono,
            correo = @correo, direccion = @direccion, id_municipio = @id_municipio
        WHERE id_persona = @id_persona
      `);
    if (!result.rowsAffected[0]) {
      next(httpError(404, "Persona no encontrada"));
      return;
    }
    const updated = await pool.request().input("id", sql.Int, Number(req.params.id)).query("SELECT * FROM persona WHERE id_persona = @id");
    res.json(updated.recordset[0]);
  } catch (error) {
    next(error);
  }
});

personas.delete("/:id", async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request().input("id", sql.Int, Number(req.params.id)).query("DELETE FROM persona WHERE id_persona = @id");
    if (!result.rowsAffected[0]) {
      next(httpError(404, "Persona no encontrada"));
      return;
    }
    res.json({ mensaje: "Persona eliminada" });
  } catch (error) {
    next(error);
  }
});

const catalogo = express.Router();

catalogo.get("/", async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT cp.id_tienda, t.nombre_tienda, cp.id_producto, pr.nombre_producto, cp.precio_vigente, cp.existencia_actual
      FROM catalogo_producto AS cp
      INNER JOIN tienda AS t ON t.id_tienda = cp.id_tienda
      INNER JOIN producto AS pr ON pr.id_producto = cp.id_producto
      ORDER BY cp.id_tienda, cp.id_producto
    `);
    res.json(result.recordset);
  } catch (error) {
    next(error);
  }
});

catalogo.get("/:idTienda/:idProducto", async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool
      .request()
      .input("id_tienda", sql.Int, Number(req.params.idTienda))
      .input("id_producto", sql.Int, Number(req.params.idProducto))
      .query(`
        SELECT cp.id_tienda, t.nombre_tienda, cp.id_producto, pr.nombre_producto, cp.precio_vigente, cp.existencia_actual
        FROM catalogo_producto AS cp
        INNER JOIN tienda AS t ON t.id_tienda = cp.id_tienda
        INNER JOIN producto AS pr ON pr.id_producto = cp.id_producto
        WHERE cp.id_tienda = @id_tienda AND cp.id_producto = @id_producto
      `);
    if (!result.recordset[0]) {
      next(httpError(404, "Producto no ofrecido en esa tienda"));
      return;
    }
    res.json(result.recordset[0]);
  } catch (error) {
    next(error);
  }
});

catalogo.post("/", async (req, res, next) => {
  try {
    const { id_tienda, id_producto, precio_vigente, existencia_actual } = req.body;
    if (!id_tienda || !id_producto || precio_vigente === undefined || existencia_actual === undefined) {
      next(httpError(400, "Faltan campos del catalogo"));
      return;
    }
    const pool = await getPool();
    await pool
      .request()
      .input("id_tienda", sql.Int, id_tienda)
      .input("id_producto", sql.Int, id_producto)
      .input("precio_vigente", sql.Decimal(12, 2), precio_vigente)
      .input("existencia_actual", sql.Int, existencia_actual)
      .query(`
        INSERT INTO catalogo_producto (id_tienda, id_producto, precio_vigente, existencia_actual)
        VALUES (@id_tienda, @id_producto, @precio_vigente, @existencia_actual)
      `);
    const created = await pool
      .request()
      .input("id_tienda", sql.Int, id_tienda)
      .input("id_producto", sql.Int, id_producto)
      .query(`
        SELECT id_tienda, id_producto, precio_vigente, existencia_actual
        FROM catalogo_producto
        WHERE id_tienda = @id_tienda AND id_producto = @id_producto
      `);
    res.status(201).json(created.recordset[0]);
  } catch (error) {
    next(error);
  }
});

catalogo.put("/:idTienda/:idProducto", async (req, res, next) => {
  try {
    const { precio_vigente, existencia_actual } = req.body;
    if (precio_vigente === undefined || existencia_actual === undefined) {
      next(httpError(400, "Faltan campos del catalogo"));
      return;
    }
    const pool = await getPool();
    const result = await pool
      .request()
      .input("id_tienda", sql.Int, Number(req.params.idTienda))
      .input("id_producto", sql.Int, Number(req.params.idProducto))
      .input("precio_vigente", sql.Decimal(12, 2), precio_vigente)
      .input("existencia_actual", sql.Int, existencia_actual)
      .query(`
        UPDATE catalogo_producto
        SET precio_vigente = @precio_vigente, existencia_actual = @existencia_actual
        WHERE id_tienda = @id_tienda AND id_producto = @id_producto
      `);
    if (!result.rowsAffected[0]) {
      next(httpError(404, "Producto no ofrecido en esa tienda"));
      return;
    }
    const updated = await pool
      .request()
      .input("id_tienda", sql.Int, Number(req.params.idTienda))
      .input("id_producto", sql.Int, Number(req.params.idProducto))
      .query(`
        SELECT id_tienda, id_producto, precio_vigente, existencia_actual
        FROM catalogo_producto
        WHERE id_tienda = @id_tienda AND id_producto = @id_producto
      `);
    res.json(updated.recordset[0]);
  } catch (error) {
    next(error);
  }
});

catalogo.delete("/:idTienda/:idProducto", async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool
      .request()
      .input("id_tienda", sql.Int, Number(req.params.idTienda))
      .input("id_producto", sql.Int, Number(req.params.idProducto))
      .query("DELETE FROM catalogo_producto WHERE id_tienda = @id_tienda AND id_producto = @id_producto");
    if (!result.rowsAffected[0]) {
      next(httpError(404, "Producto no ofrecido en esa tienda"));
      return;
    }
    res.json({ mensaje: "Catalogo eliminado" });
  } catch (error) {
    next(error);
  }
});

module.exports = {
  paises: catalogRouter("pais", "id_pais", ["nombre_pais"]),
  departamentos: catalogRouter("departamento", "id_departamento", ["nombre_departamento", "id_pais"]),
  municipios: catalogRouter("municipio", "id_municipio", ["nombre_municipio", "id_departamento"]),
  tiposTienda: catalogRouter("tipo_tienda", "id_tipo_tienda", ["nombre_tipo_tienda"]),
  tiposIdentificacion: catalogRouter("tipo_identificacion", "id_tipo_identificacion", ["nombre_tipo_identificacion"]),
  cargos: catalogRouter("cargo", "id_cargo", ["nombre_cargo"]),
  categorias: catalogRouter("categoria", "id_categoria", ["nombre_categoria"]),
  marcas: catalogRouter("marca", "id_marca", ["nombre_marca"]),
  estadosVenta: catalogRouter("estado_venta", "id_estado_venta", ["nombre_estado_venta"]),
  metodosPago: catalogRouter("metodo_pago", "id_metodo_pago", ["nombre_metodo_pago"]),
  personas,
  catalogo,
};
