/**
 * AI Handler for Taqwa AI
 * 
 * Core AI orchestration using Groq LLaMA-3.1-70B for Islamic Q&A.
 * Integrates Quran and Hadith references for authentic responses.
 */

const Groq = require("groq-sdk");
const ethicsGuard = require("./ethics.guard");
const quranService = require("./quran.service");
const hadithService = require("./hadith.service");

// ============================================
// GROQ CONFIGURATION
// ============================================

/**
 * Initialize Groq client
 * @returns {Object} Groq client instance
 */
const getGroqClient = () => {
    const apiKey = process.env.GROQ_API_KEY;
    if (!apiKey) {
        throw new Error("GROQ_API_KEY environment variable is not set");
    }
    return new Groq({ apiKey });
};

/**
 * Default AI model configuration
 */
const DEFAULT_MODEL = "llama-3.1-70b-versatile";
const DEFAULT_MAX_TOKENS = 2048;
const DEFAULT_TEMPERATURE = 0.7;

// ============================================
// KEYWORD EXTRACTION
// ============================================

/**
 * Extract keywords from user question for Quran/Hadith search
 * @param {string} question - User's question
 * @returns {Array<string>} List of keywords
 */
const extractKeywords = (question) => {
    // Remove common words and punctuation
    const stopWords = new Set([
        "what", "is", "the", "a", "an", "in", "on", "at", "for", "to",
        "of", "and", "or", "how", "why", "when", "where", "who", "which",
        "can", "could", "would", "should", "does", "do", "did", "has",
        "have", "had", "be", "been", "being", "am", "are", "was", "were",
        "i", "you", "he", "she", "it", "we", "they", "my", "your", "his",
        "her", "its", "our", "their", "this", "that", "these", "those",
        "about", "according", "tell", "me", "please", "islam", "islamic",
        "muslim", "quran", "hadith", "prophet", "allah",
    ]);

    const words = question
        .toLowerCase()
        .replace(/[^\w\s]/g, "")
        .split(/\s+/)
        .filter((word) => word.length > 2 && !stopWords.has(word));

    // Return unique keywords
    return [...new Set(words)];
};

/**
 * Determine the topic category of the question
 * @param {string} question - User's question
 * @returns {string|null} Topic category
 */
const categorizeQuestion = (question) => {
    const topics = {
        prayer: ["prayer", "salah", "salat", "pray", "namaz", "wudu", "ablution"],
        fasting: ["fast", "fasting", "ramadan", "suhoor", "iftar", "sawm"],
        charity: ["zakat", "charity", "sadaqah", "giving", "poor", "needy"],
        hajj: ["hajj", "umrah", "pilgrimage", "mecca", "kaaba"],
        marriage: ["marriage", "nikah", "wedding", "spouse", "husband", "wife"],
        death: ["death", "funeral", "janazah", "grave", "burial"],
        food: ["halal", "haram", "food", "eat", "drink", "alcohol", "pork"],
        finance: ["interest", "riba", "usury", "loan", "mortgage", "investment"],
        family: ["parents", "children", "mother", "father", "family"],
        character: ["manners", "character", "akhlaq", "patience", "honesty"],
    };

    const lowerQuestion = question.toLowerCase();

    for (const [topic, keywords] of Object.entries(topics)) {
        if (keywords.some((keyword) => lowerQuestion.includes(keyword))) {
            return topic;
        }
    }

    return null;
};

// ============================================
// REFERENCE GATHERING
// ============================================

/**
 * Gather relevant Quran and Hadith references for a question
 * @param {string} question - User's question
 * @returns {Promise<Object>} References object
 */
