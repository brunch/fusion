(function() {
  exports.printLine = function(line) {
    return process.stdout.write(line + '\n');
  };
}).call(this);
