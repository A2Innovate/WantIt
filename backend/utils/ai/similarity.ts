import { pipeline, ImagePipelineInputs } from "@huggingface/transformers";

let _pipe: ImagePipelineInputs | null = null;
async function getPipe() {
  if (!_pipe) {
    try {
      _pipe = await pipeline(
        "feature-extraction",
        "sentence-transformers/all-mpnet-base-v2"
      );
    } catch (error) {
      console.error("Failed to load Xenova model:", error);
      throw new Error("Xenova service unavailable");
    }
  }
  return _pipe;
}
export async function getEmbeddings(text: string) {
  const pipe = await getPipe();
  const prediction = await pipe(text);
//   console.log(prediction[0].tolist()[0]);
  return prediction;
}
  
