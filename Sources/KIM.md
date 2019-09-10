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
