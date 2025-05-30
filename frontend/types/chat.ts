import type { Message } from './message';

export interface Chat {
  person: {
    name: string;
    username: string;
  };
  messages: Message[];
}
