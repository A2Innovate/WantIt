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
  type: NotificationType;
  createdAt: string;
}
