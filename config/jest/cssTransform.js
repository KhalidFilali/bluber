module.exports = {
  process() {
    return 'module.exports = {};';
  },
  getCacheKey(fileData, filename) {
    return 'cssTransform';
  },
};
