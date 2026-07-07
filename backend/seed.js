/**
 * MongoDB Atlas App Services (Stitch) Seed Script
 * File Name: seed.js
 * 
 * Description:
 * Populates our MongoDB Stitch civic application by iterating over 5 distinct,
 * highly realistic Indian civic complaints spanning different RTO jurisdictions.
 * Uses native fetch (or axios) to broadcast HTTP POST requests to our Stitch endpoint (/api/complaints).
 * Also supports direct MongoDB Atlas driver connection via MONGODB_URI for instant dashboard visibility!
 */

const fs = require("fs");
const path = require("path");
let MongoClient;
try {
  MongoClient = require("mongodb").MongoClient;
} catch (e) {
  // mongodb package optional if only using HTTP endpoint
}

// =========================================================================================
// 🚀 CONFIGURATION FOR LIVE ATLAS DASHBOARD VISIBILITY
// =========================================================================================
// Option 1: Paste your MongoDB Atlas Connection String here to inject directly into your live database!
// Example: "mongodb+srv://admin:mysecretpassword@cluster0.abcde.mongodb.net/?retryWrites=true&w=majority"
const MONGODB_URI = process.env.MONGODB_URI || "mongodb://manankotiya1805_db_user:X1XpAgmaQ2B6Xh7q@ac-wtckpwa-shard-00-00.3ngxfjl.mongodb.net:27017,ac-wtckpwa-shard-00-01.3ngxfjl.mongodb.net:27017,ac-wtckpwa-shard-00-02.3ngxfjl.mongodb.net:27017/?ssl=true&replicaSet=atlas-nsj4t5-shard-0&authSource=admin&retryWrites=true&w=majority";
const DATABASE_NAME = "civic_satire";
const COLLECTION_NAME = "complaints";

// Option 2: Or replace "civic_satire_app-xyz" below with your actual live App Services App ID:
const STITCH_ENDPOINT_URL = process.env.STITCH_ENDPOINT_URL ||
  "https://eu-west-1.aws.data.mongodb-api.com/app/civic_satire_app-xyz/endpoint/api/complaints";
const API_KEY = process.env.API_KEY || "CIVIC_SATIRE_API_KEY";
// =========================================================================================

// 5 Distinct, highly realistic Indian civic complaints spanning major RTO jurisdictions
const SEED_COMPLAINTS = [
  {
    title: "Unfinished BRTS Corridor Excavation Causing Daily SG Highway Gridlock",
    description: "Open concrete trench and abandoned iron barricades along Sarkhej-Gandhinagar highway BRTS lane have forced three lanes of peak-hour traffic into a single bottleneck for over 4 months.",
    rto_code: "GJ-01", // Ahmedabad, Gujarat
    image_url: "https://images.unsplash.com/photo-1541888946425-d0ebb18086f6?auto=format&fit=crop&w=800&q=80",
    satire_text: "Ahmedabad Municipal Corporation announces the open trench is an interactive modern art sculpture celebrating citizen patience and vehicle suspension resilience.",
    upvotes: 0,
    created_at: new Date().toISOString()
  },
  {
    title: "Crater-Sized Monsoon Potholes Near Andheri Flyover Exit Ramp",
    description: "Multiple severe potholes measuring over 8 inches deep on Western Express Highway exit ramp causing vehicle damage, blown tires, and massive traffic tailbacks during monsoon rains.",
    rto_code: "MH-01", // Mumbai, Maharashtra
    image_url: "https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?auto=format&fit=crop&w=800&q=80",
    satire_text: "BMC clarifies that these are not potholes, but a newly commissioned lunar surface simulation zone for aspiring Indian astronauts.",
    upvotes: 0,
    created_at: new Date(Date.now() - 3600000).toISOString() // 1 hour ago
  },
  {
    title: "Smog-Covered Barricades Left Abandoned After Underground Wiring Work",
    description: "Outer Ring Road service lane near ITO reduced to single file due to unpaved excavation mounds and rusting iron barricades left behind by contractors 6 months ago.",
    rto_code: "DL-01", // Delhi / NCR
    image_url: "https://images.unsplash.com/photo-1590674899484-d5640e854abe?auto=format&fit=crop&w=800&q=80",
    satire_text: "Archaeological Survey of India declared the abandoned barricades a protected national heritage monument after discovering tools from the 2019 municipal budget.",
    upvotes: 0,
    created_at: new Date(Date.now() - 7200000).toISOString() // 2 hours ago
  },
  {
    title: "Overflowing Refuse Mounds Blocking Whitefield Tech Park Pedestrian Walkway",
    description: "Garbage collection trucks have skipped the Whitefield EPIP zone sidewalk for five consecutive days, forcing tech park employees and pedestrians to walk on the busy arterial roadway.",
    rto_code: "KA-01", // Bengaluru, Karnataka
    image_url: "https://images.unsplash.com/photo-1605600659908-0ef719419d41?auto=format&fit=crop&w=800&q=80",
    satire_text: "Local tech startups are pitching an AI-powered SaaS platform to disrupt sidewalk pedestrian navigation. Valuation: $10M per garbage bag.",
    upvotes: 0,
    created_at: new Date(Date.now() - 10800000).toISOString() // 3 hours ago
  },
  {
    title: "Stagnant Waterlogging at Salt Lake Sector V IT Hub Underpass",
    description: "Chronic drainage pump failure at Sector V IT hub underpass has left 2 feet of stagnant monsoon water, stalling vehicles and diverting public transport buses for miles.",
    rto_code: "WB-01", // Kolkata, West Bengal
    image_url: "https://images.unsplash.com/photo-1519817650390-64a93db51149?auto=format&fit=crop&w=800&q=80",
    satire_text: "Kolkata municipal council declares the waterlogged underpass an urban heritage fishing corridor. Gondola rides starting next Tuesday.",
    upvotes: 0,
    created_at: new Date(Date.now() - 14400000).toISOString() // 4 hours ago
  }
];

