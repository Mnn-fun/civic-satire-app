# MongoDB Atlas Schema & Data Access Configuration

This directory contains the strict schema validation rules for the **National Civic Satire App** backend.

## 1. App Services (Stitch) Schema & GraphQL Configuration

The file [`complaints_schema.json`](file:///d:/techathons/Build%20with%20ai%20-2026/civic-satire-app/backend/schema/complaints_schema.json) defines the **Data Access Rules** and schema for Atlas App Services.

When uploaded to Atlas App Services, this schema automatically generates the GraphQL type definitions and ensures strict type enforcement on all HTTP/GraphQL endpoint requests.

### Key Architectural Decisions:
- **`title`: "Complaint"**: Names the generated GraphQL type `Complaint` (with queries `complaint` and `complaints`).
- **`required` Array**: Enforces that all fields are non-nullable (`!`) in the GraphQL schema and rejected if omitted during HTTP/GraphQL mutations.
- **`bsonType`: ["int", "long"] for `upvotes`**: Prevents serialization mismatches between 32-bit and 64-bit integer representations from different client drivers while enforcing `"minimum": 0`.
- **`rto_code` Regex Pattern**: Enforces valid Regional Transport Office formatting (e.g., `MH-01`, `DL-01`).
- **`additionalProperties`: false**: Rejects any arbitrary or malformed payload fields from reaching the database via APIs.

---

## 2. Database-Level Shell Validation

To apply this schema directly at the MongoDB database level using `mongosh` or the Atlas Query Console (for defense-in-depth), run:

```javascript
db.runCommand({
  collMod: "complaints",
  validator: {
    $jsonSchema: {
      title: "Complaint",
      description: "A national civic feed complaint with AI-generated satire.",
      type: "object",
      required: [
        "_id",
        "title",
        "description",
        "rto_code",
        "image_url",
        "satire_text",
        "upvotes",
        "created_at"
      ],
      additionalProperties: false,
      properties: {
        _id: {
          bsonType: "objectId",
          description: "Unique ObjectId identifier for the complaint."
        },
        title: {
          bsonType: "string",
          description: "Brief headline of the civic issue.",
          minLength: 5,
          maxLength: 150
        },
        description: {
          bsonType: "string",
          description: "Detailed description of the civic complaint.",
          minLength: 10,
          maxLength: 2000
        },
        rto_code: {
          bsonType: "string",
          description: "Regional Transport Office code identifying the district (e.g., MH-01, DL-01, KA-05).",
          pattern: "^[A-Z]{2}-[0-9]{2,4}$"
        },
        image_url: {
          bsonType: "string",
          description: "URL of the uploaded photographic evidence.",
          pattern: "^https?://.+"
        },
        satire_text: {
          bsonType: "string",
          description: "AI-generated satirical commentary on the complaint.",
          minLength: 1
        },
        upvotes: {
          bsonType: [
            "int",
            "long"
          ],
          description: "Number of upvotes received from citizens.",
          minimum: 0
        },
        created_at: {
          bsonType: "date",
          description: "Timestamp when the complaint was submitted."
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});
```
