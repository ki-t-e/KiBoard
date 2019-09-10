/*
# KiBoard
Kixt Keyboards

___

Copyright (C) 2019 Kyebego

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

The GNU General Public License is available online at
<https://www.gnu.org/licenses/>.

___

##  Usage:

To come.
*/
var InputMethodsMap,
    KEYS,
    KiBoard,
    controlValues,
    getHardcodedKeyValue,
    internalAdd,
    internalModifiers,
    internalQuery,
    internalRemove,
    qwertyValues,
    sendMessage,
    slice = [].slice;
internalAdd = Symbol("Add to internal input methods map");
internalRemove = Symbol("Remove from internal input methods map");
internalQuery = Symbol("Query current charset");
internalModifiers = Symbol("Internal modifiers object");
export default KiBoard = class KiBoard {
  constructor(...inputMethods) {
    var AltGraph, CapsLock, Shift, currentInputMethod, id, inputMethodsMap, messager, mode, state;
    inputMethodsMap = new InputMethodsMap(...inputMethods);
    currentInputMethod = inputMethodsMap.first;
    mode = state = "";
    id = "";
    messager = null;
    AltGraph = false;
    CapsLock = false;
    Shift = false;
    Object.defineProperties(this, {
      [internalAdd]: {
        value: InputMethodsMap.prototype.add.bind(inputMethodsMap)
      },
      [internalRemove]: {
        value: InputMethodsMap.prototype.remove.bind(inputMethodsMap)
      },
      [internalQuery]: {
        get: () => {
          return KIM.query.bind(KIM, this, currentInputMethod);
        }
      },
      [internalModifiers]: {
        value: Object.seal(Object.defineProperties({}, {
          AltGraph: {
            enumerable: true,
            get: () => {
              return AltGraph;
            },
            set: n => {
              return AltGraph = !!n;
            }
          },
          CapsLock: {
            enumerable: true,
            get: () => {
              return CapsLock;
            },
            set: n => {
              return CapsLock = !!n;
            }
          },
          Shift: {
            enumerable: true,
            get: () => {
              return Shift;
            },
            set: n => {
              return Shift = !!n;
            }
          }
        }))
      },
      id: {
        get: () => {
          return id || null;
        },
        set: n => {
          return id = `${n != null ? n : ""}`;
        }
      },
      messager: {
        get: () => {
          return messager;
        },
        set: n => {
          if (typeof n === "function") {
            messager = n;
            sendMessage.call(this);
          } else {
            messager = null;
          }
        }
      },
      layout: {
        enumerable: true,
        get: () => {
          var ref;
          return `${(ref = currentInputMethod != null ? currentInputMethod.name : void 0) != null ? ref : ""}` || null;
        },
        set: n => {
          var name;

          if (!((name = `${n != null ? n : ""}`) && inputMethodsMap.has(name))) {
            return;
          }

          currentInputMethod = inputMethodsMap.get(name);
          mode = state = "";
          sendMessage.call(this);
        }
      },
      layouts: {
        enumerable: true,
        get: () => {
          return inputMethodsMap.list();
        }
      },
      charset: {
        enumerable: true,
        get: () => {
          var ref;
          return `${(ref = currentInputMethod != null ? currentInputMethod.charset : void 0) != null ? ref : ""}` || null;
        },
        set: n => {
          var iri, newInputMethod;

          if (this.charset === (iri = `${n}`)) {
            return;
          }

          newInputMethod = inputMethodsMap.filterByCharset(iri).first;

          if (!newInputMethod) {
            return;
          }

          currentInputMethod = newInputMethod;
          mode = state = "";
          sendMessage.call(this);
        }
      },
      charsets: {
        enumerable: true,
        get: () => {
          return inputMethodsMap.charsets();
        }
      },
      modifiers: {
        enumerable: true,
        get: () => {
          return {
            AltGraph,
            CapsLock,
            Shift
          };
        }
      },
      mode: {
        enumerable: true,
        get: () => {
          return mode || null;
        },
        set: n => {
          return mode = `${n != null ? n : ""}`;
        }
      },
      state: {
        enumerable: true,
        get: () => {
          return state || null;
        },
        set: n => {
          return state = `${n != null ? n : ""}`;
        }
      },
      terminator: {
        enumerable: true,
        get: () => {
          var ref, terminator;

          if (state) {
            if (typeof (terminator = currentInputMethod != null ? (ref = currentInputMethod.terminators) != null ? ref[state] : void 0 : void 0) === "number") {
              return String.fromCharCode(terminator >>> 0);
            } else {
              return `${terminator != null ? terminator : ""}` || null;
            }
          }
        }
      }
    });
  }

  addLayout(inputMethod) {
    var layout;
    ({
      layout
    } = this);

    if (layout === this[internalAdd](inputMethod)) {
      return this.layout = layout;
    }
  }

  removeLayout(name) {
    var charset, layout, removed;
    ({
      layout,
      charset
    } = this);

    if (layout === (removed = this[internalRemove](name))) {
      if (charset) {
        this.charset = charset;
      }

      if (this.layout === removed) {
        return this.layout = layouts[0];
      }
    }
  }

  attach(target) {
    target.addEventListener("keydown", this);
    return target.addEventListener("keyup", this);
  }

  remove(target) {
    target.removeEventListener("keydown", this);
    return target.removeEventListener("keyup", this);
  }

  query(code) {
    if (KEYS.has(code)) {
      return this[internalQuery](code);
    } else {
      return getHardcodedKeyValue(code, {
        Shift: this.modifiers.Shift
      });
    }
  }

  handleEvent(event) {
    var Control, code, i, j, key, len, len1, m, previousState, ref, ref1, ref2, ref3, result;

    switch (event.type) {
      case "keydown":
        ref = ["AltGraph", "CapsLock", "Shift"];

        for (i = 0, len = ref.length; i < len; i++) {
          m = ref[i];
          this[internalModifiers][m] = event.getModifierState(m);
        }

        if (event.getModifierState("Meta")) {
          return;
        }

        event.preventDefault();
        previousState = this.state;

        if (!(code = `${(ref1 = event.code) != null ? ref1 : ""}`)) {
          return;
        }

        result = (Control = event.getModifierState("Control")) || !KEYS.has(code) ? getHardcodedKeyValue(code, {
          Alt: event.getModifierState("Alt"),
          Control,
          Shift: this.modifiers.Shift
        }) : this[internalQuery](code);

        switch (false) {
          case !(typeof result === "object" && (result.mode != null || result.state != null)):
            if (result.mode != null) {
              this.mode = result.mode;
            }

            if (result.state != null) {
              this.state = result.state;
            }

            sendMessage.call(this, previousState && this.state !== previousState ? {
              code,
              previousState
            } : {
              code
            });
            break;

          case typeof result !== "number":
            this.state = "";
            key = String.fromCharCode(result >>> 0);
            sendMessage.call(this, previousState ? {
              code,
              key,
              previousState
            } : {
              code,
              key
            });
            break;

          case result == null:
            this.state = "";
            key = `${result}`;
            sendMessage.call(this, previousState ? key ? {
              code,
              key,
              previousState
            } : {
              code,
              previousState
            } : key ? {
              code,
              key
            } : {
              code
            });
            break;

          case !(previousState && KEYS.has(code)):
            this.state = "";
            sendMessage.call(this, (key = this.terminator) ? {
              key,
              previousState
            } : {
              previousState
            });
            this.handleEvent(event);
        }

        break;

      case "keyup":
        ref2 = ["AltGraph", "CapsLock", "Shift"];

        for (j = 0, len1 = ref2.length; j < len1; j++) {
          m = ref2[j];
          this[internalModifiers][m] = event.getModifierState(m);
        }

        break;

      case "message":
        if (!((typeof data !== "undefined" && data !== null ? data.target : void 0) === "https://kite.KIBI.network/KiBoard" && ((ref3 = data.id) != null ? ref3 : "") === this.id)) {
          break;
        }

    }
  }

};
export var KIM = Object.defineProperties({}, {
  query: {
    enumerable: true,
    value: ({
      modifiers,
      mode,
      state
    }, inputMethod, code) => {
      var i, keyMap, len, plannedState, ref, ref1, ref2, ref3, ref4, ref5, ref6, ref7, result, terminator;

      if (!(inputMethod != null ? (ref = inputMethod.keyMaps) != null ? ref.length : void 0 : void 0)) {
        return;
      }

      result = void 0;
      ref1 = [].concat(inputMethod.keyMaps);

      for (i = 0, len = ref1.length; i < len; i++) {
        keyMap = ref1[i];

        if (!(`${(ref2 = keyMap.mode) != null ? ref2 : ""}` || null === mode)) {
          continue;
        }

        if (keyMap.modifiers != null) {
          if (![].concat(keyMap.modifiers).some(function (conditions) {
            var modifier, value;

            for (modifier in modifiers) {
              value = modifiers[modifier];

              if (conditions[modifier] != null) {
                if (!!conditions[modifier] !== value) {
                  return false;
                }
              }
            }

            return true;
          })) {
            continue;
          }
        }

        if ((result = keyMap[code]) == null) {
          continue;
        }

        if (typeof result === "object" && result.action != null) {
          if (((ref3 = inputMethod.actions) != null ? ref3[result.action] : void 0) != null) {
            result = (ref4 = keyMap.actions[result.action][state]) != null ? ref4 : keyMap.actions[result.action][""];
          } else {
            continue;
          }
        }

        break;
      }

      if (result == null) {
        return;
      }

      if (typeof result === "object") {
        if (plannedState = `${(ref5 = result.state) != null ? ref5 : ""}`) {
          ({
            terminator,
            ...result
          } = result);

          if (terminator = `${(ref6 = (ref7 = inputMethod.terminators) != null ? ref7[plannedState] : void 0) != null ? ref6 : ""}`) {
            result.terminator = terminator;
          }

          return result;
        }

        return { ...result
        };
      }

      return result;
    }
  }
});
qwertyValues = {
  Backquote: "`~",
  Digit1: "1!",
  Digit2: "2@",
  Digit3: "3#",
  Digit4: "4$",
  Digit5: "5%",
  Digit6: "6^",
  Digit7: "7&",
  Digit8: "8*",
  Digit9: "9(",
  Digit0: "0)",
  Minus: "-_",
  Equal: "=+",
  IntlYen: "\\|",
  KeyQ: "qQ",
  KeyW: "wW",
  KeyE: "eE",
  KeyR: "rR",
  KeyT: "tT",
  KeyY: "yY",
  KeyU: "uU",
  KeyI: "iI",
  KeyO: "oO",
  KeyP: "pP",
  BracketLeft: "[{",
  BracketRight: "]}",
  Backslash: "\\|",
  KeyA: "aA",
  KeyS: "sS",
  KeyD: "dD",
  KeyF: "fF",
  KeyG: "gG",
  KeyH: "hH",
  KeyJ: "jJ",
  KeyK: "kK",
  KeyL: "lL",
  Semicolon: ";:",
  Quote: "'\"",
  IntlBackslash: "\\|",
  KeyZ: "zZ",
  KeyX: "xX",
  KeyC: "cC",
  KeyV: "vV",
  KeyB: "bB",
  KeyN: "nN",
  KeyM: "mM",
  Comma: ",<",
  Period: ".>",
  Slash: "/?",
  IntlRo: "/?",
  Space: " ",
  NumpadEqual: "=",
  NumpadParenLeft: "(",
  NumpadParenRight: ")",
  NumpadDivide: "/",
  NumpadMultiply: "*",
  NumpadSubtract: "-",
  Numpad7: "7",
  Numpad8: "8",
  Numpad9: "9",
  NumpadAdd: "+",
  Numpad4: "4",
  Numpad5: "5",
  Numpad6: "6",
  NumpadComma: ",",
  Numpad1: "1",
  Numpad2: "2",
  Numpad3: "3",
  NumpadStar: "*",
  Numpad0: "0",
  NumpadHash: "#",
  NumpadDecimal: ".",
  Escape: "\x7F"
};
controlValues = {
  Backspace: "\u80DF",
  Tab: "\t\u80D9",
  Enter: "\u80D1\u80D0",
  Help: ["\x05\x7F"],
  Home: "\r",
  PageUp: "\u80DC",
  Delete: "\u80DE",
  End: "\u80DD",
  PageDown: "\f",
  ArrowUp: "\u80DA",
  ArrowLeft: "\b",
  ArrowDown: "\n",
  ArrowRight: "\u80D8",
  NumpadEnter: "\v\u80DB",
  Escape: ["\x1B\x7F"],
  F1: ["\x05\x7F"],
  F2: ["\x06\x7F"],
  F3: ["\x07\x7F"],
  F4: ["\x15\x7F"],
  F5: "\x11",
  F6: "\x12",
  F7: "\x13",
  F8: "\x14",
  F9: ["\u80CA\x7F"],
  F10: ["\u80CB\x7F"],
  F11: ["\u80CC\x7F"],
  F12: ["\u80CD\x7F"],
  Pause: "\u80D7\x11",
  Suspend: "\x13",
  Resume: "\x12",
  Abort: "\x14"
};

