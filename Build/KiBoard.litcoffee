<header>
	<div align="right">
		<b><cite>KiBoard</cite></b><br />
		Source and Documentation<br />
		<code>Sources/README.md</code>
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

# KiBoard

## Symbols for internal use

The following symbols are used for object properties which are not intended for public use.
While it is possible to access them from external scripts (e.g., with `Object.getOwnPropertyDescriptors`), doing so is not advised unless you *really* know what youʼre doing.

`internalAdd` and `internalRemove` can be used to add and remove input methods from the internal input methods map, which is otherwise not exposed outside of the constructor scope.

	internalAdd = Symbol "Add to internal input methods map"
	internalRemove = Symbol "Remove from internal input methods map"

`internalQuery` is used to query the current input method, whose object is not available outside of the constructor scope, by keycode.

	internalQuery = Symbol "Query current charset"

`internalModifiers` provides a sealed object whose own properties give the current modifier states of the keyboard.
In contrast to the preferred `"modifiers"` property, writes to the properties of this object are propagated back to the `KiBoard` itself.

	internalModifiers = Symbol "Internal modifiers object"

## Class definition

If you have a list of KIM objects, you can provide them to the `KiBoard` on creation:

```js
kiBoard = new KiBoard(InputMethod1, InputMethod2);
```

Otherwise, you will be able to add them later with `KiBoard.prototype.addLayout`:

```js
kiBoard.addLayout(InputMethod3);
```

	export default class KiBoard

### Constructor

		constructor: ( inputMethods... ) ->

#### Setup

The first order of business is generating the map of input methods for the `KiBoard`.
See [InputMethodsMap](./InputMethodsMap.md) for more on the `InputMethodsMap` constructor.

			inputMethodsMap = new InputMethodsMap inputMethods...

The first provided input method in the resulting map is used as the current input method.
This will be the same as the first provided input method, unless it was overwritten.

			currentInputMethod = inputMethodsMap.first

`mode` and `state` are both initialized to the empty string (the default).

			mode = state = ""

The `id` for the `KiBoard` is initialized to the empty string, and `messanger` is initialized to be null.
These can be changed via properties after object creation.

			id = ""
			messager = null

`AltGraph`, `CapsLock`, and `Shift` reflect the corresponding modifier states.
They are exposed (read-write) via `internalModifiers` or (read-only) via `"modifiers"`.

			AltGraph = off
			CapsLock = off
			Shift = off

#### Properties

			Object.defineProperties @,

The symbol properties which map to functions are simple `Function.prototype.bind`s on functions declared elsewhere.
The `internalModifiers` property is an immutable sealed object whose own properties provide modifier read/write access.

				[ internalAdd ]: value: InputMethodsMap::add.bind inputMethodsMap
				[ internalRemove]: value: InputMethodsMap::remove.bind inputMethodsMap
				[ internalQuery ]: get: => KIM.query.bind KIM, @, currentInputMethod
				[ internalModifiers ]: value: Object.seal Object.defineProperties { },
					AltGraph:
						enumerable: yes
						get: => AltGraph
						set: ( n ) => AltGraph = !!n
					CapsLock:
						enumerable: yes
						get: => CapsLock
						set: ( n ) => CapsLock = !!n
					Shift:
						enumerable: yes
						get: => Shift
						set: ( n ) => Shift = !!n

`"id"` gets and sets the `id`, and `"messager"` gets and sets the `messager`.
The former is coerced into a string, and the latter is `null` unless the provided argument is a function.

				id:
					get: => id or null
					set: ( n ) => id = "#{ n ? "" }"
				messager:
					get: => messager
					set: ( n ) =>
						if typeof n is "function"
							messager = n
							sendMessage.call @
						else messager = null
						return

`"layout"` gets the name of the currently selected input method, or returns `undefined` if none is selected.
It can be set in order to select a new input method by name; this only has an effect if there is a matching input method in the `KiBoard`'s internal input method map.
The list of names for all available input methods is available as an `Array` on the `"layouts"` property.

