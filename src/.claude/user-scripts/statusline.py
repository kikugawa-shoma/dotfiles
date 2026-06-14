#!/usr/bin/env python3
"""Pattern 1: Minimal dots - colored circles with numbers only"""
import json, sys
from datetime import datetime, timezone, timedelta

data = json.load(sys.stdin)

R = '\033[0m'
DIM = '\033[2m'
BOLD = '\033[1m'

def fmt_remaining(value):
    if value is None:
        return None
    try:
        if isinstance(value, (int, float)):
            dt = datetime.fromtimestamp(value, tz=timezone.utc)
        else:
            dt = datetime.fromisoformat(str(value).replace('Z', '+00:00'))
            if dt.tzinfo is None:
                dt = dt.replace(tzinfo=timezone.utc)
    except (ValueError, OSError, OverflowError):
        return None
    secs = int((dt - datetime.now(timezone.utc)).total_seconds())
    if secs < 0:
        secs = 0
    h, rem = divmod(secs, 3600)
    m, s = divmod(rem, 60)
    return f'{h:02d}:{m:02d}:{s:02d}'

def gradient(pct):
    if pct < 50:
        r = int(pct * 5.1)
        return f'\033[38;2;{r};200;80m'
    else:
        g = int(200 - (pct - 50) * 4)
        return f'\033[38;2;255;{max(g, 0)};60m'

def dot(pct):
    p = round(pct)
    return f'{gradient(pct)}●{R} {BOLD}{p}%{R}'

model = data.get('model', {}).get('display_name', 'Claude')
parts = [f'{BOLD}{model}{R}']

ctx = data.get('context_window', {}).get('used_percentage')
if ctx is not None:
    parts.append(f'ctx:{dot(ctx)}')
else:
    parts.append(f'ctx:{dot(0)}')

five = data.get('rate_limits', {}).get('five_hour', {}).get('used_percentage')
five_resets = fmt_remaining(data.get('rate_limits', {}).get('five_hour', {}).get('resets_at'))
five_pct = five if five is not None else 0
five_part = f'5h:{dot(five_pct)}'
if five_resets is not None:
    five_part += f' {DIM}⏳{five_resets}{R}'
parts.append(five_part)

week = data.get('rate_limits', {}).get('seven_day', {}).get('used_percentage')
if week is not None:
    parts.append(f'7d:{dot(week)}')
else:
    parts.append(f'7d:{dot(0)}')

print(f' {DIM}|{R} '.join(parts))


