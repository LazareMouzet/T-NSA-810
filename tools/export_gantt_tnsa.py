#!/usr/bin/env python3
"""
Wrapper around gantt-exporter for T-NSA project.

Customisation: for tasks starting before the first milestone,
Target date takes priority over closedAt for the end date.
This preserves planned dates for early-phase tasks while keeping
actual completion dates for later ones.

Usage (same args as export_gantt.py):
    python tools/export_gantt_tnsa.py --login <user> --project <num> [options]
"""

import sys
import os
import importlib.util
from datetime import date

# ---------------------------------------------------------------------------
# Import the upstream export_gantt module from the submodule
# ---------------------------------------------------------------------------
_HERE = os.path.dirname(os.path.abspath(__file__))
_UPSTREAM = os.path.join(_HERE, "gantt-exporter", "export_gantt.py")

spec = importlib.util.spec_from_file_location("export_gantt", _UPSTREAM)
gantt = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gantt)

# Re-export helpers we'll need
parse_date = gantt.parse_date
extract_field = gantt.extract_field
extract_milestone = gantt.extract_milestone
extract_iteration = gantt.extract_iteration
escape = gantt.escape
die = gantt.die
fetch_items = gantt.fetch_items
fetch_repo_milestones = gantt.fetch_repo_milestones


def main():
    """Patched main() with milestone-aware end-date priority."""
    import argparse
    from datetime import timedelta

    parser = argparse.ArgumentParser(
        description="Export GitHub Project to Mermaid Gantt (T-NSA wrapper)"
    )
    parser.add_argument("--login", required=True, help="GitHub username")
    parser.add_argument("--project", type=int, required=True, help="Project number")
    parser.add_argument("--repo", help="Repository (owner/name) to fetch milestones from")
    parser.add_argument("--group", default="Subject", help="Field to group by")
    parser.add_argument("--start", default="Start date", help="Start date field")
    parser.add_argument("--default-duration", type=int, default=7,
                        help="Default duration in days for tasks without end date")
    parser.add_argument("--min-duration", type=int, default=3,
                        help="Minimum visual duration in days for short tasks")
    parser.add_argument("--list", action="store_true", help="List all items (debug)")
    parser.add_argument("--include-undated", action="store_true",
                        help="Include tasks without dates (uses today)")
    args = parser.parse_args()

    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if not token:
        die("Set GITHUB_TOKEN or GH_TOKEN")

    title, raw = fetch_items(token, args.login, args.project)

    # Debug: list all items (delegate to upstream logic)
    if args.list:
        print(f"Project: {title}")
        print(f"Items: {len(raw)}")
        for i, node in enumerate(raw):
            fields = (node.get("fieldValues") or {}).get("nodes") or []
            name = extract_field(fields, "Title") or "(no title)"
            ms = extract_milestone(node)
            it = extract_iteration(fields)
            start = extract_field(fields, args.start)
            group = extract_field(fields, args.group)
            print(f"\n{i+1}. {name}")
            print(f"   Raw node: {node}")
            print(f"   Group: {group or '-'}")
            print(f"   Start: {start or '-'}")
            if ms:
                print(f"   Milestone: {ms['title']} (due: {ms['due'] or '-'})")
            if it:
                print(f"   Iteration: {it['title']} (start: {it['start']}, {it['duration']} days)")
        return

    # Parse items into tasks and milestones
    tasks = []
    milestones = {}  # title -> due date
    today = date.today()

    # Fetch milestones from repo if specified
    if args.repo:
        parts = args.repo.split("/")
        if len(parts) != 2:
            die("--repo must be in format owner/name")
        owner, repo_name = parts
        repo_milestones = fetch_repo_milestones(token, owner, repo_name)
        for ms in repo_milestones:
            ms_due = parse_date(ms.get("dueOn"))
            if ms_due and ms.get("title"):
                milestones[ms["title"]] = ms_due

    # ── First pass: collect all milestones from items ──────────────────
    for node in raw:
        ms = extract_milestone(node)
        if ms and ms.get("title"):
            ms_due = parse_date(ms.get("due"))
            if ms_due and ms["title"] not in milestones:
                milestones[ms["title"]] = ms_due

    # Determine the first (earliest) milestone date
    first_milestone_date = min(milestones.values()) if milestones else None

    # ── Second pass: process tasks ─────────────────────────────────────
    for node in raw:
        fields = (node.get("fieldValues") or {}).get("nodes") or []
        content = node.get("content") or {}
        name = extract_field(fields, "Title")
        if not name:
            continue

        # Check for iteration (can use as date source)
        it = extract_iteration(fields)

        start = parse_date(extract_field(fields, args.start))

        closed_at = parse_date(content.get("closedAt"))
        target_date = parse_date(extract_field(fields, "Target date"))

        # End date priority depends on position relative to first milestone:
        # - Before first milestone: Target date > closedAt (planned date matters more)
        # - After first milestone:  closedAt > Target date (actual completion matters more)
        if first_milestone_date and start and start < first_milestone_date:
            end = target_date or closed_at
        else:
            end = closed_at or target_date

        # Fallback to iteration dates if no start/end
        if not start and not end and it:
            start = parse_date(it.get("start"))
            if start and it.get("duration"):
                end = start + timedelta(days=int(it["duration"]))

        # Handle tasks without dates
        if not start and not end:
            if args.include_undated:
                start = today
            else:
                continue

        if not start:
            start = end
        if not end:
            end = start + timedelta(days=args.default_duration)

        # Ensure minimum visual duration
        if (end - start).days < args.min_duration:
            end = start + timedelta(days=args.min_duration)

        group = extract_field(fields, args.group) or "Other"
        tasks.append({"name": escape(name), "group": escape(group),
                       "start": start, "end": end})

    if not tasks and not milestones:
        die("No tasks found")

    # Group tasks
    groups = {}
    for t in tasks:
        groups.setdefault(t["group"], []).append(t)

    # Calculate max group name length for leftPadding
    max_group_name_len = max((len(task["group"]) for task in tasks), default=0)
    if milestones:
        max_group_name_len = max(max_group_name_len, len("Milestones"))
    left_padding = max(150, min(500, max_group_name_len * 7))

    # Output
    print("```mermaid")
    print(f"%%{{init: {{'gantt': {{'leftPadding': {left_padding}}}}}}}%%")
    print("gantt")
    print(f"  title {escape(title)}")
    print("  dateFormat YYYY-MM-DD")
    print()

    # Milestones section
    if milestones:
        print("  section Milestones")
        for ms_title, ms_due in sorted(milestones.items(), key=lambda x: x[1]):
            print(f"  {escape(ms_title)} : milestone, m{hash(ms_title) % 1000}, {ms_due}, 0d")
        print()

    # Task sections
    for g in sorted(groups.keys()):
        print(f"  section {g}")
        for t in sorted(groups[g], key=lambda x: x["start"]):
            print(f"  {t['name']} : {t['start']}, {t['end']}")
        print()
    print("```")


if __name__ == "__main__":
    main()
