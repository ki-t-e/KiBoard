<header>
	<div align="right">
		<b><cite>KiBoard</cite></b><br />
		Source and Documentation<br />
		<code>Sources/Controls.md</code>
	</div>
	<hr />
	<div align="justify">
		<small>
			Copyright © 2019 Kyebego.
			Code released under GNU GPLv3 (or any later version); documentation released under CC BY-SA 4.0.
			For more information, see the license notice at the bottom of this document.
		</small>
	</div>
</header>

# KiBoard Control Values

This file defines the hard-coded control codes which may be output by `KiBoard` regardless of layout.

## QWERTY mappings

The `qwertyValues` object provides unshifted and shifted key values for each supported KiBoard code, plus escape.
These follow the US QWERTY layout and are used when these keys are pressed alongside Control.

	qwertyValues =
		Backquote: "`~"
		Digit1: "1!"
		Digit2: "2@"
		Digit3: "3#"
		Digit4: "4$"
		Digit5: "5%"
		Digit6: "6^"
		Digit7: "7&"
		Digit8: "8*"
		Digit9: "9("
		Digit0: "0)"
		Minus: "-_"
		Equal: "=+"
		IntlYen: "\\|"
		KeyQ: "qQ"
		KeyW: "wW"
		KeyE: "eE"
		KeyR: "rR"
		KeyT: "tT"
		KeyY: "yY"
		KeyU: "uU"
		KeyI: "iI"
		KeyO: "oO"
		KeyP: "pP"
		BracketLeft: "[{"
		BracketRight: "]}"
		Backslash: "\\|"
		KeyA: "aA"
		KeyS: "sS"
		KeyD: "dD"
		KeyF: "fF"
		KeyG: "gG"
		KeyH: "hH"
		KeyJ: "jJ"
		KeyK: "kK"
		KeyL: "lL"
		Semicolon: ";:"
		Quote: "'\""
		IntlBackslash: "\\|"
		KeyZ: "zZ"
		KeyX: "xX"
		KeyC: "cC"
		KeyV: "vV"
		KeyB: "bB"
		KeyN: "nN"
		KeyM: "mM"
		Comma: ",<"
		Period: ".>"
		Slash: "/?"
		IntlRo: "/?"
		Space: " "
		NumpadEqual: "="
		NumpadParenLeft: "("
		NumpadParenRight: ")"
		NumpadDivide: "/"
		NumpadMultiply: "*"
		NumpadSubtract: "-"
		Numpad7: "7"
		Numpad8: "8"
		Numpad9: "9"
		NumpadAdd: "+"
		Numpad4: "4"
		Numpad5: "5"
		Numpad6: "6"
		NumpadComma: ","
		Numpad1: "1"
		Numpad2: "2"
		Numpad3: "3"
		NumpadStar: "*"
		Numpad0: "0"
		NumpadHash: "#"
		NumpadDecimal: "."
		Escape: "\x7F" # NOTHING; Control + Escape is the same as Escape on its own, but Control + Alt + Escape provides the Application variant.

## Control mappings

The `controlValues` object provides unshifted and shifted hardcoded control codes for the various functional keys supported by `KiBoard`.
The values used are standardized [Kixt Controls](https://spec.kibi.network/Kixt/-/Controls/).

	controlValues =
		Backspace: "\u80DF" # OOPS
		Tab: "\t\u80D9" # NEXT / PREVIOUS
		Enter: "\u80D1\u80D0" # LINE SEPARATOR / PARAGRAPH SEPARATOR
		Help: [ "\x05\x7F" ] # ENQUIRY, NOTHING
		Home: "\r" # LINE START
		PageUp: "\u80DC" # PAGE PREVIOUS
		Delete: "\u80DE" # IGNORE
		End: "\u80DD" # LINE END
		PageDown: "\f" # PAGE NEXT
		ArrowUp: "\u80DA" # RETRACT
		ArrowLeft: "\b" # BACK
		ArrowDown: "\n" # ADVANCE
		ArrowRight: "\u80D8" # FORWARD
		NumpadEnter: "\v\u80DB" # LINE NEXT / LINE PREVIOUS
		Escape: [ "\x1B\x7F" ] # COMMAND, NOTHING
		F1: [ "\x05\x7F" ] # ENQUIRY, NOTHING
		F2: [ "\x06\x7F" ] # CONFIRM, NOTHING
		F3: [ "\x07\x7F" ] # ALERT, NOTHING
		F4: [ "\x15\x7F" ] # ERROR, NOTHING
		F5: "\x11" # BOOT
		F6: "\x12" # RESUME
		F7: "\x13" # WAIT
		F8: "\x14" # HALT
		F9: [ "\u80CA\x7F" ] # APPLICATION COMMAND, NOTHING
		F10: [ "\u80CB\x7F" ] # USER COMMAND, NOTHING
		F11: [ "\u80CC\x7F" ] # OPERATING SYSTEM COMMAND, NOTHING
		F12: [ "\u80CD\x7F" ] # DEVICE COMMAND, NOTHING
		Pause: "\u80D7\x11" # BREAK / BOOT
		Suspend: "\x13" # WAIT
		Resume: "\x12" # RESUME
		Abort: "\x14" # HALT

## Getting the key value

Control together with a recognized key send an escape sequence consisting of either `1B` or `80CA` (if Alt is also pressed) followed by a single value.
Otherwise the hardcoded value is determined by the key pressed.

	getHardcodedKeyValue = ( code, { Alt, Control, Shift } ) => if Control and qwertyValues.hasOwnProperty code then (if Alt then "\u80CA" else "\x1B") + (Shift and qwertyValues[code][1] or qwertyValues[code][0]) else if controlValues.hasOwnProperty code then Shift and controlValues[code][1] or controlValues[code][0]

<footer>
	<details>
		<summary>License notice</summary>
		<p>
			This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
			Similarly, you can redistribute and/or modify the documentation sections of this document under the terms of the Creative Commons Attribution-ShareAlike 4.0 International License.
		</p>
		<p>
			This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
			See the GNU General Public License for more details.
		</p>
		<p>
			You should have received copies of the GNU General Public License and the Creative Commons Attribution-ShareAlike 4.0 International License along with this source.
			If not, see https://www.gnu.org/licenses/ and https://creativecommons.org/licenses/by-sa/4.0/.
		</p>
	</details>
</footer>