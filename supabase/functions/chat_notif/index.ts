// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.0.0"
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

  // Log the received chat message
  console.log('New chat message received:', {
    username: payload.record.username,
    message: payload.record.msg,
    user_id: payload.record.user_id,
    timestamp: payload.record.created_at
  });

  // Return success response
  return new Response(JSON.stringify({ 
    success: true, 
    message: "Chat message processed successfully",
    data: {
      username: payload.record.username,
      message: payloa.record.msg,
      timestamp: payload.record.created_at
    }
  }), {
    headers: { "Content-Type": "application/json" },
    status: 200
  });
});
