const processCivicComplaint = require("./processCivicComplaint");

// Mocking MongoDB Collection for Local Verification
global.mockComplaintsCollection = {
  insertOne: async function(doc) {
    console.log("\n--> [Mock MongoDB Atlas] insertOne executed successfully!");
    console.log("--> Inserted BSON Document Keys:", Object.keys(doc));
    console.log("--> _id BSON Type:", doc._id.constructor.name);
    console.log("--> created_at Type:", doc.created_at.constructor.name);
    return { insertedId: doc._id };
  }
};

async function runTest() {
  const samplePayload = {
    title: "Crater-Sized Potholes on Western Express Highway Commute",
    description: "Multiple deep potholes near Andheri flyover causing severe traffic jams and vehicle damage.",
    rto_code: "MH-01",
    image_url: "https://example.com/pothole_mumbai.jpg"
  };

  console.log("====================================================================");
  console.log("STARTING STITCH / APP SERVICES AGENTIC WORKFLOW TEST");
  console.log("====================================================================");
  
  const result = await processCivicComplaint(samplePayload);
  
  console.log("\n====================================================================");
  console.log("FINAL RETURNED CLEAN JSON OBJECT (Stitch Endpoint Response)");
  console.log("====================================================================");
  console.log(JSON.stringify(result, null, 2));
}

runTest().catch(err => {
  console.error("Test execution failed:", err);
  process.exit(1);
});
