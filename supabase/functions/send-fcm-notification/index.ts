import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import * as jose from "https://deno.land/x/jose@v4.14.4/index.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

// Menghasilkan OAuth2 Access Token dari Service Account Google
async function getGoogleAccessToken(serviceAccount: ServiceAccount): Promise<string> {
  const pem = serviceAccount.private_key.replace(/\\n/g, "\n");
  const key = await jose.importPKCS8(pem, "RS256");

  const jwt = await new jose.SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(serviceAccount.client_email)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt()
    .setExpirationTime("1h")
    .sign(key);

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const data = await res.json();
  if (!res.ok) {
    throw new Error(`Google Auth Token Error: ${JSON.stringify(data)}`);
  }
  return data.access_token;
}

// Mengirim FCM Push Message menggunakan HTTP v1 API
async function sendFcmMessage({
  accessToken,
  projectId,
  fcmToken,
  title,
  body,
  data,
}: {
  accessToken: string;
  projectId: string;
  fcmToken: string;
  title: string;
  body: string;
  data: Record<string, string>;
}) {
  const fcmEndpoint = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
  const response = await fetch(fcmEndpoint, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${accessToken}`,
    },
    body: JSON.stringify({
      message: {
        token: fcmToken,
        notification: {
          title,
          body,
        },
        data: {
          ...data,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        android: {
          priority: "high",
          notification: {
            channel_id: "curhat_notifications",
            sound: "default",
          },
        },
      },
    }),
  });

  const resJson = await response.json();
  if (!response.ok) {
    throw new Error(`FCM send failed: ${JSON.stringify(resJson)}`);
  }
  return resJson;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const rawServiceAccount = Deno.env.get("FIREBASE_SERVICE_ACCOUNT") || Deno.env.get("FCM_SERVICE_ACCOUNT");
    if (!rawServiceAccount) {
      return new Response(
        JSON.stringify({
          error: "Secret FIREBASE_SERVICE_ACCOUNT is not configured. Please set it using Supabase CLI: supabase secrets set FIREBASE_SERVICE_ACCOUNT='{...}'",
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
      );
    }

    const serviceAccount: ServiceAccount = JSON.parse(rawServiceAccount);
    const projectId = serviceAccount.project_id || "curhat-finder";

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const payload = await req.json();

    let targetUserId = "";
    let notifTitle = "Curhat Finder";
    let notifBody = "Ada notifikasi baru";
    let customData: Record<string, string> = {};

    // 1. Direct Payload (untuk pengujian langsung dari API/curl)
    if (payload.target_user_id) {
      targetUserId = payload.target_user_id;
      notifTitle = payload.title || notifTitle;
      notifBody = payload.body || notifBody;
      customData = payload.data || {};
    }
    // 2. Webhook: Pesan Chat Konseling Baru (chat_messages INSERT)
    else if (payload.table === "chat_messages" && payload.type === "INSERT") {
      const record = payload.record;
      const sessionId = record.session_id;
      const senderRole = record.sender_role;
      const senderId = record.sender_id;

      const { data: session, error: sessionErr } = await supabase
        .from("counseling_sessions")
        .select("student_id, counselor_id")
        .eq("id", sessionId)
        .single();

      if (session) {
        // Ambil isi teks pesan dari message_text atau fallback content
        const rawText = record.message_text || record.content || "";
        const snippet = rawText.length > 80 ? rawText.substring(0, 77) + "..." : rawText;

        // Tentukan penerima secara deterministik:
        // Prioritas 1: Bandingkan sender_id dengan student_id / counselor_id
        // Prioritas 2: Fallback ke sender_role
        const isStudentSender = senderId
          ? senderId === session.student_id
          : (senderRole === "student" || senderRole === "mahasiswa");

        if (isStudentSender) {
          targetUserId = session.counselor_id;
          notifTitle = "Pesan Konseling Masuk";
          notifBody = snippet || "Mahasiswa mengirimkan pesan.";
          customData = {
            type: "counseling_counselor_chat",
            session_id: sessionId,
          };
        } else {
          targetUserId = session.student_id;
          notifTitle = "Pesan dari Konselor Sebaya";
          notifBody = snippet || "Konselor telah membalas pesanmu.";
          customData = {
            type: "counseling_student_chat",
            session_id: sessionId,
          };
        }

        // Proteksi Self-Notification: Jangan pernah kirim notifikasi ke pengirim sendiri
        if (senderId && targetUserId === senderId) {
          console.log(`Skipping notification: target user is sender (${senderId})`);
          return new Response(
            JSON.stringify({ status: "skipped", reason: "Target user is the message sender" }),
            { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
          );
        }
      } else {
        console.error(`Session not found for session_id: ${sessionId}`, sessionErr);
      }
    }
    // 3. Webhook: Antrean Baru Masuk (counseling_queues INSERT)
    else if (payload.table === "counseling_queues" && payload.type === "INSERT") {
      const record = payload.record;
      targetUserId = record.assigned_counselor_id;
      const faculty = record.student_faculty ? ` [${record.student_faculty}]` : "";
      notifTitle = "Antrean Konseling Baru";
      notifBody = `Ada mahasiswa baru${faculty} yang sedang menunggu bimbingan.`;
      customData = {
        type: "counseling_new_queue",
        session_id: record.id,
      };
    }
    // 4. Webhook: Pesan Anonim Baru (anon_messages INSERT)
    else if (payload.table === "anon_messages" && payload.type === "INSERT") {
      const record = payload.record;
      const sessionId = record.session_id;
      const senderId = record.sender_id;
      const isSystem = record.is_system === true;

      const { data: session } = await supabase
        .from("anon_chat_sessions")
        .select("user1_id, user2_id, mode, is_bot_session")
        .eq("id", sessionId)
        .single();

      if (session) {
        if (isSystem) {
          const rawText = record.message_text || record.content || "";
          if (rawText.includes("Partner obrolan telah terhubung")) {
            // Beri tahu user1 yang sedang menunggu bahwa partner sudah bergabung
            targetUserId = session.user1_id;
            notifTitle = "Partner Anonim Terhubung! ✨";
            notifBody = "Teman curhatmu sudah masuk ke ruang obrolan. Yuk mulai saling sapa!";
            customData = {
              type: "anon_chat",
              session_id: sessionId,
              mode: session.mode || "Cuma mau didengar",
            };
          } else {
            return new Response(
              JSON.stringify({ status: "skipped", reason: "Standard system welcome message" }),
              { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
            );
          }
        } else {
          targetUserId = (session.user1_id === senderId) ? session.user2_id : session.user1_id;
          const rawText = record.message_text || record.content || "";
          const snippet = rawText.length > 80 ? rawText.substring(0, 77) + "..." : rawText;

          notifTitle = "Pesan Obrolan Anonim";
          notifBody = snippet || "Teman bicaramu mengirimkan pesan.";
          customData = {
            type: "anon_chat",
            session_id: sessionId,
            mode: session.mode || "Cuma mau didengar",
          };

          // Proteksi Self-Notification
          if (senderId && targetUserId === senderId) {
            return new Response(
              JSON.stringify({ status: "skipped", reason: "Target user is the message sender" }),
              { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
            );
          }
        }
      }
    }

    if (!targetUserId) {
      return new Response(
        JSON.stringify({ status: "ignored", reason: "No valid recipient found in event payload" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
      );
    }

    // Ambil FCM Token penerima dari tabel profiles
    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("fcm_token")
      .eq("id", targetUserId)
      .single();

    if (profileError || !profile?.fcm_token) {
      return new Response(
        JSON.stringify({ status: "skipped", reason: `Target user (${targetUserId}) does not have an active fcm_token` }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
      );
    }

    // Ambil Google OAuth2 Access Token & Kirim ke Google FCM API
    const accessToken = await getGoogleAccessToken(serviceAccount);
    const fcmResult = await sendFcmMessage({
      accessToken,
      projectId,
      fcmToken: profile.fcm_token,
      title: notifTitle,
      body: notifBody,
      data: customData,
    });

    return new Response(
      JSON.stringify({ success: true, target_user: targetUserId, result: fcmResult }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message || String(err) }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
    );
  }
});
