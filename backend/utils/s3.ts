import {
  DeleteObjectCommand,
  PutObjectCommand,
  S3Client,
} from "@aws-sdk/client-s3";

export const s3 = new S3Client({
  endpoint: Deno.env.get("S3_ENDPOINT")!,
  region: Deno.env.get("S3_REGION")!,
  credentials: {
    accessKeyId: Deno.env.get("S3_ACCESS_KEY")!,
    secretAccessKey: Deno.env.get("S3_SECRET_KEY")!,
  },
  forcePathStyle: true,
});

export async function uploadFile(
  { file, key }: { file: File; key: string },
) {
  return s3.send(
    new PutObjectCommand({
      Bucket: Deno.env.get("S3_BUCKET")!,
      Key: key,
      Body: new Uint8Array(await file.arrayBuffer()),
    }),
  );
}

export function deleteFile(key: string) {
  return s3.send(
    new DeleteObjectCommand({
      Bucket: Deno.env.get("S3_BUCKET")!,
      Key: key,
    }),
  );
}
