var ecoo = require('./eco/eco');
var fusion = require('./../../lib/fusion');
exports.createTemplateObject = function(content, source, directoryPrefix) {
  return ecoo.compile(content, { identifier: fusion.templateNamespace(source, directoryPrefix)});
};