const gatherReferences = async (question) => {
    const references = {
        quran: [],
        hadith: [],
    };

    const keywords = extractKeywords(question);
    const topic = categorizeQuestion(question);

    try {
        // Search Quran for relevant verses
        if (topic) {
            const quranMatches = await quranService.findRelevantVerses(topic, 3);
            references.quran = quranMatches.map((match) => ({
                surah: match.surah,
                surahName: match.surahName,
                ayah: match.ayah,
                text: match.text,
            }));
        } else if (keywords.length > 0) {
            // Try searching with the first few keywords
            for (const keyword of keywords.slice(0, 2)) {
                try {
                    const results = await quranService.searchQuran(keyword);
                    if (results.matches && results.matches.length > 0) {
                        references.quran.push(...results.matches.slice(0, 2).map((m) => ({
                            surah: m.surah,
                            surahName: m.surahName,
                            ayah: m.ayah,
                            text: m.text,
                        })));
                        break;
                    }
                } catch (e) {
                    // Continue with next keyword
                }
            }
        }
    } catch (error) {
        console.warn("Error fetching Quran references:", error.message);
    }

    try {
        // Search Hadith for relevant narrations
        if (topic) {
            const hadithMatches = await hadithService.findRelevantHadiths(topic, 2);
            references.hadith = hadithMatches.map((match) => ({
                collection: match.collectionName || match.collection,
                number: match.hadithNumber,
                text: match.textEnglish || match.textArabic,
                grade: match.grade,
            }));
        }
    } catch (error) {
        console.warn("Error fetching Hadith references:", error.message);
    }

    return references;
};

// ============================================
// AI RESPONSE GENERATION
// ============================================

/**
 * Generate AI response for a question
 * @param {string} question - User's question
 * @param {Object} options - Generation options
 * @returns {Promise<Object>} AI response with references
 */
const generateResponse = async (question, options = {}) => {
    // Validate the prompt
    const validation = ethicsGuard.validatePrompt(question);
    if (!validation.isValid) {
        return {
            success: false,
            answer: validation.message,
            sources: [],
            references: { quran: [], hadith: [] },
            blocked: true,
            reason: validation.reason,
        };
    }

    // Gather Quran and Hadith references
    const references = await gatherReferences(question);

    // Determine sources
    const sources = [];
    if (references.quran.length > 0) sources.push("Quran");
    if (references.hadith.length > 0) sources.push("Hadith");
    sources.push("AI");

    try {
        // Initialize Groq client
        const groq = getGroqClient();

        // Build contextual prompt with references
        const context = {
            quranVerses: references.quran.map((q) => ({
                surah: q.surah,
                ayah: q.ayah,
                text: q.text,
            })),
            hadithReferences: references.hadith.map((h) => ({
                collection: h.collection,
                number: h.number,
                text: h.text,
            })),
        };

        const messages = ethicsGuard.createContextualPrompt(question, context);

        // Generate response using Groq
        const completion = await groq.chat.completions.create({
            model: options.model || DEFAULT_MODEL,
            messages: messages,
            max_tokens: options.maxTokens || DEFAULT_MAX_TOKENS,
            temperature: options.temperature || DEFAULT_TEMPERATURE,
            top_p: 0.9,
            stream: false,
        });

        let answer = completion.choices[0]?.message?.content || "";

        // Validate and enhance the response
        const responseValidation = ethicsGuard.validateResponse(answer);
        if (!responseValidation.isValid) {
            return {
                success: false,
                answer: responseValidation.message,
                sources: [],
                references: { quran: [], hadith: [] },
                blocked: true,
                reason: responseValidation.reason,
            };
        }

        // Enhance response with proper Islamic phrases
        answer = ethicsGuard.enhanceResponse(answer);

        // Add warning if response might contain unverified content
        if (responseValidation.warning) {
            answer += "\n\n⚠️ " + responseValidation.message;
        }

        return {
            success: true,
            answer,
            sources,
            references: {
                quran: references.quran,
                hadith: references.hadith,
            },
            usage: {
                promptTokens: completion.usage?.prompt_tokens || 0,
                completionTokens: completion.usage?.completion_tokens || 0,
                totalTokens: completion.usage?.total_tokens || 0,
            },
        };
    } catch (error) {
        console.error("AI generation error:", error);

        // Handle specific Groq errors
        if (error.message?.includes("rate limit")) {
            return {
                success: false,
                answer: "I'm currently experiencing high demand. Please try again in a moment.",
                sources: [],
                references: { quran: [], hadith: [] },
                error: "rate_limit",
            };
        }

        if (error.message?.includes("API key")) {
            return {
                success: false,
                answer: "There was a configuration error. Please contact support.",
                sources: [],
                references: { quran: [], hadith: [] },
                error: "config_error",
            };
        }

        return {
            success: false,
            answer: ethicsGuard.getFallbackResponse("error"),
            sources: [],
            references: { quran: [], hadith: [] },
            error: "generation_failed",
        };
    }
};

