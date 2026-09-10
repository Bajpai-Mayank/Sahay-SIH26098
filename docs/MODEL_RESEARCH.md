# SAHAY-AI — Model Research

> Comparison tables for AI/ML models relevant to the platform.
> This is a research document — models must be independently evaluated.

## LLM Models

| Model             | Purpose              | Languages        | Size          | License        | Hardware       | API?    | Local?  | Free?          | Limitations                                       |
|-------------------|----------------------|------------------|---------------|----------------|----------------|---------|---------|----------------|---------------------------------------------------|
| Gemini 1.5 Flash  | Chat, analysis       | 40+ incl Hindi   | Cloud         | Proprietary    | Cloud          | Yes     | No      | Free tier      | API key required, rate limits                     |
| Gemini 1.5 Pro    | Complex analysis     | 40+ incl Hindi   | Cloud         | Proprietary    | Cloud          | Yes     | No      | Limited free   | Higher cost, rate limits                          |
| Gemma 2 2B        | Local chat           | English + some    | 2B params     | Apache 2.0     | 4GB+ RAM       | Via Ollama | Yes  | Yes            | Limited multilingual, smaller context             |
| Gemma 2 7B        | Local analysis       | English + some    | 7B params     | Apache 2.0     | 8GB+ RAM       | Via Ollama | Yes  | Yes            | Moderate multilingual support                     |
| Gemma 2 9B        | Local analysis       | English + some    | 9B params     | Apache 2.0     | 12GB+ RAM      | Via Ollama | Yes  | Yes            | Better quality, higher resource needs             |
| Qwen 2.5 3B      | Multilingual chat    | 29+ incl Hindi   | 3B params     | Apache 2.0     | 4GB+ RAM       | Via Ollama | Yes  | Yes            | Good Hindi, smaller context                       |
| Qwen 2.5 7B      | Multilingual analysis| 29+ incl Hindi   | 7B params     | Apache 2.0     | 8GB+ RAM       | Via Ollama | Yes  | Yes            | Good multilingual, moderate resources             |
| Phi-3 Mini        | Efficient local      | English + limited | 3.8B params  | MIT            | 4GB+ RAM       | Via Ollama | Yes  | Yes            | Limited Hindi support                             |
| Llama 3.1 8B     | General purpose      | 8 languages      | 8B params     | Llama 3.1 License | 8GB+ RAM   | Via Ollama | Yes  | Yes            | License restrictions for some uses                |

**Recommendation:** Start with MockProvider. Evaluate Gemini Flash for cloud, Qwen 2.5 7B for local Hindi support.

## ASR (Automatic Speech Recognition)

| Model                | Purpose              | Languages        | Size          | License        | API?    | Local?  | Free?   | Notes                                              |
|----------------------|----------------------|------------------|---------------|----------------|---------|---------|---------|-----------------------------------------------------|
| Whisper (OpenAI)     | General ASR          | 99 languages     | Tiny to Large | MIT            | Via API | Yes     | Yes     | Good Hindi, well-documented                         |
| Whisper Large V3     | High-quality ASR     | 99 languages     | 1.5B params   | MIT            | Via API | Yes     | Yes     | Best accuracy, high resource needs                  |
| IndicWhisper         | Indian language ASR  | 12 Indian langs  | Various       | MIT            | No      | Yes     | Yes     | Fine-tuned for Indian languages                     |
| Vakyansh ASR         | Indian language ASR  | Hindi + regional  | Various       | Open           | API     | Yes     | Yes     | Government-backed, needs evaluation                 |
| AI4Bharat Indic ASR  | Indian language ASR  | 22 Indian langs  | Various       | CC-BY-4.0      | API     | Yes     | Yes     | Best coverage for Indian languages                  |

**Recommendation:** Whisper Large V3 for development. Evaluate IndicWhisper/AI4Bharat for Hindi-specific accuracy.

## Translation

| Model                | Purpose              | Languages        | Size          | License        | Local?  | Free?   | Notes                                              |
|----------------------|----------------------|------------------|---------------|----------------|---------|---------|-----------------------------------------------------|
| IndicTrans2          | Indian translation   | 22 Indian + En   | 320M-1.1B    | MIT            | Yes     | Yes     | State-of-the-art for Indian languages               |
| NLLB-200             | Multilingual NMT     | 200 languages    | 600M-3.3B    | CC-BY-NC-4.0   | Yes     | Yes     | Non-commercial license                              |
| Google Translate API | Cloud translation    | 130+ languages   | Cloud         | Proprietary    | No      | Limited | Reliable but costs at scale                         |
| IndicTransTokenizer  | Tokenization         | Indian languages | Small         | MIT            | Yes     | Yes     | Required for IndicTrans2                            |

**Recommendation:** IndicTrans2 for offline Hindi-English translation.

## NLP Models

| Model / Library      | Purpose              | Languages        | License        | Local?  | Notes                                              |
|----------------------|----------------------|------------------|----------------|---------|-----------------------------------------------------|
| HF Sentiment Models  | Sentiment analysis   | Multilingual     | Various        | Yes     | Many fine-tuned options available                   |
| GoEmotions (Google)  | Emotion detection    | English          | Apache 2.0     | Yes     | 27 emotion categories                              |
| XLM-RoBERTa          | Multilingual NLU     | 100 languages    | MIT            | Yes     | Good base for fine-tuning Hindi                     |
| MuRIL (Google)       | Indian language NLU  | 17 Indian langs  | Apache 2.0     | Yes     | Best for Indian language understanding              |
| IndicBERT            | Indian NLU           | 12 Indian langs  | MIT            | Yes     | AI4Bharat, good for classification                  |
| spaCy                | NER, tokenization    | 70+ languages    | MIT            | Yes     | Pipeline-based, efficient                           |
| fasttext             | Language detection   | 176 languages    | MIT            | Yes     | Very fast language identification                   |
| sentence-transformers| Embeddings           | Multilingual     | Apache 2.0     | Yes     | Semantic search, similarity                         |

## Voice/Acoustic Analysis

| Library / Model      | Purpose              | License        | Notes                                              |
|----------------------|----------------------|----------------|-----------------------------------------------------|
| librosa              | Audio features       | ISC            | Speech rate, pitch, energy, MFCCs                   |
| openSMILE            | Acoustic features    | audEERING License | Research-grade, comprehensive feature sets       |
| pyAudioAnalysis      | Audio classification | Apache 2.0     | Feature extraction + classification                 |
| SpeechBrain          | Speech processing    | Apache 2.0     | Emotion recognition, speaker verification           |
| Wav2Vec2             | Speech representations| MIT           | Fine-tunable for emotion detection                  |

**Note:** Acoustic features are NOT clinical biomarkers. They are engineering signals for support priority computation.

---

> **CRITICAL:** All models must be independently evaluated for:
> 1. Performance on Hindi and Indian English
> 2. License compatibility with project use
> 3. Hardware requirements vs. available infrastructure
> 4. Bias and fairness (especially for vulnerable populations)
> 5. False positive/negative rates for safety-critical features
