"""Run evaluator tests with Balatro's LuaJIT DLL and installed Steamodded helpers.

Usage: python tests/run_poker_hands.py [path/to/lua51.dll]
"""
import ctypes
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
DLL = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(
    "C:/Program Files (x86)/Steam/steamapps/common/Balatro/lua51.dll"
)
lua = ctypes.CDLL(str(DLL))
lua.luaL_newstate.restype = ctypes.c_void_p
lua.luaL_openlibs.argtypes = [ctypes.c_void_p]
lua.luaL_loadbuffer.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t, ctypes.c_char_p]
lua.lua_pcall.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int]
lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
lua.lua_tolstring.restype = ctypes.c_char_p
lua.lua_close.argtypes = [ctypes.c_void_p]
state = lua.luaL_newstate()
lua.luaL_openlibs(state)


def run(source, name, execute=True):
    data = source.encode()
    status = lua.luaL_loadbuffer(state, data, len(data), name.encode())
    if not status and execute:
        status = lua.lua_pcall(state, 0, 0, 0)
    if status:
        raise RuntimeError(lua.lua_tolstring(state, -1, None).decode())


try:
    for filename in ("main.lua", "poker_hands.lua", "seals/blank.lua", "achievements.lua",
                     "consumable_sticker_tools.lua",
                     "jokers/paul.lua", "jokers/glitch.lua", "consumables/excalibur.lua",
                     "consumables/freezer.lua", "consumables/mortgage.lua"):
        run((ROOT / filename).read_text(encoding="utf-8"), filename, False)
    overrides = (ROOT.parent / "Steamodded/src/overrides.lua").read_text(encoding="utf-8")
    run("function get_straight(" + overrides.split("function get_straight(", 1)[1].split("\nend", 1)[0]
        + "\nend", "Steamodded get_straight")
    vanilla = (ROOT.parent / "lovely/dump/functions/misc_functions.lua").read_text(encoding="utf-8")
    run("function get_X_same(" + vanilla.split("function get_X_same(", 1)[1].split("\nend", 1)[0]
        + "\nend", "patched get_X_same")
    run("TEST_ROOT = '" + ROOT.as_posix() + "'", "test root")
    run((ROOT / "tests/poker_hands.lua").read_text(encoding="utf-8"), "poker hand tests")
    run((ROOT / "tests/achievements.lua").read_text(encoding="utf-8"), "achievement tests")
    run((ROOT / "tests/blind_hands.lua").read_text(encoding="utf-8"), "Boss Blind hand tests")
    run((ROOT / "tests/kitty_tungsten.lua").read_text(encoding="utf-8"), "Kitty and Tungsten Cube tests")
    run((ROOT / "tests/blind_effects.lua").read_text(encoding="utf-8"), "Boss Blind effect tests")
    utils = (ROOT.parent / "Steamodded/src/utils.lua").read_text(encoding="utf-8")
    destroy_helper = "function SMODS.destroy_cards(" + utils.split("function SMODS.destroy_cards(", 1)[1].split("\n-- Hand Limit API", 1)[0]
    run(destroy_helper + "\nTEST_destroy_cards = SMODS.destroy_cards", "Steamodded destruction helper")
    run((ROOT / "tests/jester_pickaxe.lua").read_text(encoding="utf-8"), "Jester and Pickaxe tests")
    run((ROOT / "tests/phantom.lua").read_text(encoding="utf-8"), "Phantom tests")
finally:
    lua.lua_close(state)
