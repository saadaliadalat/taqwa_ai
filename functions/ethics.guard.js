/**
 * Ethics Guard for Taqwa AI
 * 
 * Implements Islamic ethical guardrails for AI responses.
 * Filters prompts and responses to ensure compliance with
 * authentic Islamic principles.
 */

// ============================================
// BLOCKED TOPICS & PATTERNS
// ============================================

/**
 * Topics that should be declined or handled carefully
 */
const BLOCKED_TOPICS = [
    // Political fatwas
    "political fatwa",
    "vote for",
    "political party",
    "election ruling",
    "government overthrow",

    // Extremism
    "jihad against",
    "kill infidels",
    "suicide bombing",
    "terrorist",
    "extremist violence",
    "takfir",

    // Non-Islamic theology
    "trinity",
    "jesus is god",
    "reincarnation",
    "karma",
    "astrology prediction",
    "horoscope",
    "fortune telling",
    "black magic spell",

    // Inappropriate content
    "dating advice",
    "boyfriend girlfriend",
    "haram relationship",

    // Sectarian
    "shia vs sunni",
    "which sect is right",
    "sectarian conflict",
];

/**
 * Patterns that indicate potentially problematic content
 */
const WARNING_PATTERNS = [
    /\b(kill|murder|harm)\s+(someone|people|person)/i,
    /\b(how to|ways to)\s+(cheat|deceive|lie)/i,
    /\b(justify|permit)\s+(violence|killing)/i,
    /\bfatwa\s+on\s+(politician|leader|president)/i,
    /\b(curse|damn)\s+(person|someone)/i,
];

/**
 * Keywords that indicate Islamic content (positive markers)
 */
const ISLAMIC_KEYWORDS = [
    "allah",
    "quran",
    "hadith",
    "prophet",
    "muhammad",
    "islam",
    "muslim",
    "salah",
    "prayer",
    "fasting",
    "ramadan",
    "zakat",
    "hajj",
    "halal",
    "haram",
    "sunnah",
    "fiqh",
    "sharia",
    "dua",
    "dhikr",
    "tawhid",
    "iman",
    "taqwa",
];

// ============================================
// VALIDATION FUNCTIONS
// ============================================

/**
 * Check if a prompt contains blocked content
 * @param {string} prompt - User's input prompt
 * @returns {Object} Validation result
 */
const validatePrompt = (prompt) => {
    const lowerPrompt = prompt.toLowerCase();

    // Check for blocked topics
    for (const topic of BLOCKED_TOPICS) {
        if (lowerPrompt.includes(topic)) {
            return {
                isValid: false,
                reason: "blocked_topic",
                message: "This question touches on topics that I cannot provide guidance on. Please consult a qualified Islamic scholar for matters related to political rulings, sectarian issues, or sensitive religious matters.",
                blockedTerm: topic,
            };
        }
    }

    // Check for warning patterns
    for (const pattern of WARNING_PATTERNS) {
        if (pattern.test(prompt)) {
            return {
                isValid: false,
                reason: "warning_pattern",
                message: "I cannot provide guidance on questions that may involve harm to others. Islam teaches peace, mercy, and justice. Please consult a qualified scholar for complex matters.",
                pattern: pattern.toString(),
            };
        }
    }

    // Check if prompt is too short or meaningless
    if (prompt.trim().length < 3) {
        return {
            isValid: false,
            reason: "too_short",
            message: "Please provide a more detailed question so I can assist you better.",
        };
    }

    // Check for very long prompts (potential injection attempts)
    if (prompt.length > 2000) {
        return {
            isValid: false,
            reason: "too_long",
            message: "Your question is too long. Please try to be more concise.",
        };
    }

    return { isValid: true };
};

/**
 * Check if prompt is related to Islamic topics
 * @param {string} prompt - User's input prompt
 * @returns {boolean} True if Islamic-related
 */
const isIslamicQuery = (prompt) => {
    const lowerPrompt = prompt.toLowerCase();
    return ISLAMIC_KEYWORDS.some((keyword) => lowerPrompt.includes(keyword));
};

/**
 * Validate and sanitize AI response
 * @param {string} response - AI-generated response
 * @returns {Object} Validation result
 */
