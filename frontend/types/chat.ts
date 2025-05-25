import type { Message } from './message';

export interface Chat {
  sender: {
    name: string;
  };
  messages: Message[];
}
