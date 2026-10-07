const express = require("express");
const { query } = require("../db");

const router = express.Router();

router.get("/ventas-ubicacion", async (req, res, next) => {
  try {
    const result = await query("SELECT * FROM Vista_Ventas_Ubicacion");
    res.json(result.recordset);
  } catch (error) {
    next(error);
  }
});

router.get("/top-productos", async (req, res, next) => {
  try {
    const result = await query("SELECT * FROM Vista_Top_Productos");
    res.json(result.recordset);
  } catch (error) {
    next(error);
  }
});

router.get("/saldos-pendientes", async (req, res, next) => {
  try {
    const result = await query("SELECT * FROM Vista_Saldos_Pendientes");
    res.json(result.recordset);
  } catch (error) {
    next(error);
  }
});

module.exports = router;
