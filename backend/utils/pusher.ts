import Pusher from "pusher";
import {
  PUSHER_APP_ID,
  PUSHER_HOST,
  PUSHER_KEY,
  PUSHER_SECRET,
} from "./global.ts";

export const pusher = new Pusher({
  appId: PUSHER_APP_ID,
  key: PUSHER_KEY,
  secret: PUSHER_SECRET,
  useTLS: true,
  host: PUSHER_HOST,
});
