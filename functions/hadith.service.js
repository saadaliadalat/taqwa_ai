/**
 * Hadith Service for Taqwa AI
 * 
 * Integration with Sunnah.com API for authentic Hadith retrieval
 * and search functionality.
 * 
 * API Documentation: https://sunnah.com/developers
 */

const axios = require("axios");

// Base URL for Sunnah.com API
const SUNNAH_API_BASE = "https://api.sunnah.com/v1";

/**
 * Get Sunnah.com API key from environment
 * @returns {string} API key
 */
const getApiKey = () => {
    const apiKey = process.env.SUNNAH_API_KEY;
    if (!apiKey) {
        throw new Error("SUNNAH_API_KEY environment variable is not set");
    }
    return apiKey;
};

/**
 * Create axios instance with authentication
 * @returns {Object} Axios instance
 */
const createApiClient = () => {
    return axios.create({
        baseURL: SUNNAH_API_BASE,
        headers: {
            "X-API-Key": getApiKey(),
            "Content-Type": "application/json",
        },
        timeout: 10000,
    });
};

// ============================================
// HADITH COLLECTIONS
// ============================================

/**
 * Available hadith collections
 */
const COLLECTIONS = {
    BUKHARI: "bukhari",
    MUSLIM: "muslim",
    NASAI: "nasai",
    ABUDAWUD: "abudawud",
    TIRMIDHI: "tirmidhi",
    IBNMAJAH: "ibnmajah",
    MALIK: "malik",
    AHMAD: "ahmad",
    DARIMI: "darimi",
};

/**
 * Collection display names
 */
const COLLECTION_NAMES = {
    bukhari: "Sahih al-Bukhari",
    muslim: "Sahih Muslim",
    nasai: "Sunan an-Nasa'i",
    abudawud: "Sunan Abu Dawud",
    tirmidhi: "Jami' at-Tirmidhi",
    ibnmajah: "Sunan Ibn Majah",
    malik: "Muwatta Malik",
    ahmad: "Musnad Ahmad",
    darimi: "Sunan ad-Darimi",
};

/**
 * Get list of all available collections
 * @returns {Promise<Array>} List of collections
 */
const getCollections = async () => {
    try {
        const client = createApiClient();
        const response = await client.get("/collections");

        return response.data.data.map((collection) => ({
            name: collection.name,
            displayName: COLLECTION_NAMES[collection.name] || collection.name,
            hasBooks: collection.hasBooks,
            hasChapters: collection.hasChapters,
            totalHadith: collection.totalHadith,
            totalAvailableHadith: collection.totalAvailableHadith,
        }));
    } catch (error) {
        console.error("Error fetching collections:", error.message);
        throw error;
    }
};

// ============================================
// HADITH RETRIEVAL
// ============================================

/**
 * Get a specific hadith by collection and number
 * @param {string} collection - Collection name
 * @param {number|string} hadithNumber - Hadith number
 * @returns {Promise<Object>} Hadith data
 */
const getHadith = async (collection, hadithNumber) => {
    try {
        const client = createApiClient();
        const response = await client.get(
            `/collections/${collection}/hadiths/${hadithNumber}`
        );

        const hadith = response.data;

        return {
            collection: collection,
            collectionName: COLLECTION_NAMES[collection] || collection,
            hadithNumber: hadith.hadithNumber,
            bookNumber: hadith.bookNumber,
            chapterNumber: hadith.chapterId,
            textArabic: hadith.hadith?.[0]?.body || "",
            textEnglish: hadith.hadith?.[1]?.body || hadith.hadith?.[0]?.body || "",
            grade: hadith.hadith?.[0]?.grades?.[0]?.grade || "Unknown",
            gradeArabic: hadith.hadith?.[0]?.grades?.[0]?.graded_by || "",
            bookName: hadith.bookNumber,
            reference: `${COLLECTION_NAMES[collection]} ${hadithNumber}`,
        };
    } catch (error) {
        if (error.response && error.response.status === 404) {
            return null;
        }
        console.error(`Error fetching hadith ${collection}:${hadithNumber}:`, error.message);
        throw error;
    }
};

/**
 * Get random hadith from a collection
 * @param {string} collection - Collection name (default: bukhari)
 * @returns {Promise<Object>} Random hadith
 */
