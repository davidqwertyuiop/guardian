#!/usr/bin/env python3
"""Rearrange Guardian mobile Dart files into feature folders.

This script is intentionally conservative:

- dry-run is the default;
- it only moves paths declared in MOVE_SPECS;
- it refuses to overwrite existing files;
- it can rewrite Dart import/export/part directives after files move.

Usage:
  python3 scripts/reorganize_mobile_features.py
  python3 scripts/reorganize_mobile_features.py --apply
  python3 scripts/reorganize_mobile_features.py --apply --no-update-imports
"""

from __future__ import annotations

import argparse
import os
import re
import shutil
from dataclasses import dataclass
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
MOBILE_LIB = REPO_ROOT / "apps" / "mobile" / "lib"


@dataclass(frozen=True)
class MoveSpec:
    source: str
    destination: str
    reason: str


MOVE_SPECS: tuple[MoveSpec, ...] = (
    MoveSpec(
        "features/location/presentation/screens/live_map_screen.dart",
        "features/map/presentation/screens/live_map_screen.dart",
        "live map screen belongs to the map feature",
    ),
    MoveSpec(
        "features/location/presentation/screens/live_map",
        "features/map/presentation/screens/live_map",
        "live map screen parts belong beside the map screen",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/map_card.dart",
        "features/map/presentation/widgets/live_map/map_card.dart",
        "map card belongs to the map feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/map_card",
        "features/map/presentation/widgets/live_map/map_card",
        "map card parts belong to the map feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/map_styles.dart",
        "features/map/presentation/widgets/live_map/map_styles.dart",
        "map styling belongs to the map feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/map_distance_badge.dart",
        "features/map/presentation/widgets/live_map/map_distance_badge.dart",
        "map overlay belongs to the map feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/place_suggestions_overlay.dart",
        "features/map/presentation/widgets/live_map/place_suggestions_overlay.dart",
        "place search overlay belongs to the map feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/address_text.dart",
        "features/map/presentation/widgets/live_map/address_text.dart",
        "map address display belongs to the map feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/top_bar.dart",
        "features/map/presentation/widgets/live_map/top_bar.dart",
        "live map top bar belongs to the map feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/top_bar",
        "features/map/presentation/widgets/live_map/top_bar",
        "live map top bar parts belong to the map feature",
    ),
    MoveSpec(
        "features/location/presentation/screens/sos_broadcasts_screen.dart",
        "features/sos/presentation/screens/sos_broadcasts_screen.dart",
        "SOS broadcasts screen belongs to the SOS feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/sos_bottom_sheet.dart",
        "features/sos/presentation/widgets/live_map/sos_bottom_sheet.dart",
        "SOS activation sheet belongs to the SOS feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/sos_bottom_sheet",
        "features/sos/presentation/widgets/live_map/sos_bottom_sheet",
        "SOS activation sheet parts belong to the SOS feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/sos_broadcasts_section.dart",
        "features/sos/presentation/widgets/sos_broadcasts_section.dart",
        "SOS broadcast section belongs to the SOS feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/sos_broadcasts",
        "features/sos/presentation/widgets/sos_broadcasts",
        "SOS broadcast section parts belong to the SOS feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/heading_out_bottom_sheet.dart",
        "features/journey/presentation/widgets/live_map/heading_out_bottom_sheet.dart",
        "heading-out sheet belongs to the journey feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/heading_out_bottom_sheet",
        "features/journey/presentation/widgets/live_map/heading_out_bottom_sheet",
        "heading-out sheet parts belong to the journey feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/heading_out_button.dart",
        "features/journey/presentation/widgets/live_map/heading_out_button.dart",
        "heading-out entry point belongs to the journey feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/heading_out_button.dart",
        "features/journey/presentation/widgets/heading_out_button.dart",
        "heading-out widget belongs to the journey feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/you_are_live_bottom_sheet.dart",
        "features/journey/presentation/widgets/live_map/you_are_live_bottom_sheet.dart",
        "active journey sheet belongs to the journey feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/broadcast_controls.dart",
        "features/journey/presentation/widgets/live_map/broadcast_controls.dart",
        "broadcast controls belong to the journey feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/broadcast_controls",
        "features/journey/presentation/widgets/live_map/broadcast_controls",
        "broadcast controls parts belong to the journey feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/broadcast_bottom_panel.dart",
        "features/journey/presentation/widgets/live_map/broadcast_bottom_panel.dart",
        "broadcast bottom panel belongs to the journey feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/broadcast_circle_card.dart",
        "features/journey/presentation/widgets/live_map/broadcast_circle_card.dart",
        "broadcast circle card belongs to the journey feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/circle_card.dart",
        "features/circles/presentation/widgets/live_map/circle_card.dart",
        "circle card belongs to the circles feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/circle_card.dart",
        "features/circles/presentation/widgets/circle_card.dart",
        "circle card belongs to the circles feature",
    ),
    MoveSpec(
        "features/location/presentation/widgets/live_map/member_avatar_row.dart",
        "features/circles/presentation/widgets/live_map/member_avatar_row.dart",
        "member avatar row belongs to the circles feature",
    ),
)


DART_DIRECTIVE_RE = re.compile(
    r"(?m)^(?P<prefix>\s*(?:import|export|part|part\s+of)\s+)(?P<quote>['\"])(?P<uri>[^'\"]+)(?P=quote)"
)


def posix(path: Path) -> str:
    return path.as_posix()