When the current input method is changed by setting this property, a message is sent via `messager`.

				layout:
					enumerable: yes
					get: => "#{ currentInputMethod?.name ? "" }" or null
					set: ( n ) =>
						return unless (name = "#{ n ? "" }") and inputMethodsMap.has name
						currentInputMethod = inputMethodsMap.get name
						mode = state = ""
						sendMessage.call @
						return
				layouts:
					enumerable: yes
					get: => do inputMethodsMap.list

Similarly, `"charset"` is the charset of the current input method, if the current input method exists and has a charset defined.
Setting this property attempts to change the current input method to one of the provided charset; this does nothing if the provided charset matches the current one.

When the current input method is changed by setting this property, a message is sent via `messager`.

				charset:
					enumerable: yes
					get: => "#{ currentInputMethod?.charset ? "" }" or null
					set: ( n ) =>
						return if @charset is iri = "#{ n }"
						newInputMethod = (inputMethodsMap.filterByCharset iri).first
						return unless newInputMethod
						currentInputMethod = newInputMethod
						mode = state = ""
						sendMessage.call @
						return
				charsets:
					enumerable: yes
					get: => do inputMethodsMap.charsets

`"modifiers"` gets the current state of keyboard modifiers as a fresh, plain object.
`"mode"` and `"state"` similarly return their values.

				modifiers:
					enumerable: yes
					get: => { AltGraph, CapsLock, Shift }
				mode:
					enumerable: yes
					get: => mode or null
					set: ( n ) => mode = "#{ n ? "" }"
				state:
					enumerable: yes
					get: => state or null
					set: ( n ) => state = "#{ n ? "" }"

If the `KiBoard` has a state and that state has a nonempty terminator, `"terminator"` returns its value.
This is interpreted as a character code if it is a number, otherwise as a string.

				terminator:
					enumerable: yes
					get: => (if typeof (terminator = currentInputMethod?.terminators?[state]) is "number" then String.fromCharCode (terminator >>> 0) else "#{ terminator ? "" }" or null) if state

### Methods

`KiBoard.prototype.addLayout` and `KiBoard.prototype.removeLayout` can be used to add (by KIM object) or remove (by name) a given input method from a `KiBoard`.
If the current input method is removed, a new one is selected, preferring one from the same charset if possible.

		addLayout: ( inputMethod ) ->
			{ layout } = @
			@layout = layout if layout is @[internalAdd] inputMethod
		removeLayout: ( name ) ->
			{ layout, charset } = @
			if layout is removed = @[internalRemove] name
				@charset = charset if charset
				@layout = layouts[0] if @layout is removed

`KiBoard.prototype.attach` and `KiBoard.prototype.remove` are convenience functions for setting up and removing the appropriate event listeners required for a `KiBoard` instance to start handling keyboard events.

		attach: ( target ) ->
			target.addEventListener "keydown", @
			target.addEventListener "keyup", @
		remove: ( target ) ->
			target.removeEventListener "keydown", @
			target.removeEventListener "keyup", @

`KiBoard.prototype.query` queries the provided keycode by passing it along to the `internalQuery` of the `KiBoard` instance.

		query: ( code ) -> if KEYS.has code then @[internalQuery] code else getHardcodedKeyValue code, { Shift: @modifiers.Shift }

### Event handling

		handleEvent: ( event ) ->
			switch event.type

#### Key presses

				when "keydown"

On every key press, the first task is to update the `internalModifiers` to match those of the provided `event`.

					@[ internalModifiers ][m] = event.getModifierState m for m in [ "AltGraph", "CapsLock", "Shift" ]

`KiBoard` leaves the handling of meta keypresses up to the OS.
Otherwise, it prevents default behaviour.

					return if event.getModifierState "Meta"
					do event.preventDefault

The current state (prior to the keypress) is stored such that it can be reported with the key value.

					previousState = @state

