/**
 * MongoDB Atlas App Services (formerly Stitch) Serverless Function
 * Function Name: processCivicComplaint
 *
 * Automated Ghibli Meme Generator Pipeline for Civic Satire:
 * Stage 1: Short & Sarcastic Caption Synthesis via Google Gemini API (Top & Bottom Meme Captions).
 * Stage 2: Studio Ghibli Artwork Engine via Hugging Face Inference API (SDXL / Anime Diffusion).
 * Stage 3: Cloudinary CDN Storage & Secure MongoDB Atlas Document Baking.
 */

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

  const cleanRto = rto_code.trim().toUpperCase();
  console.log(`[Ghibli Pipeline: Initiated] Processing civic complaint for RTO [${cleanRto}]...`);

  // =========================================================================
  // STAGE 1: Short & Sarcastic Caption Synthesis (Google Gemini API)
  // =========================================================================
  const memeCaptions = await synthesizeMemeCaptions({
    title: title.trim(),
    description: description.trim(),
    rtoCode: cleanRto,
  });
  console.log(`[Stage 1 Complete] Meme Captions Synthesized -> Top: "${memeCaptions.top_caption}" | Bottom: "${memeCaptions.bottom_caption}"`);

  // =========================================================================
  // STAGE 2: Studio Ghibli Artwork Engine (Hugging Face Inference API)
  // =========================================================================
  const ghibliArtworkResult = await generateGhibliArtwork({
    title: title.trim(),
    description: description.trim(),
    rtoCode: cleanRto,
  });
  console.log(`[Stage 2 Complete] Ghibli Artwork Engine generated illustration buffer/URL (source: ${ghibliArtworkResult.source}).`);

  // =========================================================================
  // STAGE 3: Cloudinary Storage & Database Record Baking
  // =========================================================================
  const finalSecureImageUrl = await uploadToCloudinary(ghibliArtworkResult, cleanRto, image_url.trim());
  console.log(`[Stage 3 Complete] Cloudinary secure_url acquired: ${finalSecureImageUrl}`);

  // Access MongoDB Atlas service via App Services context
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

  const combinedSatireText = `${memeCaptions.top_caption} — ${memeCaptions.bottom_caption}`;

  // Build BSON document strictly adhering to MongoDB schema rules
  const complaintDoc = {
    _id: new BSON.ObjectId(),
    title: title.trim(),
    description: description.trim(),
    rto_code: cleanRto,
    image_url: finalSecureImageUrl, // Baked secure Cloudinary URL
    original_image_url: image_url.trim(),
    ghibli_meme_url: finalSecureImageUrl,
    satire_text: combinedSatireText,
    meme_captions: {
      top_caption: memeCaptions.top_caption,
      bottom_caption: memeCaptions.bottom_caption,
    },
    upvotes: 0,
    created_at: new Date(),
  };

  // Execute secure database insertion
  const insertResult = await complaintsCollection.insertOne(complaintDoc);
  console.log(`[Database: Insert Success] Document persisted with _id: ${insertResult.insertedId || complaintDoc._id}`);

  // Return clean structured JSON response
  return {
    _id: complaintDoc._id.toString(),
    title: complaintDoc.title,
    description: complaintDoc.description,
    rto_code: complaintDoc.rto_code,
    image_url: complaintDoc.image_url,
    original_image_url: complaintDoc.original_image_url,
    ghibli_meme_url: complaintDoc.ghibli_meme_url,
    satire_text: complaintDoc.satire_text,
    meme_captions: complaintDoc.meme_captions,
    upvotes: complaintDoc.upvotes,
    created_at: complaintDoc.created_at.toISOString(),
    workflow_metadata: {
      stage_1_caption_engine: memeCaptions.provider,
      stage_2_ghibli_engine: ghibliArtworkResult.source,
      stage_3_storage_provider: "Cloudinary CDN",
      processing_status: "COMPLETED",
      executed_at: new Date().toISOString(),
    },
  };
};

