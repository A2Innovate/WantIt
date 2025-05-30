import { ImagePipelineInputs, pipeline } from "@huggingface/transformers";

let _pipe: ImagePipelineInputs | null = null;
const NSFW_THRESHOLD = 0.6;
const NSFW_CATEGORIES = ["porn", "hentai", "sexy"];

async function getPipe() {
  if (!_pipe) {
    try {
      _pipe = await pipeline(
        "image-classification",
        "onnx-community/nsfw-image-detector-ONNX",
      );
    } catch (error) {
      console.error("Failed to load NSFW model:", error);
      throw new Error("NSFW detection service unavailable");
    }
  }
  return _pipe;
}

export async function detectNSFW(image: File) {
  const pipe = await getPipe();
  const prediction = await pipe(image);
  for (const result of prediction) {
    if (
      result.score > NSFW_THRESHOLD &&
      NSFW_CATEGORIES.includes(result.label)
    ) {
      return true;
    }
  }
  return false;
}
