#!/usr/bin/env python3
"""Generate palette files from theme/palette.lua (single source of truth).

Usage:
    python3 theme/generate.py
"""
import re
import sys
from pathlib import Path

DOTFILES_ROOT = Path(__file__).parent.parent


def parse_palette(lua_file: Path) -> dict[str, str]:
    pattern = re.compile(r"(base[0-9A-F]{2})\s*=\s*\"(#[0-9a-fA-F]{6})\"")
    colors = {m.group(1): m.group(2) for m in pattern.finditer(lua_file.read_text())}
    if not colors:
        print(f"Error: no colors found in {lua_file}", file=sys.stderr)
        sys.exit(1)
    return colors


def hex_to_rgb(hex_color: str) -> tuple[int, int, int]:
    h = hex_color.lstrip("#")
    return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)


def generate_palette_toml(colors: dict[str, str], out: Path) -> None:
    lines = [
        "# ============================================================",
        "# COLOR PALETTES",
        "# このファイルは theme/generate.py で自動生成されます。直接編集しないこと",
        "# ============================================================",
        "[palettes.custom]",
    ] + [f'{k} = "{v}"' for k, v in sorted(colors.items())]
    out.write_text("\n".join(lines) + "\n")
    print(f"  ✅ {out.relative_to(DOTFILES_ROOT)}")


def update_starship_toml(colors: dict[str, str], starship_file: Path) -> None:
    content = starship_file.read_text()
    marker = "[palettes.custom]"
    idx = content.find(marker)
    if idx == -1:
        print(
            f"  ⚠️  '{marker}' が見つかりません: {starship_file}",
            file=sys.stderr,
        )
        return
    palette_block = (
        "# このセクションは theme/generate.py で自動生成されます。直接編集しないこと\n"
        "[palettes.custom]\n"
        + "".join(f'{k} = "{v}"\n' for k, v in sorted(colors.items()))
    )
    starship_file.write_text(content[:idx] + palette_block)
    print(f"  ✅ {starship_file.relative_to(DOTFILES_ROOT)}")


def generate_eza_zsh(colors: dict[str, str], out: Path) -> None:
    def ansi(key: str) -> str:
        r, g, b = hex_to_rgb(colors[key])
        return f"38;2;{r};{g};{b}"

    content = (
        "# このファイルは theme/generate.py で自動生成されます。直接編集しないこと\n"
        "export LS_COLORS=\"\\\n"
        f"di={ansi('base0D')}:\\\n"
        f"ex={ansi('base0B')}:\\\n"
        f"ln={ansi('base0E')}:\\\n"
        f"fi={ansi('base05')}:\\\n"
        "\"\n"
        "\n"
        "export EZA_COLORS=\"$LS_COLORS\"\n"
    )
    out.write_text(content)
    print(f"  ✅ {out.relative_to(DOTFILES_ROOT)}")


def main() -> None:
    palette_lua = DOTFILES_ROOT / "theme" / "palette.lua"
    if not palette_lua.exists():
        print(f"Error: {palette_lua} not found", file=sys.stderr)
        sys.exit(1)

    colors = parse_palette(palette_lua)

    print("🎨 Generating palette files from theme/palette.lua ...")
    generate_palette_toml(colors, DOTFILES_ROOT / "theme" / "palette.toml")
    update_starship_toml(colors, DOTFILES_ROOT / "starship" / ".starship.toml")
    generate_eza_zsh(colors, DOTFILES_ROOT / "zsh" / ".zsh.d" / "06_eza.zsh")
    print("Done.")


if __name__ == "__main__":
    main()
