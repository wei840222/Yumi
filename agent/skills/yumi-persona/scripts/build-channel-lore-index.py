#!/usr/bin/env python3
"""Build a compact named-cast index from yt-dlp metadata and zh-Hant VTT files."""

from __future__ import annotations

import argparse
import html
import json
import re
from dataclasses import dataclass
from pathlib import Path

DEFAULT_GROUPS = {
    "Yumi": ("Yumi",),
    "Wojak": ("Wojak",),
    "B哥": ("B哥",),
    "阿布": ("阿布", "啊布"),
}
TIMESTAMP_RE = re.compile(r"^\d{2}:\d{2}(?::\d{2})?[.,]\d{3}\s+-->")
TAG_RE = re.compile(r"<[^>]+>")


@dataclass(frozen=True)
class Entry:
    video_id: str
    upload_date: str
    title: str
    url: str
    caption_path: Path
    text: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Index named-cast mentions in creator-supplied zh-Hant YouTube captions."
    )
    parser.add_argument("input_dir", type=Path, help="Directory containing yt-dlp .info.json and .vtt files")
    parser.add_argument(
        "--keyword",
        action="append",
        dest="keywords",
        help="Keyword to count; repeat for multiple values (defaults to Yumi/Wojak/B哥/阿布, with 啊布 merged as an alias)",
    )
    parser.add_argument("--output", type=Path, help="Write Markdown to this path instead of stdout")
    return parser.parse_args()


def clean_caption(path: Path) -> str:
    lines: list[str] = []
    for raw in path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = html.unescape(TAG_RE.sub("", raw)).strip()
        if not line or line.startswith(("WEBVTT", "Kind:", "Language:", "NOTE")):
            continue
        if TIMESTAMP_RE.match(line) or line.isdigit():
            continue
        if not lines or lines[-1] != line:
            lines.append(line)
    return "\n".join(lines)


def canonical_caption(root: Path, video_id: str) -> Path | None:
    candidates = [
        path
        for path in root.glob("*.zh-Hant.vtt")
        if not path.name.endswith("-zh-Hant.vtt") and video_id in path.name
    ]
    return sorted(candidates)[0] if candidates else None


def load_entries(root: Path) -> tuple[list[Entry], int]:
    entries: list[Entry] = []
    metadata_count = 0
    for path in sorted(root.glob("*.info.json")):
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            continue
        video_id = data.get("id")
        if not isinstance(video_id, str) or len(video_id) != 11:
            continue
        metadata_count += 1
        caption = canonical_caption(root, video_id)
        if caption is None:
            continue
        date = str(data.get("upload_date") or "")
        if len(date) == 8 and date.isdigit():
            date = f"{date[:4]}-{date[4:6]}-{date[6:]}"
        entries.append(
            Entry(
                video_id=video_id,
                upload_date=date or "unknown",
                title=str(data.get("title") or video_id),
                url=f"https://www.youtube.com/watch?v={video_id}",
                caption_path=caption,
                text=clean_caption(caption),
            )
        )
    return entries, metadata_count


def render(
    entries: list[Entry], metadata_count: int, groups: dict[str, tuple[str, ...]]
) -> str:
    rows: list[str] = []
    for entry in entries:
        counts = [
            sum(entry.text.lower().count(alias.lower()) for alias in aliases)
            for aliases in groups.values()
        ]
        if not any(counts):
            continue
        title = entry.title.replace("|", "\\|")
        count_cells = " | ".join(str(count) for count in counts)
        rows.append(
            f"| {entry.upload_date} | [{title}]({entry.url}) | {count_cells} |"
        )

    header_keywords = " | ".join(groups)
    separator = " | ".join("---:" for _ in groups)
    lines = [
        "# 隨意畫 named-cast caption index",
        "",
        f"Metadata files: {metadata_count}; canonical zh-Hant captions: {len(entries)}; matching videos: {len(rows)}.",
        "",
        f"| Date | Official video | {header_keywords} |",
        f"|---|---|{separator}|",
        *rows,
        "",
        "Counts locate candidate episodes; they do not prove speaker identity or continuity. Review the official video before adding lore.",
    ]
    return "\n".join(lines) + "\n"


def main() -> int:
    args = parse_args()
    root = args.input_dir.expanduser().resolve()
    if not root.is_dir():
        raise SystemExit(f"input directory does not exist: {root}")
    groups = (
        {keyword: (keyword,) for keyword in args.keywords}
        if args.keywords
        else DEFAULT_GROUPS
    )
    entries, metadata_count = load_entries(root)
    output = render(entries, metadata_count, groups)
    if args.output:
        destination = args.output.expanduser()
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_text(output, encoding="utf-8")
    else:
        print(output, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