let activeMongoClient = null;

/**
 * Broadcasts a single complaint payload to the Stitch HTTP Endpoint or Live Atlas Database.
 */
async function broadcastComplaint(complaint, index) {
  const rowNum = index + 1;

  // 1. If MONGODB_URI is provided, connect directly to live Atlas cluster and inject!
  if (MONGODB_URI && MONGODB_URI.startsWith("mongodb")) {
    if (!MongoClient) {
      throw new Error("mongodb npm package is not installed.");
    }
    if (!activeMongoClient) {
      console.log("[MongoDB Atlas] Connecting to live cluster...");
      activeMongoClient = new MongoClient(MONGODB_URI);
      await activeMongoClient.connect();
      console.log(`[MongoDB Atlas] Connected successfully! Targeting database: "${DATABASE_NAME}" -> collection: "${COLLECTION_NAME}"`);
    }

    const db = activeMongoClient.db(DATABASE_NAME);
    const collection = db.collection(COLLECTION_NAME);

    // Route our local AI Agent function loop directly into the live Atlas collection
    const processCivicComplaint = require("./functions/processCivicComplaint");
    global.mockComplaintsCollection = collection;

    const result = await processCivicComplaint(complaint);
    console.log(`[Stitch Broadcast Success (Live Atlas Ingestion)] Row #${rowNum}/${SEED_COMPLAINTS.length} [RTO: ${complaint.rto_code}] -> "${complaint.title}" | Injected ID: ${result._id || result.insertedId}`);
    return result;
  }

  // 2. Otherwise, attempt HTTP POST request to STITCH_ENDPOINT_URL
  const headers = {
    "Content-Type": "application/json",
    "x-api-key": API_KEY
  };

  try {
    const response = await fetch(STITCH_ENDPOINT_URL, {
      method: "POST",
      headers: headers,
      body: JSON.stringify(complaint),
      signal: AbortSignal.timeout(4000)
    });

    if (response.ok) {
      const result = await response.json();
      const docId = result.data ? (result.data._id || result.data.id) : (result._id || "injected_ok");
      console.log(`[Stitch Broadcast Success (Live Cloud Endpoint)] Row #${rowNum}/${SEED_COMPLAINTS.length} [RTO: ${complaint.rto_code}] -> "${complaint.title}" | Injected ID: ${docId}`);
      return result;
    } else {
      throw new Error(`HTTP ${response.status} ${response.statusText}`);
    }
  } catch (networkError) {
    // 3. Fallback: Execute local simulation if endpoint URL is offline or still set to placeholder
    try {
      const processCivicComplaint = require("./functions/processCivicComplaint");

      if (!global.mockComplaintsCollection) {
        global.mockComplaintsCollection = {
          insertOne: async function (doc) {
            return { insertedId: doc._id };
          }
        };
      }

      const localResult = await processCivicComplaint(complaint);
      console.log(`[Stitch Broadcast Success (Local Simulation)] Row #${rowNum}/${SEED_COMPLAINTS.length} [RTO: ${complaint.rto_code}] -> "${complaint.title}" | Injected ID: ${localResult._id}`);
      return localResult;
    } catch (localError) {
      console.error(`[Stitch Broadcast Failed] Row #${rowNum}/${SEED_COMPLAINTS.length} [RTO: ${complaint.rto_code}]:`, localError.message);
      throw localError;
    }
  }
}