If the control key is pressed, or this is not a KIM-supported key, then its result is a hardcoded value.
See [Controls](./Controls.md) for a list of these.
Otherwise, an `internalQuery` attempts to get the resulting value of the keypress.

					return unless code = "#{ event.code ? "" }"
					result = if (Control = event.getModifierState "Control") or not KEYS.has code then getHardcodedKeyValue code, {
						Alt: event.getModifierState "Alt"
						Control
						Shift: @modifiers.Shift
					} else @[ internalQuery ] code

The impact of the result depends on its type.

					switch

An object which changes the mode or state has no further impact.

						when typeof result is "object" and (result.mode? or result.state?)
							@mode = result.mode if result.mode?
							@state = result.state if result.state?
							sendMessage.call @, if previousState and @state isnt previousState then { code, previousState } else { code }

A number is interpreted as a character code.
This resets the state.

						when typeof result is "number"
							@state = ""
							key = String.fromCharCode (result >>> 0)
							sendMessage.call @, if previousState then { code, key, previousState } else { code, key }

Any other result is interpreted as a string.
This resets the state.

						when result?
							@state = ""
							key = "#{ result }"
							sendMessage.call @, if previousState then (if key then { code, key, previousState } else { code, previousState }) else if key then { code, key } else { code }

Otherwise, no result was found.
If this was a KIM-supported code and the `KiBoard` was in a state, it is exited and the entire process is attempted again.
If a terminator is present for the state, it is sent (with no associated code).

						when previousState and KEYS.has code
							@state = ""
							sendMessage.call @, if (key = @terminator) then { key, previousState } else { previousState }
							@handleEvent event

#### Key releases

`KiBoard` generally only recognizes key presses, not releases.
However, it does update its modifier state on key release.

				when "keyup" then @[ internalModifiers ][m] = event.getModifierState m for m in [ "AltGraph", "CapsLock", "Shift" ]

#### Messages

Message handling is not (yet!) supported on `KiBoard` instances.

				when "message"
					break unless data?.target is "https://kite.KIBI.network/KiBoard" and (data.id ? "") is @id

			return

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

_______________________________________________________________________

<header>
	<div align="right">
		<b><cite>KiBoard</cite></b><br />
		Source and Documentation<br />
		<code>Sources/KIM.md</code>
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

# KiBoard Input Methods

The exported `KIM` object provides utility properties and functions for use with `KiBoard` input methods.

	export KIM = Object.defineProperties { },

## Querying

The `KIM.query` function queries a given `inputMethod` using the state of the provided `board` for the value corresponding to the given `code`.
It finds the first `keyMap` whose `mode` and specified `modifiers` match those given by the `board`, and which contains an entry for the given `code`, and gets the value of that entry.
If the value is an object with a `action` property, it instead takes looks at the value of the corresponding key in the `inputMethod`'s `actions`, and takes the value from that object which corresponds to the board's current `state`.
If the value is an object with a `state` property, the `terminator` associated with the `state` is added to the object before returning.

		query:
			enumerable: yes
			value: ( { modifiers, mode, state }, inputMethod, code ) =>
				return unless inputMethod?.keyMaps?.length
				result = undefined
				for keyMap in [ ].concat inputMethod.keyMaps
					continue unless "#{ keyMap.mode ? "" }" or null is mode
					if keyMap.modifiers?
						continue unless ([ ].concat keyMap.modifiers).some ( conditions )->
							for modifier, value of modifiers when conditions[modifier]?
								return no if !!conditions[modifier] isnt value
							return yes
					continue unless (result = keyMap[code])?
					if typeof result is "object" and result.action?
						if inputMethod.actions?[result.action]?
							result = keyMap.actions[result.action][state] ? keyMap.actions[result.action][""]
						else continue
					break
				return unless result?
				if typeof result is "object"
					if plannedState = "#{ result.state ? "" }"
						{ ...result, terminator } = result
						result.terminator = terminator if terminator = "#{ inputMethod.terminators?[plannedState] ? "" }"
						return result
					return { result... } # shallow-clone the result
				return result

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