const getRandomHadith = async (collection = COLLECTIONS.BUKHARI) => {
    try {
        const client = createApiClient();
        const response = await client.get(`/collections/${collection}/hadiths/random`);

        const hadith = response.data;

        return {
            collection: collection,
            collectionName: COLLECTION_NAMES[collection] || collection,
            hadithNumber: hadith.hadithNumber,
            bookNumber: hadith.bookNumber,
            textArabic: hadith.hadith?.[0]?.body || "",
            textEnglish: hadith.hadith?.[1]?.body || hadith.hadith?.[0]?.body || "",
            grade: hadith.hadith?.[0]?.grades?.[0]?.grade || "Unknown",
            reference: `${COLLECTION_NAMES[collection]} ${hadith.hadithNumber}`,
        };
    } catch (error) {
        console.error(`Error fetching random hadith from ${collection}:`, error.message);
        throw error;
    }
};

/**
 * Get multiple hadiths from a collection
 * @param {string} collection - Collection name
 * @param {number} page - Page number
 * @param {number} limit - Number of hadiths per page
 * @returns {Promise<Object>} Paginated hadith list
 */
const getHadiths = async (collection, page = 1, limit = 20) => {
    try {
        const client = createApiClient();
        const response = await client.get(
            `/collections/${collection}/hadiths`,
            { params: { page, limit } }
        );

        return {
            collection: collection,
            collectionName: COLLECTION_NAMES[collection] || collection,
            page: response.data.page,
            limit: response.data.limit,
            total: response.data.total,
            hadiths: response.data.data.map((hadith) => ({
                hadithNumber: hadith.hadithNumber,
                bookNumber: hadith.bookNumber,
                textArabic: hadith.hadith?.[0]?.body || "",
                textEnglish: hadith.hadith?.[1]?.body || hadith.hadith?.[0]?.body || "",
                grade: hadith.hadith?.[0]?.grades?.[0]?.grade || "Unknown",
                reference: `${COLLECTION_NAMES[collection]} ${hadith.hadithNumber}`,
            })),
        };
    } catch (error) {
        console.error(`Error fetching hadiths from ${collection}:`, error.message);
        throw error;
    }
};

// ============================================
// BOOKS & CHAPTERS
// ============================================

/**
 * Get books within a collection
 * @param {string} collection - Collection name
 * @returns {Promise<Array>} List of books
 */
const getBooks = async (collection) => {
    try {
        const client = createApiClient();
        const response = await client.get(`/collections/${collection}/books`);

        return response.data.data.map((book) => ({
            bookNumber: book.bookNumber,
            bookName: book.book?.[0]?.name || "",
            bookNameEnglish: book.book?.[1]?.name || book.book?.[0]?.name || "",
            hadithRange: `${book.hadithStartNumber} - ${book.hadithEndNumber}`,
            numberOfHadith: book.numberOfHadith,
        }));
    } catch (error) {
        console.error(`Error fetching books from ${collection}:`, error.message);
        throw error;
    }
};

/**
 * Get hadiths by book number
 * @param {string} collection - Collection name
 * @param {number|string} bookNumber - Book number
 * @param {number} page - Page number
 * @param {number} limit - Hadiths per page
 * @returns {Promise<Object>} Book hadiths
 */
const getHadithsByBook = async (collection, bookNumber, page = 1, limit = 20) => {
    try {
        const client = createApiClient();
        const response = await client.get(
            `/collections/${collection}/books/${bookNumber}/hadiths`,
            { params: { page, limit } }
        );

        return {
            collection,
            bookNumber,
            page: response.data.page,
            limit: response.data.limit,
            total: response.data.total,
            hadiths: response.data.data.map((hadith) => ({
                hadithNumber: hadith.hadithNumber,
                textArabic: hadith.hadith?.[0]?.body || "",
                textEnglish: hadith.hadith?.[1]?.body || "",
                grade: hadith.hadith?.[0]?.grades?.[0]?.grade || "Unknown",
                reference: `${COLLECTION_NAMES[collection]} ${hadith.hadithNumber}`,
            })),
        };
    } catch (error) {
        console.error(`Error fetching hadiths from book ${bookNumber}:`, error.message);
        throw error;
    }
};

// ============================================
// SEARCH FUNCTIONALITY
// ============================================

/**
 * Search hadiths by keyword
 * Note: Sunnah.com API has limited search capabilities
 * This is a basic implementation that searches through cached/fetched data
 * @param {string} keyword - Search keyword
 * @param {string} collection - Collection to search in (optional)
 * @param {number} maxResults - Maximum results to return
 * @returns {Promise<Array>} Search results
 */
