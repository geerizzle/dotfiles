#!/usr/bin/env python3
# Waybar weather from wttr.in (no API key). `weather.py pick` opens wofi to choose a location.
import json, os, subprocess, sys, urllib.parse, urllib.request

STATE = os.path.expanduser("~/.local/state/waybar-weather")
LOC_FILE, RECENT_FILE = f"{STATE}/location", f"{STATE}/recent"
SIGNAL = 8  # matches "signal" in the waybar config

# wttr.in (WorldWeatherOnline) condition codes -> Nerd Font icons
ICONS = [
    ({113}, "\U000f0599"),                                   # clear
    ({116}, "\U000f0595"),                                   # partly cloudy
    ({119, 122}, "\U000f0590"),                              # cloudy
    ({143, 248, 260}, "\U000f0591"),                         # fog
    ({200, 386, 389, 392, 395}, "\U000f0593"),               # thunder
    ({302, 305, 308, 314, 356, 359}, "\U000f0596"),          # heavy rain
    ({176, 263, 266, 281, 284, 293, 296, 299, 311, 353}, "\U000f0597"),  # rain
    ({179, 182, 185, 227, 230, 317, 320, 323, 326, 329, 332, 335, 338,
      350, 362, 365, 368, 371, 374, 377}, "\U000f0598"),     # snow/sleet
]
MOON, UNKNOWN = "\U000f0594", "\U000f059e"


def read(path, default=""):
    try:
        return open(path).read().strip()
    except OSError:
        return default


def icon(code, desc):
    if code == 113 and desc.strip().lower() == "clear":  # wttr says "Sunny" by day, "Clear" at night
        return MOON
    return next((ic for codes, ic in ICONS if code in codes), UNKNOWN)


def show():
    loc = read(LOC_FILE)
    url = f"https://wttr.in/{urllib.parse.quote(loc)}?format=j1&m"
    try:
        with urllib.request.urlopen(url, timeout=10) as r:
            d = json.load(r)
        c, area = d["current_condition"][0], d["nearest_area"][0]
        place = f'{area["areaName"][0]["value"]}, {area["country"][0]["value"]}'
        ic = icon(int(c["weatherCode"]), c["weatherDesc"][0]["value"])
        # Symbols font for the icon: the text Nerd Font draws icons off-center (see style.css)
        out = {"text": f'<span font_family="Symbols Nerd Font">{ic}</span> {c["temp_C"]}°C',
               "tooltip": (f'{place}{"" if loc else " (auto)"}\n'
                           f'{c["weatherDesc"][0]["value"]}, feels like {c["FeelsLikeC"]}°C\n'
                           f'Humidity {c["humidity"]}%  Wind {c["windspeedKmph"]} km/h {c["winddir16Point"]}\n'
                           "Click to change location")}
    except Exception as e:  # offline or bad location: keep the module, explain in the tooltip
        out = {"text": f"{UNKNOWN} --", "class": "error", "tooltip": f"Weather unavailable for '{loc or 'auto'}': {e}\nClick to change location"}
    print(json.dumps(out), flush=True)


def pick():
    recent = [l for l in read(RECENT_FILE).splitlines() if l]
    menu = "\n".join(["auto"] + recent)
    choice = subprocess.run(["wofi", "--dmenu", "--prompt", "city (type a new one, or auto)",
                             "--width", "350", "--height", "250", "--cache-file", "/dev/null"],
                            input=menu, capture_output=True, text=True).stdout.strip()
    if not choice:
        return
    os.makedirs(STATE, exist_ok=True)
    loc = "" if choice == "auto" else choice
    open(LOC_FILE, "w").write(loc)
    if loc:
        open(RECENT_FILE, "w").write("\n".join([loc] + [r for r in recent if r != loc][:9]) + "\n")
    subprocess.run(["pkill", f"-RTMIN+{SIGNAL}", "-x", "waybar"])


if __name__ == "__main__":
    pick() if sys.argv[1:] == ["pick"] else show()
