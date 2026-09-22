#!/usr/bin/env python3
# RunCat for waybar: a cat that runs faster with CPU load and sleeps when the CPU is nearly idle.
# Speed curve from RunCat/gnome-runcat; frames in runcat/ are GPL-3 (see runcat/NOTICE.md).
import json, math, os, subprocess, time

HERE = os.path.dirname(os.path.realpath(__file__))
CACHE = os.path.expanduser("~/.cache/runcat")
FRAMES = {f"f{i}": f"active/{i}.svg" for i in range(5)} | {"idle": "idle/0.svg"}
SAMPLE_S = 2.0      # seconds between CPU samples
SMOOTH_MS = 500     # speed eases toward the new cycle length with this time constant
IDLE_BELOW = 10     # CPU % under which the cat sleeps


def cycle_ms(util):
    # ms for one full run cycle: 250 at 100% CPU, 1100 at 0%
    return 250 + 850 * (1 - util / 100) ** 2


def render_frames():
    # Tint the white SVGs with the wal foreground and render them to PNG, because GTK here has no SVG loader.
    try:
        color = json.load(open(os.path.expanduser("~/.cache/wal/colors.json")))["special"]["foreground"]
    except (OSError, KeyError, ValueError):
        color = "#ffffff"
    # One runcat runs per monitor: render in a private dir, then swap files in atomically.
    tmp = os.path.join(CACHE, f".tmp-{os.getpid()}")
    os.makedirs(tmp, exist_ok=True)
    pngs = {}
    for name, src in FRAMES.items():
        svg = open(os.path.join(HERE, "runcat", src)).read().replace("#ffffff", color)
        pngs[name] = os.path.join(tmp, name + ".png")
        subprocess.run(["magick", "-background", "none", "-density", "48", "svg:-", pngs[name]],
                       input=svg.encode(), check=True)
    # Crop every frame to the union of their bounding boxes so the cat doesn't jump between frames.
    boxes = []
    for p in pngs.values():
        w, rest = subprocess.check_output(["magick", p, "-format", "%@", "info:"]).decode().split("x")
        h, x, y = map(int, rest.split("+"))
        boxes.append((int(x), int(y), int(x) + int(w), int(y) + h))
    x0, y0 = min(b[0] for b in boxes), min(b[1] for b in boxes)
    x1, y1 = max(b[2] for b in boxes), max(b[3] for b in boxes)
    for p in pngs.values():
        subprocess.run(["magick", p, "-crop", f"{x1 - x0}x{y1 - y0}+{x0}+{y0}", "+repage", p], check=True)
    for name, p in pngs.items():
        os.replace(p, os.path.join(CACHE, name + ".png"))
    os.rmdir(tmp)


def cpu_times():
    v = list(map(int, open("/proc/stat").readline().split()[1:]))
    return v[3] + v[4], sum(v)  # idle + iowait, total


def main():
    render_frames()
    prev = cpu_times()
    time.sleep(0.3)
    util, last_sample, cycle, frame = None, 0.0, cycle_ms(0), 0
    while True:
        now = time.monotonic()
        if util is None or now - last_sample >= SAMPLE_S:
            cur = cpu_times()
            d_idle, d_total = cur[0] - prev[0], cur[1] - prev[1]
            util = 100 * (1 - d_idle / d_total) if d_total else 0.0
            prev, last_sample = cur, now
        asleep = util < IDLE_BELOW
        delay = 1.0 if asleep else cycle / 5 / 1000
        cycle += (cycle_ms(util) - cycle) * (1 - math.exp(-delay * 1000 / SMOOTH_MS))
        print(json.dumps({"text": f"{util:.0f}%", "class": "idle" if asleep else f"f{frame}",
                          "tooltip": f"CPU {util:.1f}%"}), flush=True)
        frame = (frame + 1) % 5
        time.sleep(delay)


if __name__ == "__main__":
    assert cycle_ms(100) == 250 and cycle_ms(0) == 1100 and cycle_ms(50) == 462.5
    main()
