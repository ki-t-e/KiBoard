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
