import { FeatureExtractionPipeline, pipeline } from '@huggingface/transformers';


let _extractor: FeatureExtractionPipeline | null = null;

async function getExtractor() {
  if (!_extractor) {
    try {
      _extractor = await pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2');
    } catch (error) {
      console.error("Failed to load NSFW model:", error);
      throw new Error("NSFW detection service unavailable");
    }
  }
  return _extractor;
}

export async function getEmbeddings(text: string) {
  const extractor = await getExtractor();
  const output = await extractor(text);
  return output.tolist()[0][0]; // Flatten the 2D array to 1D
}
  