const validateResponse = (response) => {
    const lowerResponse = response.toLowerCase();

    // Check for blocked content in response
    for (const topic of BLOCKED_TOPICS) {
        if (lowerResponse.includes(topic)) {
            return {
                isValid: false,
                reason: "response_contains_blocked",
                message: "I cannot provide this response. Please consult a qualified Islamic scholar for guidance on this matter.",
            };
        }
    }

    // Check for warning patterns in response
    for (const pattern of WARNING_PATTERNS) {
        if (pattern.test(response)) {
            return {
                isValid: false,
                reason: "response_warning_pattern",
                message: "I cannot provide this response. Please consult a qualified Islamic scholar for guidance on this matter.",
            };
        }
    }

    // Check for potential hallucinations or fabricated hadith
    const fabricationPatterns = [
        /hadith\s+(?:says?|states?|mentions?)\s*[:"'].*?(?:source|reference)\s*(?:unknown|unclear)/i,
        /the\s+prophet\s+said\s*[:"'].*?(?:though|but)\s+(?:this|the)\s+source/i,
    ];

    for (const pattern of fabricationPatterns) {
        if (pattern.test(response)) {
            return {
                isValid: true,
                warning: "potential_unverified_source",
                message: "This response may contain unverified sources. Always verify with authentic hadith collections.",
            };
        }
    }

    return { isValid: true };
};

// ============================================
// PROMPT ENHANCEMENT
// ============================================

/**
 * System prompt for Islamic AI assistant
 */
const SYSTEM_PROMPT = `You are Taqwa AI, a knowledgeable and respectful Islamic assistant. Your role is to provide authentic Islamic guidance based ONLY on:

1. The Holy Quran - The word of Allah
2. Authentic Hadith - Sayings of Prophet Muhammad (peace be upon him)
3. Scholarly consensus (Ijma) from recognized Islamic scholars

IMPORTANT GUIDELINES:

1. ALWAYS cite your sources:
   - For Quran: Mention Surah name and Ayah number
   - For Hadith: Mention the collection (Bukhari, Muslim, etc.) and hadith number if known
   
2. NEVER provide:
   - Political fatwas or rulings on voting/elections
   - Rulings that promote violence or extremism
   - Guidance on non-Islamic religious practices
   - Personal opinions presented as Islamic rulings
   - Made-up or unverified hadith

3. When you don't know:
   - Clearly state "I don't have sufficient knowledge on this matter"
   - Recommend consulting a qualified Islamic scholar
   
4. Use respectful language:
   - Say "Peace be upon him" (PBUH) when mentioning Prophet Muhammad
   - Say "Subhanahu wa ta'ala" (SWT) when mentioning Allah
   - Be kind and encouraging to the questioner

5. For fiqh (jurisprudence) questions:
   - Acknowledge different valid scholarly opinions when they exist
   - Never claim one madhab is superior to others
   - Recommend consulting local scholars for personal matters

Remember: You are a helper, not a mufti. Guide users to authentic sources and scholars.`;

/**
 * Create enhanced prompt with system instructions
 * @param {string} userPrompt - User's question
 * @returns {Array} Messages array for the AI
 */
const createEnhancedPrompt = (userPrompt) => {
    return [
        {
            role: "system",
            content: SYSTEM_PROMPT,
        },
        {
            role: "user",
            content: userPrompt,
        },
    ];
};

/**
 * Add Quran and Hadith context to the prompt
 * @param {string} userPrompt - Original user prompt
 * @param {Object} context - Additional context from Quran/Hadith APIs
 * @returns {Array} Enhanced messages array
 */
const createContextualPrompt = (userPrompt, context = {}) => {
    const messages = [
        {
            role: "system",
            content: SYSTEM_PROMPT,
        },
    ];

    // Add Quran context if available
    if (context.quranVerses && context.quranVerses.length > 0) {
        const quranContext = context.quranVerses
            .map((v) => `[Surah ${v.surah}:${v.ayah}] "${v.text}"`)
            .join("\n");

        messages.push({
            role: "system",
            content: `Relevant Quran verses for context:\n${quranContext}`,
        });
    }

    // Add Hadith context if available
    if (context.hadithReferences && context.hadithReferences.length > 0) {
        const hadithContext = context.hadithReferences
            .map((h) => `[${h.collection}, Hadith ${h.number}] "${h.text}"`)
            .join("\n");

        messages.push({
            role: "system",
            content: `Relevant Hadith for context:\n${hadithContext}`,
        });
    }

    messages.push({
        role: "user",
        content: userPrompt,
    });

    return messages;
};

// ============================================
// RESPONSE POST-PROCESSING
// ============================================

/**
 * Add standard Islamic phrases if missing
 * @param {string} response - AI response
 * @returns {string} Enhanced response
 */
const enhanceResponse = (response) => {
    let enhanced = response;

    // Ensure Prophet's name is followed by honorific
    enhanced = enhanced.replace(
        /\bProphet Muhammad(?!\s*\(|\s*peace|\s*ﷺ)/gi,
        "Prophet Muhammad (peace be upon him)"
    );

    // Ensure Allah is mentioned with respect
    enhanced = enhanced.replace(
        /\bAllah(?!\s*\(|\s*Subhanahu|\s*SWT)/gi,
        "Allah (Subhanahu wa ta'ala)"
    );

    return enhanced;
};

/**
 * Get fallback response for invalid queries
 * @param {string} reason - Reason for fallback
 * @returns {string} Fallback message
 */
const getFallbackResponse = (reason = "general") => {
    const fallbacks = {
        blocked_topic: "I cannot provide guidance on this topic as it goes beyond the scope of authentic Islamic sources. Please consult a qualified Islamic scholar for matters related to political rulings, sectarian issues, or sensitive religious questions.",

        warning_pattern: "I'm designed to provide guidance based on the Quran and authentic Hadith. This question touches on matters that require careful scholarly analysis. Please consult a local imam or qualified Islamic scholar.",

        non_islamic: "I specialize in questions related to Islam, the Quran, and authentic Hadith. For questions on other topics, please consult appropriate sources.",

        general: "I cannot answer this question as it goes beyond authentic Islamic sources. Please rephrase your question or consult a qualified Islamic scholar.",

        error: "I apologize, but I'm unable to process this request at the moment. Please try again or rephrase your question.",
    };

    return fallbacks[reason] || fallbacks.general;
};

module.exports = {
    // Validation
    validatePrompt,
    validateResponse,
    isIslamicQuery,

    // Prompt creation
    SYSTEM_PROMPT,
    createEnhancedPrompt,
    createContextualPrompt,

    // Response processing
    enhanceResponse,
    getFallbackResponse,

    // Constants
    BLOCKED_TOPICS,
    WARNING_PATTERNS,
    ISLAMIC_KEYWORDS,
};
