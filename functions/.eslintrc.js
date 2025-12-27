module.exports = {
    root: true,
    env: {
        es6: true,
        node: true,
    },
    extends: [
        "eslint:recommended",
        "google",
    ],
    parserOptions: {
        ecmaVersion: 2020,
    },
    rules: {
        "quotes": ["error", "double"],
        "max-len": ["error", { "code": 120 }],
        "indent": ["error", 2],
        "object-curly-spacing": ["error", "always"],
        "require-jsdoc": "off",
        "valid-jsdoc": "off",
        "comma-dangle": ["error", "always-multiline"],
        "no-unused-vars": ["warn", { "argsIgnorePattern": "^_" }],
    },
};
