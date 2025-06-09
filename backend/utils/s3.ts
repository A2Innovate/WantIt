import {
  DeleteObjectCommand,
  DeleteObjectsCommand,
  ListObjectsV2Command,
  ListObjectsV2CommandOutput,
  PutObjectCommand,
  S3Client,
} from "@aws-sdk/client-s3";
import {
  S3_ACCESS_KEY,
  S3_BUCKET,
  S3_ENDPOINT,
  S3_REGION,
  S3_SECRET_KEY,
} from "@/utils/global.ts";

export const s3 = new S3Client({
  endpoint: S3_ENDPOINT,
  region: S3_REGION,
  credentials: {
    accessKeyId: S3_ACCESS_KEY,
    secretAccessKey: S3_SECRET_KEY,
  },
  forcePathStyle: true,
});

export async function uploadFile(
  { file, key }: { file: File; key: string },
) {
  return s3.send(
    new PutObjectCommand({
      Bucket: S3_BUCKET,
      Key: key,
      Body: new Uint8Array(await file.arrayBuffer()),
    }),
  );
}

export function uploadFileBuffer(
  { buffer, key }: { buffer: Uint8Array; key: string },
) {
  return s3.send(
    new PutObjectCommand({
      Bucket: S3_BUCKET,
      Key: key,
      Body: buffer,
    }),
  );
}

export async function deleteFile(key: string) {
  return await s3.send(
    new DeleteObjectCommand({
      Bucket: S3_BUCKET,
      Key: key,
    }),
  );
}

export async function listFiles(prefix: string) {
  const objects: string[] = [];
  let continuationToken: string | undefined = undefined;

  do {
    const listResponse: ListObjectsV2CommandOutput = await s3.send(
      new ListObjectsV2Command({
        Bucket: S3_BUCKET,
        Prefix: prefix,
        ContinuationToken: continuationToken,
      }),
    );

    for (const object of listResponse.Contents ?? []) {
      if (object.Key) {
        objects.push(object.Key);
      }
    }

    if (listResponse.IsTruncated) {
      continuationToken = listResponse.NextContinuationToken;
    } else {
      continuationToken = undefined;
    }
  } while (continuationToken);

  return objects;
}

export async function deleteRecursive(
  key: string,
) {
  const objectsToDelete = await listFiles(key);

  while (objectsToDelete.length > 0) {
    const batch = objectsToDelete.splice(0, 1000);
    await s3.send(
      new DeleteObjectsCommand({
        Bucket: S3_BUCKET,
        Delete: { Objects: batch.map((key) => ({ Key: key })) },
      }),
    );
  }
}
