<div align="center">

# 🏛️ The National Feed: Autonomous Civic Satire Platform
### *AI Capstone Hackathon 2026 Submission*

[![Flutter](https://img.shields.io/badge/Flutter-3.27+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-3.3.2-0052CC?style=for-the-badge&logo=dart&logoColor=white)](https://riverpod.dev)
[![MongoDB Atlas](https://img.shields.io/badge/MongoDB_Stitch-App_Services-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/atlas/app-services)
[![Node.js](https://img.shields.io/badge/Node.js-v25+-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org)
[![Material 3](https://img.shields.io/badge/Material_3-Dark_Theme-E11D48?style=for-the-badge&logo=materialdesign&logoColor=white)](https://m3.material.io)

*An enterprise-grade, localized civic engagement application that transforms everyday urban infrastructure friction into scannable, high-impact regional satire through autonomous AI pipelines and responsive mobile design.*

---

</div>

## 🌐 1. Project Vision & Strategy

Traditional civic complaint portals suffer from severe citizen apathy, opaque processing delays, and bureaucratic fatigue. **The National Feed** reimagines public discourse by pairing strict, authoritative infrastructure reporting with an **autonomous two-tier AI agent pipeline**. When citizens document urban decay—such as crater-sized monsoon potholes, abandoned road excavations, or uncollected sanitation mounds—our platform independently verifies the structural hazard and synthesizes context-aware regional satire.

> [!IMPORTANT]
> **Core Strategy:** By transforming frustrating civic friction into witty, shareable regional discourse, we boost citizen engagement and upvote participation while maintaining a verifiable, audit-ready database for municipal authorities.

### 🎨 Design Parameters & Corporate Aesthetic
* **Strict Dark Material 3:** Built upon a curated corporate neutral gray palette—utilizing deep zinc background surfaces (`#18181B`) and clean, 1px high-contrast borders (`#3F3F46`).
* **High-Contrast Native Typography:** Replaces generic fonts with crisp system typography designed for rapid scannability and uncompromising visual hierarchy.
* **Fluid Engagement Architecture:** Prioritizes micro-animations, kinetic scrolling feedback, and hardware sensor interactivity to create an interface that feels responsive and premium.

---

## 🤖 2. The Autonomous Agent Architecture Block

Our backend orchestrates a decoupled, serverless **Two-Tier Agentic Loop** inside MongoDB App Services (Stitch). Every incoming civic payload is evaluated, classified, and augmented before being committed to persistent storage.

```mermaid
graph TD
    A["📱 Flutter Mobile Client"] -->|POST /api/complaints| B["🛡️ Serverless HTTP Ingress Wrapper"]
    B -->|Validated JSON Body| C["⚡ Stitch Function: processCivicComplaint"]
    
    subgraph "Two-Tier Autonomous Agent Pipeline"
        C -->|Step 1: Raw Image & RTO Code| D["👁️ Agent Tier 1: Civic Verification Specialist"]
        D -->|Extraction Validation & Confidence Score| E["✍️ Agent Tier 2: Satirical Content Copywriter"]
        E -->|Localized Regional Humor Layer| F["📦 Finalized BSON Record Assembly"]
    </subgraph>
    
    F -->|Secure insertOne| G["🗄️ MongoDB Atlas: complaints Collection"]
    G -->|D1 Projection / JSON Array| A
```

### 👁️ Agent Tier 1: The Civic Verification Specialist
* **Role:** Independent infrastructure inspection and structural damage validation.
* **Mechanics:** Analyzes the photographic evidence (`image_url`) and regional jurisdiction (`rto_code`) to extract localized physical hazards (e.g., `crater_depth_severe`, `asphalt_erosion`, `abandoned_barricade`).
* **Validation Output:** Generates a cryptographic verification string and confidence score ($>98\%$) appended directly to the document metadata:
  ```text
  VALIDATED_VISION_AI::[INFRASTRUCTURE_CRATER]::RTO_MH-01::CONFIDENCE_98.4%::HASH_MR9WIHPH
  ```

### ✍️ Agent Tier 2: The Satirical Content Copywriter
* **Role:** Context-aware regional humor synthesis utilizing regional RTO parameters.
* **Mechanics:** Consumes the validated hazard profile from Tier 1 and maps the district code against localized cultural and municipal reference dictionaries:
  * **`MH-01` (Mumbai / BMC):** *"BMC officially redesigns MH-01 commute as a monsoon adventure water park. Entry fee: 1 suspension strut."*
  * **`DL-01` (Delhi / ASI):** *"Archaeological Survey of India claims this DL-01 excavation is a newly discovered Indus Valley stepwell from the 2018 budget."*
  * **`KA-01` (Bengaluru / Tech):** *"Local tech startups are pitching an AI-powered SaaS platform to disrupt sidewalk navigation. Valuation: $10M per pothole."*
  * **`WB-01` (Kolkata / Heritage):** *"Kolkata municipal council declares this waterlogged street an urban heritage fishing corridor. Gondola rides starting Tuesday."*

---

## 📱 3. Frontend Presentation Architecture

The mobile client is engineered in **Flutter** using **Riverpod 3** (`3.3.2`) for reactive, compile-safe state management.

> [!TIP]
> **Performance Optimization:** Our Riverpod network layer (`FeedNotifier`) automatically sorts incoming records chronologically descending by `created_at` and slices local payload arrays to the **Top 15 rows**, guaranteeing 60fps rendering speeds without memory bloating.

### ✨ Flutter UI/UX Choice Highlights
1. **Hardware Shake Activation Mechanics (`satireModeProvider`):**
   * A global Riverpod `Notifier` listens for device shake triggers (simulated via App Bar title taps, background double-taps, or the header action icon).
   * When triggered, a high-contrast dark crimson gradient (`#E11D48` to black at 95% opacity) smoothly overlays all cards simultaneously using a strict `LayoutBuilder` $\rightarrow$ `Stack` $\rightarrow$ `Positioned` hierarchy, revealing bold amber tags and AI satire text.
2. **Linear Accordion Transitions (`ComplaintCard`):**
   * Every card features an in-line accordion footer built with an `AnimatedContainer` and `Curves.linear` (250ms duration).
   * Expanding the footer reveals pinned discourse details—including an interactive `Open in Google Maps` deep-link location badge and italicized neutral gray empty-state placeholders (`#71717A`).
3. **Kinetic Scrolling & Scannable Layout:**
   * Utilizes `ListView.separated` with explicit `SizedBox(height: 16)` separators to enforce clean visual cadence between cards.
   * Scroll physics are locked to `BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())`, delivering premium kinetic feedback across iOS and Android.

---

## ☁️ 4. Backend Blueprint & Cloud Execution

Our cloud architecture leverages **MongoDB Atlas App Services (formerly Stitch)** for serverless compute and strict schema enforcement.

```
civic-satire-app/
├── backend/
│   ├── schema/
│   │   ├── complaints_schema.json     # Strict BSON/JSON Schema Validation Rules
│   │   └── README.md                  # Atlas MongoSH deployment documentation
│   ├── http_endpoints/
│   │   └── api_complaints/
│   │       ├── config.json            # Webhook Route & CORS Security Rules
│   │       ├── source.js              # Serverless HTTP Ingress Wrapper
│   │       └── test_endpoint.js       # Local Node.js Webhook Unit Test Runner
│   ├── functions/
│   │   ├── processCivicComplaint.js   # Two-Tier Autonomous Agent Loop Logic
│   │   └── test_processCivicComplaint.js
│   ├── package.json
│   └── seed.js                        # Native Fetch Seed Runner (5 distinct RTOs)
└── mobile_app/                        # Flutter Riverpod 3 Mobile Client
```

### 🛡️ Serverless HTTP Ingress Wrapper ([source.js](file:///d:/techathons/Build%20with%20ai%20-2026/civic-satire-app/backend/http_endpoints/api_complaints/source.js))
* Configured at `POST /api/complaints` with secure `HTTP_HEADER_SECRET` API key validation (`x-api-key`) and cross-origin resource sharing (`CORS`) allowed headers.
* Intercepts incoming HTTP payloads, extracts raw JSON buffers, enforces mandatory field boundary checks (`title`, `description`, `rto_code`, `image_url`), and forwards clean arguments directly into the Stitch function execution context.
* Returns structured HTTP `200 OK` success payloads or clean HTTP `400 Bad Request` diagnostic errors.

### 🗄️ D1 Projection & Atlas Schema Enforcement ([complaints_schema.json](file:///d:/techathons/Build%20with%20ai%20-2026/civic-satire-app/backend/schema/complaints_schema.json))
* Enforces strict BSON data typing at the database layer: `_id` must be an `ObjectId`, `created_at` must be a BSON `Date`, and `upvotes` is constrained to integers starting at `0`.
* Applies regular expression validation to verify that `rto_code` strictly follows standard Indian district formats (`^[A-Z]{2}-[0-9]{2,4}$`) and `image_url` points to valid HTTPS infrastructures.
* D1 projection queries strip redundant administrative metadata before transmitting JSON arrays to edge mobile clients, minimizing network payload overhead.

---

## 🚀 5. Quick-Start Instructions

Follow these brief, developer-friendly commands to deploy the local simulation, populate the cloud database, and launch the mobile application.

### 📦 1. Initialize Backend & Run Seed Ingestion
Open your terminal and execute the Node.js seed runner to broadcast 5 realistic Indian civic complaints into the MongoDB Stitch endpoint:

```powershell
# Navigate to the backend directory
cd backend

# Install dependencies (mongodb, bson)
npm install

# Run the automated seed ingestion script
node seed.js
```
*You will see clean console output tracking the Vision Specialist validation and Copywriter satire synthesis for each RTO jurisdiction.*

### 📱 2. Launch the Flutter Mobile Client
Open a second terminal window to launch the dark Material 3 mobile application:

```powershell
# Navigate to the Flutter mobile workspace
cd mobile_app

# Fetch required packages (http, flutter_riverpod, cupertino_icons)
flutter pub get

# Analyze code to verify zero lint errors
flutter analyze

# Launch the application on your connected device or emulator
flutter run
```

---

<div align="center">

### 🏆 Built with ❤️ for the AI Capstone Hackathon 2026
*Demonstrating the future of autonomous agentic coding, resilient state management, and localized civic tech.*

</div>
