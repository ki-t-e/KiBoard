<header>
	<div align="right">
		<b><cite>KiBoard</cite></b><br />
		Source and Documentation<br />
		<code>Sources/Keys.md</code>
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

# Writing System Keys for KiBoard

The following `Set` gives all of the key codes recognized by KiBoard.
These are the same as the [“writing system keys”](https://www.w3.org/TR/uievents-code/#writing-system-keys) specified in [<cite>UI Events KeyboardEvent code Values</cite>](https://www.w3.org/TR/uievents-code/), except with `"Space"` instead of `"Backspace"`.
It also includes some numpad keys.

	KEYS = new Set [
		"Backquote"
		"Backslash"
		# Backspace is placed here in the standard, but it is functional, not a writing system key.
		"BracketLeft"
		"BracketRight"
		"Comma"
		"Digit0"
		"Digit1"
		"Digit2"
		"Digit3"
		"Digit4"
		"Digit5"
		"Digit6"
		"Digit7"
		"Digit8"
		"Digit9"
		"Equal"
		"IntlBackslash"
		"IntlRo"
		"IntlYen"
		"KeyA"
		"KeyB"
		"KeyC"
		"KeyD"
		"KeyE"
		"KeyF"
		"KeyG"
		"KeyH"
		"KeyI"
		"KeyJ"
		"KeyK"
		"KeyL"
		"KeyM"
		"KeyN"
		"KeyO"
		"KeyP"
		"KeyQ"
		"KeyR"
		"KeyS"
		"KeyT"
		"KeyU"
		"KeyV"
		"KeyW"
		"KeyX"
		"KeyY"
		"KeyZ"
		"Minus"
		"Period"
		"Quote"
		"Semicolon"
		"Slash"
		"Space" # Space is considered a functional key, but it is recognized.
		"NumpadEqual"
		"NumpadParenLeft"
		"NumpadParenRight"
		"NumpadDivide"
		"NumpadMultiply"
		"NumpadSubtract"
		"Numpad7"
		"Numpad8"
		"Numpad9"
		"NumpadAdd"
		"Numpad4"
		"Numpad5"
		"Numpad6"
		"NumpadComma"
		"Numpad1"
		"Numpad2"
		"Numpad3"
		"NumpadStar"
		"Numpad0"
		"NumpadHash"
		"NumpadDecimal"
	]

`KEYS` are exposed to other modules through the `"keys"` property on the `KIM` object.

	Object.defineProperty KIM, "keys",
		enumerable: yes
		value: => new Set KEYS

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
