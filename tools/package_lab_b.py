"""Package existing Lab B evidence; never create playtest data or upload it."""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    base = ROOT / "tmp" / "lab-b-submission-20261014"
    output = base
    index = 2
    while output.exists():
        output = Path(str(base) + f"-{index}")
        index += 1
    output.mkdir(parents=True)
    for name in ["AGENTS.md", "GDD.md", "PROTOTYPE.md", "BUILD_LOG.md",
                 "README.md", "SUBMISSION_CHECKLIST.md"]:
        shutil.copy2(ROOT / name, output / name)
    shutil.copytree(ROOT / "build" / "web", output / "web",
                    ignore=shutil.ignore_patterns("*.import"))
    shutil.copy2(ROOT / "build" / "web.zip", output / "web.zip")
    shutil.copytree(ROOT / "telemetry", output / "telemetry")
    real_json = list((output / "telemetry").rglob("*.json"))
    for path in real_json:
        json.loads(path.read_text(encoding="utf-8-sig"))
    tracked = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT)
    omitted = []
    with zipfile.ZipFile(output / "EverFront-project-with-git.zip", "w",
                         compression=zipfile.ZIP_DEFLATED) as archive:
        for name in tracked.decode("utf-8").split("\0"):
            if not name:
                continue
            path = ROOT / name
            if name.startswith("build/") or not path.is_file():
                omitted.append(name)
                continue
            archive.write(path, "EverFront/" + name)
        for path in (ROOT / ".git").rglob("*"):
            if path.is_file() and not path.name.endswith(".lock"):
                archive.write(path, "EverFront/" + path.relative_to(ROOT).as_posix())
        # Include manually supplied real exports even when not committed.
        tracked_names = set(tracked.decode("utf-8").split("\0"))
        for path in (ROOT / "telemetry").rglob("*"):
            name = path.relative_to(ROOT).as_posix()
            if path.is_file() and name not in tracked_names:
                archive.write(path, "EverFront/" + name)
    verification = output / "engineering-verification"
    verification.mkdir()
    for path in (ROOT / "tmp" / "submission-checks").glob("*.log"):
        shutil.copy2(path, verification / path.name)
    manifest = {
        "source_commit": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT).decode().strip(),
        "working_tree": subprocess.check_output(["git", "status", "--short"], cwd=ROOT).decode(),
        "real_telemetry_json_count": len(real_json),
        "omitted_generated_or_missing_tracked_files": omitted,
        "note": "Working-copy source snapshot with original Git history; engineering logs are not playtest evidence.",
        "sha256": {},
    }
    for path in output.rglob("*"):
        if path.is_file():
            manifest["sha256"][path.relative_to(output).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
    (output / "MANIFEST.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print(output)
    print(f"Real telemetry files: {len(real_json)}; source ZIP includes .git")


if __name__ == "__main__":
    main()
