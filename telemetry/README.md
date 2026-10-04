# Actual playtest exports

Place real tester JSON downloads here. None have been collected yet. Never add fabricated participants or automated smoke-test events to this folder.

Browser: T or the panel's Export JSON button downloads the current session. Desktop: JSON is archived in Godot `user://lab_b_telemetry`, and export opens that directory. Copy actual files here and record the filename/session in PROTOTYPE.md. New tester exports/archives the previous session before starting another; archives are never cleared. Browser download requests cannot prove the user saved the file, so check the downloaded file before handing over.

Records contain version, variant, parameters, run IDs, UTC timestamp and events. Files may include administrative endings; filter them according to PROTOTYPE.md. Automated tests use `--lab-test`, disable persistent tester logs and put validation artifacts under ignored `tmp/`.
