# Actual playtest exports

Place real tester JSON downloads here. None have been collected yet. Never add fabricated participants or automated smoke-test events to this folder.

Browser: T or the panel's Export JSON button downloads the current session. Desktop: JSON is archived in Godot `user://lab_b_telemetry`, and export opens that directory. Copy actual files here and record the filename/session in PROTOTYPE.md. New tester exports/archives the previous session before starting another; archives are never cleared. Browser download requests cannot prove the user saved the file, so check the downloaded file before handing over.

Schema 2 records contain version, variant (A/B), restart_mode, parameter_mode (原版/慢速/快速换弹/自定义), full parameters, checkpoint, run IDs and UTC timestamps. Raw retry events distinguish the first keypress time from the time gameplay resumes. Administrative endings are excluded from outcome statistics; a real death followed by returning to the start screen remains an unretried failure. Starting or returning to the menu retains the tester session. Automated tests use `--lab-test`, disable persistent tester logs and put validation artifacts under ignored `tmp/`.
