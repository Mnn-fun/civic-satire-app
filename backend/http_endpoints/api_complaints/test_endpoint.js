const endpointHandler = require("./source");
const processCivicComplaint = require("../../functions/processCivicComplaint");

// Mock our processCivicComplaint function and MongoDB Collection for Local Verification
global.mockProcessCivicComplaint = processCivicComplaint;
global.mockComplaintsCollection = {
  insertOne: async function(doc) {
    return { insertedId: doc._id };
  }
};

class MockResponse {
  constructor() {
    this.statusCode = null;
    this.headers = {};
    this.body = null;
  }
  setStatusCode(code) { this.statusCode = code; }
  setHeader(key, value) { this.headers[key] = value; }
  setBody(body) { this.body = body; }
}

async function runTests() {
  console.log("====================================================================");
  console.log("STARTING STITCH HTTP ENDPOINT (/api/complaints) VERIFICATION");
  console.log("====================================================================");

  // -------------------------------------------------------------------------
  // TEST CASE 1: Valid Civic Complaint Payload (Expected HTTP 200 OK)
  // -------------------------------------------------------------------------
  console.log("\n--> [TEST CASE 1] Sending Valid Civic Complaint Payload...");
  const validPayload = {
    httpMethod: "POST",
    body: {
      text: () => JSON.stringify({
        title: "Crater-Sized Potholes on Western Express Highway Commute",
        description: "Multiple deep potholes near Andheri flyover causing vehicle damage during rush hour.",
        rto_code: "MH-01",
        image_url: "https://example.com/pothole_mumbai_endpoint.jpg"
      })
    }
  };

  const res1 = new MockResponse();
  await endpointHandler(validPayload, res1);
  console.log(`[Result 1] HTTP Status Code: ${res1.statusCode}`);
  console.log("[Result 1] Response Body:\n", res1.body);

  // -------------------------------------------------------------------------
  // TEST CASE 2: Missing Mandatory Fields (Expected HTTP 400 Bad Request)
  // -------------------------------------------------------------------------
  console.log("\n--> [TEST CASE 2] Sending Payload with Missing Mandatory Fields (image_url missing)...");
  const invalidPayload = {
    httpMethod: "POST",
    body: {
      text: () => JSON.stringify({
        title: "Barricaded Road Excavation",
        description: "Outer Ring Road lane reduced to single file due to unfinished wiring.",
        rto_code: "DL-01"
        // Notice: image_url is missing!
      })
    }
  };

  const res2 = new MockResponse();
  await endpointHandler(invalidPayload, res2);
  console.log(`[Result 2] HTTP Status Code: ${res2.statusCode}`);
  console.log("[Result 2] Response Body:\n", res2.body);

  if (res1.statusCode === 200 && res2.statusCode === 400) {
    console.log("\n====================================================================");
    console.log("ALL ENDPOINT VERIFICATION TESTS PASSED!");
    console.log("====================================================================");
  } else {
    throw new Error("Test failed: Unexpected status codes returned.");
  }
}

runTests().catch(err => {
  console.error("Endpoint test failed:", err);
  process.exit(1);
});
