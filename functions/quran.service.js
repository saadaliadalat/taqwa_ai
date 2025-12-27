/**
 * Quran Service for Taqwa AI
 * 
 * Integration with AlQuran Cloud API for Quranic verse retrieval
 * and search functionality.
 * 
 * API Documentation: https://alquran.cloud/api
 */

const axios = require("axios");

// Base URL for AlQuran Cloud API (no API key required)
const ALQURAN_API_BASE = "https://api.alquran.cloud/v1";

// Cache for Quran data to reduce API calls
const cache = {
    surahs: null,
    lastFetch: null,
};

const CACHE_DURATION = 3600000; // 1 hour in milliseconds

// ============================================
// SURAH INFORMATION
// ============================================

/**
 * Get list of all Surahs
 * @returns {Promise<Array>} List of Surah information
 */
const getAllSurahs = async () => {
    // Check cache
    if (cache.surahs && cache.lastFetch && (Date.now() - cache.lastFetch < CACHE_DURATION)) {
        return cache.surahs;
    }

    try {
        const response = await axios.get(`${ALQURAN_API_BASE}/surah`);

        if (response.data.code === 200) {
            cache.surahs = response.data.data;
            cache.lastFetch = Date.now();
            return cache.surahs;
        }

        throw new Error("Failed to fetch Surah list");
    } catch (error) {
        console.error("Error fetching Surah list:", error.message);
        throw error;
    }
};

/**
 * Get Surah information by number
 * @param {number} surahNumber - Surah number (1-114)
 * @returns {Promise<Object>} Surah information
 */
const getSurahInfo = async (surahNumber) => {
    if (surahNumber < 1 || surahNumber > 114) {
        throw new Error("Invalid Surah number. Must be between 1 and 114.");
    }

    try {
        const response = await axios.get(`${ALQURAN_API_BASE}/surah/${surahNumber}`);

        if (response.data.code === 200) {
            return response.data.data;
        }

        throw new Error(`Failed to fetch Surah ${surahNumber}`);
    } catch (error) {
        console.error(`Error fetching Surah ${surahNumber}:`, error.message);
        throw error;
    }
};

// ============================================
// AYAH RETRIEVAL
// ============================================

/**
 * Get a specific Ayah (verse)
 * @param {number} surahNumber - Surah number (1-114)
 * @param {number} ayahNumber - Ayah number
 * @param {string} edition - Translation edition (default: English)
 * @returns {Promise<Object>} Ayah data
 */
const getAyah = async (surahNumber, ayahNumber, edition = "en.asad") => {
    try {
        const response = await axios.get(
            `${ALQURAN_API_BASE}/ayah/${surahNumber}:${ayahNumber}/editions/ar.alafasy,${edition}`
        );

        if (response.data.code === 200) {
            const [arabic, translation] = response.data.data;

            return {
                surah: surahNumber,
                ayah: ayahNumber,
                surahName: arabic.surah.englishName,
                surahNameArabic: arabic.surah.name,
                textArabic: arabic.text,
                textTranslation: translation.text,
                edition: translation.edition.name,
                juz: arabic.juz,
                page: arabic.page,
                hizbQuarter: arabic.hizbQuarter,
            };
        }

        throw new Error(`Failed to fetch Ayah ${surahNumber}:${ayahNumber}`);
    } catch (error) {
        console.error(`Error fetching Ayah ${surahNumber}:${ayahNumber}:`, error.message);
        throw error;
    }
};

/**
 * Get multiple Ayahs from a Surah
 * @param {number} surahNumber - Surah number
 * @param {number} startAyah - Starting Ayah number
 * @param {number} endAyah - Ending Ayah number
 * @param {string} edition - Translation edition
 * @returns {Promise<Array>} List of Ayahs
 */
const getAyahRange = async (surahNumber, startAyah, endAyah, edition = "en.asad") => {
    const ayahs = [];

    for (let i = startAyah; i <= endAyah; i++) {
        try {
            const ayah = await getAyah(surahNumber, i, edition);
            ayahs.push(ayah);
        } catch (error) {
            console.warn(`Could not fetch Ayah ${surahNumber}:${i}`);
        }
    }

    return ayahs;
};

/**
 * Get a complete Surah with translation
 * @param {number} surahNumber - Surah number
 * @param {string} edition - Translation edition
 * @returns {Promise<Object>} Complete Surah with Ayahs
 */
const getFullSurah = async (surahNumber, edition = "en.asad") => {
    try {
        const response = await axios.get(
            `${ALQURAN_API_BASE}/surah/${surahNumber}/editions/ar.alafasy,${edition}`
        );

        if (response.data.code === 200) {
            const [arabic, translation] = response.data.data;

            return {
                number: arabic.number,
                name: arabic.name,
                englishName: arabic.englishName,
                englishNameTranslation: arabic.englishNameTranslation,
                revelationType: arabic.revelationType,
                numberOfAyahs: arabic.numberOfAyahs,
                ayahs: arabic.ayahs.map((arabicAyah, index) => ({
                    number: arabicAyah.numberInSurah,
                    textArabic: arabicAyah.text,
                    textTranslation: translation.ayahs[index].text,
                    juz: arabicAyah.juz,
                    page: arabicAyah.page,
                })),
            };
        }

        throw new Error(`Failed to fetch Surah ${surahNumber}`);
    } catch (error) {
        console.error(`Error fetching full Surah ${surahNumber}:`, error.message);
        throw error;
    }
};

// ============================================
// SEARCH FUNCTIONALITY
// ============================================

