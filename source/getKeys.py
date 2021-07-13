#!/usr/bin/env python3

import applescript
import time
# test
cmd = """tell application "System Events"
	keystroke "c" using command down
	delay 0.25
end tell"""

t1 = time.perf_counter()
applescript.run(cmd)
applescript.run(cmd)
t2 = time.perf_counter()
print(f"Python ran code in {t2 - t1:0.4f} seconds")

t1 = time.perf_counter()
cmd = """tell application "System Events"
	keystroke "v" using command down
end tell"""

t1 = time.perf_counter()
r = applescript.run(cmd)
t2 = time.perf_counter()
print(f"Python ran code in {t2 - t1:0.4f} seconds")
