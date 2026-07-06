/**
 * MongoDB Atlas App Services (formerly Stitch) Serverless Function
 * Function Name: processCivicComplaint
 * 
 * Agentic Workflow for Civic Satire Complaints:
 * Step 1: Vision Extraction Agent evaluates image_url and generates validation metadata.
 * Step 2: Satirical Copywriter Agent generates localized meme copy based on RTO code.
 * Step 3: Secure database insertion into MongoDB Atlas with strict schema compliance.
 */

// In Atlas App Services, BSON is available globally or required via standard bson module
const BSON = typeof global.BSON !== "undefined" ? global.BSON : require("bson");

exports = async function processCivicComplaint(payload) {
  // Validate incoming payload structure
  if (!payload || typeof payload !== "object") {
    throw new Error("Invalid payload: Complaint data object required.");
  }

  const { title, description, rto_code, image_url } = payload;

  if (!title || !description || !rto_code || !image_url) {
    throw new Error("Missing required fields: title, description, rto_code, and image_url must be provided.");
  }

  console.log(`[Agent Loop: Initiated] Processing civic complaint for RTO [${rto_code}]...`);

  // ==========================================
  // STEP 1: Vision Extraction AI Agent Module
  // ==========================================
  const visionMetadata = await runVisionExtractionAgent(image_url, rto_code);
  console.log(`[Agent Loop: Step 1 Complete] Vision Agent validated image. Extraction Validation: ${visionMetadata.validation_string}`);

  // ==========================================
  // STEP 2: Satirical Copywriter AI Agent
  // ==========================================
  const satireText = await runSatiricalCopywriterAgent({
    title,
    description,
    rto_code,
    visionMetadata
  });
  console.log(`[Agent Loop: Step 2 Complete] Copywriter Agent generated satirical copy: "${satireText}"`);

  // ==========================================
  // STEP 3: Secure MongoDB Insertion
  // ==========================================
  // Access MongoDB Atlas service via App Services context
  // Fallback to mock/test db object if context is simulated during local tests
  let complaintsCollection;
  if (typeof context !== "undefined" && context.services) {
    const mongodb = context.services.get("mongodb-atlas");
    const db = mongodb.db("civic_satire_db");
    complaintsCollection = db.collection("complaints");
  } else if (global.mockComplaintsCollection) {
    complaintsCollection = global.mockComplaintsCollection;
  } else {
    throw new Error("Execution Environment Error: App Services context.services is undefined. Verify function is executing within MongoDB Stitch / App Services.");
  }

  // Build BSON document strictly adhering to complaints_schema.json rules
  const complaintDoc = {
    _id: new BSON.ObjectId(),
    title: title.trim(),
    description: description.trim(),
    rto_code: rto_code.trim().toUpperCase(),
    image_url: image_url.trim(),
    satire_text: satireText,
    upvotes: 0, // Enforces integer 0 for fresh submissions
    created_at: new Date() // Enforces current BSON Date timestamp
  };

  // Execute secure insertion query
  const insertResult = await complaintsCollection.insertOne(complaintDoc);
  console.log(`[Database: Insert Success] Document persisted with _id: ${insertResult.insertedId || complaintDoc._id}`);

  // ==========================================
  // Return Clean JSON Object
  // ==========================================
  const cleanResponse = {
    _id: complaintDoc._id.toString(),
    title: complaintDoc.title,
    description: complaintDoc.description,
    rto_code: complaintDoc.rto_code,
    image_url: complaintDoc.image_url,
    satire_text: complaintDoc.satire_text,
    upvotes: complaintDoc.upvotes,
    created_at: complaintDoc.created_at.toISOString(),
    workflow_metadata: {
      vision_validation: visionMetadata.validation_string,
      extracted_features: visionMetadata.extracted_features,
      confidence_score: visionMetadata.confidence_score,
      processing_status: "COMPLETED",
      executed_at: new Date().toISOString()
    }
  };

  return cleanResponse;
};

// ---------------------------------------------------------------------------
// Internal Agent Logic Blocks (Simulated Agentic Modules)
// ---------------------------------------------------------------------------

/**
 * Step 1 Helper: Mock Computer Vision Agent
 * Evaluates photographic evidence URL and outputs validation string and extracted hazards.
 */
