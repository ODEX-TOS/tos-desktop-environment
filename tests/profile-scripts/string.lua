local filehandle = require("tde.lib-tde.file")

print(filehandle.string("/proc/cpuinfo"))
filehandle.lines("/proc/cpuinfo")
