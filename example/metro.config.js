const path = require('path');
const { getDefaultConfig } = require('@react-native/metro-config');

const root = path.resolve(__dirname, '..');

/**
 * Metro configuration
 * https://facebook.github.io/metro/docs/configuration
 *
 * Export a Promise because `react-native-monorepo-config` is ESM-only and must be loaded via dynamic import()
 * in a CommonJS metro.config.
 */
async function getConfig() {
  const { withMetroConfig } = await import('react-native-monorepo-config');
  return withMetroConfig(getDefaultConfig(__dirname), {
    root,
    dirname: __dirname,
  });
}

module.exports = getConfig();