async function runVisionExtractionAgent(imageUrl, rtoCode) {
  // Simulate asynchronous agent processing delay
  await new Promise(resolve => setTimeout(resolve, 100));

  // Determine hazard type based on keyword analysis of URL or default selection
  const lowerUrl = imageUrl.toLowerCase();
  let extractedFeatures = ["road_surface_degradation", "traffic_obstruction"];
  let hazardType = "GENERAL_CIVIC_HAZARD";

  if (lowerUrl.includes("pothole") || lowerUrl.includes("road") || lowerUrl.includes("highway")) {
    extractedFeatures = ["crater_depth_severe", "asphalt_erosion", "monsoon_water_pooling"];
    hazardType = "INFRASTRUCTURE_CRATER";
  } else if (lowerUrl.includes("garbage") || lowerUrl.includes("refuse") || lowerUrl.includes("waste")) {
    extractedFeatures = ["uncollected_refuse_overflow", "sidewalk_blockage", "biohazard_zone"];
    hazardType = "SANITATION_OVERFLOW";
  } else if (lowerUrl.includes("excavation") || lowerUrl.includes("barricade") || lowerUrl.includes("construction")) {
    extractedFeatures = ["abandoned_barricade", "open_trench_hazard", "pedestrian_detour"];
    hazardType = "ABANDONED_EXCAVATION";
  }

  const timestampCode = Date.now().toString(36).toUpperCase();
  const validationString = `VALIDATED_VISION_AI::[${hazardType}]::RTO_${rtoCode.toUpperCase()}::CONFIDENCE_98.4%::HASH_${timestampCode}`;

  return {
    extracted_features: extractedFeatures,
    confidence_score: 0.984,
    validation_string: validationString
  };
}

/**
 * Step 2 Helper: Mock Satirical Copywriter Agent
 * Generates localized witty satirical meme text based on the district's RTO code.
 */
async function runSatiricalCopywriterAgent({ title, description, rto_code, visionMetadata }) {
  await new Promise(resolve => setTimeout(resolve, 100));

  const cleanRto = rto_code.trim().toUpperCase();
  const stateCode = cleanRto.split("-")[0]; // e.g., "MH" from "MH-01"

  // Localized satire rule sets by Indian state/region codes
  const satireTemplates = {
    "MH": [
      `BMC officially redesigns ${cleanRto} commute as a monsoon adventure water park. Entry fee: 1 suspension strut.`,
      `Municipal authorities clarify that this crater in ${cleanRto} is actually a newly commissioned lunar landing simulation zone.`,
      `Local real estate brokers in ${cleanRto} now advertising this pothole as a premium 0-BHK open-air waterfront property.`
    ],
    "DL": [
      `Archaeological Survey of India claims this ${cleanRto} excavation is a newly discovered Indus Valley stepwell from the 2018 budget.`,
      `PWD declares this traffic hazard in ${cleanRto} an essential speed-control obstacle course for Olympic slalom training.`,
      `Smog-resistant barricades in ${cleanRto} left untouched for so long they have now been granted permanent resident voting rights.`
    ],
    "KA": [
      `Bengaluru tech entrepreneurs in ${cleanRto} now pitching an AI-driven SaaS platform to disrupt sidewalk navigation. Valuation: $10M.`,
      `BBMP announces this road condition in ${cleanRto} is a deliberate ergonomic intervention to encourage remote work.`,
      `Traffic bottleneck in ${cleanRto} has been moving so slowly that commuters are now forming local cooperative housing societies.`
    ],
    "WB": [
      `Kolkata municipal council declares this ${cleanRto} waterlogged street an urban heritage fishing corridor. Tram rides diverted indefinitely.`,
      `Local cultural committee in ${cleanRto} proposes naming this road depression after a famous 19th-century revolutionary poem.`
    ],
    "TN": [
      `Chennai Corporation introduces smart-road initiative in ${cleanRto} where streetlights work exclusively during daytime solar hours.`,
      `Monsoon drainage trench in ${cleanRto} declared an architectural triumph in passive urban rainwater harvesting.`
    ]
  };

  // Select localized template or fallback to national satire template
  const regionTemplates = satireTemplates[stateCode];
  if (regionTemplates && regionTemplates.length > 0) {
    // Pick a deterministic template based on title length
    const index = title.length % regionTemplates.length;
    return regionTemplates[index];
  }

  // Default national civic satire fallback
  return `Municipal Corporation declares this ${cleanRto} hazard a permanent modern art installation symbolizing citizen resilience and fiscal patience.`;
}

// Ensure Node.js / CommonJS compatibility for local testing
if (typeof module !== "undefined" && module.exports) {
  module.exports = exports;
}
