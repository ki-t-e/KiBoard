{ build, clear, configure, watch } = require 'Roost'

# See <https://go.KIBI.family/Roost/> for the meaning of this configuration.
configure
	destination: "Build/"
	literate: yes
	minify: no
	name: "KiBoard"
	order: [
		"README"
		"KIM"
		"Controls"
		"Keys"
		"InputMethodsMap"
		"Messaging"
	]
	preamble: "Sources/README.js"
	prefix: "Sources/"
	suffix: ".md"

task "build", "build KiBoard", build
task "watch", "build KiBoard and watch for changes", watch
task "clear", "remove built files", clear