getHardcodedKeyValue = (code, {
  Alt,
  Control,
  Shift
}) => {
  if (Control && qwertyValues.hasOwnProperty(code)) {
    return (Alt ? "\u80CA" : "\x1B") + (Shift && qwertyValues[code][1] || qwertyValues[code][0]);
  } else if (controlValues.hasOwnProperty(code)) {
    return Shift && controlValues[code][1] || controlValues[code][0];
  }
};

KEYS = new Set(["Backquote", "Backslash", "BracketLeft", "BracketRight", "Comma", "Digit0", "Digit1", "Digit2", "Digit3", "Digit4", "Digit5", "Digit6", "Digit7", "Digit8", "Digit9", "Equal", "IntlBackslash", "IntlRo", "IntlYen", "KeyA", "KeyB", "KeyC", "KeyD", "KeyE", "KeyF", "KeyG", "KeyH", "KeyI", "KeyJ", "KeyK", "KeyL", "KeyM", "KeyN", "KeyO", "KeyP", "KeyQ", "KeyR", "KeyS", "KeyT", "KeyU", "KeyV", "KeyW", "KeyX", "KeyY", "KeyZ", "Minus", "Period", "Quote", "Semicolon", "Slash", "Space", "NumpadEqual", "NumpadParenLeft", "NumpadParenRight", "NumpadDivide", "NumpadMultiply", "NumpadSubtract", "Numpad7", "Numpad8", "Numpad9", "NumpadAdd", "Numpad4", "Numpad5", "Numpad6", "NumpadComma", "Numpad1", "Numpad2", "Numpad3", "NumpadStar", "Numpad0", "NumpadHash", "NumpadDecimal"]);
Object.defineProperty(KIM, "keys", {
  enumerable: true,
  value: () => {
    return new Set(KEYS);
  }
});