/**
 * Search in Quran for a keyword
 * @param {string} keyword - Search keyword
 * @param {string} edition - Edition to search in (default: English)
 * @returns {Promise<Object>} Search results
 */
const searchQuran = async (keyword, edition = "en.asad") => {
    if (!keyword || keyword.trim().length < 2) {
        throw new Error("Search keyword must be at least 2 characters.");
    }

    try {
        const response = await axios.get(
            `${ALQURAN_API_BASE}/search/${encodeURIComponent(keyword)}/${edition}`
        );

        if (response.data.code === 200) {
            const results = response.data.data;

            return {
                count: results.count,
                matches: results.matches.map((match) => ({
                    surah: match.surah.number,
                    surahName: match.surah.englishName,
                    ayah: match.numberInSurah,
                    text: match.text,
                    edition: results.edition.name,
                })),
            };
        }

        return { count: 0, matches: [] };
    } catch (error) {
        if (error.response && error.response.status === 404) {
            return { count: 0, matches: [] };
        }
        console.error(`Error searching Quran for "${keyword}":`, error.message);
        throw error;
    }
};

/**
 * Find relevant Quran verses for a topic
 * @param {string} topic - Topic to search for
 * @param {number} maxResults - Maximum number of results
 * @returns {Promise<Array>} Relevant Ayahs
 */
const findRelevantVerses = async (topic, maxResults = 5) => {
    // Common Islamic topic keywords mapping
    const topicKeywords = {
        prayer: ["salat", "prayer", "worship", "prostrate"],
        charity: ["zakat", "charity", "give", "poor", "needy"],
        fasting: ["fasting", "ramadan", "fast", "abstain"],
        hajj: ["hajj", "pilgrimage", "kaaba", "mecca"],
        patience: ["patience", "steadfast", "persevere", "patient"],
        forgiveness: ["forgiveness", "forgive", "mercy", "repent"],
        gratitude: ["grateful", "thankful", "praise", "blessings"],
        family: ["parents", "children", "family", "spouse", "marriage"],
        knowledge: ["knowledge", "learn", "wisdom", "understand"],
        death: ["death", "hereafter", "resurrection", "judgment"],
    };

    // Determine keywords to search
    const searchTerms = topicKeywords[topic.toLowerCase()] || [topic];
    const allMatches = [];

    for (const term of searchTerms) {
        try {
            const results = await searchQuran(term);
            if (results.matches) {
                allMatches.push(...results.matches);
            }
        } catch (error) {
            console.warn(`Search failed for term "${term}"`);
        }
    }

    // Remove duplicates by Surah:Ayah
    const uniqueMatches = [];
    const seen = new Set();

    for (const match of allMatches) {
        const key = `${match.surah}:${match.ayah}`;
        if (!seen.has(key)) {
            seen.add(key);
            uniqueMatches.push(match);
        }
    }

    return uniqueMatches.slice(0, maxResults);
};

// ============================================
// RANDOM VERSE
// ============================================

/**
 * Get a random verse from the Quran
 * @param {string} edition - Translation edition
 * @returns {Promise<Object>} Random Ayah
 */
const getRandomVerse = async (edition = "en.asad") => {
    // Total Ayahs in the Quran: 6236
    const randomAyahNumber = Math.floor(Math.random() * 6236) + 1;

    try {
        const response = await axios.get(
            `${ALQURAN_API_BASE}/ayah/${randomAyahNumber}/editions/ar.alafasy,${edition}`
        );

        if (response.data.code === 200) {
            const [arabic, translation] = response.data.data;

            return {
                surah: arabic.surah.number,
                surahName: arabic.surah.englishName,
                surahNameArabic: arabic.surah.name,
                ayah: arabic.numberInSurah,
                totalAyahNumber: arabic.number,
                textArabic: arabic.text,
                textTranslation: translation.text,
                edition: translation.edition.name,
                juz: arabic.juz,
            };
        }

        throw new Error("Failed to fetch random verse");
    } catch (error) {
        console.error("Error fetching random verse:", error.message);
        throw error;
    }
};

/**
 * Get Ayat al-Kursi (Verse of the Throne)
 * @param {string} edition - Translation edition
 * @returns {Promise<Object>} Ayat al-Kursi
 */
const getAyatAlKursi = async (edition = "en.asad") => {
    return getAyah(2, 255, edition);
};

/**
 * Get the last two verses of Surah Al-Baqarah
 * @param {string} edition - Translation edition
 * @returns {Promise<Array>} Last two Ayahs
 */
const getLastTwoAyahsAlBaqarah = async (edition = "en.asad") => {
    return getAyahRange(2, 285, 286, edition);
};

// ============================================
// AVAILABLE EDITIONS
// ============================================

/**
 * Get list of available translation editions
 * @returns {Promise<Array>} Available editions
 */
const getAvailableEditions = async () => {
    try {
        const response = await axios.get(`${ALQURAN_API_BASE}/edition?format=text&type=translation`);

        if (response.data.code === 200) {
            return response.data.data.map((edition) => ({
                identifier: edition.identifier,
                language: edition.language,
                name: edition.name,
                englishName: edition.englishName,
            }));
        }

        throw new Error("Failed to fetch editions");
    } catch (error) {
        console.error("Error fetching editions:", error.message);
        throw error;
    }
};

module.exports = {
    // Surah operations
    getAllSurahs,
    getSurahInfo,
    getFullSurah,

    // Ayah operations
    getAyah,
    getAyahRange,

    // Search
    searchQuran,
    findRelevantVerses,

    // Special verses
    getRandomVerse,
    getAyatAlKursi,
    getLastTwoAyahsAlBaqarah,

    // Editions
    getAvailableEditions,
};
