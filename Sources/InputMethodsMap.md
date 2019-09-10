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
