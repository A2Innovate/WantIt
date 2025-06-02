import type { User } from './user';
import type { Offer } from './offer';
import type { Request } from './request';

export enum NotificationType {
  NEW_OFFER = 'NEW_OFFER',
  NEW_MESSAGE = 'NEW_MESSAGE',
  NEW_OFFER_COMMENT = 'NEW_OFFER_COMMENT'
}

export interface Notification {
  id: number;
  userId: number;
  relatedUserId: number;
  relatedOfferId: number;
  relatedRequestId: number;
  relatedUser?: Pick<User, 'name'>;
  relatedOffer?: Offer;
  relatedRequest?: Request;
  type: NotificationType;
  read: boolean;
  createdAt: string;
}
