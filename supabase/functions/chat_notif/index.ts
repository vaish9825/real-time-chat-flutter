// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.0.0"
import serviceAccount from '../service-account.json' with { type: 'json' }
import { JWT } from 'npm:google-auth-library@9'
import dotenv from 'npm:dotenv';

dotenv.config({ path: '../.env' });

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_ANON_KEY')!,
);

interface Chat {
  id: string;
  created_at: string; // or Date, depending on your usage
  msg: string;
  username: string;
  user_img: string;
  user_id: string;
}

interface WebHookPayload {
  type: 'INSERT',
  table: string,
  record: Chat,
  schema: 'public',
}


Deno.serve(async (req) => {
  const payload: WebHookPayload = await req.json();

  if (!payload.record) {
    return new Response(JSON.stringify({ error: "No record in payload" }), { status: 400 });
  }

  // Get the user's FCM token from your users table
  const { data, error } = await supabase
    .from("users")
    .select("fcm_token")
    .eq("id", payload.record.user_id)
    .single();

  if (error || !data?.fcm_token) {
    return new Response(JSON.stringify({ error: "No FCM token found" }), { status: 400 });
  }

  const accessToken = await getAccessToken(
    {clientEmail: serviceAccount.client_email,
    privateKey: serviceAccount.private_key,}
  )

  // Send push notification via FCM
  const fcmRes = await fetch(
    `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      message: {
        token: data.fcm_token,
        notification: {
          title: payload.record.username,
          body: payload.record.msg,
        },
      },
    }),
  });

  const fcmData = await fcmRes.json();

  return new Response(JSON.stringify({ fcm: fcmData }), {
    headers: { "Content-Type": "application/json" },
  });
});

const getAccessToken = ({
  clientEmail,
  privateKey,
}: {
  clientEmail: string
  privateKey: string
}): Promise<string> => {
  return new Promise((resolve, reject) => {
    const jwtClient = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    })
    jwtClient.authorize((err, tokens) => {
      if (err) {
        reject(err)
        return
      }
      resolve(tokens!.access_token!)
    })
  })
}