def rel_to_lib(path: Path) -> str:
    return posix(path.relative_to(MOBILE_LIB))


def build_move_plan() -> dict[Path, Path]:
    plan: dict[Path, Path] = {}
    for spec in MOVE_SPECS:
        source = MOBILE_LIB / spec.source
        destination = MOBILE_LIB / spec.destination

        if not source.exists():
            continue

        if source.is_dir():
            for file_path in sorted(source.rglob("*")):
                if file_path.is_file():
                    plan[file_path] = destination / file_path.relative_to(source)
        elif source.is_file():
            plan[source] = destination

    return {src: dst for src, dst in plan.items() if src != dst}


def validate_plan(plan: dict[Path, Path]) -> list[str]:
    errors: list[str] = []
    destinations: dict[Path, Path] = {}

    for source, destination in plan.items():
        previous = destinations.get(destination)
        if previous is not None:
            errors.append(
                f"two sources target {rel_to_lib(destination)}: "
                f"{rel_to_lib(previous)} and {rel_to_lib(source)}"
            )
        destinations[destination] = source

        if destination.exists() and source.resolve() != destination.resolve():
            errors.append(
                f"destination already exists: {rel_to_lib(destination)} "
                f"(from {rel_to_lib(source)})"
            )

    return errors


def dart_files_to_rewrite(plan: dict[Path, Path]) -> list[Path]:
    files: set[Path] = set()
    for dart_file in MOBILE_LIB.rglob("*.dart"):
        files.add(dart_file)
    for destination in plan.values():
        if destination.suffix == ".dart":
            files.add(destination)
    return sorted(files)


def resolve_old_uri(current_file: Path, uri: str) -> Path | None:
    if uri.startswith("package:guardian/"):
        return MOBILE_LIB / uri.removeprefix("package:guardian/")

    if uri.startswith(("dart:", "package:", "http:", "https:")):
        return None

    if not uri.endswith(".dart"):
        return None

    return (current_file.parent / uri).resolve()


def relative_uri(from_file: Path, to_file: Path) -> str:
    return posix(Path(os.path.relpath(to_file, from_file.parent)))


def package_uri(to_file: Path) -> str:
    return f"package:guardian/{rel_to_lib(to_file)}"


def rewrite_dart_content(
    old_file: Path,
    content: str,
    plan: dict[Path, Path],
    prefer_package_imports: bool,
) -> str:
    new_file = plan.get(old_file, old_file)

    def replace(match: re.Match[str]) -> str:
        uri = match.group("uri")
        resolved = resolve_old_uri(old_file, uri)
        if resolved is None:
            return match.group(0)

        target = plan.get(resolved, resolved)
        if not target.exists() and resolved not in plan:
            return match.group(0)

        directive = match.group("prefix").strip()
        if uri.startswith("package:guardian/") or (
            prefer_package_imports and directive in {"import", "export"}
        ):
            new_uri = package_uri(target)
        else:
            new_uri = relative_uri(new_file, target)

        return f"{match.group('prefix')}{match.group('quote')}{new_uri}{match.group('quote')}"

    return DART_DIRECTIVE_RE.sub(replace, content)


def rewrite_imports(
    plan: dict[Path, Path],
    apply: bool,
    prefer_package_imports: bool,
) -> int:
    changed = 0
    for old_file in dart_files_to_rewrite(plan):
        read_path = old_file if old_file.exists() else plan.get(old_file)
        if read_path is None or not read_path.exists():
            continue

        content = read_path.read_text(encoding="utf-8")
        new_content = rewrite_dart_content(
            old_file=old_file,
            content=content,
            plan=plan,
            prefer_package_imports=prefer_package_imports,
        )
        if new_content == content:
            continue

        changed += 1
        write_path = plan.get(old_file, old_file)
        print(f"  rewrite imports: {rel_to_lib(write_path)}")
        if apply:
            write_path.parent.mkdir(parents=True, exist_ok=True)
            write_path.write_text(new_content, encoding="utf-8")

    return changed


def apply_moves(plan: dict[Path, Path]) -> None:
    for source, destination in sorted(plan.items(), key=lambda item: rel_to_lib(item[0])):
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(source), str(destination))


def print_plan(plan: dict[Path, Path]) -> None:
    if not plan:
        print("No file moves needed.")
        return

    print(f"Planned moves: {len(plan)} file(s)")
    for source, destination in sorted(plan.items(), key=lambda item: rel_to_lib(item[0])):
        print(f"  {rel_to_lib(source)} -> {rel_to_lib(destination)}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Move Guardian mobile Dart files into their feature folders."
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="perform the moves. Without this flag the script only prints a plan.",
    )
    parser.add_argument(
        "--no-update-imports",
        action="store_true",
        help="do not rewrite Dart import/export/part directives.",
    )
    parser.add_argument(
        "--prefer-package-imports",
        action="store_true",
        help="rewrite relative import/export directives as package:guardian imports.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    plan = build_move_plan()
    errors = validate_plan(plan)

    print_plan(plan)
    if errors:
        print("\nRefusing to continue:")
        for error in errors:
            print(f"  - {error}")
        return 1

    if not args.no_update_imports:
        print("\nImport rewrite pass:")
        changed = rewrite_imports(
            plan=plan,
            apply=args.apply,
            prefer_package_imports=args.prefer_package_imports,
        )
        if changed == 0:
            print("  no import changes needed")

    if args.apply:
        apply_moves(plan)
        print("\nApplied feature-folder reorganization.")
    else:
        print("\nDry run only. Re-run with --apply to move files.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