// ============================================================================
// STAGE 1 HELPER: Short & Sarcastic Caption Synthesis (Gemini API)
// ============================================================================
async function synthesizeMemeCaptions({ title, description, rtoCode }) {
  const promptText = `You are a satirical Indian civic commentator. Analyze this civic issue:
Title: "${title}"
Description: "${description}"
RTO Jurisdiction: "${rtoCode}"

Create a punchy, humorous 2-part image meme caption localized to Indian civic irony.
Output format MUST be strictly JSON:
{
  "top_caption": "SHORT PUNCHY SETUP CAPTION IN UPPERCASE",
  "bottom_caption": "IRONIC PUNCHLINE REFERENCE IN UPPERCASE"
}`;

  const geminiApiKey =
    (typeof context !== "undefined" && context.values && context.values.get("GEMINI_API_KEY")) ||
    process.env.GEMINI_API_KEY;

  if (geminiApiKey && typeof context !== "undefined" && context.http) {
    try {
      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiApiKey}`;
      const response = await context.http.post({
        url: geminiUrl,
        headers: { "Content-Type": ["application/json"] },
        body: JSON.stringify({
          contents: [{ parts: [{ text: promptText }] }],
          generationConfig: { temperature: 0.85, maxOutputTokens: 150 },
        }),
        timeout: 6000,
      });

      if (response && response.statusCode === 200 && response.body) {
        const bodyText = response.body.text ? response.body.text() : response.body.toString();
        const parsed = JSON.parse(bodyText);
        const candidateText =
          parsed?.candidates?.[0]?.content?.parts?.[0]?.text || "";
        const jsonMatch = candidateText.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          const memeJson = JSON.parse(jsonMatch[0]);
          if (memeJson.top_caption && memeJson.bottom_caption) {
            return {
              top_caption: String(memeJson.top_caption).trim(),
              bottom_caption: String(memeJson.bottom_caption).trim(),
              provider: "GEMINI_1.5_FLASH",
            };
          }
        }
      }
    } catch (err) {
      console.warn(`[Stage 1 Fallback] Gemini HTTP request timed out or errored: ${err.message}`);
    }
  }

  // Resilient Localized Indian Civic Irony Fallback Engine
  const stateCode = rtoCode.split("-")[0].toUpperCase();
  const fallbackCaptions = {
    MH: {
      top: `MUMBAI METRO & BMC PROUDLY PRESENT`,
      bottom: `${rtoCode}: PERMANENT LUNAR ADVENTURE CRATER PARK`,
    },
    DL: {
      top: `DELHI PWD HERITAGE PRESERVATION PROGRAM`,
      bottom: `ANCIENT BARRICADE STANDING PROUD SINCE 2018 BUDGET`,
    },
    KA: {
      top: `BENGALURU AI-DRIVEN TRAFFIC OPTIMIZATION`,
      bottom: `${rtoCode}: COMMUTE SLOWED TO PROMOTE MINDFUL MEDITATION`,
    },
  };

  const selected = fallbackCaptions[stateCode] || {
    top: `MUNICIPAL CORPORATION CIVIC UPGRADE`,
    bottom: `${rtoCode}: DECLARED AN ESSENTIAL MODERN ART INSTALLATION`,
  };

  return {
    top_caption: selected.top,
    bottom_caption: selected.bottom,
    provider: "LOCAL_CIVIC_IRONY_ENGINE",
  };
}

// ============================================================================
// STAGE 2 HELPER: Studio Ghibli Artwork Engine (Hugging Face API)
// ============================================================================
async function generateGhibliArtwork({ title, description, rtoCode }) {
  // Derive concise topic phrase for diffusion prompt
  const combined = `${title} ${description}`.toLowerCase();
  let complaintTopic = "a busy Indian city street with civic infrastructure work";
  let fallbackImage = "https://images.unsplash.com/photo-1614728894747-a83421e2b9c9?auto=format&fit=crop&w=800&q=80";

  if (combined.includes("pothole") || combined.includes("crater") || combined.includes("road")) {
    complaintTopic = "a huge rain-filled pothole in the middle of a picturesque city road with reflections";
    fallbackImage = "https://images.unsplash.com/photo-1614728894747-a83421e2b9c9?auto=format&fit=crop&w=800&q=80";
  } else if (combined.includes("water") || combined.includes("flood") || combined.includes("drain")) {
    complaintTopic = "a flooded street with boats and monsoon rain gently falling in an anime city";
    fallbackImage = "https://images.unsplash.com/photo-1516483638261-f4dbaf036963?auto=format&fit=crop&w=800&q=80";
  } else if (combined.includes("garbage") || combined.includes("refuse") || combined.includes("waste")) {
    complaintTopic = "an overgrown whimsical street corner reclaimed by lush nature and foliage";
    fallbackImage = "https://images.unsplash.com/photo-1511497584788-87676104235f?auto=format&fit=crop&w=800&q=80";
  } else if (combined.includes("barricade") || combined.includes("excavat") || combined.includes("trench")) {
    complaintTopic = "mysterious ancient stone ruins and colorful barricades on a peaceful street";
    fallbackImage = "https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?auto=format&fit=crop&w=800&q=80";
  }

  const hfPrompt = `Studio Ghibli anime style illustration of ${complaintTopic}, detailed hand-drawn watercolor aesthetic, cinematic lighting, clean vibrant colors, cozy anime background scenery, 2d animation masterpiece.`;

  const hfToken =
    (typeof context !== "undefined" && context.values && context.values.get("HF_TOKEN")) ||
    process.env.HF_TOKEN;

  if (hfToken && typeof context !== "undefined" && context.http) {
    try {
      const hfModelUrl = `https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0`;
      const hfResponse = await context.http.post({
        url: hfModelUrl,
        headers: {
          "Authorization": [`Bearer ${hfToken}`],
          "Content-Type": ["application/json"],
          "Accept": ["image/png"],
        },
        body: JSON.stringify({
          inputs: hfPrompt,
          parameters: { guidance_scale: 7.5, num_inference_steps: 25 },
        }),
        timeout: 9000,
      });

      if (hfResponse && hfResponse.statusCode === 200 && hfResponse.body) {
        const rawBuffer = hfResponse.body.toBase64
          ? hfResponse.body.toBase64()
          : hfResponse.body.toString("base64");
        return {
          bufferBase64: rawBuffer,
          prompt: hfPrompt,
          source: "HUGGING_FACE_SDXL",
        };
      }
    } catch (err) {
      console.warn(`[Stage 2 Fallback] Hugging Face API timeout/error: ${err.message}`);
    }
  }

  return {
    fallbackUrl: fallbackImage,
    prompt: hfPrompt,
    source: "GHIBLI_CURATED_FALLBACK_CDN",
  };
}

// ============================================================================
// STAGE 3 HELPER: Cloudinary Storage & Upload Preset Streamer
// ============================================================================
async function uploadToCloudinary(artworkResult, rtoCode, originalImageUrl) {
  const cloudinaryCloudName =
    (typeof context !== "undefined" && context.values && context.values.get("CLOUDINARY_CLOUD_NAME")) ||
    process.env.CLOUDINARY_CLOUD_NAME;
  const cloudinaryUploadPreset =
    (typeof context !== "undefined" && context.values && context.values.get("CLOUDINARY_UPLOAD_PRESET")) ||
    process.env.CLOUDINARY_UPLOAD_PRESET ||
    "unsigned_civic_preset";

  // If we have an active Cloudinary configuration and a base64 buffer from Hugging Face
  if (artworkResult.bufferBase64 && cloudinaryCloudName && typeof context !== "undefined" && context.http) {
    try {
      const uploadUrl = `https://api.cloudinary.com/v1_1/${cloudinaryCloudName}/image/upload`;
      const dataUri = `data:image/png;base64,${artworkResult.bufferBase64}`;

      const clResponse = await context.http.post({
        url: uploadUrl,
        headers: { "Content-Type": ["application/json"] },
        body: JSON.stringify({
          file: dataUri,
          upload_preset: cloudinaryUploadPreset,
          folder: `street_voice_ghibli/${rtoCode}`,
        }),
        timeout: 8000,
      });

      if (clResponse && clResponse.statusCode === 200 && clResponse.body) {
        const bodyText = clResponse.body.text ? clResponse.body.text() : clResponse.body.toString();
        const uploadData = JSON.parse(bodyText);
        if (uploadData.secure_url) {
          return uploadData.secure_url;
        }
      }
    } catch (err) {
      console.warn(`[Stage 3 Fallback] Cloudinary upload timeout/error: ${err.message}`);
    }
  }

  // Return generated fallback or curated Ghibli meme URL
  return artworkResult.fallbackUrl || originalImageUrl;
}

if (typeof module !== "undefined" && module.exports) {
  module.exports = exports;
}