_______________________________________________________________________

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
_______________________________________________________________________

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

_______________________________________________________________________

<header>
	<div align="right">
		<b><cite>KiBoard</cite></b><br />
		Source and Documentation<br />
		<code>Sources/README.md</code>
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

# KiBoard Input Methods Maps

The internal `InputMethodsMap` is an extension to `Map` which makes it easier to handle maps of KIM objects.

## Class definition

	class InputMethodsMap extends Map

### Constructor

In contrast to the ordinary `Map` constructor, `InputMethodsMap` takes a splat of input methods, just like `KiBoard`.

		constructor: ( inputMethods... ) ->
			do super

#### Setup

Each provided input method is added to the map by its name, provided the name is nonempty.
If an input method with the given name already exists in the map, it is first deleted.

			inputMethods.forEach ( inputMethod ) =>
				if name = "#{ inputMethod?.name ? "" }"
					Map::delete.call @, name
					Map::set.call @, name, inputMethod

#### Properties

The `first` property is added as a convenient getter for the first value in the map.

			Object.defineProperty @, "first",
				enumerable: yes
				get: =>
					return unless @size
					(do (Map::values.call @).next).value

### Methods

The `InputMethodsMap.prototype.add` function adds a new input method to the map by name, deleting any previous one first.
It returns the name of the added input method, or false if the input method had no name (and was thus not added).

		add: ( inputMethod ) ->
			return no unless name = "#{ inputMethod?.name ? "" }"
			Map::delete.call @, name
			Map::set.call @, name, inputMethod
			return name

The `InputMethodsMap.prototype.remove` function removes an input method by name.
It returns the provided name, unless no input method by that name existed in the map, in which case it returns `false`.

		remove: ( name ) ->
			return no unless name = "#{ name ? "" }"
			return no unless Map::has.call @, name
			Map::delete.call @, name
			return name

The `InputMethodsMap.prototype.filterByCharset` function returns a new `InputMethodMap` containing only those input methods whose charset matches the provided argument.

		filterByCharset: ( charset ) -> Object.setPrototypeOf (
			new Map (
				Array.from @
					.filter ( [ ..., inputMethod ] ) => "#{ inputMethod.charset ? "" }" is "#{ charset ? "" }"
			)
		), InputMethodsMap::

`InputMethodsMap.prototype.list` creates a new array which lists the names in the map.

		list: -> Array.from Map::keys.call @

`InputMethodsMap.prototype.charsets` creates a new array which lists the charsets in the map.

		charsets: -> Array.from new Set (
			Array.from Map::values.call @
				.map ( [ ..., { charset } ] ) => "#{ charset }"
		)

### Class properties

`Symbol.species` on `InputMethodsMap` is just `Map`.
The `"delete"` and `"set"` properties on `InputMethodsMap.prototype` are set to `undefined`, to prevent the equivalent `Map` functions from being reached through the prototype chain.
`"remove"` and `"add"` should be used on `InputMethodsMap` instead.

		Object.defineProperty @, Symbol.species, value: Map
		Object.defineProperties @::,
			delete: value: undefined
			set: value: undefined

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

_______________________________________________________________________

<header>
	<div align="right">
		<b><cite>KiBoard</cite></b><br />
		Source and Documentation<br />
		<code>Sources/Messaging.md</code>
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

# KiBoard Messaging

The internal `message` function is used to simplify the code pertaining to dispatching messages from `KiBoard` instances to their associated messagers.
`message` must be called with a `KiBoard` instance as its `this` value.

	sendMessage = ( data = { } ) ->
		throw new TypeError "KiBoard messages can only be sent from a KiBoard instance." unless @ instanceof KiBoard
		header = sender: "https://kite.KIBI.network/KiBoard/"
		header[key] = value for key in [
			"id"
			"layout"
			"charset"
			"mode"
			"modifiers"
			"state"
		] when value = @[key] # Only nonempty values are sent
		@messager? { ...header, ...data }

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
