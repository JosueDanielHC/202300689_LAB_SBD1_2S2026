require("dotenv").config();

const express = require("express");
const { query } = require("./db");
const { sendSqlError } = require("./errors");
const catalogos = require("./routes/catalogos");

const app = express();
app.use(express.json());

app.get("/", (req, res) => {
  res.json({
    servicio: "Comercial La Estrella",
    mensaje: "La API no tiene pagina web. Usa estas rutas.",
    rutas: [
      "/api/health",
      "/api/clientes",
      "/api/productos",
      "/api/tiendas",
      "/api/empleados",
      "/api/ventas",
      "/api/pagos",
      "/api/detalles-venta",
      "/api/reportes/ventas-ubicacion",
      "/api/reportes/top-productos",
      "/api/reportes/saldos-pendientes",
    ],
  });
});

app.get("/api/health", async (req, res, next) => {
  try {
    await query("SELECT 1 AS ok");
    res.json({ ok: true, servicio: "Comercial La Estrella" });
  } catch (error) {
    next(error);
  }
});

app.use("/api/paises", catalogos.paises);
app.use("/api/departamentos", catalogos.departamentos);
app.use("/api/municipios", catalogos.municipios);
app.use("/api/tipos-tienda", catalogos.tiposTienda);
app.use("/api/tipos-identificacion", catalogos.tiposIdentificacion);
app.use("/api/cargos", catalogos.cargos);
app.use("/api/categorias", catalogos.categorias);
app.use("/api/marcas", catalogos.marcas);
app.use("/api/estados-venta", catalogos.estadosVenta);
app.use("/api/metodos-pago", catalogos.metodosPago);
app.use("/api/personas", catalogos.personas);
app.use("/api/catalogo", catalogos.catalogo);
app.use("/api/tiendas", require("./routes/tiendas"));
app.use("/api/empleados", require("./routes/empleados"));
app.use("/api/clientes", require("./routes/clientes"));
app.use("/api/productos", require("./routes/productos"));
app.use("/api/ventas", require("./routes/ventas"));
app.use("/api/pagos", require("./routes/pagos"));
app.use("/api/detalles-venta", require("./routes/detalles"));
app.use("/api/reportes", require("./routes/reportes"));

app.use((req, res) => {
  res.status(404).json({ error: "Ruta no encontrada" });
});

app.use((error, req, res, next) => {
  sendSqlError(res, error);
});

const port = Number(process.env.PORT || 3000);
app.listen(port, () => {
  console.log(`API escuchando en http://localhost:${port}`);
});