const searchHadiths = async (keyword, collection = null, maxResults = 10) => {
    if (!keyword || keyword.trim().length < 3) {
        throw new Error("Search keyword must be at least 3 characters.");
    }

    const results = [];
    const collectionsToSearch = collection
        ? [collection]
        : [COLLECTIONS.BUKHARI, COLLECTIONS.MUSLIM];

    for (const col of collectionsToSearch) {
        try {
            // Fetch first 100 hadiths from the collection
            const response = await getHadiths(col, 1, 100);

            // Filter hadiths containing the keyword
            const matches = response.hadiths.filter((hadith) => {
                const text = (hadith.textEnglish || hadith.textArabic || "").toLowerCase();
                return text.includes(keyword.toLowerCase());
            });

            results.push(...matches.map((h) => ({ ...h, collection: col })));

            if (results.length >= maxResults) break;
        } catch (error) {
            console.warn(`Search failed for collection ${col}`);
        }
    }

    return results.slice(0, maxResults);
};

/**
 * Find relevant hadiths for a topic
 * @param {string} topic - Topic to search for
 * @param {number} maxResults - Maximum results
 * @returns {Promise<Array>} Relevant hadiths
 */
const findRelevantHadiths = async (topic, maxResults = 5) => {
    // Topic to keyword mapping for common Islamic topics
    const topicKeywords = {
        prayer: ["prayer", "salah", "prostration", "worship"],
        charity: ["charity", "zakat", "sadaqah", "give", "poor"],
        fasting: ["fasting", "ramadan", "fast", "suhoor", "iftar"],
        hajj: ["hajj", "pilgrimage", "umrah", "kaaba"],
        patience: ["patience", "steadfast", "trial", "hardship"],
        knowledge: ["knowledge", "learn", "seek", "scholar"],
        manners: ["manners", "character", "kind", "gentle"],
        family: ["parent", "mother", "father", "child", "spouse"],
        honesty: ["honest", "truth", "trust", "lie"],
        death: ["death", "grave", "hereafter", "judgment"],
    };

    const keywords = topicKeywords[topic.toLowerCase()] || [topic];
    const allResults = [];

    for (const keyword of keywords) {
        try {
            const results = await searchHadiths(keyword, null, maxResults);
            allResults.push(...results);
        } catch (error) {
            console.warn(`Failed to search for keyword: ${keyword}`);
        }
    }

    // Remove duplicates
    const uniqueResults = [];
    const seen = new Set();

    for (const result of allResults) {
        const key = `${result.collection}:${result.hadithNumber}`;
        if (!seen.has(key)) {
            seen.add(key);
            uniqueResults.push(result);
        }
    }

    return uniqueResults.slice(0, maxResults);
};

// ============================================
// SPECIAL HADITHS
// ============================================

/**
 * Get 40 Nawawi Hadiths (famous collection)
 * This requires fetching from a specific book if available
 */
const FOR_DAILY_REMINDER_COLLECTIONS = [
    { collection: COLLECTIONS.BUKHARI, hadithNumbers: [1, 6, 7, 8, 9, 10] },
    { collection: COLLECTIONS.MUSLIM, hadithNumbers: [1, 2, 3, 4, 5] },
];

/**
 * Get a hadith suitable for daily reminder
 * @returns {Promise<Object>} Hadith for reminder
 */
const getHadithForReminder = async () => {
    const collections = Object.values(COLLECTIONS);
    const randomCollection = collections[Math.floor(Math.random() * collections.length)];

    try {
        return await getRandomHadith(randomCollection);
    } catch (error) {
        // Fallback to Bukhari if random collection fails
        return await getRandomHadith(COLLECTIONS.BUKHARI);
    }
};

/**
 * Validate if a hadith is authentic (Sahih or Hasan)
 * @param {Object} hadith - Hadith object
 * @returns {boolean} True if authentic
 */
const isAuthenticHadith = (hadith) => {
    if (!hadith || !hadith.grade) return false;

    const authenticGrades = [
        "sahih",
        "hasan",
        "صحيح",
        "حسن",
        "sahih lighairihi",
        "hasan sahih",
    ];

    return authenticGrades.some((grade) =>
        hadith.grade.toLowerCase().includes(grade.toLowerCase())
    );
};

module.exports = {
    // Constants
    COLLECTIONS,
    COLLECTION_NAMES,

    // Collections
    getCollections,

    // Hadith retrieval
    getHadith,
    getRandomHadith,
    getHadiths,

    // Books
    getBooks,
    getHadithsByBook,

    // Search
    searchHadiths,
    findRelevantHadiths,

    // Utilities
    getHadithForReminder,
    isAuthenticHadith,
};