/**
 * Generate a quick response without reference lookup
 * Useful for simple greetings or common questions
 * @param {string} question - User's question
 * @returns {Promise<Object>} AI response
 */
const generateQuickResponse = async (question) => {
    // Validate the prompt
    const validation = ethicsGuard.validatePrompt(question);
    if (!validation.isValid) {
        return {
            success: false,
            answer: validation.message,
            sources: [],
            blocked: true,
        };
    }

    try {
        const groq = getGroqClient();
        const messages = ethicsGuard.createEnhancedPrompt(question);

        const completion = await groq.chat.completions.create({
            model: DEFAULT_MODEL,
            messages: messages,
            max_tokens: 1024,
            temperature: 0.7,
            stream: false,
        });

        let answer = completion.choices[0]?.message?.content || "";
        answer = ethicsGuard.enhanceResponse(answer);

        return {
            success: true,
            answer,
            sources: ["AI"],
        };
    } catch (error) {
        console.error("Quick response error:", error);
        return {
            success: false,
            answer: ethicsGuard.getFallbackResponse("error"),
            sources: [],
        };
    }
};

// ============================================
// SPECIALIZED QUERIES
// ============================================

/**
 * Get explanation for a specific Quran verse
 * @param {number} surah - Surah number
 * @param {number} ayah - Ayah number
 * @returns {Promise<Object>} Explanation response
 */
const explainVerse = async (surah, ayah) => {
    try {
        // Fetch the verse first
        const verse = await quranService.getAyah(surah, ayah);

        const question = `Please explain the meaning and context of this Quran verse:\n\n"${verse.textTranslation}"\n\n(Surah ${verse.surahName}, Ayah ${ayah})`;

        const response = await generateQuickResponse(question);

        return {
            ...response,
            verse: {
                surah,
                surahName: verse.surahName,
                ayah,
                textArabic: verse.textArabic,
                textTranslation: verse.textTranslation,
            },
            sources: ["Quran", "AI"],
        };
    } catch (error) {
        console.error("Error explaining verse:", error);
        return {
            success: false,
            answer: "Unable to explain this verse at the moment. Please try again.",
            error: error.message,
        };
    }
};

/**
 * Get explanation for a hadith
 * @param {string} collection - Hadith collection name
 * @param {number|string} hadithNumber - Hadith number
 * @returns {Promise<Object>} Explanation response
 */
const explainHadith = async (collection, hadithNumber) => {
    try {
        // Fetch the hadith first
        const hadith = await hadithService.getHadith(collection, hadithNumber);

        if (!hadith) {
            return {
                success: false,
                answer: "Hadith not found. Please check the collection name and number.",
            };
        }

        const question = `Please explain the meaning and lessons from this hadith:\n\n"${hadith.textEnglish}"\n\n(${hadith.reference})`;

        const response = await generateQuickResponse(question);

        return {
            ...response,
            hadith: {
                collection: hadith.collection,
                collectionName: hadith.collectionName,
                hadithNumber: hadith.hadithNumber,
                textArabic: hadith.textArabic,
                textEnglish: hadith.textEnglish,
                grade: hadith.grade,
            },
            sources: ["Hadith", "AI"],
        };
    } catch (error) {
        console.error("Error explaining hadith:", error);
        return {
            success: false,
            answer: "Unable to explain this hadith at the moment. Please try again.",
            error: error.message,
        };
    }
};

module.exports = {
    // Main functions
    generateResponse,
    generateQuickResponse,

    // Specialized queries
    explainVerse,
    explainHadith,

    // Utilities
    extractKeywords,
    categorizeQuestion,
    gatherReferences,

    // Configuration
    DEFAULT_MODEL,
    DEFAULT_MAX_TOKENS,
    DEFAULT_TEMPERATURE,
};
