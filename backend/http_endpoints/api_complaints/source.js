/**
 * MongoDB Atlas App Services (Stitch) HTTP Endpoint Wrapper
 * Route: POST /api/complaints
 * Function Name: api_complaints_post
 *
 * Description:
 * Extracts JSON body from incoming HTTP POST payload, validates mandatory fields,
 * and forwards the payload into the `processCivicComplaint` Stitch function.
 * Manages HTTP error boundaries and response headers gracefully.
 */

exports = async function(payload, response) {
  // 1. Set default CORS and Content-Type headers for clean client consumption
  response.setHeader("Content-Type", "application/json");
  response.setHeader("Access-Control-Allow-Origin", "*");
  response.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");

  // Handle preflight OPTIONS request if routed here
  if (payload && payload.httpMethod === "OPTIONS") {
    response.setStatusCode(200);
    response.setBody(JSON.stringify({ status: "OK", message: "CORS preflight successful." }));
    return;
  }

  try {
    // 2. Extract and parse incoming JSON body from HTTP payload
    if (!payload || !payload.body) {
      response.setStatusCode(400);
      response.setBody(JSON.stringify({
        error: "Bad Request",
        message: "HTTP request payload is empty. Expected JSON body with civic complaint details."
      }));
      return;
    }

    let rawText = "";
    if (typeof payload.body.text === "function") {
      rawText = payload.body.text();
    } else if (typeof payload.body === "string") {
      rawText = payload.body;
    } else if (Buffer.isBuffer(payload.body) || payload.body instanceof Uint8Array) {
      rawText = payload.body.toString("utf8");
    } else if (typeof payload.body === "object") {
      // If Stitch already auto-parsed JSON body
      rawText = JSON.stringify(payload.body);
    }

    if (!rawText || !rawText.trim()) {
      response.setStatusCode(400);
      response.setBody(JSON.stringify({
        error: "Bad Request",
        message: "Request body cannot be empty."
      }));
      return;
    }

    let requestData;
    try {
      requestData = JSON.parse(rawText);
    } catch (parseErr) {
      response.setStatusCode(400);
      response.setBody(JSON.stringify({
        error: "Bad Request",
        message: `Malformed JSON payload: ${parseErr.message}`
      }));
      return;
    }

    // 3. Graceful Error Boundaries: Validate mandatory fields before executing workflow
    const { title, description, rto_code, image_url } = requestData;
    const missingFields = [];
    if (!title || !title.trim()) missingFields.push("title");
    if (!description || !description.trim()) missingFields.push("description");
    if (!rto_code || !rto_code.trim()) missingFields.push("rto_code");
    if (!image_url || !image_url.trim()) missingFields.push("image_url");

    if (missingFields.length > 0) {
      response.setStatusCode(400);
      response.setBody(JSON.stringify({
        error: "Bad Request",
        message: `Missing mandatory field(s): [${missingFields.join(", ")}]. All fields are required to process a civic complaint.`,
        missing_fields: missingFields
      }));
      return;
    }

    console.log(`[HTTP Endpoint: POST /api/complaints] Forwarding valid request for RTO [${rto_code}] to processCivicComplaint...`);

    // 4. Forward arguments directly into our existing `processCivicComplaint` Stitch function
    let processedResult;
    if (typeof context !== "undefined" && context.functions && typeof context.functions.execute === "function") {
      processedResult = await context.functions.execute("processCivicComplaint", requestData);
    } else if (global.mockProcessCivicComplaint) {
      // Fallback for local Node.js unit testing
      processedResult = await global.mockProcessCivicComplaint(requestData);
    } else {
      throw new Error("Execution Environment Error: context.functions.execute is unavailable. Ensure function is running inside MongoDB App Services.");
    }

    // 5. Return HTTP 200 OK with target finalized object
    response.setStatusCode(200);
    response.setBody(JSON.stringify({
      status: "SUCCESS",
      code: 200,
      data: processedResult
    }, null, 2));

  } catch (err) {
    console.error("[HTTP Endpoint: Server Error] Unexpected failure:", err);
    // Handle internal server or workflow errors
    response.setStatusCode(500);
    response.setBody(JSON.stringify({
      error: "Internal Server Error",
      message: err.message || "An unexpected error occurred while processing the civic complaint."
    }));
  }
};

if (typeof module !== "undefined" && module.exports) {
  module.exports = exports;
}
