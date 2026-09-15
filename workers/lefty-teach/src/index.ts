/**
 * Lefty Teach Me Left-Handed proxy.
 * Holds OPENAI_API_KEY server-side; iOS authenticates with X-Lefty-App-Secret.
 */

const SCHEMA_VERSION = "1";
const MAX_IMAGE_BYTES = 4 * 1024 * 1024;

const GUIDE_JSON_SCHEMA = {
  type: "object",
  additionalProperties: false,
  required: [
    "title",
    "estimatedMinutes",
    "summary",
    "whatChanges",
    "whatStaysSame",
    "confidence",
    "clarifyingQuestion",
    "steps",
    "safetyNote",
  ],
  properties: {
    title: { type: "string" },
    estimatedMinutes: { type: ["integer", "null"] },
    summary: { type: "string" },
    whatChanges: { type: "string" },
    whatStaysSame: { type: "string" },
    confidence: {
      type: "string",
      enum: ["high", "uncertain", "needMoreInfo", "unsafe"],
    },
    clarifyingQuestion: { type: ["string", "null"] },
    steps: {
      type: "array",
      items: {
        type: "object",
        additionalProperties: false,
        required: ["number", "instruction"],
        properties: {
          number: { type: "integer" },
          instruction: { type: "string" },
        },
      },
    },
    safetyNote: { type: ["string", "null"] },
  },
} as const;

const SYSTEM_PROMPT = `You are Lefty, a left-handed learning coach for users aged 13+.

Your only job: turn right-handed (or unclear) instructions into clear left-handed step-by-step guidance.

Critical rules:
1. Do NOT blindly replace "right" with "left" or mirror every instruction.
2. Decide what actually changes for a left-handed learner vs what stays the same.
3. If blindly mirroring would make the technique incorrect, say so and choose the correct approach.
4. If information is insufficient, set confidence to "needMoreInfo", ask one clarifyingQuestion, and keep steps minimal or empty.
5. For clearly dangerous activities (weapons, power tools, hazardous chemicals, etc.), set confidence to "unsafe", refuse detailed how-to steps, and explain briefly.
6. For normal household risk (kitchen knives, scissors), you may guide carefully and set safetyNote like "Ask an adult to help with this one." when appropriate for teens.
7. Never invent certainty. Use confidence "uncertain" when handedness guidance may vary.
8. Steps must be short, practical, one action each, with explicit LEFT/RIGHT hand references where relevant.
9. Do not produce social, medical-diagnosis, or unrelated chatbot content.
10. Photograph/instruction context: focus on the activity, not the person's identity.`;

interface TeachRequestBody {
  schemaVersion?: string;
  text?: string;
  imageBase64?: string;
  mimeType?: string;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    if (request.method === "OPTIONS") {
      return cors(new Response(null, { status: 204 }));
    }

    const url = new URL(request.url);
    if (request.method !== "POST" || url.pathname !== "/v1/teach") {
      return cors(json({ error: "not_found" }, 404));
    }

    const provided = request.headers.get("X-Lefty-App-Secret") ?? "";
    if (!secretsEqual(provided, env.LEFTY_APP_SECRET)) {
      return cors(json({ error: "unauthorized" }, 401));
    }

    if (!env.OPENAI_API_KEY) {
      console.error(JSON.stringify({ event: "missing_openai_key" }));
      return cors(json({ error: "teach_failed" }, 502));
    }

    let body: TeachRequestBody;
    try {
      body = (await request.json()) as TeachRequestBody;
    } catch {
      return cors(json({ error: "invalid_json" }, 400));
    }

    const schemaVersion = body.schemaVersion ?? SCHEMA_VERSION;
    if (schemaVersion !== SCHEMA_VERSION) {
      return cors(json({ error: "unsupported_schema" }, 400));
    }

    const text = typeof body.text === "string" ? body.text.trim() : "";
    const imageBase64 =
      typeof body.imageBase64 === "string" ? body.imageBase64.trim() : "";
    const mimeType =
      typeof body.mimeType === "string" && body.mimeType.startsWith("image/")
        ? body.mimeType
        : "image/jpeg";

    if (!text && !imageBase64) {
      return cors(json({ error: "text_or_image_required" }, 400));
    }