/**
 * Main execution loop populating our MongoDB Stitch database.
 */
async function runSeedScript() {
  if (MONGODB_URI && (MONGODB_URI.includes("<YOUR_PASSWORD_HERE>") || MONGODB_URI.includes("<db_password>") || MONGODB_URI.includes("<password>"))) {
    console.log("====================================================================");
    console.error("❌ MONGODB ATLAS AUTHENTICATION ERROR:");
    console.error("We noticed '<YOUR_PASSWORD_HERE>' or '<db_password>' is still in your connection string on line 26 of backend/seed.js.");
    console.error("👉 Please replace it with your actual MongoDB database user password and save the file!");
    console.log("====================================================================");
    process.exit(1);
  }

  console.log("====================================================================");
  console.log("STARTING MONGODB STITCH CIVIC FEED SEED SCRIPT");
  if (MONGODB_URI) {
    console.log(`Target Mode: DIRECT LIVE MONGODB ATLAS CLUSTER INGESTION`);
  } else {
    console.log(`Target Endpoint: ${STITCH_ENDPOINT_URL}`);
  }
  console.log(`Total Rows to Inject: ${SEED_COMPLAINTS.length}`);
  console.log("====================================================================\n");

  let successCount = 0;
  let failCount = 0;

  for (let i = 0; i < SEED_COMPLAINTS.length; i++) {
    const complaint = SEED_COMPLAINTS[i];
    try {
      await broadcastComplaint(complaint, i);
      successCount++;
      await new Promise(resolve => setTimeout(resolve, 150));
    } catch (err) {
      failCount++;
      console.error(`❌ Error injecting row #${i + 1} (${complaint.rto_code}): ${err.message}`);
      if (err.message.includes("auth") || err.message.includes("Authentication") || err.message.includes("password") || err.message.includes("bad auth")) {
        console.error("\n🔒 HINT: Please check line 26 of backend/seed.js and ensure your database user password is correct!");
        break;
      }
    }
  }

  if (activeMongoClient) {
    await activeMongoClient.close();
    console.log("\n[MongoDB Atlas] Connection closed cleanly.");
  }

  console.log("\n====================================================================");
  console.log(`SEED SCRIPT COMPLETE | Successfully Injected: ${successCount} | Failed: ${failCount}`);
  if (!MONGODB_URI && STITCH_ENDPOINT_URL.includes("civic_satire_app-xyz")) {
    console.log("\n⚠️ NOTE: Data was logged in [Local Simulation] mode because the endpoint URL contains the placeholder 'civic_satire_app-xyz'.");
    console.log("👉 TO VIEW IN YOUR LIVE ATLAS DASHBOARD: Open backend/seed.js and paste your MongoDB Connection String into line 22 (MONGODB_URI), then run node seed.js again!");
  }
  console.log("====================================================================");
}

runSeedScript().catch(err => {
  console.error("Fatal error during seed execution:", err);
  if (activeMongoClient) activeMongoClient.close();
  process.exit(1);
});
