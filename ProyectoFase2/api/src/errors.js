function httpError(status, message) {
  const error = new Error(message);
  error.status = status;
  return error;
}

function textsOf(error) {
  const texts = [];
  if (error && error.message) {
    texts.push(error.message);
  }
  if (error && Array.isArray(error.precedingErrors)) {
    for (const item of error.precedingErrors) {
      if (item && item.message) {
        texts.push(item.message);
      }
    }
  }
  return texts;
}

function sendSqlError(res, error) {
  const texts = textsOf(error);
  const message = texts[0] || "Error de base de datos";
  if (texts.some((text) => text.includes("Stock insuficiente"))) {
    res.status(400).json({ error: "Stock insuficiente" });
    return;
  }
  const number = error && error.number;
  if (number === 2627 || number === 2601 || number === 547 || number === 515) {
    res.status(400).json({ error: message });
    return;
  }
  if (error && error.status) {
    res.status(error.status).json({ error: message });
    return;
  }
  res.status(500).json({ error: message });
}

module.exports = {
  httpError,
  sendSqlError,
};
