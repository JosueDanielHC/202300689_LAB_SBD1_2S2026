const express = require("express");
const { sql, getPool } = require("../db");
const { httpError } = require("../errors");

const router = express.Router();

const selectEmpleado = `
  SELECT
    e.id_empleado,
    e.fecha_contratacion,
    e.id_tienda,
    t.nombre_tienda,
    e.id_cargo,
    c.nombre_cargo,
    p.id_persona,
    p.nombres,
    p.apellidos,
    p.telefono,
    p.correo,
    p.direccion,
    p.id_municipio,
    m.nombre_municipio
  FROM empleado AS e
  INNER JOIN persona AS p ON p.id_persona = e.id_persona
  INNER JOIN tienda AS t ON t.id_tienda = e.id_tienda
  INNER JOIN cargo AS c ON c.id_cargo = e.id_cargo
  INNER JOIN municipio AS m ON m.id_municipio = p.id_municipio
`;

function leerPersona(body) {
  const correo = body.correo === undefined || body.correo === "" ? null : body.correo;
  return {
    nombres: body.nombres,
    apellidos: body.apellidos,
    telefono: body.telefono,
    correo,
    direccion: body.direccion,
    id_municipio: body.id_municipio,
  };
}

router.get("/", async (req, res, next) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`${selectEmpleado} ORDER BY e.id_empleado`);
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
      .query(`${selectEmpleado} WHERE e.id_empleado = @id`);
    if (!result.recordset[0]) {
      next(httpError(404, "Empleado no encontrado"));
      return;
    }
    res.json(result.recordset[0]);
  } catch (error) {
    next(error);
  }
});

router.post("/", async (req, res, next) => {
  try {
    const persona = leerPersona(req.body);
    const { fecha_contratacion, id_tienda, id_cargo } = req.body;
    if (!persona.nombres || !persona.apellidos || !persona.telefono || !persona.direccion || !persona.id_municipio || !fecha_contratacion || !id_tienda || !id_cargo) {
      next(httpError(400, "Faltan campos del empleado"));
      return;
    }
    const pool = await getPool();
    const tx = new sql.Transaction(pool);
    await tx.begin();
    try {
      const idPersona = (await new sql.Request(tx).query("SELECT ISNULL(MAX(id_persona), 0) + 1 AS nuevoId FROM persona")).recordset[0].nuevoId;
      const idEmpleado = (await new sql.Request(tx).query("SELECT ISNULL(MAX(id_empleado), 0) + 1 AS nuevoId FROM empleado")).recordset[0].nuevoId;
      await new sql.Request(tx)
        .input("id_persona", sql.Int, idPersona)
        .input("nombres", sql.VarChar(80), persona.nombres)
        .input("apellidos", sql.VarChar(80), persona.apellidos)
        .input("telefono", sql.VarChar(20), persona.telefono)
        .input("correo", sql.VarChar(120), persona.correo)
        .input("direccion", sql.VarChar(150), persona.direccion)
        .input("id_municipio", sql.Int, persona.id_municipio)
        .query(`
          INSERT INTO persona (id_persona, nombres, apellidos, telefono, correo, direccion, id_municipio)
          VALUES (@id_persona, @nombres, @apellidos, @telefono, @correo, @direccion, @id_municipio)
        `);
      await new sql.Request(tx)
        .input("id_empleado", sql.Int, idEmpleado)
        .input("fecha_contratacion", sql.Date, fecha_contratacion)
        .input("id_tienda", sql.Int, id_tienda)
        .input("id_cargo", sql.Int, id_cargo)
        .input("id_persona", sql.Int, idPersona)
        .query(`
          INSERT INTO empleado (id_empleado, fecha_contratacion, id_tienda, id_cargo, id_persona)
          VALUES (@id_empleado, @fecha_contratacion, @id_tienda, @id_cargo, @id_persona)
        `);
      await tx.commit();
      const created = await pool.request().input("id", sql.Int, idEmpleado).query(`${selectEmpleado} WHERE e.id_empleado = @id`);
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
    const persona = leerPersona(req.body);
    const { fecha_contratacion, id_tienda, id_cargo } = req.body;
    if (!persona.nombres || !persona.apellidos || !persona.telefono || !persona.direccion || !persona.id_municipio || !fecha_contratacion || !id_tienda || !id_cargo) {
      next(httpError(400, "Faltan campos del empleado"));
      return;
    }
    const pool = await getPool();
    const actual = await pool
      .request()
      .input("id", sql.Int, Number(req.params.id))
      .query("SELECT id_persona FROM empleado WHERE id_empleado = @id");
    if (!actual.recordset[0]) {
      next(httpError(404, "Empleado no encontrado"));
      return;
    }
    const tx = new sql.Transaction(pool);
    await tx.begin();
    try {
      await new sql.Request(tx)
        .input("id_persona", sql.Int, actual.recordset[0].id_persona)
        .input("nombres", sql.VarChar(80), persona.nombres)
        .input("apellidos", sql.VarChar(80), persona.apellidos)
        .input("telefono", sql.VarChar(20), persona.telefono)
        .input("correo", sql.VarChar(120), persona.correo)
        .input("direccion", sql.VarChar(150), persona.direccion)
        .input("id_municipio", sql.Int, persona.id_municipio)
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
        .input("id_empleado", sql.Int, Number(req.params.id))
        .input("fecha_contratacion", sql.Date, fecha_contratacion)
        .input("id_tienda", sql.Int, id_tienda)
        .input("id_cargo", sql.Int, id_cargo)
        .query(`
          UPDATE empleado
          SET fecha_contratacion = @fecha_contratacion,
              id_tienda = @id_tienda,
              id_cargo = @id_cargo
          WHERE id_empleado = @id_empleado
        `);
      await tx.commit();
      const updated = await pool.request().input("id", sql.Int, Number(req.params.id)).query(`${selectEmpleado} WHERE e.id_empleado = @id`);
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
      .query("DELETE FROM empleado WHERE id_empleado = @id");
    if (!result.rowsAffected[0]) {
      next(httpError(404, "Empleado no encontrado"));
      return;
    }
    res.json({ mensaje: "Empleado eliminado" });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
