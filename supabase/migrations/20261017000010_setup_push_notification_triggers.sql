-- Migration 0010: Setup pg_net and automatic push notification triggers for FCM
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

CREATE OR REPLACE FUNCTION public.trigger_fcm_notification()
RETURNS TRIGGER AS $$
DECLARE
  payload JSONB;
BEGIN
  payload := jsonb_build_object(
    'table', TG_TABLE_NAME,
    'type', TG_OP,
    'record', row_to_json(NEW)
  );

  PERFORM net.http_post(
    url := 'https://rvtzxuvfuntbeuwjoify.supabase.co/functions/v1/send-fcm-notification',
    headers := jsonb_build_object('Content-Type', 'application/json'),
    body := payload
  );

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Mencegah kegagalan webhook membatalkan transaksi utama
    RAISE WARNING 'FCM notification webhook warning: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 1. Trigger untuk pesan chat konseling baru
DROP TRIGGER IF EXISTS trg_notify_new_chat_message ON public.chat_messages;
CREATE TRIGGER trg_notify_new_chat_message
AFTER INSERT ON public.chat_messages
FOR EACH ROW
EXECUTE FUNCTION public.trigger_fcm_notification();

-- 2. Trigger untuk antrean konseling baru
DROP TRIGGER IF EXISTS trg_notify_new_counseling_queue ON public.counseling_queues;
CREATE TRIGGER trg_notify_new_counseling_queue
AFTER INSERT ON public.counseling_queues
FOR EACH ROW
EXECUTE FUNCTION public.trigger_fcm_notification();

-- 3. Trigger untuk pesan obrolan anonim baru
DROP TRIGGER IF EXISTS trg_notify_new_anon_message ON public.anon_messages;
CREATE TRIGGER trg_notify_new_anon_message
AFTER INSERT ON public.anon_messages
FOR EACH ROW
EXECUTE FUNCTION public.trigger_fcm_notification();