InputMethodsMap = function () {
  class InputMethodsMap extends Map {
    constructor(...inputMethods) {
      super();
      inputMethods.forEach(inputMethod => {
        var name, ref;

        if (name = `${(ref = inputMethod != null ? inputMethod.name : void 0) != null ? ref : ""}`) {
          Map.prototype.delete.call(this, name);
          return Map.prototype.set.call(this, name, inputMethod);
        }
      });
      Object.defineProperty(this, "first", {
        enumerable: true,
        get: () => {
          if (!this.size) {
            return;
          }

          return Map.prototype.values.call(this).next().value;
        }
      });
    }

    add(inputMethod) {
      var name, ref;

      if (!(name = `${(ref = inputMethod != null ? inputMethod.name : void 0) != null ? ref : ""}`)) {
        return false;
      }

      Map.prototype.delete.call(this, name);
      Map.prototype.set.call(this, name, inputMethod);
      return name;
    }

    remove(name) {
      if (!(name = `${name != null ? name : ""}`)) {
        return false;
      }

      if (!Map.prototype.has.call(this, name)) {
        return false;
      }

      Map.prototype.delete.call(this, name);
      return name;
    }

    filterByCharset(charset) {
      return Object.setPrototypeOf(new Map(Array.from(this).filter(arg => {
        var arg, inputMethod, ref;
        [inputMethod] = slice.call(arg, -1);
        return `${(ref = inputMethod.charset) != null ? ref : ""}` === `${charset != null ? charset : ""}`;
      })), InputMethodsMap.prototype);
    }

    list() {
      return Array.from(Map.prototype.keys.call(this));
    }

    charsets() {
      return Array.from(new Set(Array.from(Map.prototype.values.call(this)).map(arg => {
        var arg, charset;
        [{
          charset
        }] = slice.call(arg, -1);
        return `${charset}`;
      })));
    }

  }

  ;
  Object.defineProperty(InputMethodsMap, Symbol.species, {
    value: Map
  });
  Object.defineProperties(InputMethodsMap.prototype, {
    delete: {
      value: void 0
    },
    set: {
      value: void 0
    }
  });
  return InputMethodsMap;
}.call(this);

sendMessage = function (data = {}) {
  var header, i, key, len, ref, value;

  if (!(this instanceof KiBoard)) {
    throw new TypeError("KiBoard messages can only be sent from a KiBoard instance.");
  }

  header = {
    sender: "https://kite.KIBI.network/KiBoard/"
  };
  ref = ["id", "layout", "charset", "mode", "modifiers", "state"];

  for (i = 0, len = ref.length; i < len; i++) {
    key = ref[i];

    if (value = this[key]) {
      header[key] = value;
    }
  }

  return typeof this.messager === "function" ? this.messager({ ...header,
    ...data
  }) : void 0;
};