    if (imageBase64) {
      const approxBytes = Math.floor((imageBase64.length * 3) / 4);
      if (approxBytes > MAX_IMAGE_BYTES) {
        return cors(json({ error: "image_too_large" }, 400));
      }
    }

    try {
      const guide = await generateGuide({
        text,
        imageBase64,
        mimeType,
        env,
      });
      return cors(json(guide, 200));
    } catch (err) {
      console.error(
        JSON.stringify({
          event: "teach_failed",
          message: String(err),
        }),
      );
      return cors(json({ error: "teach_failed" }, 502));
    }
  },
};

async function generateGuide(args: {
  text: string;
  imageBase64: string;
  mimeType: string;
  env: Env;
}): Promise<Record<string, unknown>> {
  const userContent: Array<
    | { type: "text"; text: string }
    | { type: "image_url"; image_url: { url: string } }
  > = [];

  const promptParts = [
    "Create a left-handed learning guide from the user's materials.",
    args.text
      ? `User instructions / description:\n${args.text}`
      : "No typed instructions were provided — rely on the image.",
  ];
  userContent.push({ type: "text", text: promptParts.join("\n\n") });

  if (args.imageBase64) {
    userContent.push({
      type: "image_url",
      image_url: {
        url: `data:${args.mimeType};base64,${args.imageBase64}`,
      },
    });
  }

  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      authorization: `Bearer ${args.env.OPENAI_API_KEY}`,
    },
    body: JSON.stringify({
      model: args.env.OPENAI_MODEL || "gpt-4o",
      temperature: 0.2,
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: userContent },
      ],
      response_format: {
        type: "json_schema",
        json_schema: {
          name: "generated_guide",
          strict: true,
          schema: GUIDE_JSON_SCHEMA,
        },
      },
    }),
  });

  if (!response.ok) {
    throw new Error(`openai_http_${response.status}`);
  }

  const payload = (await response.json()) as {
    choices?: Array<{ message?: { content?: string } }>;
  };
  const content = payload.choices?.[0]?.message?.content;
  if (!content) {
    throw new Error("missing_content");
  }

  const parsed = JSON.parse(content) as Record<string, unknown>;
  return normalizeGuide(parsed);
}

function normalizeGuide(input: Record<string, unknown>): Record<string, unknown> {
  const confidence = String(input.confidence || "uncertain");
  const allowed = new Set(["high", "uncertain", "needMoreInfo", "unsafe"]);
  const stepsRaw = Array.isArray(input.steps) ? input.steps : [];

  return {
    title: String(input.title || "Left-Handed Guide").slice(0, 120),
    estimatedMinutes:
      typeof input.estimatedMinutes === "number"
        ? Math.max(1, Math.min(120, Math.round(input.estimatedMinutes)))
        : null,
    summary: String(input.summary || "").slice(0, 600),
    whatChanges: String(input.whatChanges || "").slice(0, 400),
    whatStaysSame: String(input.whatStaysSame || "").slice(0, 400),
    confidence: allowed.has(confidence) ? confidence : "uncertain",
    clarifyingQuestion:
      input.clarifyingQuestion == null
        ? null
        : String(input.clarifyingQuestion).slice(0, 300),
    steps: stepsRaw.slice(0, 12).map((step, index) => {
      const s = step as Record<string, unknown>;
      return {
        number:
          typeof s.number === "number" && s.number > 0
            ? Math.round(s.number)
            : index + 1,
        instruction: String(s.instruction || "").slice(0, 500),
      };
    }),
    safetyNote:
      input.safetyNote == null ? null : String(input.safetyNote).slice(0, 300),
  };
}

function secretsEqual(provided: string, expected: string | undefined): boolean {
  if (!expected) return false;
  const encoder = new TextEncoder();
  const a = encoder.encode(provided);
  const b = encoder.encode(expected);
  if (a.byteLength !== b.byteLength) return false;
  let diff = 0;
  for (let i = 0; i < a.byteLength; i++) {
    diff |= a[i]! ^ b[i]!;
  }
  return diff === 0;
}

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "content-type": "application/json" },
  });
}

function cors(response: Response): Response {
  const headers = new Headers(response.headers);
  headers.set("access-control-allow-origin", "*");
  headers.set(
    "access-control-allow-headers",
    "content-type, x-lefty-app-secret",
  );
  headers.set("access-control-allow-methods", "POST, OPTIONS");
  return new Response(response.body, { status: response.status, headers });
}
